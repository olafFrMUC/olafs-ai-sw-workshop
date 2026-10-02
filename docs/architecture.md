# Architecture of the workshop

What the moving parts are, how they interact - and **why** each one exists.
Every mechanism below was paid for by a real incident; the rationale is
part of the design, not decoration.

## 1. The three-layer layout

```
<workspace root>/              container, NOT a git repo (agents read AGENTS.md here)
  workshop/                    ONE git repo: the reusable way of working
    skills/                    method playbooks (distilled from practice)
    _template-*/               project skeletons
    handoff-*.md, agent-roles.md, setup.ps1
  apps/<project>/              one git repo PER software project
  knowledge/<project>/         one git repo PER writing project
```

**Why:** the method layer must outlive and out-travel any single project.
Keeping it in its own repo means projects upgrade their way of working by
pulling, and the container root is where workspace-wide rules (AGENTS.md)
live without being versioned into every project.

## 2. The chat topology (who talks to whom)

```
                 OWNER (all content decisions, gate verdicts, commit approval)
                  |  opens windows, relays handoffs to external models
        +---------+-----------+----------------+
        |                     |                |
  STEERING CHAT         METHODS CHAT      WORK CHATS (one per unit,
  (Coordinator)         (way of working)  or sub-agents of the
  plans/dispatches      roles, skills,    steering chat)
  units, enforces       handoffs, studies
  the two rules
```

**Why three kinds:** proven failure modes. Work chats that steer drift
into decisions that are not theirs; a coordinator that also maintains the
method starts editing files mid-incident; and without a methods chat the
way of working rots (nobody owns it). The coordinator **never decides
content**; the methods chat **never runs the project**; the owner keeps
what cannot be delegated: content verdicts, gate verdicts, commit approval.

**Sub-agents are synchronous** (hard-won knowledge): they block the parent
chat while running and do nothing between follow-ups. Therefore long work
runs **detached** (scripts/pipelines with a status file + watchdog), and
agents are only dispatched for bounded, judgement-shaped units with an
abort condition.

## 3. The register model (the project's nervous system)

Projects keep their truth in **machine-readable registers**:

| Register | IDs | Answers |
|---|---|---|
| `01-requirements/requirements.md` | REQ-### | what must be true |
| `DECISIONS.md` | DEC-### | what was chosen, why, what it supersedes |
| `CHANGELOG.md` | CHG-### | what changed, when, why |
| `OPEN-QUESTIONS.md` | OQ-### | what is still open, resolved by which DEC |
| `RISKS.md` | RISK-### | what can hurt, mitigation |
| `04-architecture/architecture.md` | SUB-###, IF-### | where things live, contracts |
| `05-module-specification/test-cases.md` | TC-### | how it is proven |
| `RELEASES.md` | R0/R1/... | what ships when |

From these, `tools/build_index.py` **generates** (never hand-edited):

- `INDEX.md` - one line per entity (the token-cheap navigation surface)
- `TRACEABILITY.md` - REQ <-> test/trace coverage
- `graph.json` - the typed relation graph (`decides`, `affects`,
  `supersedes`, `closes`, `covers`, `allocated_to`, `tested_by`,
  `in_release`, `links`)

**Why generated, not maintained:** small models (and tired humans) fail at
structured state maintenance mostly by premature overwrite. State that can
be derived must be derived; prose state is reserved for what cannot.

**Why the graph matters:** multi-hop questions ("what depends on X?",
"what did this decision supersede?", "which requirement has no test?")
are one query (`tools/query_graph.py impact|neighbors|uncovered|...`)
instead of an afternoon of grepping. The **HTML viewer**
(`graph.bat` -> self-contained `graph.html`: search, side panel with the
register text, edge-type filters) makes the same graph readable for
humans. A young project can ignore the graph; it grows valuable exactly
when the registers do - and since the tooling ships in the template,
there is nothing to retrofit.

## 4. The unit lifecycle (how work actually flows)

```
idea -> Coordinator writes a DATED HANDOFF (task, done criterion,
        ABORT CONDITION, estimate incl. model class, write-scope, roles)
      -> owner go -> author executes (work chat or sub-agent)
      -> reviewer (!= author) checks AGAINST FILES
      -> fixes -> verification -> registrar anchors (CHG, STATE, INDEX)
      -> commit proposal -> OWNER approves -> push -> CI glance
```

Two rules hold at every step: **one editor per file at a time**;
**reviewer != author**. And the evidence rule: claims only with
verifiable evidence - "not verifiable" is a legitimate answer.

**Why the abort condition is mandatory:** a sub-agent with a hard
verification criterion ("verify with 3 named items") and no exit strategy
once retried all night and burned a full token budget. Empty results are
DATA, not proof your query is wrong. Bounded attempts, then STOP and
report the gap - a reported gap is a completed unit with a finding.

## 5. Gates and the decision loop

- **Phase gates** (V-model, phases 01-08) and **release gates** (R0, R1,
  ...): two perspectives - "is this the right thing?" (owner) and "is it
  unambiguous, testable, traceable?" (facilitator). Verdicts:
  PASS / PASS-WITH-ACTIONS (the honest default; actions get IDs and a
  home) / FAIL. Gate records are files in `reviews/`, never chat lines.
- **Decision meetings** instead of drip-feeding: a standing agenda
  (draft/ready/decided/processed), items management-ready (situation,
  constraints, options with one-line risks, recommendation), the owner
  answers briefly, the agent writes the DEC.
- **Decision friction:** if a DEC blocks, over-costs or proves
  unfavourable, any role stops the affected unit and reports with
  evidence + options. A revision is a NEW DEC that supersedes the old
  one - history is never silently corrected (and the graph shows the
  supersession chain).

## 6. Model routing (cost architecture)

| Class | Used for | Set by |
|---|---|---|
| strong | truly critical judgements only | the human opening the window |
| standard | coordinator, PM, builds with mechanical done criteria | same |
| review/research (external) | independent reviews, research | owner relay (handoff on disk) |
| mechanical | registrar, formatting, log/index processing | same |

Agents cannot switch models; the handoff names the class. A gate review
on too weak a model costs more than it saves; routine work on the
strongest model is the same waste in the other direction (measured:
> $100 in two days before this rule existed).

## 7. The ops layer (when work outlives the chat)

`skills/autonomous-pipelines/`: status.json-as-state, detached execution,
GUARD halts with budget caps, receipts as the done definition, a watchdog
script instead of any polling agent. The owner's machine may go off; the
work continues, auditable afterwards.
