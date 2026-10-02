# Concept: token-efficient agent navigation in spec-driven projects

2026-08-07, owner request. Status: proposal. Applies to all projects in this workspace
(first adopter: geo-knowledge-guide).

> **Supplement:** [`agent-navigation-supplement.md`](agent-navigation-supplement.md) (Claude,
> 2026-08-07) agrees with the three-layer model and adds what this document does not cover:
> measured register sizes, frontmatter as the generator's substrate, **generating the derived
> views** (traceability, coverage tables, release membership) rather than only the index,
> splitting prose-per-record registers, archiving closed material, and the output-token side.

## 1. Problem

The V-model produces many documents: requirements, changelog, decision records, solution
concept, risks, open questions, traceability, release plan. Every continued task forces the
agent to re-read them, and the token cost of each session start grows linearly with project
history.

The documents serve **two audiences with two reading modes**:

- **The owner** needs readable prose (to follow and review the work).
- **The agent** needs targeted access (current state, the one relevant slice, the "why" of
  a decision).

The token consumption comes from the agent reading prose documents **in full** when 90 % of
tasks need 5 % of the content.

## 2. Why not a knowledge graph (now)

- **Drift risk.** A graph beside the prose documents must be kept in sync with them. Every
  serious finding in both concept cross-check rounds lived exactly on such seams between
  documents (see the consistency-sweep skill). A graph is one more seam that breaks.
- **Tooling cost.** The agent cannot query a graph natively - that needs an MCP server or
  scripts. Real infrastructure for a documentation problem.
- **Not needed.** The project entities carry **stable IDs** (REQ-###, DEC-###, OQ-###,
  RISK-###, CHG-###). With stable IDs, grep plus targeted line-range reads *is* exact
  retrieval. Semantic search pays off on large unstructured corpora, not on a small
  structured one.

The traceability matrix is already "the graph as a table". A real graph becomes interesting
later, when the product itself exists - the project knowledge could then live in the
product's own knowledge graph (dogfooding). Not before.

## 3. The solution: three layers + navigation rules

The agent never reads whole registers; it navigates.

```
Layer 1: STATE.md          (~40 lines, always current)
         phase, counts, next action, pointers.
         Read FIRST - answers "where are we?"

Layer 2: INDEX.md          (one line per entity, GENERATED)
         DEC-012 | accepted | relevance model  -> DECISIONS.md
         REQ-062 | MUST     | relevance score  -> requirements.md
         Read SECOND - answers "where does X live?"

Layer 3: the prose documents (unchanged)
         read ONLY targeted: grep for the ID, read the lines
         around the hit. Answers "what exactly / why?"
```

Plus **navigation rules** in the workspace `AGENTS.md` (and each project's CLAUDE.md)
prescribing the read order: *STATE -> INDEX -> targeted grep. Never full reads.*

Two properties make this hold up:

- **The index is generated, not maintained.** A small script rebuilds it from the
  registers, so it cannot drift by hand - and if it ever disagrees, the consistency-sweep
  skill already knows how to catch that mechanically.
- **The prose is untouched.** Owner readability does not change by a comma. The index is an
  additional view, not a replacement.

## 4. Owner readability

Preserved by construction: the layers separate the audiences. The owner keeps reading
DECISIONS.md and the concept as prose and never needs to open the index. The only change
for the owner: none.

## 5. The second token sink: tool/fetch discipline

In practice the largest token block in the first sessions was not the registers but
research fetches (a single news-API dump dwarfed everything else). Same rule applies:
targeted endpoints, bounded result sets, never fetch a whole list when one item answers the
question. This goes into the same AGENTS.md rule set.

## 6. Rollout

1. `STATE.md` + `INDEX.md` (with generator script) in geo-knowledge-guide.
2. Navigation rules into the workspace `AGENTS.md`.
3. Use it on the next real task and compare: which files did the agent open, how much did
   it read? Adjust the layers from that observation.
4. If it works, fold the pattern into `workshop/_template-software-project/` (and the
   knowledge template) so new projects start with it.

## 7. Validation

- The index is regenerable and matches the registers mechanically (a consistency-sweep
  check: every index line's ID exists in the target file, and vice versa).
- A session that answers "what did DEC-012 decide and what does it affect?" without opening
  DECISIONS.md in full is the acceptance test.

## 8. External validation (2026-08-15)

The pattern this document describes is independently confirmed by the broader agent
community. A widely shared guide (x.com/undefinedKi/status/2068306794116501544,
June 2026) describes building an "AI second brain" from the same ingredients we use:
plain-text files the user owns, a model reading the whole store instead of re-explaining
every session, per-project instruction files (`CLAUDE.md` ~ our `AGENTS.md`/STATE.md),
reusable skills, and linking notes into a graph over time - the pattern Andrej Karpathy
called the "LLM Wiki" (April 2026).

Two takeaways for this workspace:

- **Our three-layer model (STATE -> INDEX -> targeted grep) is the same idea, applied to
  spec-driven engineering registers** rather than a personal knowledge vault. The external
  confirmation is encouraging, not a reason to change anything.
- **One borrowed rule worth adopting:** "keys, not prompts" - safety belongs in the
  permission layer (scoped, read-only credentials), not in prompt instructions. We follow
  this already for the C-2 experiment (env-var-only secrets, least-privilege IAM policies)
  and it should stay the standard for every future credential.

Deliberately not adopted: the MCP/Obsidian coupling (extra tooling layer - section 2's
argument against premature infrastructure applies) and scheduled auto-organization
(our WORKLOG/Registrar discipline covers the same need, human-controlled).
