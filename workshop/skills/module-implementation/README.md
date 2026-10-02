# Skill: module implementation - from SUB-### specs and TC-### to verified code

How to turn gated module specifications and behavioral test cases into working,
reviewed and verified code - the first code phase of a project. Distilled at the
start of geo-knowledge-guide phase 06 (2026-08), after phases 01-05 closed
(requirements, concept, validation, architecture, module specification) with the
spec gate PASS on 2026-08-18: 85 behavioral TCs against the IF-### contracts,
SUB-001..010 specced, SUB-011/012 recorded as post-R1/post-MVP boundaries, and
DEC-019 fixing the licences (code AGPL-3.0, documentation CC BY-SA 4.0).

**Use when:** the specs and the TC register exist and the submodules now need
code plus executable tests; when an "implementation" of a submodule imports a
sibling's internals instead of the IF-### contract; when tests are being
written from the code instead of from the TC register; when the traceability
chain TC-### -> code -> test is breaking because test names lost their TC IDs.

---

## 1. Kickoff artifacts: before the first line of module code

Phase 06 is the first code phase, so its kickoff produces the artifacts that
must exist before the repository accumulates code (and goes public):

- **`LICENSE` (AGPL-3.0) at the repository root** (DEC-019). Relicensing is
  cheap now (single author) and practically impossible once external
  contributors hold copyright - that is exactly why the decision was taken
  before code exists.
- **A short licence header per source file** - one or two comment lines naming
  the licence (SPDX short form is fine, e.g. `SPDX-License-Identifier:
  AGPL-3.0-only`), not the full licence text. Make it part of the template
  every new source file starts from, so no file lands without it.
- **A documentation licence note (CC BY-SA 4.0)** covering the requirements,
  architecture and specification documents - one note, placed where a reader
  of the docs finds it (e.g. the docs register's README). The commons *data*
  licence (ODbL vs. CC BY-SA vs. CC0) is a separate open question and is NOT
  decided here.
- **`src/` scaffold**: one module per SUB-### (see section 2), the contract
  layer first (section 3), and the test layout the chosen framework expects.

These are one-time kickoff units, recorded as CHG entries like every other
artifact. A code phase that starts writing modules before the licence
artifacts exist builds a retrofit.

## 2. `src/` structure discipline: one module per SUB-###

The architecture's decomposition is the code's decomposition - no second,
code-specific decomposition that quietly re-partitions the system:

- **One module (package / directory) per SUB-###**, named so the binding is
  greppable (e.g. `sub-001-ingestion/` or the language-idiomatic equivalent).
  A module implements exactly its register entry's responsibility - nothing a
  different SUB-### owns.
- **Modules communicate only through the IF-### contracts.** If SUB-006 needs
  something from SUB-003, it imports the IF-002 contract types, never
  SUB-003's internal structures. The moment a consumer reaches into a
  provider's internals, the contract stops being the source of truth and the
  next refactor breaks a caller nobody counted.
- **Internals stay private.** A module's public surface is its side of the
  contracts it participates in; everything else (helpers, private models,
  caches) is internal by the language's own visibility mechanism, not by
  convention.
- **Shared code that is not a contract** (pure utilities used by several
  modules) gets an explicit shared location; it is never smuggled into one
  module and imported sideways.

## 3. Contract-first: IF-### before module logic

Implement the contracts before the modules that fulfill them:

- **Every IF-### becomes a typed interface plus data classes/types** in the
  chosen stack - one code artifact per contract, named after it (the IF-###
  ID greppable in file or symbol names). Field names, nullability and the
  status vocabularies come from the contract register verbatim; the typed
  status vocabulary rule from phase 04 means status values are a closed type
  (enum / string-literal union), not free strings.
- **Error mapping is made testable, not implied.** For every error and empty
  case a contract names (e.g. IF-001's unclassed-item rejection, IF-002's
  valid `items: []` vs. store-unavailable, IF-005's
  `resolved|ambiguous|unresolved`), the spec says which internal condition
  maps to which contract value - implement that mapping as explicit, named
  code (a mapper function, an error type per case), so a test can trigger the
  internal condition and assert the contract value. "We handle that somewhere"
  is an unverifiable mapping.
- **Contract and implementation change together or not at all.** A contract
  change follows the register's versioning rule (additive = minor, breaking =
  major plus migration note in CHANGELOG.md); it is never made silently inside
  a module PR.

## 4. TC-### to executable test: the mapping rules

The TC register is the test backlog; the mapping is mechanical enough to check:

- **Every behavioral TC gets at least one executable test.** The TC says what
  goes in and what is observed through a contract; the test constructs exactly
  that input and asserts exactly that observable result. Nothing else earns
  the TC's "done".
- **The TC-### ID stays findable in the test.** Put it in the test name or an
  adjacent comment (e.g. `test_tc_015_neg03_enrichment_unavailable` or a
  `// TC-015` line). This keeps the chain TC -> code -> test greppable -
  traceability does not end at the specification, and a test that lost its ID
  is a test whose coverage claim can no longer be verified.
- **Unit test where the TC's seam is one module; integration test where the
  TC crosses a provider/consumer pair.** Many TCs assert behavior through a
  contract observed from both sides (e.g. a `no_results` status that SUB-001
  produces, SUB-003 stores, SUB-006 maps, SUB-007 renders - TC-015 covers four
  sub-requirements). Those become integration tests: real contract boundary,
  doubles only outside the asserted seam (e.g. an external authority endpoint
  or the model boundary, the "hermetic injection" pattern the TC register
  itself names). A TC is not forced down to unit level to make it cheap -
  it is implemented at the level its scenario asserts.
