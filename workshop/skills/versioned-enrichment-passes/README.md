# Skill: versioned enrichment passes over the versioned store

How to run a bulk re-derivation pass (categorization, geo/entity enrichment,
taxonomy growth) over a versioned item store (SUB-003 write path) - safely,
idempotently, and correctable without rewriting 18k untouched rows.
Distilled from three passes in geo-knowledge-guide (2026-09-10/11):
categorization v1 -> v1.5 (18,265 items, 4 correction bumps), taxonomy
growth v1.1 (P1082 fetch, 12,893 new versions), tier-2 geo completion
(15,636 new versions, 4.6 h detached).

**Use when:** a derived field on every (or a large subset of) current
store items must be re-computed from external evidence (caches, Wikidata,
a mapping table) and written back as new versions; a mapping/config fix
must propagate to items an earlier pass already wrote; you need an audit
trail of exactly which rows changed and why.

---

## 1. When this pattern applies

- The store is versioned: writes go through the real store write path
  (`KnowledgeStore.write`), material field changes produce NEW_VERSION
  with `change_reason=material_change`, and the store classifies
  identical revision signals as NO_OP.
- The pass is a *re-derivation*, not an ingest: the facts are computed
  from caches/config, not authored. Deterministic scripts only - no LLM
  in the write path (all three passes: 0 tokens).
- The change is bulk (thousands of rows), so a sloppy pass produces
  either silent non-propagation or 18k rows of version noise.

## 2. Required mechanics (all six, every time)

### 2.1 Versioned guid suffix + old-suffix stripping

Every pass stamps the revision guid with a **versioned** suffix
(`#categorization-v1`, `-v1.1` ... `-v1.5`, `#tier2-geo`) and strips any
previous suffix of the same family before appending the current one
(`_GUID_SUFFIX_RE = re.compile(r"#categorization-v1(\.\d+)?$")`).

Why versioned: the store's revision-signal match (guid + fact_hash) is
the idempotency mechanism - and also the trap. A re-run whose only
change is the mapping produces the *same* guid + *same* fact_hash ->
NO_OP -> the fix silently never lands (the F1 NO_OP-swallow, below).
Bumping the suffix makes the correction run's signal differ for exactly
the affected items; an immediate re-run matches again. Suffix history of
one script: v1 -> v1.1 (F1 fix) -> v1.2 (taxonomy growth) -> v1.3 (audit
fix) -> v1.4 (review F-1 fix) -> v1.5 (A-4 category). Bump discipline:
**any correction that must propagate to already-written items bumps the
suffix; the bump history lives in the script header comment.**

### 2.2 Material-change skip BEFORE the store write

Compare the computed categories/content against the current row and
`continue` without calling `store.write` when nothing material changed.
Without this, a bumped suffix makes the store classify every untouched
row UPDATED_IN_PLACE - a guid-refresh rewrite of 18,253 rows to fix 12
(the F1 second half). With it, correction passes are surgical:
`written=12 unchanged=18253`, `written=147 unchanged=18118`,
`written=39 unchanged=18226`, `written=13 unchanged=18252`.

### 2.3 Honest fallback - never fabricate, and know whose value you keep

Unmapped / no-QID / no-P31 / unknown-population items get the honest
fallback (`["history"]`, `gemeinde`, kept marker) - never a guessed
value, never a None smuggled in from a failed fetch (a failed Wikidata
chunk is NOT cached as "unknown"; only a real fetch returning no claim
is unknown).

Root-cause lesson (F1, the deeper half): on fallback, an item must keep
its current categories ONLY if this pass never touched it. Check the guid
suffix: if the item was categorized by this pass and its mapping was
later removed, it must fall back to the honest value - otherwise the old
assigned category sticks forever and a removed mapping can never
propagate. First-time foreign items keep what they have; own-output
items re-derive honestly.

### 2.4 Dry-run -> apply -> idempotency re-run as the gate

Three runs, numbers recorded each time:

1. **Dry-run**: classify + plan counters, no writes. Compare plan vs
   intent BEFORE applying (tier-2 geo: plan said geo 15,398 / geoless
   1,332 / no_qid 0; apply matched exactly).
2. **Apply**: `DONE: written=N no_op=M unchanged=K skipped=S reasons={...}`.
   N must match the dry-run expectation; investigate any surprise.
3. **Idempotency re-run** (same suffix, immediately after):
   `written=0` is the acceptance criterion. Nonzero writes on the re-run
   = the pass re-reads its own output as a change = a bug (see 4.1).

Long fetches: batch + persist a cache across runs (population cache,
enrichment cache); a rate-limited fetch (429 ~1 chunk/30 s) runs
detached and re-runs converge as the cache fills. Two-phase
fetch-then-write keeps the write leg off the network.

### 2.5 Stratified audit sampling

After apply, audit n=30..50 stratified across the *new/changed*
categories, seed 42 (reproducible sample), agent-judged, per-category
error rates in the run record. Both audits that ran found real mapping
bugs the green tests had not: v1 n=50 found awards->grundwissen and
orchestra->ereignisse (12 % pre-fix, 0 % post-fix); v1.1 n=30 found the
Grosse-Kreisstadt mis-banding (17 % pre-fix, 0 % post-fix). An audit is
not decoration - it is the step that catches mapping-table bugs (vs
implementation bugs; the classification logic was correct in both cases).

