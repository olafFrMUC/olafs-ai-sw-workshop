# Handoff template - start prompt for work chats

Template for starting a new work chat (one unit = one chat).
Fill in the `<...>` parts; hand the rest along unchanged. Background:
`agent-roles.md` (roles), `agent-navigation-concept.md` (STATE-first navigation),
`skills/decision-meeting/` (escalation path). Handoffs are project documents and
are written in **English** (owner language rule, 2026-08-22).

```markdown
# Handoff: <short title of the work unit>

## Project & entry
- Project: <e.g. apps/geo-knowledge-guide>
- Read `STATE.md` first, then `INDEX.md`, then targeted greps. Never read a
  register in full.

## Task
<concrete, one unit>
Done criterion: <measurable, e.g. "concept section 3.4 revised; coverage table
checked; CHG entry written; STATE.md next-action updated; INDEX rebuilt via
`python tools/build_index.py`">
Abort condition (MANDATORY when the done criterion names concrete external
expectations - specific items, live measurements, payload checks): <e.g. "if a
named item is not resolvable after <=3 targeted queries, STOP and report the
gap - do not reformulate">

## Estimate (fill before the owner go)
- Duration: <S (<1 h) / M (hours) / L (day+)>
- Token cost: <~EUR order of magnitude, marked as estimate>
- Server cost: <EUR, e.g. VPS hours; 0 if local>
- Uncertainty: <what could make this bigger>
- Model class: <strong / standard / mechanical - see agent-roles.md,
  "Model routing". The person opening the window sets the model accordingly:
  the coordinator recommends, the human sets (agents cannot switch models).>

## Your role(s)
<e.g. Author for 02-solution-concept/, Registrar for CHANGELOG/STATE>
Reviewer is <name/chat> - you do not review your own work.

## Write-scope (only these files)
- <file/directory 1>
- <file/directory 2>
Everything else: read-only.

## Rules
- Decision needed? -> Stop, formulate an option proposal, escalate to the owner
  (steering chat). Do not decide yourself.
- Decision friction (a DEC blocks, over-costs or proves unfavourable)? -> Stop,
  report with evidence + options to the steering chat. Procedure:
  workshop/agent-roles.md, "Decision friction".
- **Abort conditions on hard done criteria (owner, 2026-09-20 - a sub-agent
  burned a full token budget overnight in an unbounded retry loop: a hard
  live-verification criterion ("verify with 3 named items") had no exit
  strategy, so empty lookups were read as "my SQL is wrong" instead of "the
  item is not there" - a syntactic random-walk retry):** when your handoff's
  done criterion names concrete external expectations, it also names the
  abort condition (<=3 targeted attempts per verification step, then STOP and
  report the gap - no reformulation). An empty or failed lookup is DATA (the
  item is absent / the path is unreachable), not proof your query is wrong.
  Partial progress reported is a valid unit result; an unbounded retry loop
  is not. If your handoff lacks the abort condition, apply this default and
  note it in your report.
- Evidence rule: status claims only with verifiable evidence (CI run, command
  output, a file on disk). Label estimates as estimates; "not verifiable" is a
  legitimate answer.
- Question windows: mid-run questions to the owner only if the unit would block
  otherwise - otherwise document the assumption, keep going, and list it under
  "deferred to owner" in your closing report.
- Registers changed (requirements, DECISIONS, OQ, RISKS, CHANGELOG, coverage or
  TC/allocation tables)? -> run `python tools/build_index.py` from the project
  root (rebuilds INDEX.md, TRACEABILITY.md **and `graph.json`**).
- **Relation graph (2026-09-12, CHG-135; extended 2026-09-13):** for
  cross-document questions use
  `python tools/query_graph.py <neighbors|impact|path|uncovered|briefing> <ID>`
  instead of multi-file grepping. Reviewers: run `impact <ID>` for the IDs you
  touch BEFORE the review and check the listed dependents. Keep IDs in
  CHANGELOG "Affected artifacts" machine-readable (`PREFIX-###`, `..` ranges,
  `/` shorthand, no wrap inside a token) - they become `affects` edges.
  Extensions: `briefing <ID>` includes the node's register-text excerpt;
  `graph.bat` (project root) opens a self-contained HTML viewer (search,
  sidepanel, edge-type filters); DEC revisions show as `supersedes` edges
  when the revising DEC carries a `- Supersedes: DEC-###` marker line
  (2026-09-13 - add one when your unit supersedes/amends a DEC, and check
  an older DEC for supersession before relying on it).
- **CI-equal local check (coordinator directive 2026-09-12 - main was red
  for ~2 days on a pre-existing mypy failure in `test_categorization_v1.py`,
  and later commits inherited the blame):** for units touching code the CI
  checks, the done criterion is the CI-equal check over the WHOLE suite
  (e.g. `mypy --strict` across all files, exactly as the workflow runs it)
  - not only the files you changed. A green check on changed files can
  still ship red to main.
- Chat language German, project documents English.
- **Unit-state schema (units of size L; SKILL.state pattern,
  research/2026-08-30-skillstate-review.md):** maintain a small structured
  state block in the dated handoff or run record, updated at each natural
  boundary: `done:` / `pending:` / `evidence:` (paths, CI runs) /
  `blockers:` / `cost so far:`. The coordinator reads THIS block instead of
  your chat history - it is what survives a window switch.
- Cost discipline (owner, 2026-08-30):
  - **Model routing (three classes, agent-roles.md):** strong for
    authoring/review, standard for steering/PM, mechanical for registrar and
    mechanical units. The handoff names the class in its estimate block;
    whoever opens the chat window sets the model - an agent (incl. the
    coordinator) cannot switch models, and sub-agents always inherit the
    parent thread's model. A gate review on too weak a model costs more than
    it saves; a registrar unit on the strongest model is money thrown away.
  - **Mechanics into scripts/CI:** counting, greps, index builds, lint runs
    happen as scripts/CI, not agent passes - agents are for judgement.
  - **Context economy:** sub-agents for bulk reading; resume sessions via
    session_id instead of restarting; reference standing handoffs by path
    instead of pasting full text.
  - **Output discipline:** output costs ~5x input - use the report structure,
    no repeated prose.
  - **Chat length is quadratic cost** (SKILL.state, arXiv 2608.26263: history
    runtimes burn O(T^2) tokens - 1.06M vs 65k at T=100 steps): rotate early,
    keep unit state in the schema block, never rely on a long chat as memory.

## Closing
1. Update `STATE.md` (phase, counts, next action).
2. `workshop/WORKLOG.md`: day entry (current date - sessions run past midnight,
   check `date`!) + snapshot if the state changed. Include **actual vs estimate**
   (duration, token ~EUR if assessable, server EUR).
3. **Register currency check (owner, 2026-09-09 - after two commits shipped
   without CHG entries):** every commit of your unit has a CHANGELOG entry,
   STATE.md latest-CHG matches the newest entry, INDEX was rebuilt. No
   commit proposal without this check.
4. Propose a commit (message draft) - do not commit without approval.
5. **After every push to main:** check `gh run list` (one glance). A red
   main stops all new units until fixed - report it to the steering chat
   immediately, never let it slide.
6. Report back to the steering chat: what is done, what is open, decision needs,
   deferred-to-owner items.

**Reviewer handoffs additionally** (owner decision 2026-09-13): the review
report is filed as a document in the project's `reviews/` folder
(`YYYY-MM-DD-<unit>-review.md`) - a WORKLOG/chat line alone is not the record.
No backfill for pre-2026-09-13 verdicts; they stay findable in the WORKLOG.
```

Instances (filled, dated examples) live in the project's `handoffs/` folder.
