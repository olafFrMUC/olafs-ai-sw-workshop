# Behaviour register

Observable behaviour of the system - what a user or an API consumer can
**SEE**, independent of how it is implemented. **Every row carries a
`Verified by` test link** - a behaviour without one is the defect class
that produced "button with no effect": it exists, nobody checks it, and
any change can silently break it. The machine check:
`python tools/query_graph.py uncovered --type behaviour` lists every row
whose Verified-by cell is empty (placeholder `<none>` counts as empty).

`graph.json` is generated from this register (`tools/build_index.py`:
`behaviour` nodes, `tracks` edges from the Links cell, `verified_by`
edges when the named test is a known test node).

**Non-duplication rule (binding):** REQs define WHAT the system must do;
BEH rows define what it observably DOES. A BEH row LINKS its REQ/BKL,
never restates it. One row per user-visible behaviour, not per function.

**Slimness rule:** rows describe CURRENT behaviour. When a behaviour is
removed, the row is DELETED by the registrar at unit close and
referenced in the closing CHG - history lives in the CHG + git.

**Next free BEH id: BEH-001** — MANDATORY: every new row takes THIS id
and increments the marker **in the same edit**. Deleted rows are
invisible; without the marker, ids get recycled and old CHG references
silently point at the wrong behaviour. Deleted ids are never reused.

## Register

| ID | Behaviour | Where observable | Verified by | Links | Status |
|----|-----------|------------------|-------------|-------|--------|
| BEH-000 | <sentinel - template row, skipped by the parser> | <UI desktop / UI mobile / API> | <test file path or `<none>`> |  | living |

<!-- Table conventions (read by tools/build_index.py):
     - ID: BEH-### (sequential, never reused after deletion; BEH-000 is the
       template sentinel)
     - Behaviour: plain language - what is seen, not how it works
     - Where observable: UI desktop | UI mobile | API | ...
     - Verified by: the test that guards it (path, e.g.
       src/tests/test_x.py or frontend/tests/x.test.ts); `<none>` =
       honestly testless - shows up in `uncovered --type behaviour`
     - Links: machine-readable IDs (`PREFIX-###`, `..` ranges, `/` shorthand,
       no wrap inside a token) - they become `tracks` edges in the graph
     - Status (LAST cell): living | boundary (explicitly out of test scope)
     - the "Next free BEH id" marker above is part of the register:
       new row = take the marker value, increment the marker in the same
       edit. tools/build_index.py warns when the marker is missing or a
       live row reached it. -->
