# 04 - Architecture (Architektur entwerfen)
Goal: decompose into submodules with defined interfaces; allocate requirements.
Inputs: 01, 02, 03. Output: architecture.md with three registers:
- SUB-### register: one responsibility per submodule, none shared.
- IF-### register: interface contracts (parties, data shapes, error/empty
  cases, versioning). Typed status vocabularies live here, not in the UI.
- Sub-requirements traced to parent REQ-###, plus the allocation table
  (machine-readable, drives TRACEABILITY columns ARC/IF and SUB):

    | REQ-### | SUB-### | IF-### |
    |---------|---------|--------|

  One row per allocation; multiple rows per REQ allowed; IF = `-` if internal.
Method: see workshop/skills/architecture-design/.
Verifies (right branch): 07 - Integration & Integration Test.
Gate: Architecture Review (independent reviewer, before implementation)
-> record in ../reviews/.
