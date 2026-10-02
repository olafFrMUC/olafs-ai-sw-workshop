# Way of working - the operating guide

How to start and how to work, day to day. Read `docs/architecture.md`
first for the why; this file is the how.

## Starting a new project

1. **Bootstrap once** (per workspace): `powershell -ExecutionPolicy
   Bypass -File .\workshop\setup.ps1` - idempotent, safe to re-run.
2. **Create the project:** copy `workshop/_template-software-project/`
   to `apps/<name>/` (or `_template-knowledge-project/` to
   `knowledge/<name>/` for writing projects). Fill in `CLAUDE.md` and
   `README.md`. `git init`, first commit, own repo, push.
3. **Open the steering chat** (Coordinator): give it a short pointer -
   "read `workshop/handoff-coordinator.md`, then start phase 01".
   Model class: standard.
4. **Phase 01 (requirements):** use `workshop/skills/testable-requirements/`
   - every acceptance criterion gets a number and a condition. Then a
   **review gate** (skill `review-gates/`): independent reviewer, verdict,
   baseline tag.
5. **Phases 02-08:** concept -> validation concept -> architecture ->
   module specification -> implementation -> integration -> validation.
   Each phase has its skill in `workshop/skills/` and ends in a gate.
   Not every project needs every phase in full depth - but phase 01 and
   the register discipline from day 1 are not negotiable.
6. **From the first release on:** switch to incremental mode (below).

## The graph (grows with your registers)

From day 1 your project already has everything the relation graph needs -
the template's registers carry the machine-readable formats (DEC marker
comments, CHG "Affected artifacts" IDs, OQ resolve-by cells):

- After any register edit: `python tools/build_index.py` (rebuilds
  INDEX.md, TRACEABILITY.md, graph.json).
- Ask it questions: `python tools/query_graph.py neighbors|impact|path|
  uncovered|briefing <ID>`.
- Look at it: `graph.bat` (builds + opens graph.html in the browser).

Small projects see a small graph - fine. The point is you never retrofit:
when the registers grow, the picture is already there.

## Daily work: the unit rhythm

1. Work happens in **units**, each with a dated handoff
   (`workshop/handoff-template.md`). The coordinator writes it; it names
   author, reviewer, write-scope, estimate and **abort condition**.
2. The owner says go. The author works; mid-run questions only when
   blocking - otherwise document the assumption, keep going.
3. The reviewer (never the author) checks the result **against files**.
4. Findings fixed, verified; the registrar anchors: CHG entry, STATE.md,
   `python tools/build_index.py`.
5. Commit only with owner approval; after every push, one glance at CI.
6. WORKLOG day entry (current date!) - the durable memory across
   sessions. Every significant step, not batched.

## Incremental mode (post-first-release)

The V-model built the foundation; ongoing work is package-oriented:

- Group changes into **packages** (a roadmap file per release).
- Each package = a sequence of handoff units, same unit rhythm as above.
- Release boundaries get a **release gate** again (the big scissors):
  evidence assembly, independent review, owner verdict, baseline tag.
- The registers + graph carry the traceability through both modes -
  that is the point of keeping them machine-readable.

## Window hygiene (chat rotation)

- One chat window per task/milestone; chats are quadratic cost, rotate
  early. Before a switch: commit + WORKLOG current.
- Steering and methods chats are standing roles with **transition
  checklists** (`handoff-coordinator.md`, `handoff-methods.md`): the
  outgoing writes the final state, the incoming verifies from files -
  never from chat history.
- A sub-agent session does not survive a window switch; resume via its
  on-disk handoff, not via memory.

## The three rules you will actually feel

1. **One editor per file at a time** - if you learn someone else holds
   the file, stop and say which paragraphs you already touched.
2. **Reviewer != author** - the second pair of eyes must be independent.
3. **Evidence rule** - claims with verifiable evidence only; "not
   verifiable" is a legitimate answer.
