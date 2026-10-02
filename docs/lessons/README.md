# Lessons - the studies behind the workshop

The workshop's mechanisms are not invented theory. Each was preceded by a
written **study or concept review** that weighed options, measured loads and
recorded the reasoning - and the decision was then anchored where it
belongs (skill, role file, register). This folder holds the studies that
shaped the workshop's core ideas, lightly edited for publication
(infrastructure identifiers replaced by placeholders; project references
kept as provenance).

Reading these shows *how* the workshop thinks: a question is researched
with verification marks (checked at source / estimate / unverifiable),
options are priced, and the owner decides on a prepared basis - never on a
vibe.

| Study | What it is | What it became |
|---|---|---|
| `2026-08-30-skillstate-review.md` | Review of Google's SKILL.state paper (arXiv): explicit execution state instead of append-only chat history - bounded prompts, linear instead of quadratic token cost, zero recovery after window switches | The `state.json`-as-state pattern in `skills/autonomous-pipelines/`; the unit-state schema in `handoff-template.md`; the early-rotation rule for chat windows |
| `2026-08-23-graph-export-concept.md` | The concept for the machine-readable **relation graph** over the project registers (typed nodes/edges, a query CLI, thresholds for when it pays off) | `tools/build_index.py` -> `graph.json` + `tools/query_graph.py` + the `graph.bat` HTML viewer, now standard in the software template |
| `2026-08-30-vps-agents-study.md` | Autonomous work on a rented box: scripted pipelines proven in practice, the two-stage watcher pilot (watchdog script + LLM GUARD triage), and the honest analysis of why sub-agents must never *wait* (they are synchronous) | `skills/autonomous-pipelines/`; the "sub-agents are synchronous" rules in `agent-roles.md` and `handoff-coordinator.md` |
| `2026-08-23-linkedin-graph-engineering-review.md` | A source-criticism review of a viral "Graph Engineering" post - an example of the verification discipline applied to outside input | Confirmation, no action - kept as an example of the source-review format |

**Lifecycle rule for studies:** a study is *input*, never a decision. When
the owner decides, the outcome is anchored where it belongs and the study
stays as the reasoning record. New studies follow the same naming:
`YYYY-MM-DD-<slug>.md`.
