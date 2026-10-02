# Agent instructions - workspace root

(The workspace root is intentionally not a git repo; this file lives here so
every agent session sees the house rules when the workspace is opened.
Adjust the bracketed parts to your setup.)

## Token-efficient navigation

Project registers grow; do not read them whole. Read order in any project
that has it:

1. `STATE.md` - current phase, counts, next action, file map.
2. `INDEX.md` - one line per entity; find the ID you need.
3. Targeted read only: grep the ID, read the lines around the hit.

Never read CHANGELOG.md, DECISIONS.md, requirements.md or OPEN-QUESTIONS.md
in full. If a generated file (`INDEX.md`, `TRACEABILITY.md`) looks stale,
regenerate it with the project's index generator instead of patching it by
hand.

Fetch discipline: targeted endpoints and bounded result sets; never fetch a
whole list when one item answers the question.

## Session conventions

- Chat language: <yours>; project documents: English.
- One chat window per task/milestone. Before switching: commit + WORKLOG
  current. A new window starts from `STATE.md` (+ `INDEX.md`), not from
  chat history.
- Decisions are prepared as proposals with options; the owner answers
  briefly, the agent then writes the DEC and closes the question.

## Roles

See `workshop/agent-roles.md` - roles across all phases (Owner, Author/
File-Holder, Reviewer, Researcher, Registrar, Coordinator, Product
Manager). Two iron rules: **one editor per file at a time**; **reviewer
!= author**. Roles are assigned per task at handoff.

## WORKLOG discipline

After **every significant step** in any project, update `workshop/WORKLOG.md`:

1. the **daily section** - newest day at the bottom, under the **current
   calendar date** (check the date; do not reuse a previous session's date),
2. the **"Current state (snapshot)"** section whenever project state changes.

The WORKLOG is the durable memory across sessions and agents - skipping it
breaks continuity. Log change-control details additionally in the project's
own `CHANGELOG.md`.

Do not leave WORKLOG updates for "later" or batch them only at commit time.

## Shell / tooling hygiene (learned from real incidents)

- **Never use `> nul` redirects in POSIX shells** (sh / git-bash) on Windows.
  `nul` is a reserved device name; redirecting to it from a POSIX shell
  creates a real file named `nul` that breaks tooling. Use `> /dev/null`
  or a tool flag instead.
- **Keep heavy generated directories out of git and out of the file
  scanner:** project `.gitignore` should cover `.venv-*/`, `.pytest_cache/`,
  `.ruff_cache/`, `.mypy_cache/`, `.pgdata*/`. If the editor's file scanner
  ever chokes on a healthy repo, add the same patterns to its
  `file_scan_exclusions`.
