# Skill: system validation - closing the V against the requirements

How to run the last V-model phase: validate the integrated system against the
original requirements using the phase-03 assets, record results per REQ, and
triage everything that cannot be executed into an honest deferral register.
Distilled at the start of geo-knowledge-guide phase 08 (2026-08-24), after
phase 07 closed PASS (integration matrix mechanical, 6 end-to-end flows,
compose shape smoke-tested in CI, T1 budget smoke) - and after the owner
decision meeting 2026-08-24 (M-015..M-021) fixed the phase-08 pattern:
**execute what is honestly executable today; defer the rest in writing, with a
named home, never silently.**

**Use when:** the system is integrated and integration-tested; the question
shifts from "does the system work" to "does it meet the requirements it was
built against"; when some validation assets depend on inputs that do not exist
yet (real corpus, rented host, reference hardware) and the temptation is to
either fake the measurement or skip the phase.

---

## 1. What phase 08 is - and what it is not

Phase 08 executes the phase-03 validation assets and closes the V against
phase 01. In geo-knowledge-guide, four executable additions (owner-approved,
M-015):

1. **Negative-path UI suite.** The catalogue's backend legs are already tested
   (TCs + e2e flows) - cite them as evidence, do not re-run. What is open is
   the *rendered* half: every non-success state renders its defined state,
   is keyboard-operable, and never freezes the UI thread.
2. **Load harness where the criteria doc is the contract.** The phase-03
   criteria draft (ladder, thresholds, M-criteria) is executed as-is; the
   harness is built *for* the criteria, not alongside them. Where the
   reference conditions (device class, network, production-like externals)
   cannot be reproduced, the executed conditions are recorded verbatim next
   to the numbers - a measurement under substitute conditions with the
   conditions stated is evidence; the same numbers without the conditions
   are fiction.
3. **Asset groundwork that removes future tooling from the critical path.**
   Assets whose *execution* is blocked on missing inputs (e.g. a gold set
   that needs a real corpus) get their skeleton + runner built and dry-run
   on synthetic data now, so the later execution is a data task, not a
   tooling task. Building the runner is phase-08 work; judging/running it
   against real data is not.
4. **Scripted accessibility sweep.** The automated half (axe-core-class
   scanner over every reachable UI state, violations triaged) is executable
   now; the manual half (contrast in real rendering, screen-reader output)
   is handed to the owner as a checklist, explicitly the owner's task.

Explicitly NOT phase 08: anything needing the real corpus (gold-set judging,
relevance calibration, LLM-experiment passes), the rented-host rollout
(separate owner go with cost estimate - the compose smoke from phase 07 is
the evidence base, not the deployment), reference-device measurements the
local environment cannot produce (deferred to the host environment, fallback
pre-approved by the owner), new features, contract changes, UI redesign -
findings are reported, not fixed.

## 2. The deferral register is the deliverable, not an appendix

The gate record's core is two lists: **validated** (per REQ, with evidence)
and **deferred** (per item: what, why it cannot run today, where it now lives
- R0 / VPS / R1 - and what unblocks it). Rules:

- Every deferral has a named home and a named unblock condition. "Later" is
  not a home.
- Every deferral was pre-approved at the concept level (the owner decision
  on the phase concept) - a deferral first surfacing at the gate is a
  concept breach; escalate, don't smuggle it into the record.
- Deferral is not failure. The phase fails only when something executable
  was not executed, or a measurement claims conditions it did not run under.

## 3. Measurement honesty (the load harness rules)

- The criteria document fixes ladder + thresholds; the harness implements
  them. Never tune a threshold to an observed run (the phase-07 rule: an
  overage on a healthy runner is a real signal - find the cause, don't
  widen the limit).
- Record the executed conditions (hardware, network emulation, tile path,
  corpus size) with every number; where the criteria name reference
  conditions you cannot meet, say so in the same table row as the number.
- A failing criterion at the top ladder tier is a *design falsification*
  (the design answer - e.g. clustering + top-N cap - does not suffice):
  the finding goes back to architecture; it is never tuned away in the test.
- Synthetic data generators must stress the mechanism (clustering-stress
  distributions), not flatter it (uniform grids).
- Determinism per construction: reference time once per run; seeds recorded;
  the configuration under test recorded with the run like locked weights -
  "what passed" must be reproducible.

## 4. Process and roles: unchanged

Same loop as phases 06/07 (skill `module-implementation` section 6,
`integration-testing` section 5): draft -> independent review
(reviewer != author) -> fixes by the file-holder -> same-reviewer
verification -> gate record (facilitator prepares the consolidated,
concept-vs-reality review; verdict field empty) -> owner verdict -> closure
unit + baseline tag (`phase-08-...-baseline`). Registrar duties after every
significant change; generator run after every register edit; units sequenced
when they touch the same registrar files.

## 5. Failure modes (phase-06/07 evidence, applied forward)

- **The gate review that only consolidates.** The phase-end gate must check
  the *concept* against reality, not just sum the unit reviews - twice
  (phases 06/07) the consolidated review found a real blocker the unit
  reviews missed (a CI dependency never pinned, a concept addition silently
  omitted). Before the gate: walk every concept item and name its evidence
  or its absence.
- **"Executable halves" shrinking quietly.** A unit that discovers an
  asset is less executable than planned reports a finding and escalates -
  it does not narrow the scope in its own write-scope and call it done.
- **The skeleton that claims execution.** A runner dry-run on synthetic
  judgements proves the *tooling*, never the *quality*. Records must say
  which of the two they are.
- **The smoke test that grew into the load harness** (carried from
  `integration-testing` section 6) - and its mirror image in phase 08: the
  load harness that degrades into a smoke because the full ladder is
  inconvenient. The ladder tiers are the contract (re-scaling a tier's
  *size* is a named, owner-visible review action, not a harness choice).
- **CI-reading failures, timing nondeterminism, "locally green"** - all
  phase-06/07 failure modes apply unchanged; for browser-driven suites add:
  a UI state asserted via implementation internals (DOM ids that are the
  code describing itself) instead of the observable state is the same
  failure as a unit test written from code.
- **Scope creep into the exclusions.** The exclusion list (corpus work,
  rollout, reference hardware, features) is owner-approved; adding any of
  it mid-phase is deployment-by-stealth in a new costume.

## Checklist

- [ ] Every phase-03 asset is either executed (evidence cited) or in the
      deferral register (home + unblock condition, pre-approved)?
- [ ] Rendered-state asserts for every non-success case; backend legs cited,
      not re-run?
- [ ] Load harness implements the criteria doc as-is; executed conditions
      recorded verbatim with the numbers; thresholds never tuned?
- [ ] Asset skeletons dry-run on synthetic data, records say "tooling
      proven, quality not measured" where that is the truth?
- [ ] Scripted accessibility sweep over all states; manual checklist handed
      to the owner in writing?
- [ ] Gate record = consolidated concept-vs-reality review with both lists
      (validated / deferred), verdict field empty; owner verdict; closure
      unit + baseline tag?
- [ ] No excluded item executed (corpus, rollout, reference hardware);
      findings reported, not fixed?
