# setup.ps1  -  workspace bootstrap (Option A layout)
# Authoritative, idempotent source of the workspace skeleton and the templates.
# Run from anywhere:  powershell -ExecutionPolicy Bypass -File .\workshop\setup.ps1
#
# Layout (created in the PARENT of this script's folder = your workspace root):
#   <root>/                     container, NOT a git repo (only workshop/ is)
#     workshop/                 this repo: templates + skills + tooling
#       _template-software-project/   copy-source for software projects (V-model)
#       _template-knowledge-project/  copy-source for writing projects (phase-based)
#       skills/                       generic, reusable skills
#       setup.ps1  README.md
#     apps/       software projects  - each its own git repo
#     knowledge/  writing projects   - each its own git repo

# The workspace root is the parent of the folder containing this script.
# Clone the repo, run the script once - it fills in everything around it.
$root = Split-Path -Parent $PSScriptRoot
$sw   = "workshop\_template-software-project"
$kn   = "workshop\_template-knowledge-project"

$dirs = @(
  "$sw\01-requirements",
  "$sw\02-solution-concept",
  "$sw\03-validation-concept",
  "$sw\04-architecture",
  "$sw\05-module-specification",
  "$sw\06-module-design-and-test",
  "$sw\07-integration",
  "$sw\08-system-validation",
  "$sw\reviews",
  "$sw\src",
  "$kn\01-concept",
  "$kn\02-research",
  "$kn\03-outline",
  "$kn\04-manuscript",
  "$kn\05-revision",
  "$kn\06-editing",
  "$kn\07-production",
  "$kn\reviews",
  "$kn\manuscript",
  "workshop\skills",
  ".claude\skills",
  "apps",
  "knowledge"
)
foreach ($d in $dirs) { New-Item -ItemType Directory -Force -Path (Join-Path $root $d) | Out-Null }

function Write-Doc([string]$rel, [string]$content) {
  $path = Join-Path $root $rel
  $dir = Split-Path -Parent $path
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  $content | Out-File -FilePath $path -Encoding utf8
  Write-Host "  created $rel"
}

# Like Write-Doc, but never overwrites an existing file. For documents that are
# maintained by hand after the first run (the root README carries the project index).
function Write-DocOnce([string]$rel, [string]$content) {
  $path = Join-Path $root $rel
  if (Test-Path $path) { Write-Host "  kept    $rel (exists, hand-maintained)"; return }
  Write-Doc $rel $content
}

# ---------------------------------------------------------------- workspace root
Write-DocOnce "README.md" @'
# Workspace Root

Container holding all projects, grouped by type. Each project is a self-contained
workspace: open its folder in Zed and Claude scopes context to it via CLAUDE.md.

    <root>/
    |-- workshop/   Generic repo: templates, skills, tooling (its own git repo)
    |   |-- _template-software-project/   Copy to start a software project
    |   |-- _template-knowledge-project/  Copy to start a writing project
    |   |-- skills/
    |   `-- setup.ps1
    |-- apps/       Software projects (each its own git repo)
    |-- knowledge/  Knowledge / writing projects (each its own git repo)
    `-- README.md

## Global principles
- Working language is English.
- The workspace root is NOT a git repo - it is only a container.
- workshop/ is one git repo (generic, reusable assets).
- Every project under apps/ or knowledge/ is its own git repo.
- Every project has a CLAUDE.md.

## Start a new software project
1. Copy workshop/_template-software-project/ to apps/<name>/.
2. Fill in CLAUDE.md and README.md.
3. cd apps/<name>; git init; commit; create the GitHub repo; push.

## Start a new writing project
1. Copy workshop/_template-knowledge-project/ to knowledge/<name>/.
2. Fill in CLAUDE.md and README.md.
3. cd knowledge/<name>; git init; commit; create the GitHub repo; push.

## Project index
| Project | Type | Status | Notes |
|---------|------|--------|-------|
| (none yet) | | | |
'@

Write-Doc "workshop\README.md" @'
# workshop - the generic repo

One git repo holding the reusable, generic assets of the workspace:

