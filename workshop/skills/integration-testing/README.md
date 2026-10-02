# Skill: integration & integration test - from tested modules to a proven system

How to take modules that each pass their own contract tests and prove that the
assembled system works: every interface crossed by a real integration test,
end-to-end flows through the real service boundaries, and the deployment shape
exercised in CI. Distilled at the start of geo-knowledge-guide phase 07
(2026-08), after phase 06 closed PASS: ten submodules (SUB-001..010)
implemented against 14 IF contracts, 112 allocation rows = 95 TC legs = 81
TCs with executable tests, 152/152 Python tests against real
Postgres+pgvector, 24/24 frontend tests, CI green on both legs.

**Use when:** phase 06 (or its equivalent) has produced individually tested
modules and the question shifts from "does each module keep its contract" to
"does the system work when they all talk to each other"; when an interface
exists on paper but no test has ever crossed it; when the first real
deployment shape (compose stack, service wiring) is being assembled.

---

## 1. Know what phase 07 adds - and what is already done

Phase 06 already tests *pairs*: each TC that crosses a provider/consumer seam
became an integration test over the real contract (real Postgres, real HTTP
for the public APIs, hermetic doubles only at external boundaries). Do not
re-run that work. Phase 07 adds exactly four things:

1. **The interface matrix, complete and mechanical.** Every IF-### gets >= 1
   named integration test that crosses the real contract boundary - and the
   coverage line is *computed*, not eyeballed. (geo-knowledge-guide: the
   generator printed "Interfaces (IF-###) with no integration test:" for two
   phases without ever computing it - finding S-5. A coverage claim that is
   not mechanically produced is a claim nobody verified.)
2. **End-to-end flows.** A small set of system-level scenarios that traverse
   the whole architecture (e.g. ingestion -> store -> index -> ranking ->
   HTTP API -> frontend render; report -> queue -> AI re-assessment ->
   write-back -> re-query). Each flow asserts at the outermost observable
   surface (the HTTP envelope, the rendered UI state), not at internals.
3. **The deployment shape, really started.** If the stack decision names a
   compose/deployment form (here: Docker Compose per DEC-021), phase 07
   builds it and smoke-tests it in CI: services boot, health checks pass,
   one end-to-end query succeeds against the composed stack. Actual rollout
   to a rented host is a separate owner go with its own cost estimate -
   never folded silently into the phase.
4. **System-level smoke of the performance budgets.** The latency budgets
   (T1/T3-class) get a smoke check (one reference query within budget on the
   CI runner, clearly marked as smoke) - the real load measurement stays in
   phase 08 with its own harness. Do not build the load harness here.

Explicitly NOT phase 07: new features, new contracts (findings go to the
owner bundle), boundary submodules (SUB-011/012 stay unbuilt - their
contracts are pinned, never "just stubbed"), the load harness, VPS rollout.

## 2. The interface matrix: how to make it mechanical

- The inventory comes from the architecture register (IF-### list), never
  from memory. For each IF: does >= 1 executable test cross the real
  boundary (both sides real, doubles only outside the asserted seam)?
- Boundary contracts (e.g. IF-013 for a post-R1 submodule) are listed as
  *pinned, not tested* - an explicit, documented category, not a silent gap.
- Hermetic boundaries (LLM, geocoder, tile provider, embedding model) count
  as integrated when the consumer side runs against the scripted double
  *through the contract* - the double lives outside the asserted seam by
  design; the contract vocabulary crossing it is what is asserted.
- The generator (or an equivalent script) computes the "no integration test"
  line from greppable markers (test names / a register column). Fix the
  tooling gap first (S-5 pattern): a coverage line that prints but never
  computes is worse than none - it looks checked.

## 3. End-to-end flows: few, outermost, hermetic

- Pick the flows from the architecture's own narrative (the query path, the
  report path), not from the module list. 3-6 flows suffice for R0.
- Each flow runs against the real services (real HTTP, real DB) with all
  external boundaries hermetic (scripted LLM adapter, scripted geocoder,
  deterministic embedder) - no live calls, no keys, no cost, in CI
  reproducible.
- Assert at the outer surface: envelope status/reason/items, the rendered
  UI state for the frontend leg. A flow test that asserts internal call
  order is the implementation describing itself (same failure mode as
  unit-level tests written from code).
- Frontend-in-the-loop: where a flow includes the UI, drive it at the fetch
  seam with the real backend behind it where feasible (dev proxy / composed
  stack); otherwise scripted envelopes that the drift guard keeps honest.

## 4. Deployment-shaped integration

- Compose file as code, pinned images (digests or exact tags), health
  checks per service; migrations run as an explicit step, not as a side
  effect of app boot.
- CI smoke: bring the stack up, wait for healthy, run one end-to-end query,
  tear down. If CI cannot run the full stack (runner limits), record the
  narrowing honestly and run the maximal subset - never claim a green the
  harness did not produce.
- Config, not code: endpoints/keys enter via env/config per the existing
  config modules; no new code paths that only exist in the compose world.

## 5. Process and roles: unchanged

Same loop as phase 06 (skill `module-implementation` section 6): draft ->
independent review (reviewer != author) -> fixes by the file-holder ->
same-reviewer verification -> gate record (facilitator prepares, verdict
field empty) -> owner verdict -> closure unit + baseline tag. Registrar
duties after every significant change; generator run after every register
edit. One editor per file; units sequenced when they touch the same
registers.

## 6. Failure modes (phase-06 evidence, apply forward)

- **"Locally green" is not evidence.** The CI invocation path is the only
  truth - and it lies too if a dependency is missing from the pin list
  (gate finding G-1: the pytest leg had never run in CI; the first real run
  immediately found a bug). After changing CI/deps, verify the leg *actually
  ran* in the CI log, not just that the workflow is green.
- **Timing-dependent nondeterminism.** Per-call wall-clock reads (or any
  ambient state) inside a loop make results order- and platform-dependent
  (TC-046: a clock tick mid-scoring flipped a tie-break only under CI
  timing). Take reference time once per request; if a result must be
  deterministic, construct it deterministic - never tune the test to the
  observed order.
- **Integration claims without a crossing test.** "The modules are tested,
  so the system is integrated" - false: an interface with no test crossing
  it is unverified glue. The matrix (section 2) exists to catch exactly this.
- **The smoke test that grew into the load harness.** Phase 07 proves the
  system works; phase 08 measures it under load. A flaky CI "load test" is
  the worst of both.
- **Deployment by stealth.** Rolling out to a rented host because the
  compose file exists skips an owner decision with cost consequences. The
  compose smoke in CI is the phase-07 deliverable; the VPS go is the owner's.
- **Silent scope additions.** New contract fields, new endpoints, a
  "helpful" stub for a boundary submodule - all findings to report, never
  unit-scope decisions (same rule as phase 06).

## Checklist

- [ ] Every IF-### has >= 1 named integration test crossing the real
      contract boundary, or is explicitly recorded as boundary-pinned -
      computed mechanically (S-5 gap fixed)?
- [ ] 3-6 end-to-end flows assert at the outermost surface, all external
      boundaries hermetic, reproducible in CI?
- [ ] Compose/deployment shape builds, boots healthy, passes one end-to-end
      smoke in CI; rollout explicitly NOT done (separate owner go)?
- [ ] Performance budgets smoke-checked and marked as smoke; no load harness?
- [ ] CI legs verified as actually running (log checked), all pins complete?
- [ ] No new features/contracts/boundary stubs; findings reported?
- [ ] Independent review done, fixes verified by the same reviewer, gate
      record prepared with empty verdict field, owner verdict, closure unit
      + baseline tag?
