# Concept: a machine-readable relation graph from the registers

2026-08-23, methods chat (owner request). Status: **APPROVED for
implementation - owner decision 2026-09-12 (deferral lifted). Trigger:
the register-size threshold was met (control registers ~420 KB ≈ ~105k
tokens, 2026-09-12), joining the two already-met thresholds (seam errors,
multi-hop questions). Implement option A per section 6.**
Context: `2026-08-23-linkedin-graph-engineering-review.md` (the external trigger).
Cross-reference: `2026-08-30-skillstate-review.md` - the dynamic twin of this
concept (execution state instead of chat history; this graph is its `P`,
STATE.md/handoffs are its `Σ`).

## 1. Starting point

Our "knowledge graph" already exists - but only **implicitly**: Markdown files
reference each other by ID (`DEC-014 -> REQ-067/068`), and `build_index.py`
already parses most of those relations today: DEC markers with `links:`, the
coverage table (REQ -> concept section), the allocation table (REQ -> SUB/IF),
the TC allocation (REQ -> TC), IF test markers in the test sources, CHANGELOG
"Affected artifacts". But the output is condensed to **reading text for humans**
(INDEX.md, TRACEABILITY.md) - agents cannot *query* any of it.

**The gap:** questions like "what depends on REQ-053?" or "which DECs does note 4
touch?" require manual grepping across files today - exactly the seam work that
the consistency-sweep skill identified as our dominant error source.

## 2. Target picture

A **generated, derived graph** (no new truth!): `build_index.py` additionally
writes `graph.json` (typed nodes + typed edges), and a small query script
`tools/query_graph.py` answers the 5-6 standard questions. Markdown stays the
only source; the graph is rebuilt on every regeneration - drift impossible by
construction.

**Edge types** (all from existing sources):

| Edge | Source | Example |
|---|---|---|
| `closes` | OQ status + DEC markers | OQ-024 -> DEC-014 |
| `decides / amends / supersedes` | DEC marker `links:` | DEC-021 -> REQ-050 |
| `covers` | coverage table | REQ-073 -> SC 3.4 |
| `allocated_to` | allocation table | REQ-053 -> SUB-003, IF-002 |
| `tested_by` | TC allocation + test markers | REQ-056 -> TC-059, IF-007 |
| `affects` | CHG "Affected artifacts" | CHG-097 -> TC-059 |
| `in_release` | RELEASES.md | REQ-089 -> R1.5 |

**Standard queries** (`query_graph.py`): `neighbors REQ-053` (what is attached),
`impact REQ-053` (transitive: what must be re-checked on change),
`path REQ-053 SUB-003`, `uncovered` (nodes missing an edge type),
`briefing REQ-073` (auto-generated context block for handoffs).

## 3. Options

| | A: `graph.json` + query script (recommended) | B: SQLite export | C: Graph DB (Neo4j etc.) |
|---|---|---|---|
| Effort | small (~1 unit: parsers exist, export + ~6 queries) | medium (schema, load logic, SQL skill in the agent) | high (server, driver, ops) |
| Query comfort | good for the standard questions | arbitrary ad-hoc SQL | full traversal |
| Extra artifact | 1 JSON file (generated) | 1 DB file (generated) | infrastructure |
| Risk | none worth naming | overkill temptation | **clearly against the standing navigation decision** ("no graph DB at this scale", agent-navigation-concept.md) |

## 4. Pros and cons

**Pros:**
- **Grounded evaluator:** reviewers / consistency-sweep check real relations
  instead of prose (missing/false/circular edges become machine-visible -
  exactly our four failure modes).
- **Token efficiency:** an agent fetches the 5 relevant IDs via `neighbors`
  instead of grepping 3 files.
- **Impact analysis before edits:** "what breaks if I change REQ-053?" becomes
  a query, not a search operation - sharpens handoff write-scopes.
- **Meeting/agenda preparation:** constraints and linked DECs enriched
  automatically.
- Reusable for climate-physics (same register pattern) - the tool amortises.

**Cons / risks:**
- **Garbage in, garbage out:** edge quality depends on marker discipline
  (free-text "Affected artifacts" lines are only partly parseable -> convention
  needed: keep IDs machine-readable there).
- **One more tool to maintain** (parser changes when register formats change).
- **Over-engineering risk:** for ~80 % of today's questions INDEX.md + grep
  suffice. The graph must complement, not replace, the simple navigation.
- Little value unless agents are actually told to use the queries in their
  handoffs (adoption must be anchored in `handoff-template.md`).

## 5. When is it worth it? (thresholds)

| Threshold | Today |
|---|---|
| Seam errors dominate review findings | **met** (core thesis of the consistency-sweep skill) |
| Multi-hop questions (REQ->SUB->IF->TC) occur regularly | **met** since phases 05/07 (85 TCs, 14 IFs, 12 SUBs) |
| Autonomous agents need machine-readable briefing context (queries instead of grep sessions) | **met** (VPS-agents study, 2026-08-30) |
| Product Manager impact analyses need `impact`/`neighbors` queries | **met** (product-manager pilot, 2026-08-30) |
| Register size > ~100k tokens | not yet (~46k tokens of control files) |
| Second project uses the pattern | climate-physics not started |
| External consumers (commons, API) | no |

**Update 2026-08-30 (owner's optimisation requirements):** the deferral
stands, but two drivers were added to the threshold table - autonomous VPS
agents (a `briefing` query is their machine-readable context, and cost
discipline favours a query over a grep session) and the product-manager role
(feature impact analyses map directly onto `impact`/`neighbors`). The
recommendation is unchanged: option A when the stable release lands.

**Recommendation:** two of five thresholds are already met, and they cover our
documented dominant error source. -> **Implement option A now** (small unit,
immediate benefit for reviewers + coordinator); deliberately not B/C.
Re-evaluate when climate-physics starts or when registers pass ~100k tokens.

## 6. Implementation plan (1 unit, write-scope `tools/`)

1. `build_index.py`: emit all parser results additionally as `graph.json`
   (nodes with type, edges with type + source); the validator warns on edges
   pointing at nonexistent IDs (a consistency win by itself).
2. `tools/query_graph.py`: the 5 standard queries, output as a compact text
   block (paste-ready for handoffs/reviews).
3. Anchoring: `handoff-template.md` (reviewer: "run `impact <ID>` before the
   review"), `skills/consistency-sweep/` (graph as the mechanical extraction
   layer), CHANGELOG + INDEX regeneration.
4. No changes to existing register formats; the single new convention: keep
   IDs machine-readable in "Affected artifacts" lines.
