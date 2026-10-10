# Backlog

All open work items in one place. **This register is the SINGLE SOURCE for
open work items** - `graph.json` is generated from it
(`tools/build_index.py`: `backlog-item` nodes, `tracks` edges from the
Links cell). Query: `python tools/query_graph.py backlog`.

**Slimness rule:** OPEN items only - status is `open | in-progress |
blocked`. There is NO done status: the registrar DELETES closed rows at
unit close and references the BKL-### in the closing CHG entry (like
`closes OQ-###`). History lives in the CHG + git, never in this register.

**Non-duplication rule (binding):**

| Content | Home | NOT the backlog because |
|---|---|---|
| Product requirement | REQ (01-requirements/requirements.md) | backlog items are WORK, not requirements |
| Unanswered question blocking a decision | OQ (OPEN-QUESTIONS.md) | has its own resolve-by mechanism |
| Feature request with user value | FR (product register, when introduced) | has its own evaluation lifecycle |
| Planned delivery (package) | the release roadmap | REFERENCES BKL items, never holds them |
| Everything else open: tech debt, review/record follow-ups, small defects, "someday" points, verbal owner points | **BKL (here)** | exactly what tends to scatter |

## Register

| ID | Item | Type | Prio | Owner | Links | Status |
|----|------|------|------|-------|-------|--------|
| BKL-001 | <first item> | follow-up | P2 | <role> |  | open |

<!-- Table conventions (read by tools/build_index.py):
     - ID: BKL-### (sequential, never reused after deletion)
     - Type: bug | debt | improvement | follow-up
     - Prio: P1 | P2 | P3
     - Owner: a role (coordinator, PM, ...) or `owner`
     - Links: machine-readable IDs (`PREFIX-###`, `..` ranges, `/` shorthand,
       no wrap inside a token) - they become `tracks` edges in the graph
     - Status (LAST cell): open | in-progress | blocked -->
