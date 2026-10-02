# Orchestration - Activity & Gate Board

Living control center. A phase may only be marked done after its gate passes.
Status: todo | in-progress | in-review | done | blocked

| # | Phase | Status | Review gate | Gate result |
|---|-------|--------|-------------|-------------|
| 01 | Requirements | todo | Requirements Review | - |
| 02 | Solution Concept | todo | Concept Review | - |
| 03 | Validation Concept & Tests | todo | Validation Review | - |
| 04 | Architecture | todo | Architecture Review | - |
| 05 | Module Specification & Test-Case Design | todo | Spec Review | - |
| 06 | Module Design & Module Test | todo | Code/Test Review | - |
| 07 | Integration & Integration Test | todo | Integration Review | - |
| 08 | System Validation | todo | Validation Sign-off | - |

## How to run it
1. Pick the lowest-numbered phase not done.
2. in-progress -> produce artifacts.
3. in-review -> run the gate -> record in reviews/YYYY-MM-DD-<gate>.md.
4. pass -> done; fail -> blocked/in-progress with actions.
5. Update CHANGELOG.md and TRACEABILITY.md as you go.

## Gate exit criteria
- Requirements Review: complete, unambiguous, testable, owned; traceability seeded.
- Concept Review: chosen solution justified in DECISIONS.md; alternatives weighed.
- Validation Review: each top-level requirement mapped to >=1 validation test.
- Architecture Review: submodules + interfaces + sub-requirements; every req allocated.
- Spec Review: each submodule specified; each sub-req has >=1 TC-###.
- Code/Test Review: implemented, module tests pass, reviewed.
- Integration Review: integrated; interface/integration tests pass.
- Validation Sign-off: all validation tests executed; results recorded; opens triaged.
