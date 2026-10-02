# Skill: module specification - SUB-### specs and behavioral test cases

How to turn a gated architecture into per-submodule specifications and test cases
that phase 06 can implement and verify from without a single clarification round.
Distilled at the start of geo-knowledge-guide phase 05 (2026-08), after phase 04
closed with a clean PASS and the owner decided that test cases (TC-###) are designed
fully in phase 05 - on the behavioral level, against the IF-### contracts, with no
test-code or framework decisions.

**Use when:** the SUB-###/IF-### registers and the allocation table exist and each
submodule now needs data models, algorithms and test cases before code; when a
"spec" restates the architecture instead of refining it; when test cases are being
derived from code (or postponed to the implementation phase) instead of from the
contracts.

---

## 1. What a SUB-### spec contains: the layer below architecture.md

One spec per SUB-###. The spec refines the submodule's register entry; it never
changes it. Three kinds of content belong here - exactly the design detail phase 04
deliberately handed down:

- **Data models with concrete field schemas.** Every structure the submodule stores
  or transforms: fields, types, units, nullability, constraints. Phase 04 defined
  the shapes that cross seams (IF-###); phase 05 defines the shapes that live
  inside the submodule. If a field schema here contradicts a contract shape, the
  spec is wrong, not the contract.
- **Algorithms and processing steps.** The ordered steps that turn the submodule's
  inputs into its outputs, at the precision a second agent could implement them
  from without guessing: which step runs when, what it consumes, what it produces,
  what it defers to another submodule.
- **Error handling in detail, mapped onto the IF-### contracts.** For every error
  and empty case the contract names (the status vocabulary, the `missing_sources`
  list, the failure modes), the spec says how this submodule produces it: which
  internal condition maps to which contract value. This mapping is the part a
  vague spec skips and an implementation then improvises.

## 2. What does NOT belong in a spec

- **No programming-language, framework or library decisions.** "Sort descending by
  score" is a spec; "use `sorted()` with a key" is phase 06. If a spec names a
  technology, it has overstepped - and it has made a hidden decision nobody gated.
- **No code.** Pseudocode for a non-obvious algorithm is fine; a code listing is a
  phase-06 artifact with the phase-05 label peeled off.
- **No repetition of IF-### contract content.** The contract is defined once, in
  the IF register. The spec references it ("produces `ambiguous_location` per
  IF-005") instead of restating the shape. One source per truth - a duplicated
  contract drifts apart from the register by the first review cycle.

## 3. TC-###: behavioral test cases, designed before code

Test cases are a phase-05 output, not a phase-06 afterthought. The core rule:

> **Every sub-requirement has at least one TC, and every TC describes observable
> behavior through an IF-### contract - concrete inputs, expected outputs and
> status - never internals.**

A TC names what goes in (a query with these constraints, a write with this item
shape), what the contract returns (these fields, this status value), and nothing
about how the submodule achieves it. A TC that asserts on an internal data
structure, a call sequence or a private function is testing the implementation,
not the spec - it breaks the moment the implementation improves, and it passes
while the contract behavior is wrong.

**Negative paths are mandatory, not a bonus.** Every error and empty case the
IF-### contracts name must surface as at least one TC, and every case of the
project's negative-path catalogue (the six `neg-01..06` cases from phase 03: no
results, geolocation refused, source unavailable, query timeout, ambiguous
location, partial outage) must be found again in the TC register, bound to the
submodule and contract that produce the behavior. The happy path is the part
everyone writes; the negative paths are where the spec's quality shows.

**Compact register format:** one line per TC - ID, the sub-requirement(s) it
covers, and a one-sentence scenario naming inputs and expected observable result.
Longer setup detail only where the scenario cannot be understood from one
sentence. A TC register written as prose paragraphs cannot be counted, cannot be
checked for coverage, and will not be checked.

**No test-code or tooling decisions.** Framework, runner, fixture machinery: all
phase 06. The TC says what is asserted, never in what language it will run.

**Why here and not in phase 06:** testability is a spec-quality criterion. At the
Spec Review, "every sub-requirement has a TC against a contract" is the check that
the spec is decidable - a sub-requirement nobody can write a TC for is a spec gap
found while fixing it is cheap. And tests written from the spec catch the
implementation; tests written from the code only confirm it.

## 4. The TC allocation table: the binding, machine-readable artifact

Traceability is one Markdown table, the phase-05 counterpart of the phase-04
allocation table, and the artifact the traceability generator
(`tools/build_index.py`) parses to project a TC column into TRACEABILITY - the
same way the phase-04 table was projected into the ARC/IF and SUB columns
(CHG-072). Keep the format exactly, so that later tooling unit can extend the
generator without a format negotiation:

```
| TC-### | REQ-### | SUB-### | IF-### |
|--------|---------|---------|--------|
| TC-001 | REQ-004 | SUB-002 | IF-005 |
| TC-002 | REQ-071 | SUB-006 | IF-007 |
| TC-002 | REQ-071 | SUB-007 | IF-007 |
```

Format rules (a generator depends on all of them):

- Header exactly `| TC-### | REQ-### | SUB-### | IF-### |`, one data row per
  binding. IDs only - no prose in the cells; scenarios live in the TC register.
- A sub-requirement is the `(REQ-###, SUB-###)` pair from the phase-04 allocation
  table. Column 2 and 3 together name the sub-requirement the TC covers; column 4
  names the contract the TC observes through. `IF-###` is `-` only when the
  behavior genuinely crosses no contract - exceptional, and the TC register must
  say why.
- **Multiple rows per TC are allowed and normal** - a case that exercises the same
  behavior across a provider/consumer pair (e.g. a `no_results` status through
  IF-007) gets one row per sub-requirement.
- **Multiple TCs per sub-requirement are expected** - happy path plus the negative
  paths from section 3.

Both coverage directions then reduce to mechanical checks - run them, never eyeball
them (see the `consistency-sweep` skill):

- **No sub-requirement without a TC:** every `(REQ-###, SUB-###)` pair in the
  phase-04 allocation table appears in columns 2+3 of at least one TC row.
- **No TC without a sub-requirement:** every TC row's `(REQ-###, SUB-###)` pair
  exists in the phase-04 allocation table, and every TC-### in the register appears
  in the table.

## 5. Failure modes seen and expected

- **TC against internals instead of behavior.** "TC-017 asserts the store's merge
  runs before ranking." That is the implementation describing itself. Rewrite
  against the contract: inputs, outputs, status. If no contract surface can express
  the assertion, either the assertion is not spec-level or an IF-### is missing -
  both are phase-05 findings, not test text.
- **Spec repeats the IF-### contract instead of refining it.** A spec section that
  re-states the contract's field shapes adds a second source of truth that drifts
  on first contact with a fix. Reference the contract; specify what the submodule
  does with it.
- **Negative paths forgotten.** A TC register of only happy paths looks complete
  and covers the easiest third of the behavior. The mechanical check against the
  contract error cases and the negative-path catalogue is what makes "covered"
  mean something.
- **TC register as prose instead of a table.** Narrative test plans cannot be
  counted or machine-checked, so the two coverage directions silently stop being
  verified. Table first, prose only where a scenario needs it.
- **Framework or language decisions smuggled into the spec.** "We test this with
  <tool>" is a phase-06 decision taken un-gated. Strike it; the TC's inputs,
  outputs and status are what phase 06 implements against.

## 6. The gate: Spec Review before any implementation

- The gate is a **Spec Review with an independent reviewer** (reviewer != author),
  held **before implementation begins**. Record it in `reviews/` like every other
  gate - see the `review-gates` skill for verdicts and findings discipline.
- Exit criteria: every SUB-### has a spec with data models, algorithms and
  error-case mappings onto its contracts; no language/framework/library decisions
  in any spec; the TC register is compact format (one line per TC plus scenario);
  the TC allocation table is in the exact format above; both coverage directions
  checked mechanically; every contract error/empty case and every negative-path
  catalogue case bound to at least one TC.
- **Testability is a review criterion, not a hope.** The reviewer samples
  sub-requirements and asks: can I tell, from this spec, whether the TC passes?
  If not, the spec is not done - no matter how finished it reads.

## Checklist

- [ ] Every SUB-### spec contains field schemas, processing steps and an
      error-case mapping onto its IF-### contracts - and nothing else?
- [ ] No programming-language, framework or library decision anywhere in a spec
      or TC?
- [ ] Contracts referenced, never restated?
- [ ] Every TC behavioral: concrete inputs, expected outputs/status via an
      IF-###, no internals?
- [ ] Every contract error/empty case and every negative-path catalogue case
      covered by at least one TC?
- [ ] TC register compact (one line per TC + scenario), not prose?
- [ ] TC allocation table in the exact `| TC-### | REQ-### | SUB-### | IF-### |`
      format, IDs only?
- [ ] Both coverage directions checked mechanically: no sub-requirement without a
      TC, no TC without a sub-requirement?
- [ ] Spec Review held with an independent reviewer, before implementation, with
      testability sampled as a criterion?