### 2.6 Regression pins in tests

Every audit/review fix lands as an executable pin, not prose:
`test_review_removed_classes_stay_unmapped` (Q618779/Q1711403/Q1447072),
`test_grosse_kreisstadt_is_population_banded_not_pinned`,
`test_regional_kreisfreie_stadt_subclasses_population_banded`. Pin the
FIX's expectation. When a later deliberate decision reverses a pin (A-4
moved Q618779 TO auszeichnungen), flag the stale pin report-first -
do not silently edit either side.

## 3. Pre-flight checks

- **One writer at a time.** Check the store/pipeline state before
  applying: the v1 pass waited 2.5 h for the tier-2 pipeline to reach
  43/43; the v1.1 pass verified "no writer process on the box" first.
  Never interleave two writers.
- **Cache shape vs reader expectation.** Verify the cache line shape the
  pass *writes* against the shape the *reader* reads - with one real
  round-trip, not by reading one side. This mismatch was a root cause
  (see 4.3).
- **Baseline measurement.** Read-only SQL counts BEFORE the write
  (entity_refs empty: 18,040; category distribution) so the after-state
  is a delta, not a claim.
- **Backup before apply** (pg_dump; tier-2 completion: 438 MB pre-pass
  dump).
- **Register new taxonomy values** via the store's own registration
  (`add_category`) before the first write - the store rejects unknown
  categories.
- **Reuse the previous pass's machinery** where it exists (tier-2 geo
  imported the unit-1 enrichment module: fetch/cache/parse + the A-1
  rule). Additive reuse, no src changes.

## 4. Failure modes observed (the reasons this skill exists)

### 4.1 The NO_OP swallow (re-reading your own output)

A suffixed guid + unchanged fact_hash makes the store's
`_signal_matches` classify the item NO_OP - so a correction pass with an
unbumped suffix silently skips exactly the items it exists to fix. The
mapping is corrected, the tests are green, and *nothing on the box
changes*. Counter: versioned suffix + strip (2.1). Detect: apply-run
counters show written=0 when the fix should have touched rows; the
idempotency re-run of the *original* pass looked clean, which is exactly
why this is treacherous - both runs "succeed".

### 4.2 The half-fix across two control surfaces

The v1.1 audit fix removed Grosse-Kreisstadt classes from the grossstadt
*class list* but left 15 regional subclasses in `class_band_overrides` -
and the override wins over the population band, so the bug survived.
The review (F-1) caught it; the fix needed a second correction pass
(written=39). Lesson: when one behavior is steered by two config
surfaces (class list + override map), a fix must touch BOTH - name the
surfaces in the fix and grep each. Same shape as 2.3 (fallback keeping
the old category): the bug one level up reappears one level down.

### 4.3 Cache-shape mismatch (silent zero)

The tier-2 pipeline's enrich cache wrote `{pageid, qid, wd:{p625,p31}}`;
the ingest carryover read `record["wp"]["qid"]`. `wp` absent -> qid None
-> geo=False for every one of 17,089 items - and every stage reported
success (`refs_carried: 0` in 43/43 etappe stats, unread). The
event-time leg worked because it read `record["wd"]`, which *was*
written - a half-working integration is harder to see than a dead one.
Counter: assert a nonzero carryover counter per stage; spot-read one
cache line through the actual reader before the bulk run.

### 4.4 Version-noise writes

Without the material-change skip (2.2), a correction pass rewrites every
row's guid - burying the 12 real changes under 18,253 fake ones and
destroying the audit trail the versioned store exists to provide.

### 4.5 Fabricated fallbacks

Caching a failed fetch as "unknown", guessing a category for an unmapped
class, or storing a null where the schema forbids it. Every observed
fallback stayed honest and *counted* (3,892 no-P31, 132 unmapped, 1,731
unknown-population -> gemeinde, 401 kept markers) - the remainder
breakdown in the run record is what makes honesty auditable.

## 5. Quick checklist for the next pass

- [ ] Scope + baseline measured (read-only SQL), plan numbers expected
- [ ] One-writer gate checked (pipeline idle / no writer process)
- [ ] Cache shape verified through the real reader on one item
- [ ] Backup taken; taxonomy values registered via the store
- [ ] Suffix versioned + old-suffix strip; fallback checks own-suffix
- [ ] Material-change skip before the store write
- [ ] Dry-run plan == apply actual; idempotency re-run writes 0
- [ ] Stratified audit (seed 42) with per-category error rates
- [ ] Each fix: both config surfaces + a regression pin; suffix bumped
- [ ] Run record: counters, distribution, remainder breakdown, deviations

Evidence: `apps/geo-knowledge-guide/ops/categorization-v1-2026-09-10.md`,
`ops/taxonomy-growth-v1-1-2026-09-11.md`,
`ops/tier2-completion-pass-2026-09-11.md`,
`scripts/categorization_v1.py`, `scripts/tier2_geo_enrichment.py`,
WORKLOG 2026-09-11 (F1/F-1 review corrections).