- **Fixtures and doubles follow the TC, not the convenience.** Where the TC
  prescribes a controlled injection point (a fixture item, a stubbed contract
  response), the test uses that point; where the TC says "through the
  contract", the test goes through the real contract implementation.
- **Framework, runner and assertion library are phase-06 decisions** - take
  them once, per stack, in the kickoff, and apply them uniformly. The TCs are
  stack-neutral by design; the tests are not the place to re-derive the
  scenario.

## 5. Boundary: SUB-011/012 are not implemented

SUB-011 (Commons Contribution Gate, post-R1) and SUB-012 (Audio & Guided Tour
Channel, post-MVP) are explicit boundaries, not work items. Phase 06 does not
implement them. Their contracts (e.g. IF-013) stay pinned at contract level -
the TCs allocated to boundary pairs hold at contract level by design - but no
module code is written for the boundary submodules. If an implementation urge
arises ("just a stub"), the answer is the register's: *vertiefen, wenn SUB-011
spezifiziert wird*.

## 6. Process and roles: draft -> review -> fixes -> verification -> gate

The six-role discipline applies to code exactly as it applied to documents:

- **Draft (implementation agent):** one editor per file at a time - the module
  holder writes its code and tests. Modules are the natural unit of file
  holding; two agents never edit the same module concurrently.
- **Independent review (Reviewer != Author):** findings with location,
  why-it-matters, suggested fix - as for every artifact. The reviewer checks
  against the spec and the TC register, not against taste: does the code
  implement the specced algorithm, does every allocated TC have a test, do
  the tests assert the TC's observable result.
- **Fixes by the file-holder, verified by the reviewer** - status per finding,
  same loop as phases 03-05.
- **Verification:** the full test run passes; the TC coverage check (every
  allocated TC has an executable test, both directions) is run mechanically,
  not eyeballed.
- **Gate (owner verdict):** recorded in `reviews/` like every other gate - see
  the `review-gates` skill. The owner keeps what cannot be delegated: the
  verdict and the decision on findings.
- **Registrar duties** after every significant change: CHANGELOG entry (CHG-###
  per the project's rules), STATE.md updated, INDEX/TRACEABILITY regenerated
  with `python tools/build_index.py` from the project root - never patched by
  hand.

## 7. Failure modes seen and expected

- **Test written from the code instead of the TC.** "The store merges before
  ranking, so assert the merge ran first." That is the implementation
  describing itself - it passes while the contract behavior is wrong. Rewrite
  from the TC: inputs in, observable contract result out.
- **Sideways imports across modules.** SUB-006 importing SUB-003's row type
  "because it is the same fields". The contract is the only legal seam;
  duplicate-free is worth less than decoupled.
- **Error mapping left implicit.** The contract's error cases exist in the
  register and the spec, but the code raises one generic error and the tests
  assert messages. Named error cases, mapped explicitly, or the negative paths
  are not testable.
- **TC IDs lost in test names.** Six months later nobody can say whether
  TC-031 is covered. The ID in name or comment costs nothing and preserves
  the chain.
- **The stack decision deferred into the first module.** Framework and test
  runner chosen ad hoc per module produce three conventions in one codebase.
  Decide once at kickoff (owner decision if it is genuinely open), apply
  uniformly.
- **Boundary modules "just stubbed".** A stub for SUB-011 grows an
  implementation nobody specified or gated. Boundaries are honored by not
  building them.
- **"Locally green" without a config file.** Lint/type tools without a checked-in
  config (e.g. ruff's src-layout detection) classify imports depending on the
  invocation directory - the author sees green, the reviewer (canonical path:
  repo root, like CI) sees red. Countermeasure: check in tool config early
  (`pyproject.toml`) and pin tool versions in CI; the CI invocation path is the
  only truth. (Seen in geo-knowledge-guide unit 1, R-1, 2026-08-20.)
- **Silent spec deviations.** The implementer "decides" a deviation from the
  spec's wording (a scoring rule, a trigger condition, a freshness default)
  because it looks plausible - but every deviation from a gated spec is a
  finding to report, never a design decision the unit may take. Reviewers:
  hunt specifically for unreported deviations from the spec's wording, not
  just for bugs. (Three of four should-fix findings in the unit-2 review were
  exactly this, 2026-08-20.)
- **Owner-approved contract follow-ups as "task 0".** Reviews of earlier units
  surface contract additions the owner approves; apply them as a separate
  first block of the next unit (architecture register + contract code + spec
  clarification, additive only, each with a reference to the owner decision)
  before writing module code on top - otherwise the new code is built against
  contracts that are already known to be stale.

## Checklist

- [ ] Kickoff artifacts exist before module code: `LICENSE` (AGPL-3.0) at repo
      root, licence header in every source file, CC BY-SA 4.0 documentation
      note (DEC-019)?
- [ ] One module per SUB-###, modules communicating only through IF-###
      contracts, internals private?
- [ ] Every IF-### implemented as typed interface + data types, status
      vocabularies as closed types, register-verbatim field names?
- [ ] Every contract error/empty case mapped explicitly and testably?
- [ ] Every behavioral TC has at least one executable test, TC-### findable in
      test name or comment?
- [ ] Integration-level tests where a TC crosses a provider/consumer pair;
      doubles only outside the asserted seam?
- [ ] SUB-011/012 not implemented (post-R1/post-MVP boundaries honored)?
- [ ] Stack/tooling decisions taken once at kickoff and applied uniformly -
      never per module?
- [ ] Independent review done (Reviewer != Author), fixes verified, full test
      run green, TC coverage checked mechanically, gate recorded with owner
      verdict?
- [ ] Registrar duties done: CHANGELOG, STATE.md, INDEX/TRACEABILITY via
      `python tools/build_index.py`?
