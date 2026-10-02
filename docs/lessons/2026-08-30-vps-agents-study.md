# Study: autonomous LLM agents on the Scaleway VPS

2026-08-30, methods chat (owner request, optimisation requirements 1f + 2).
Status: **UPDATED 2026-09-12** - option A is meanwhile PROVEN IN PRACTICE
(the tier-2 pre-fill and the final reindex ran as autonomous pipelines on
the box, coordinator-driven via SSH; method distilled as
`workshop/skills/autonomous-pipelines/`). Remaining open piece: headless
CLI AGENTS on the box (not just scripted pipelines) - pilot design in
section 10.
**UPDATED 2026-09-27 (section 11):** the nanny-loop problem recurred
despite the live watchdog - root cause identified as a discipline gap
(sub-agents are synchronous; waiting tasks must never be dispatched),
anchored in `agent-roles.md` + `handoff-coordinator.md`. NEW FACT: a
second box exists ("lab" for experiments) - option B is no longer a
purchase decision, it is an allocation decision.

**Goal:** agents that work independently of the owner's machine - long tasks
without user interaction, no requirement that the local computer stays on.

## 1. What already exists (and is proven)

- **The box:** `<box-instance-name>` (Scaleway DEV1-L, 4 vCPU/8 GB, 40 GB,
  Ubuntu 26.04, PAR 2), flexible IPv4 `<box-ip>`, SSH-only (verified:
  only port 22). Cost EUR 0.05304/h ~ EUR 38.7/month, cap EUR 40/month
  (owner addendum 2026-08-26). The box STAYS ON. It runs the product stack
  (compose: db/backend/geo/frontend) and, right now, the phase-08
  measurements (L4 suites, detached).
- **Proven pattern (phase 08):** long measurements run detached on the box
  (nohup/tmux + `progress.log`), results come back per scp, a local shutdown
  mid-unit cost nothing - twice. Non-interactive work on the box is not the
  question; **agent-driven** work is.
- **LLM access:** Scaleway Generative APIs (OpenAI-compatible endpoint, EU,
  per-token) already used for the R0 extraction (mistral-small-3.2-24b;
  EUR 1.23/1,000 items). External API keys (Anthropic, OpenAI) possible from
  the box as well.

## 2. Options

### Option A - CLI agent headless on the existing box
An agentic CLI (Claude Code headless, Aider, OpenCode or similar) in
tmux/systemd on `<box-instance-name>`, driven per SSH kickoff; models via
Scaleway Generative APIs or external keys.
- Pros: no new infrastructure; box is already paid; SSH-only exposure stays;
  detached pattern proven.
- Cons: **resource contention with phase-08 measurements** (timing-sensitive!
  an agent compiling/testing next to an L4 suite contaminates p95 numbers);
  one failure domain.
- **UPDATE 2026-09-12: PROVEN for scripted pipelines** - the tier-2 pre-fill
  (43 stages, GUARD halts, resume) and the final reindex (18,265 embeddings)
  ran exactly this way (detached, status.json, coordinator polls per SSH).
  The remaining unproven half is the LLM-agent variant (pilot, section 10).

### Option B - dedicated small instance for agents
A second, small instance (e.g. DEV1-S, ~EUR 8-10/month, ~ - verify current
pricing) solely for agent workloads.
- Pros: full isolation from measurements; independent lifecycle (can be
  stopped/deleted without touching the product box); clean budget line.
- Cons: extra monthly cost; second box to harden and watch.

### Option C - GitHub Actions as the agent runner
Agent CLIs run as CI jobs (workflow_dispatch / schedule), e.g. a "unit
runner" workflow that checks out the repo, runs the agent on a scoped task,
pushes a branch, opens a PR.
- Pros: **zero always-on cost** (free tier ~2,000 CI minutes/month for
  private repos, Linux); runs without any box; logs/artifacts built in;
  the project's CI discipline extends naturally; no contention with the VPS.
- Cons: per-run time limits (hours, not days); secrets must live in GitHub
  secrets; not suited for work that needs the VPS (measurements against the
  product stack, large seeds).