- _template-software-project/   copy-source for software projects (V-model lifecycle)
- _template-knowledge-project/  copy-source for writing projects (phase-based)
- skills/                       generic, reusable skills
- setup.ps1                     authoritative, idempotent workspace bootstrap

Templates are copy-sources: copy one out to apps/<name>/ or knowledge/<name>/,
then run `git init` in the copy (do NOT copy this repo`s .git).
'@

# Hand-maintained: this README carries the skill index, which grows as skills are added.
Write-DocOnce "workshop\skills\README.md" @'
# skills
Generic, reusable skills and tooling shared across projects.
One skill per subfolder; document its purpose and usage in the subfolder`s README.

Agent-neutral by design: any agent working in this workspace can be pointed at them. For a
skill you want an agent to load automatically, add a thin pointer under that agent`s own
skill location (for Claude Code: `.claude/skills/<name>/SKILL.md`) rather than duplicating
the content here.

Keep an index table here: one row per skill, with "use when" rather than a description.
'@

# Thin pointers so Claude Code auto-discovers the skills. The workspace root is not a git repo, so
# these would otherwise be unversioned - generating them here keeps them reproducible from the
# versioned workshop repo. Write-DocOnce: the seed is minimal, the maintained summaries stay.
# The 13 pointers are generated below from $skills - never add a pointer by hand here.
$skills = @(
  @('decision-research',           'Use when an open question needs facts before the owner can decide (sources, prices, rate limits, licences, corpus sizes), when a second research pass over the same ground is needed, or when a cost/feasibility claim should be checked rather than believed.'),
  @('review-gates',                'Use when preparing or running a phase review gate, tracking review findings, setting a gate verdict, or closing an open question through a decision record (DEC/ADR).'),
  @('testable-requirements',       'Use when writing or reviewing acceptance criteria - especially when one says "appropriate", "sufficient", "relevant", "fast", "measurably" or names no number at all.'),
  @('consistency-sweep',           'Use before a review gate, after incorporating review findings, or whenever two agents worked the same material - to find defects between documents rather than inside them.'),
  @('architecture-design',         'Use when decomposing a concept into submodules with interface contracts (SUB-###/IF-###), allocating requirements, or producing the machine-readable allocation table for the architecture phase.'),
  @('autonomous-pipelines',        'Use when a workload runs longer than ~15 minutes, the owner''s machine must not stay on, or a job must survive disconnects and be auditable afterwards.'),
  @('decision-meeting',            'Use when several owner decisions are pending in different documents, work chats escalate options that wait weeks for a pick, or the owner should decide in one sitting instead of being drip-fed.'),
  @('module-specification',        'Use when the SUB-###/IF-### registers and the allocation table exist and each submodule needs data models, algorithms and test cases before code.'),
  @('module-implementation',       'Use when the specs and the TC register exist and the submodules need code plus executable tests, or when an "implementation" bypasses the IF-### contract seams.'),
  @('integration-testing',         'Use when phase 06 (or its equivalent) has produced individually tested modules and the assembled system must now be proven: every IF crossed by a real integration test, e2e flows, deployment shape in CI.'),
  @('system-validation',           'Use when the system is integrated and the last V-model phase must validate it against the original requirements, incl. the honest deferral register for what cannot be executed yet.'),
  @('contract-evolution',          'Use when a shipped IF-### contract needs new observable behavior and the question is "extend or break?" - the additive-only pattern, drift guards, bit-identical default.'),
  @('versioned-enrichment-passes', 'Use when a derived field on every (or a large subset of) current store items must be re-computed from external evidence - versioned guid suffixes, idempotency gates, audits.'),
  @('box-evidence-drivers',        'Use when an owner-visible UI change must land on the box and be proven with scripted, measurable evidence (headless viewports, BEFORE/AFTER), never asserted.')
)
foreach ($s in $skills) {
  $body = @"
---
name: $($s[0])
description: $($s[1])
---

# $($s[0])

Playbook: ``workshop/skills/$($s[0])/README.md`` - read it before using the skill.
"@
  Write-DocOnce ".claude\skills\$($s[0])\SKILL.md" $body
}

# --------------------------------------------------- software-project template
Write-Doc "$sw\.gitignore" @'
# OS
.DS_Store
Thumbs.db
desktop.ini

# Editor / IDE
.idea/
.vscode/
*.swp

# Environments / secrets
.env
.env.*
!.env.example

# Dependencies / build output
node_modules/
dist/
build/
out/
target/
bin/
obj/
__pycache__/
*.pyc
.venv/
venv/
.venv-*/

# Tool caches
.pytest_cache/
.ruff_cache/
.mypy_cache/

# Local data directories
.pgdata*/
pgdata-*/

# Logs / temp
*.log
*.tmp
'@

Write-Doc "$sw\CLAUDE.md" @'
# Project: <NAME>

> Copy this template to apps/<project-name>/, then fill in the sections below.

## What this is
<One paragraph: app / web / combination, target users, purpose.>

## Working method - V-model lifecycle
Left branch top-down (decomposition), right branch bottom-up (verification):

    01 Requirements ----------------------------->  08 System Validation
       02 Solution Concept
          03 Validation Concept -----------------> (defines 08 tests)
             04 Architecture ------------------->  07 Integration & Test
                05 Module Specification -------->  06 Module Design & Test

## Rules
- Stable IDs: REQ-###, ARC-###, SUB-###, IF-###, TC-###, RISK-###, DEC-###, OQ-###.
- Traceability is mandatory - update TRACEABILITY.md on every change.
- Log every change in CHANGELOG.md with reason.
- Record structural decisions in DECISIONS.md (ADR).
- Track open questions in OPEN-QUESTIONS.md - never leave one without a phase or release
  that must answer it.
- Schedule work in RELEASES.md by referencing REQ IDs, never by restating requirement text.
- Do not close a phase until its review gate passes (ORCHESTRATION.md).
- Record reviews in reviews/.

## Project-specific instructions for Claude
<Coding conventions, tech stack, constraints.>

## Method support (workshop skills)
Roles (who does what): see workshop/agent-roles.md - five roles across all phases;
one editor per file, reviewer != author. Skills (how): per phase, distilled from
practice - a skill is written *after* its phase has been lived, never before.

| Phase | Skill (workshop/skills/) | Status |
|-------|--------------------------|--------|
| 01 Requirements | testable-requirements | exists |
| 02 Solution Concept | decision-research (+ closure-proposal pattern in review-gates) | exists |
| every gate | review-gates | exists |
| cross-cutting | consistency-sweep | exists |
| 03 Validation Concept | - | distill after the phase |
| 04 Architecture | architecture-design | exists |
| 05-08 | - | distill after the phase |
'@

Write-Doc "$sw\ORCHESTRATION.md" @'
# Orchestration - Activity & Gate Board

Living control center. A phase may only be marked done after its gate passes.
Status: todo | in-progress | in-review | done | blocked

| # | Phase | Status | Review gate | Gate result |
|---|-------|--------|-------------|-------------|
| 01 | Requirements | todo | Requirements Review | - |
| 02 | Solution Concept | todo | Concept Review | - |
| 03 | Validation Concept & Tests | todo | Validation Review | - |
| 04 | Architecture | todo | Architecture Review | - |
| 05 | Module Specification & Test-Case Design | todo | Spec Review | - |
| 06 | Module Design & Module Test | todo | Code/Test Review | - |
| 07 | Integration & Integration Test | todo | Integration Review | - |
| 08 | System Validation | todo | Validation Sign-off | - |

## How to run it
1. Pick the lowest-numbered phase not done.
2. in-progress -> produce artifacts.
3. in-review -> run the gate -> record in reviews/YYYY-MM-DD-<gate>.md.
4. pass -> done; fail -> blocked/in-progress with actions.
5. Update CHANGELOG.md and TRACEABILITY.md as you go.

## Gate exit criteria
- Requirements Review: complete, unambiguous, testable, owned; traceability seeded.
- Concept Review: chosen solution justified in DECISIONS.md; alternatives weighed.
- Validation Review: each top-level requirement mapped to >=1 validation test.
- Architecture Review: submodules + interfaces + sub-requirements; every req allocated.
- Spec Review: each submodule specified; each sub-req has >=1 TC-###.
- Code/Test Review: implemented, module tests pass, reviewed.
- Integration Review: integrated; interface/integration tests pass.
- Validation Sign-off: all validation tests executed; results recorded; opens triaged.
'@

Write-Doc "$sw\CHANGELOG.md" @'
# Change Log

Every change logged with its reason. Newest first.

    ## [CHG-###] YYYY-MM-DD - <title>
    - Reason: why the change was needed
    - Change: what was changed
    - Affected artifacts: REQ-###, ARC-###, TC-### ...
    - Impact: what else was updated
    - By: <author>

---

## [CHG-000] YYYY-MM-DD - Project initialized from template
- Reason: start of project
- Change: created V-model workspace from _template-software-project
- Affected artifacts: all (initial)
- By: <author>
'@

Write-Doc "$sw\DECISIONS.md" @'
# Decision Records (ADR)

Structural decisions and why - separate from routine changes. Newest first.

    ## [DEC-###] YYYY-MM-DD - <title>
    - Status: proposed | accepted | superseded by DEC-###
    - Context: the problem forcing a choice
    - Options considered: A, B, C (trade-offs)
    - Decision: what was chosen
    - Consequences: implications, follow-ups, risks (link RISK-###)

---

## [DEC-000] YYYY-MM-DD - Adopt V-model lifecycle
- Status: accepted
- Context: need a rigorous, traceable development process
- Options considered: ad-hoc; agile-only; V-model with review gates
- Decision: V-model with review gates and full traceability
- Consequences: phase discipline; upfront specification effort
'@

Write-Doc "$sw\TRACEABILITY.md" @'
# Traceability Matrix

Links each requirement through the whole V so nothing is unbuilt or unverified.

| REQ | Solution | Architecture (ARC/IF) | Submodule (SUB) | Test case (TC) | Validation test | Status |
|-----|----------|-----------------------|-----------------|----------------|-----------------|--------|
| REQ-001 | | | | | | open |

## Coverage checks (fill during reviews)
- Requirements with no allocated submodule:
- Requirements with no test case:
- Test cases with no parent requirement (orphans):
- Interfaces (IF-###) with no integration test:
'@

Write-Doc "$sw\RISKS.md" @'
# Risk Register

| RISK | Description | Likelihood (L/M/H) | Impact (L/M/H) | Mitigation | Owner | Status |
|------|-------------|--------------------|----------------|------------|-------|--------|
| RISK-001 | | | | | | open |
'@

Write-Doc "$sw\GLOSSARY.md" @'
# Glossary

| Term | Definition |
|------|------------|
| | |
'@

Write-Doc "$sw\OPEN-QUESTIONS.md" @'
# Open Questions Register

Cross-cutting register of everything not yet decided - next to RISKS.md and DECISIONS.md,
because open questions rarely stay inside one phase.

**Rule: no open question without a place where it gets answered.** "Resolve by" names the
phase or release; a question may stay open at a gate, but never unassigned.
Answered questions stay in the table with their answer - they are not deleted.

Status: `open` | `resolved`. Mark the critical path: what blocks the next release.

| ID | Question | Resolve by | Affects | Status |
|----|----------|-----------|---------|--------|
| OQ-001 | | | | open |

## Answers to the resolved questions
<One paragraph per resolved question: the answer, its date, the DEC-### if there is one,
and what follows from it.>

## Critical path
<Which questions block the next release.>
'@

Write-Doc "$sw\RELEASES.md" @'
# Release Plan & Backlog

Which requirement lands in which increment.

**Format rule:** entries reference REQ-### and never restate the requirement text. The
requirement is the single source of truth; this file only decides *when*. That way the two
cannot drift apart. Releases and backlog live in one file on purpose - a separate backlog
would be a third overlapping list next to the priority column and the scope note.

**No dates** until effort estimates exist. Order only.

Status: `planned` | `in progress` | `done`

## R0 - Walking skeleton (internal)
<The thinnest vertical slice that proves the riskiest part. Which REQ-### does it touch,
and what is the exit criterion?>

## R1 - MVP
<All MUST requirements, plus the SHOULDs that cannot wait - each with a reason why it
cannot. Which open questions block this release?>

## R2 ...
<Further increments.>

## Backlog (not scheduled)
| REQ | Item | Note |
|-----|------|------|
| | | |

## Not planned (deliberately)
<Things decided against, with the reason - so they are not rediscovered every few months.>
'@

Write-Doc "$sw\README.md" @'
# <PROJECT NAME>

<Short description.>

## Structure (V-model)
| Folder | Phase | Produces |
|--------|-------|----------|
| 01-requirements/ | Requirements | REQ-### needs, constraints, acceptance |
| 02-solution-concept/ | Solution Concept | evaluated approaches, chosen concept |
| 03-validation-concept/ | Validation Concept & Tests | strategy + validation tests |
| 04-architecture/ | Architecture | submodules, interfaces IF-###, sub-reqs |
| 05-module-specification/ | Module Spec & Test-Case Design | SUB-### + TC-### |
| 06-module-design-and-test/ | Module Design & Test | code + module tests |
| 07-integration/ | Integration & Integration Test | integrated build + tests |
| 08-system-validation/ | System Validation | validation results vs. requirements |
| reviews/ | cross-cutting | review records per gate |
| src/ | | source code |

## Control files
ORCHESTRATION.md (start here), TRACEABILITY.md, CHANGELOG.md, DECISIONS.md,
RISKS.md, OPEN-QUESTIONS.md, RELEASES.md, GLOSSARY.md, CLAUDE.md.
'@

Write-Doc "$sw\01-requirements\README.md" @'
# 01 - Requirements (Anforderungserstellung)
Goal: capture what the system must do and its constraints.
Outputs: REQ-###, each unambiguous, testable, owned; acceptance criteria.
Verifies (right branch): 08 - System Validation.
Guidance: one requirement = one testable statement; classify functional /
non-functional; seed TRACEABILITY.md.
Gate: Requirements Review -> record in ../reviews/.
'@

Write-Doc "$sw\02-solution-concept\README.md" @'
# 02 - Solution Concept (Loesungskonzepte)
Goal: develop and compare candidate approaches; choose one.
Inputs: 01-requirements. Outputs: evaluated options + chosen concept.
Record the choice + rejected alternatives in ../DECISIONS.md.
Gate: Concept Review -> record in ../reviews/.
'@

Write-Doc "$sw\03-validation-concept\README.md" @'
# 03 - Validation Concept & Tests (Validierungskonzept)
Goal: define HOW the system is validated vs. requirements; specify top-level
validation tests up front (executed in phase 08).
Inputs: 01, 02. Outputs: validation strategy + tests mapped to REQ-###.
Gate: Validation Review -> record in ../reviews/.
'@

Write-Doc "$sw\04-architecture\README.md" @'
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
'@

Write-Doc "$sw\05-module-specification\README.md" @'
# 05 - Module Specification & Test-Case Design
Goal: fully specify each submodule and design its test cases BEFORE code.
Inputs: 04. Outputs: SUB-### specs; TC-### covering each sub-requirement.
Verifies (right branch): 06 - Module Test.
Gate: Spec Review -> record in ../reviews/.
'@

Write-Doc "$sw\06-module-design-and-test\README.md" @'
# 06 - Module Design & Module Test
Goal: implement each submodule and prove it against its TC-### cases.
Inputs: 05. Source in ../src/. Outputs: submodules + passing module tests.
Gate: Code/Test Review -> log changes in ../CHANGELOG.md, record in ../reviews/.
'@

Write-Doc "$sw\07-integration\README.md" @'
# 07 - Integration & Integration Test
Goal: integrate submodules; verify interfaces and interactions.
Inputs: 06, interfaces IF-### from 04. Outputs: integrated build + test results.
Gate: Integration Review -> record in ../reviews/.
'@

Write-Doc "$sw\08-system-validation\README.md" @'
# 08 - System Validation (Gesamtvalidierung)
Goal: validate the integrated system vs. original requirements using phase-03 tests.
Inputs: 03 (tests), 07 (build). Outputs: results per REQ-###; sign-off.
Closes the V against phase 01.
Gate: Validation Sign-off -> record in ../reviews/.
'@

Write-Doc "$sw\reviews\README.md" @'
# Reviews
One record per gate. File: YYYY-MM-DD-<gate>.md.

    # Review: <gate name>
    - Date / Phase / Participants
    - Artifacts reviewed: REQ-###, ARC-### ...
    - Checklist result (per exit criterion: pass/fail)
    - Findings / actions: ID, description, owner, due
    - Result: PASS | PASS-WITH-ACTIONS | FAIL
'@

Write-Doc "$sw\src\README.md" @'
# src
Source code. Mirror the submodules (SUB-###) from ../04-architecture.
'@

# --------------------------------------------------- knowledge-project template
Write-Doc "$kn\.gitignore" @'
# OS
.DS_Store
Thumbs.db
desktop.ini

# Editor / IDE
.idea/
.vscode/
*.swp

# Build / export artifacts
/export/
/build/
*.tmp
~$*
'@

Write-Doc "$kn\CLAUDE.md" @'
# Writing Project: <TITLE>

> Copy this template to knowledge/<project-name>/, then fill in the sections below.

## What this is
<One paragraph: kind of book (e.g. Sachbuch), topic, target readers, core message.>

## Working method - phase-based lifecycle
    01 Concept -> 02 Research -> 03 Outline -> 04 Manuscript
       -> 05 Revision -> 06 Editing -> 07 Production
The manuscript itself lives in manuscript/ (one file per chapter).

## Rules
- Stable IDs: CH-## (chapter), SEC-### (section), SRC-### (source), DEC-###.
- Every claim that needs backing cites a SRC-### from 02-research.
- Log every substantive change in CHANGELOG.md with reason.
- Record structural decisions (scope, structure, voice) in DECISIONS.md.
- Do not advance a phase until its review gate passes (ORCHESTRATION.md).
- Record reviews in reviews/.

## Project-specific instructions for Claude
<Voice & style, language, audience level, formatting conventions.>
'@

Write-Doc "$kn\ORCHESTRATION.md" @'
# Orchestration - Phase & Gate Board

Living control center. A phase may only be marked done after its gate passes.
Status: todo | in-progress | in-review | done | blocked

| # | Phase | Status | Review gate | Gate result |
|---|-------|--------|-------------|-------------|
| 01 | Concept & Expose | todo | Concept Review | - |
| 02 | Research | todo | Source Review | - |
| 03 | Outline | todo | Structure Review | - |
| 04 | Manuscript (draft) | todo | Draft Review | - |
| 05 | Revision | todo | Content Review | - |
| 06 | Editing & Proofreading | todo | Language Review | - |
| 07 | Production | todo | Release Sign-off | - |

## Gate exit criteria
- Concept Review: topic, audience, core message, scope and unique angle are clear.
- Source Review: claims are backed; sources (SRC-###) captured and credible.
- Structure Review: chapter/section outline complete and logically ordered.
- Draft Review: every planned chapter has a complete first draft.
- Content Review: arguments coherent, gaps closed, structure holds end to end.
- Language Review: grammar, style and consistency checked; formatting uniform.
- Release Sign-off: final export produced; metadata and front/back matter complete.
'@

Write-Doc "$kn\CHANGELOG.md" @'
# Change Log

Every substantive change logged with its reason. Newest first.

    ## [CHG-###] YYYY-MM-DD - <title>
    - Reason: why
    - Change: what
    - Affected: CH-##, SEC-###, SRC-### ...
    - By: <author>

---

## [CHG-000] YYYY-MM-DD - Project initialized from template
- Reason: start of project
- Change: created writing workspace from _template-knowledge-project
- By: <author>
'@

Write-Doc "$kn\DECISIONS.md" @'
# Decision Records

Structural decisions (scope, structure, voice, audience) and why. Newest first.

    ## [DEC-###] YYYY-MM-DD - <title>
    - Status: proposed | accepted | superseded by DEC-###
    - Context: what forced the choice
    - Options considered: A, B, C
    - Decision: what was chosen
    - Consequences: implications, follow-ups

---

## [DEC-000] YYYY-MM-DD - Adopt phase-based writing lifecycle
- Status: accepted
- Context: need a structured, reviewable path from idea to finished book
- Decision: 01 Concept .. 07 Production with review gates
- Consequences: upfront concept/research discipline before drafting
'@

Write-Doc "$kn\GLOSSARY.md" @'
# Glossary

| Term | Definition |
|------|------------|
| | |
'@

Write-Doc "$kn\README.md" @'
# <BOOK TITLE>

<Short description: what the book is about and for whom.>

## Structure (phase-based)
| Folder | Phase | Produces |
|--------|-------|----------|
| 01-concept/ | Concept & Expose | topic, audience, core message, scope, angle |
| 02-research/ | Research | sources SRC-###, notes, evidence |
| 03-outline/ | Outline | chapter/section structure (CH-##, SEC-###) |
| 04-manuscript/ | Manuscript | drafting notes; text goes in ../manuscript/ |
| 05-revision/ | Revision | content/structure rework |
| 06-editing/ | Editing & Proofreading | language, style, consistency |
| 07-production/ | Production | typesetting, export, release |
| reviews/ | cross-cutting | review records per gate |
| manuscript/ | | the actual book text, one file per chapter |

## Control files
ORCHESTRATION.md (start here), CHANGELOG.md, DECISIONS.md, GLOSSARY.md, CLAUDE.md.
'@

Write-Doc "$kn\01-concept\README.md" @'
# 01 - Concept & Expose
Goal: define the book. Topic, target readers, core message, scope, unique angle.
Output: a short expose. Gate: Concept Review -> record in ../reviews/.
'@

Write-Doc "$kn\02-research\README.md" @'
# 02 - Research
Goal: gather and vet material. Capture each source as SRC-### with a full reference.
Output: source list + notes. Gate: Source Review -> record in ../reviews/.
'@

Write-Doc "$kn\03-outline\README.md" @'
# 03 - Outline
Goal: structure the book into chapters (CH-##) and sections (SEC-###).
Output: complete, logically ordered outline. Gate: Structure Review.
'@

Write-Doc "$kn\04-manuscript\README.md" @'
# 04 - Manuscript (draft)
Goal: write the first full draft. Text lives in ../manuscript/ (one file per chapter,
e.g. CH-01.md). This folder holds drafting notes and per-chapter status.
Gate: Draft Review -> record in ../reviews/.
'@

Write-Doc "$kn\05-revision\README.md" @'
# 05 - Revision
Goal: rework content and structure - coherence, gaps, argument flow.
Gate: Content Review -> record in ../reviews/.
'@

Write-Doc "$kn\06-editing\README.md" @'
# 06 - Editing & Proofreading
Goal: language pass - grammar, style, consistency, formatting.
Gate: Language Review -> record in ../reviews/.
'@

Write-Doc "$kn\07-production\README.md" @'
# 07 - Production
Goal: produce the final artifact - typesetting/export, metadata, front/back matter.
Output goes to ./export or /export. Gate: Release Sign-off -> record in ../reviews/.
'@

Write-Doc "$kn\reviews\README.md" @'
# Reviews
One record per gate. File: YYYY-MM-DD-<gate>.md.

    # Review: <gate name>
    - Date / Phase / Participants
    - Reviewed: CH-##, SEC-###, SRC-### ...
    - Checklist result (per exit criterion: pass/fail)
    - Findings / actions: description, owner, due
    - Result: PASS | PASS-WITH-ACTIONS | FAIL
'@

Write-Doc "$kn\manuscript\README.md" @'
# manuscript
The actual book text. One file per chapter (CH-01.md, CH-02.md, ...),
following the outline in ../03-outline.
'@

Write-Host ""
Write-Host "Done. Option-A skeleton created at $root"
