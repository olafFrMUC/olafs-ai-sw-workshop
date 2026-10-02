# Agent roles for this workspace

2026-08-07, owner request. Status: accepted working convention.
Coordinator role added 2026-08-12 (owner decision, steering chat).
Sub-agent execution mode added 2026-08-15 (owner instruction, steering chat).
Product Manager added as the seventh role 2026-09-12 (owner decision, after
the pilot 2026-08-30..09-06: one full feature-request cycle completed, all
seven decision-meeting recommendations adopted).

Roles answer **who is responsible and who may do what**. They are deliberately few and
cut across all phases of the V-model - phases differ in *method* (that is what the
`skills/` are for), not in accountability.

## Why this exists

Three things happened in geo-knowledge-guide phases 01-02 that roles would have
prevented or made cheaper:

1. **Duplicate edit:** two agents applied the same review fix to the same file; the
   concept carried both paragraphs, committed (cross-check finding G-1).
2. **Duplicate research:** a second research pass ran in parallel to an existing one and
   had to be reconciled afterwards as a supplement.
3. **And the positive proof:** when the split was explicit (one agent authors the
   concept, another cross-checks it independently), the review found 19 real issues
   before the gate.

## The seven roles

| Role | Does | Never does |
|---|---|---|
| **Owner** | decides (content verdicts, DEC acceptance, gate verdicts); reviews content in phases 01-02 (mandatory) and may review anything at any time | - |
| **Author / File-Holder** | writes and edits an artifact (concept, proposal, code, register) | - |
| **Reviewer** | checks independently; reports findings with location, why-it-matters, suggested fix | patches files held by someone else |
| **Researcher** | produces verified facts (✓/~/‽ marks), measures loads, prices options | decides; the output is input, never a decision |
| **Registrar** | keeps the registers in sync: regenerates INDEX/TRACEABILITY, CHANGELOG entry, WORKLOG daily + snapshot, correct calendar dates | - |
| **Coordinator (Projektleiter)** | plans and controls: derives next actions from STATE/WORKLOG, prepares handoffs, assigns roles per task and enforces the two rules at assignment, tracks open decision proposals, checks completion reports against done criteria, keeps the decision agenda and prepares + moderates decision meetings (skill:
decision-meeting), keeps `data-architecture.md` (the owner's data-map of the
project files) up to date whenever the way of working changes | decides content (Owner's privilege); edits files in someone else's write-scope |
| **Product Manager** | owns the product view: maintains RELEASES.md, `product/` (PRODUCT.md, ROADMAP.md, FEATURE-REQUESTS.md with the FR-### register); takes up feature requests, evaluates and schedules them as proposals; commissions impact analyses and concept studies (as handoffs to Researcher work chats, never done itself); initiates REQ changes via handoffs (requirements.md stays owner territory); plans feature implementation together with the Coordinator | decides content - release scope, feature priorities and REQ changes are owner decisions, prepared as agenda items; code edits; performs analyses itself |

## The two rules

1. **One editor per file at a time.** The holder of the file edits it; the reviewer
   reports and does not patch. If you already started editing when you learn someone else
   holds the file, say so immediately and name the exact paragraphs you inserted.
2. **Reviewer ≠ Author.** The second pair of eyes must be independent - that independence
   was the lever of both concept cross-checks.

## The evidence rule (owner instruction, 2026-08-30)

Status claims only with **verifiable evidence**: a CI run, command output, a file on
disk, a session state. Label estimates as estimates (with an order of magnitude, `~`),
and treat "not verifiable" as a legitimate answer. Never claim a sub-agent is active -
verify by follow-up in its session. Reviewers check claims **against files, not against
the report** (proven 2026-08-28: a wrong 38/42 total survived in four documents until
the reviewer counted the artifacts). Background: a coordinator misreported durations
and sub-agent activity.

## Model routing (owner instruction, 2026-08-30; cost-adjusted 2026-09-25/26)

Units run in three model classes - named in the handoff's estimate block
(`Model class:`). Agents cannot switch models: **the coordinator recommends
the class, the person opening the chat window sets the model.** Sub-agents
always inherit the parent thread's model - a unit that needs a different
class must run in its own window.

| Class | Used for | Current candidates |
|---|---|---|
| **strong** | Truly critical judgements ONLY: gate-critical passes, complex concept judgement calls | Claude Sonnet 5 (Opus) - **cost warning (owner, 2026-09-25): > $100 in two days on routine strong-class work; Claude is excellent but expensive, so the class is deliberately narrow** |
| **standard** | Coordinator, Product Manager, regular units, **builds with a hard mechanical done criterion (CI-equal)** | Kimi K3 (proven, cheap) |
| **review/research (external)** | Independent reviews, research passes, impact analyses | Gemini 3.1 Pro (proven in 5 term-6 test balloons: caught a real arithmetic error 4 same-window passes missed; U1 review PASS) |
| **mechanical** | Registrar, formatting, log/index processing, dry-runs | Kimi K3 or Claude Haiku; Scaleway Generative API models after the pilot (OpenAI-compatible endpoint - tool-calling quality must be proven first) |

**External models run via the owner relay (term-6 pattern):** Claude/Gemini
windows cannot be spawned by the coordinator as sub-agents - the coordinator
writes the handoff **on disk, paste-ready** (fresh session + on-disk handoff
is the resume pattern), the owner opens the window, pastes the pointer and
relays the result. The manual step is the price of model diversity; keep it
small by keeping handoffs paste-ready.

**Gemini subscription (owner, 2026-09-26):** Google AI Pro - ~EUR 5/month for
the first 3 months (until 2026-12-24), then ~EUR 20/month. Usage so far =
owner-opened **chat windows in the Gemini app** (flat-rate within the app
limits - no per-token cost). **API limits under this subscription: NOT
clarified** (the subscription is app access; the API is a separate product
with its own tiers). Relevant only if Gemini calls should ever be automated
(e.g. guard triage) - the Scaleway API path stays the default for automation.

Caution (SKILL.state finding, 2026-08-30): small models fail at structured
state patches mostly by **premature overwrite** (68 % of failures). The
mechanical class therefore never owns **prose state maintenance** - its state
lives in generated files (build_index) or simple validated JSON schemas.

Cost truth: a gate review on too weak a model costs more than it saves; a
registrar unit on the strongest model is money thrown away - and routine
units on Claude are the same waste in the other direction (2026-09-25).

## Content review by phase (owner instruction, 2026-08-15)

In phases 01-02 the owner's content review is **mandatory**: the fundamental
capabilities of the product are defined there. From phase 03 onward the work is
implementation-oriented; the owner cannot and need not do every content review
personally. Content review is then **delegated to an independent review agent**
(Reviewer != Author holds unchanged), who reports findings with location,
why-it-matters and suggested fix. The owner keeps what cannot be delegated: the
**gate verdict** and the decision on findings. The owner may review any artifact
personally at any time.

## Decision friction

Decisions are made on the information known at the time - they can turn out
unfavourable or wrong (owner instruction, 2026-08-12). **Every role has a reporting
duty**: if a DEC

1. blocks the current task,
2. causes disproportionate effort, or
3. proves unfavourable given new information,

stop the affected unit and report to the steering chat: which DEC, what friction -
with **evidence** (measurement, blocker, new source; not a hunch) - and options
(keep + workaround / revise the DEC / reopen the OQ). The Coordinator collects
friction reports and puts them to the owner with options; the owner decides.

A revision is recorded as a **new DEC that supersedes the old one**. The old DEC
stays in the record with its original reasoning - history is never silently
corrected. Machine-readable (2026-09-13, owner decision): the revising entry
carries a `- Supersedes: DEC-###` relation line directly under its marker
comment (`- Amends:` analogue; the id also stays in the `links:` list) -
`build_index.py` turns it into a graph `supersedes` edge.

## Default assignment per task

Roles are assigned **per task at handoff**, not permanently per agent. When the owner
hands over a task, name who authors and who reviews. Rotating is fine and healthy; an
unstated assignment is not. Exception: the **Coordinator** is a standing role - it lives
in the steering chat, not in a work chat (start prompt: `handoff-coordinator.md`).

Worked example from phase 02: kimi-k3 = Researcher + Author (research, concept,
incorporation), Claude Code = Reviewer (two cross-check rounds) + Registrar for its own
changes. Next phase may flip.

## Mapping to activities

| Activity | Lead role | Second role |
|---|---|---|
| Open-question research | Researcher | Reviewer (verifies the verification marks) |
| Closure proposal / concept | Author | Reviewer (cross-check before the gate) |
| Gate preparation + consolidation | Author in the "Facilitator" hat (author of the review record - a hat of the Author role, not a seventh role) | Phases 01-02: Owner (content pass); phase 03+: review agent (content pass) + Owner (verdict) |
| Incorporating findings | the File-Holder named in the review | Reviewer verifies (status per finding) |
| Register hygiene (INDEX, TRACEABILITY, logs) | Registrar | consistency-sweep as the check |
| Steering / orchestration across units | Coordinator (steering chat) | Owner (decides escalations) |
| Product planning (releases, roadmap, FR register) | Product Manager | Owner (decides scope/priorities); Coordinator (schedules the work units) |

## Sub-agent execution mode

Since 2026-08-14 (owner instruction): the Coordinator starts work units **directly as
sub-agents** from the steering chat instead of asking the owner to open a chat window
per unit. The owner has little time and is only pulled in for decisions and content
reviews.

The mode changes the mechanics, not the accountabilities:

- The **dated handoff remains the binding specification** - the sub-agent receives its
  path and works it exactly; nothing is specified only in chat.
- The two rules apply unchanged (one editor per file, Reviewer ≠ Author); roles are
  named in the handoff as before.
- The sub-agent's completion report goes to the steering chat; the Coordinator checks
  it against the done criteria before marking the handoff done.
- Commit discipline is unchanged: the sub-agent proposes a message, the owner
  approves, nothing is committed without that approval.

**Sub-agents are SYNCHRONOUS - two operational truths (owner, 2026-09-27,
after repeated nanny-loop incidents):**

1. **A sub-agent blocks the parent chat until it reports.** There is no
   background execution in this environment: while a sub-agent session runs,
   the coordinator chat WAITS. Therefore a sub-agent must never contain a
   wait - no sleep loops, no repeated ssh checks on a running box process,
   no "watch the pipeline" tasks. Box work runs **detached on the box**
   (tmux + `pipeline_watchdog.py`, skill `autonomous-pipelines/` section 7);
   the sub-agent's job ends at launch verification (process up, status.json
   writing, watchdog armed), then it reports and CLOSES. Checking progress
   later = one ssh tail of the watchlog, seconds, done by the coordinator
   itself at a natural point - never a waiting agent.
2. **A sub-agent never "works in the background" between follow-ups.**
   Believing one does is a proven misconception (it caused false "unit is
   running" claims). The evidence rule holds: never claim a sub-agent is
   active - verify via follow-up in its session; a session that is not
   actively being followed up does nothing. Work that must outlive a chat
   belongs detached on the box or on disk (handoff), never in an assumed
   background session.

## Note on scope

This convention lives in the workspace root (`../AGENTS.md` links here) and applies to
every project under `apps/` and `knowledge/`. The per-phase methods live in `skills/`;
the phase↔skill map is in each project's CLAUDE.md (generated by `setup.ps1`).