### Option D - Zed on the VPS via VNC (rejected)
Zed is a GUI editor without a headless agent mode; a desktop on the server
adds RAM load and attack surface for no benefit over a CLI agent.

## 3. Recommended architecture (A or C, same pattern)

**Git is the exchange medium; the coordinator stays the gate.**

### The runner loop: state-driven, not transcript-driven (SKILL.state)

Where we control the runtime (Options A-C), implement the agent loop after
the SKILL.state pattern (arXiv 2608.26263, review:
`2026-08-30-skillstate-review.md`) instead of a growing chat transcript:

1. The runner keeps a small `state.json` (the unit-state schema: done /
   pending / evidence / blockers / cost).
2. Per step the model gets only: the immutable handoff (`P`), `state.json`
   (`Σ`), and the latest log tail / observation (`O`) - never the transcript.
3. The model returns a state patch + next action; a script validates the
   patch (schema, no key loss) before applying it - malformed patches are
   rolled back and retried, never silently merged.

Effect (paper's numbers): bounded prompt per step, linear instead of
quadratic token cost (65k vs 1.06M at T=100), no context decay on long runs
(e.g. 100k-seed jobs), zero recovery after external state changes.

### Flow
1. The Coordinator briefs the unit (handoff with write-scope, done criterion,
   estimate) and starts the agent: per SSH/tmux on the box (A/B) or per
   `workflow_dispatch` (C).
2. The agent works **on a branch only** (`unit/<slug>`), commits there,
   pushes, opens a PR (or reports back the branch name).
3. Reviewer != author stays: a review agent (or the coordinator's reviewer
   sub-agent) checks the branch **against files**, then the owner gets the
   bundle (PR + report + actual-vs-estimate) at the next natural point.
4. Logging: the agent appends to a run log (progress.log pattern); the
   coordinator records the unit in the WORKLOG as usual.

**Model choice:** routine/mechanical units (registrar work, formatting,
index/log processing) can run on Scaleway Generative API models (cheap, EU);
authoring/review units should use the strongest available model (external
key) - the same model-routing rule as the local cost discipline. Measure
quality per unit type before scaling.

## 4. Guardrails (mandatory for unattended agents)

- **Branch-only**, never direct to main; merge only after review + owner go.
- **Write-scope per task** in the brief; the agent gets only what it needs.
- **Budget caps:** token/EUR ceiling per unit (abort + report when hit);
  monthly VPS ceiling already exists (EUR 40) - CI minutes watched likewise.
- **Secrets:** scoped API keys (least privilege), stored as GitHub secrets or
  env on the box, never in the repo; no owner SSH keys on the agent path.
- **Stop conditions in the brief:** 3x-failure stop, time-box, and the
  phase-08 rule "runtime prognosis > 24 h = proposal, not silent reduction".
- **Exposure rule:** the box stays SSH-only; agents open no ports.
- **Evidence rule:** the agent's closing report lists verifiable artifacts
  (branch, CI run, log files) - never bare claims.
- **No product-box agents during measurement windows** (phase 08 lesson:
  p95 numbers must stay clean).

## 5. Cost estimate (orders of magnitude, ~)

| Item | Cost |
|---|---|
| Option A (existing box) | EUR 0 extra instance (within the EUR 40 cap) + LLM tokens |
| Option B (dedicated small instance) | ~EUR 8-10/month extra + LLM tokens |
| Option C (GitHub Actions) | EUR 0 within the free minutes + LLM tokens |
| LLM tokens per unit | routine unit on Scaleway models: ~EUR 0.1-2; authoring/review unit on a strong model: ~EUR 2-15 (~) |

The phase-08 lesson holds: **tokens >> server**. The decision that matters is
model routing and unit scoping, not the instance size.

## 6. Risks

- **Measurement contamination** (Option A during phase 08) - mitigated by the
  measurement-window rule; after phase 08 the box is mostly idle.
- **Runaway cost/agent** - budget caps + branch-only + review gate.
- **Quality of unattended work** - unchanged review discipline (reviewer !=
  author, claims against files); unattended does not mean unreviewed.
- **Security** - SSH-only exposure, scoped keys, no secrets in repo.

## 7. Recommendation + staging

1. ~~Stage 1 (pilot, now): Option C~~ **SUPERSEDED 2026-09-12:** practice
   chose option A first - autonomous scripted pipelines on the box are
   proven and skilled (`autonomous-pipelines/`). Option C (GitHub Actions)
   stays available for box-independent units, no pilot needed.
2. **Stage 2 (now): the headless CLI-agent pilot** (section 10) - the one
   unproven piece: an LLM agent on the box taking over judgement tasks
   (GUARD triage) instead of only scripted thresholds.
3. **Stage 3 (only if agent load becomes regular): Option B** - a dedicated
   small instance, so the product box never competes with agents.

**When it is worth it:** as soon as >1 unit per week runs unattended
(proven since tier 2), or whenever the owner's machine staying on becomes
the constraint (already true for night runs).

## 8. Open decisions for the owner (meeting candidates)

- M: Pilot via GitHub Actions - **RESOLVED 2026-09-12 (superseded by the
  proven option-A practice).**
- M: API keys on the box / in GitHub secrets - which providers, what budget
  ceiling per month? **Still open - needed for the section-10 pilot.**
- M: After the pilot - stay on C, move to A, or commission B? **Partly
  resolved: A for pipelines. B decision stays deferred until agent load
  is regular.**

## 10. Pilot: headless watcher agent for ingestion pipelines (2026-09-12)

**Status 2026-09-27: BOTH stages LIVE and proven** (watchdog +
`guard_triage.py` on Scaleway mistral-small, go-live verified 2026-09-12;
watchdog start is a mandatory checklist item in `autonomous-pipelines/`
section 7). The pilot answered its question: scripted pipelines + scripted
watchdog + LLM triage-on-GUARD cover the need WITHOUT a general headless
agent. What did NOT hold: the discipline that no agent waits on the box -
see section 11.

**Problem (owner):** during box ingestion runs, a coordinator sub-agent
polls `status.json` and thereby blocks the coordinator chat for hours.

**Pilot idea (two stages, honest about the LLM boundary):**

- **Stage A - watchdog script (no LLM, immediate relief):** a small tmux/
  cron watchdog on the box reads `status.json` every N minutes and appends
  to a `watchlog` ONLY on state changes, GUARD events and completion. The
  coordinator reads the watchlog on demand (one ssh tail) instead of
  polling. Cost ~0; no chat blocked. This covers 90 % of the need - polling
  is mechanics, and mechanics belong in scripts (cost discipline).
- **Stage B - LLM judgement agent (the actual CLI-agent pilot):** on a
  GUARD halt, a headless CLI agent (e.g. Claude Code headless or Aider with
  a Scaleway/Anthropic key) receives (handoff-brief, status.json, last log
  tail) - the SKILL.state triple - and writes a triage note: what happened,
  evidence, 2-3 options with a recommendation. The owner decides at the
  next natural point; the coordinator chat is never blocked.

**Success criteria:** coordinator chat unblocked during a full ingestion
stage; triage notes evidence-based (reviewer spot-check); cost per GUARD
triage < ~EUR 1 (Scaleway model) - compared to an hour of blocked
coordinator chat.

**Guardrails:** read-only on the pipeline workdir; writes only the triage
note; scoped API key on the box (env, not repo); hard time-box per triage.

**Candidate first run:** the tier-3 pre-fill, with stage A from the start
and stage B armed for GUARD events.

## 9. Accessing the box (owner ops note, 2026-08-30)

Answers to the owner's access questions, kept here so they are not lost:

- **SSH is the way.** The box is SSH-only (verified: only port 22 open; key
  `<path-to-your-ssh-key>` on the owner's machine). Scaleway's web
  console (serial) exists as an emergency path.
- **Virtual desktop (VNC/xrdp):** technically installable, **not
  recommended** on a server (RAM load, attack surface, no benefit over SSH).
- **Own applications:** yes - full root, install whatever is needed (that is
  what options A/B in this study build on).
- **Data storage:** yes - the instance disk (40 GB), plus optional Scaleway
  Block Storage or Object Storage (S3-compatible, e.g. for backups of
  seeds/dumps).
- **VPN into the home network (FRITZ!Box 7582):** the FRITZ!Box speaks
  WireGuard (FRITZ!OS >= 7.50 for device connections; LAN-LAN coupling in
  newer firmware). **Simplest robust path: Tailscale** on the box + the home
  devices - no FRITZ!Box configuration, NAT traversal, free tier suffices.
- **Zed on the box:** not sensible (GUI editor, no headless agent mode;
  the owner's workflow is Windows-centric). For autonomous agents use the
  CLI path in this study.

## 11. The nanny-loop recurrence + the second box (2026-09-27, owner)

**What happened (owner report 2026-09-27):** the section-10 problem
RECURRED despite the live watchdog - coordinator sub-agents kept checking
the box "like a nanny" and blocked the coordinator chat for hours; and
the coordinator repeatedly believed sub-agents work in the background
(they do not - impossible in this environment).

**Root cause: a discipline gap, not a tooling gap.** The watchdog covers
the pipeline-watching need; the failures were dispatches of WAITING tasks
to SYNCHRONOUS sub-agents (a sub-agent blocks the parent chat until it
reports; between follow-ups it does nothing). Anchored 2026-09-27 in
`agent-roles.md` ("Sub-agent execution mode": two operational truths) and
`handoff-coordinator.md` (session-registry duty: never dispatch waiting
tasks; kill a nanny sub-agent on sight).

**New fact: a second box exists ("lab" for experiments, owner
2026-09-27).** Option B (dedicated agent instance) changes from a
purchase decision to an ALLOCATION decision. What the lab box already
settles without any new method: experiment isolation (Prism-style
spikes), zero contention with the product box, disposable lifecycle.

**Can agents run ON the box? - the honest answer (method view):**

- **Already running, proven:** scripted pipeline agents with LLM steps
  (extraction/enrichment passes) + the stage-B triage agent
  (SKILL.state triple -> mistral-small via Scaleway API, ~EUR
  0.001-0.003/triage). This IS an agent on the box - narrow, scripted,
  budget-capped.
- **The next step would be a GENERAL headless agent loop** (a CLI agent
  taking open-ended units on the box, option A/B as designed in sections
  2-4: state.json runner loop, branch-only, budget caps, review gate).
  Feasibility is unchanged (SSH box, API keys reachable); the open
  questions are operational: which CLI runner (Claude Code headless /
  Aider / OpenCode - tool-calling quality on the chosen model must be
  proven first, the mechanical-class caution), which model behind it
  (Scaleway API for cost; Gemini API limits under the new subscription
  are UNCLARIFIED; Claude API = the cost signal we just escaped), and
  who reviews its output (reviewer != author holds for machines too).
- **Options for the owner (decision candidates, prepared not decided):**
  - **B1 - lab box as experiment stage only** (status quo + allocation):
    spikes and disposable experiments there, pipelines stay scripted on
    the product box. Zero new method risk. Recommended baseline.
  - **B2 - pilot a general headless agent on the lab box:** one scoped
    unit type (e.g. overnight research/mechanical units), the section-3
    runner loop, branch-only, EUR cap per night, coordinator reviews
    receipts in the morning. This is the real test of "agents on the
    box" beyond the scripted pattern. Cost of the pilot: one unit of
    setup + a capped token budget; risk contained by the lab box being
    disposable.
  - **B3 - defer:** the scripted pattern + owner-relay windows (Kimi/
    Gemini/Claude) already cover the workload; revisit when unit volume
    makes the manual relay the bottleneck (the relay is manual but the
    2026-09-26 Gemini subscription made it cheap).

  The 2026-09-27 incidents strengthen B2's case (human-attended agents
  are the failure point) AND B3's case (the incidents were discipline
  failures now fixed by rule, not by missing infrastructure).
  **OWNER DECISION 2026-09-27: the B-choice is DEFERRED until the
  Prism-spike experiment completes.** Reason: the spike decides whether
  a local ternary model (Bonsai-2-27B class) is viable for
  extraction/check work - if yes, the model economics of B2 change
  completely (a box agent on a local model is nearly token-free, no
  Scaleway/Gemini/Claude API behind the loop). Deciding B2 before the
  spike result would mean answering the model question blind.
