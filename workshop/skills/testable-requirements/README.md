# Skill: making requirements testable

Turning "should feel fast", "results should be relevant", "the radius adapts to speed" into
criteria you can pass or fail. Distilled from geo-knowledge-guide phase 01, where three
requirements blocked the gate on the "testable" criterion until they were reworked.

**Use when:** a requirement's acceptance criterion contains *appropriate, sufficient, good,
relevant, fast, measurably, as needed* - or names no number at all.

---

## 1. The three-part rule

> A target is only useful if it names **what is measured**, **under which conditions**, and
> **where the pass/fail line sits.**

Miss any of the three and the requirement is prose. "Query responds quickly" fails all three.
"Query → first result list, on a mid-range mobile device over 4G with a warm cache, p95 ≤ 2.5 s
over 100 runs" passes all three and can be argued about honestly.

## 2. Prefer a formula with test vectors over a lookup table

A table of values invites bikeshedding over each row and hides the intent. A formula with
**one tunable coefficient** makes the intent explicit and gives you a single knob:

```
r = clamp(v_smoothed × T_lookahead, r_min, r_max)
T_lookahead = 5 min      # how far ahead the user should be informed
r_min = 250 m            # floor
r_max = 10 km            # cap
```

Then publish the **expected values as test vectors** with a tolerance: at 5 km/h → 420 m, at
50 km/h → 4.2 km, ±10 %. The formula is the requirement; the table is the test.

Say out loud what the coefficient does to the edges. Changing the lookahead from 3 to 5 minutes
moved the cap from binding at 200 km/h to binding at 120 km/h - worth knowing *before* the
decision, and a one-line note in the record afterwards.

## 3. Add stability rules wherever the input is noisy

Anything driven by a sensor, a counter or a live feed needs a second requirement about
*changing*, not just about *value*:

- smooth the input (rolling median over a window),
- change only past a threshold (> 20 % deviation),
- change at most once per interval.

Then make the stability itself testable: "in a 10-minute run with the input fluctuating ±15 %,
the output changes no more than 20 times and never more than once per 30 s."

## 4. Separate "what is found" from "what is shown"

A retrieval criterion and a presentation criterion are different requirements. A wide search
radius is correct and a flood of results is still wrong. Cap the *delivery* rate separately -
"at most one announced item per 200 m walking" - and let the relevance ordering pick which ones
survive the cap.

## 5. Gold sets for anything relevance- or quality-shaped

For "results are relevant", "the summary is accurate", "search understands meaning", the only
honest criterion is an evaluation asset. Build it once and let several requirements point at it.

- **N queries, graded 0-3**, one line of reasoning per judgement, versioned in the repo.
- Include a **hard subset** that isolates the claim: for semantic search, paraphrase pairs with
  **no shared content word**. If the claim is cross-language, include cross-language pairs.
- **Thresholds** per metric (nDCG@10 ≥ 0.70, Recall@20 ≥ 0.80, ...).
- **A baseline uplift**, and this is the one people skip: *"≥ +20 percentage points Recall@10
  over a keyword baseline on the paraphrase subset."* It forces the expensive approach to prove
  it earns its cost, and it is the metric that would actually catch a broken embedding pipeline.
- **A regression gate**: no metric drops more than N points versus the previous release.
- Record who judged it. A single-judge set is fine early - write down that it measures
  "relevant *to that judge*" so nobody mistakes it for ground truth later.

The gold set usually ends up doing double duty: ours became both the release gate and the
calibration instrument for the relevance factors. Expect that and design it to be re-run
cheaply.

## 6. Latency

- Define a **reference scenario** once: device class, network, cache state, number of runs.
  Every number afterwards refers to it.
- Report **p50 and p95**, never a single figure.
- Report **warm and cold separately**, and allow the cold case to be worse early.
- Give a **hard limit** with the behaviour past it - "5 s, then an explicit error state". A
  target without a failure behaviour is not a criterion.
- Derive the consequences and write them down: a 2.0 s audio start means streaming or
  pre-generated audio, not "synthesize then play". That is where a latency target actually
  constrains the architecture.

## 7. Volume and cache criteria: define what counts

"Repeat queries are served from the store" is untestable until *repeat* is defined. Ours became:
"a query whose location, time window and categories are **fully contained** in an already
ingested area", with the threshold "≥ 80 % of them served without an external fetch, at warm
p95 ≤ 2.5 s". The definition is the hard part; the percentage is easy afterwards.

## 8. Be honest when a criterion is directional

Not everything can carry a number at the time you write it. A post-MVP requirement may
legitimately say "ranks measurably higher with the preference set than without, same query and
data" - that is a *comparison*, which is testable, rather than a threshold.

What is not acceptable is dressing a directional criterion as a measurement. If you write
"measurably faster", say against what and by how much - or say plainly that the threshold is
set when the feature is built, and note which phase sets it.

## 9. Checklist

- [ ] What is measured, under which conditions, where is the line?
- [ ] Formula plus test vectors rather than a bare table?
- [ ] Stability rule for noisy inputs?
- [ ] Retrieval and presentation limits separated?
- [ ] For quality claims: an evaluation asset with thresholds **and a baseline uplift**?
- [ ] p50/p95, warm/cold, N runs, hard limit with failure behaviour?
- [ ] Terms in the definition ("repeat", "relevant", "current") defined somewhere?
- [ ] Consequences of the target written down where they constrain the design?
- [ ] Anything still directional marked as directional?
