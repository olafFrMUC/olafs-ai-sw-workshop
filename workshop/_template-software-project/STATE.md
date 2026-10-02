# State - <project name>

The project's single navigation entry: current phase, counts, next action,
file map. Keep it short - it is read first by every agent session
(token-efficient navigation, see AGENTS.md). Regenerate-derived files with
`python tools/build_index.py` (INDEX.md, TRACEABILITY.md, graph.json).

## Where we are
<one paragraph: current phase/release, what is done, what is being worked on>

## Counts
- Latest CHG: CHG-000 | DECs: 1 | REQ: 0 | OQ open: 1 | Risks: 0
- (update at every registrar pass - the register currency check at unit
  close verifies these against the actual registers)

## Next actions
1. <the next unit, one line>

## Map
| What | Where |
|---|---|
| All entities, one line each | `INDEX.md` (generated) |
| Relation graph (derived, queryable) | `graph.json` (generated) + `tools/query_graph.py` + `graph.bat` (viewer) |
| Requirements | `01-requirements/requirements.md` |
| Decisions | `DECISIONS.md` |
| Changes | `CHANGELOG.md` |
| Open questions | `OPEN-QUESTIONS.md` |
| Risks | `RISKS.md` |

## Regenerate
`python tools/build_index.py` from the project root rebuilds `INDEX.md`,
`TRACEABILITY.md` and `graph.json`. Run it after any edit to requirements,
DECISIONS, OPEN-QUESTIONS, RISKS, CHANGELOG, RELEASES, or the concept's
coverage table. Query the graph with `python tools/query_graph.py
<neighbors|impact|path|uncovered|briefing> <ID>`; view it with `graph.bat`.
