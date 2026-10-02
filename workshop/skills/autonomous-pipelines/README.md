# Skill: autonomous box pipelines (detached long runs with watchers)

How to run long, unattended data workloads (corpus pre-fills, re-extractions,
reindexes, measurements) on the VPS instead of the owner's machine - safely,
resumably, and with honest cost accounting. Distilled from the T4 LLM pass,
the tier-2 pre-fill (43 stages, GUARD halts), and the final reindex
(18,265 embeddings, 71.8 min) in geo-knowledge-guide (2026-08/09).

**Use when:** a workload runs longer than ~15 minutes; the owner's machine must
not stay on; the job must survive disconnects and be auditable afterwards.

---

## 1. The shape of a well-run pipeline

```
brief (handoff with estimate) -> pre-flight check -> detached run on the box
-> watch via status.json -> GUARD halts on threshold breaches -> owner
decision -> resume -> run record + receipt -> registrar + commit bundle
```

The owner's machine is only needed for: the kickoff SSH command, GUARD
decisions, and the final commit. Everything between happens on the box.

**The status file is the state** (the SKILL.state pattern, see
`workshop/research/2026-08-30-skillstate-review.md`): the pipeline writes a
small `status.json` after every stage (done/pending/evidence/counters/cost).
Anyone - coordinator, owner, a later session - reads THAT file to learn the
truth, never a chat history. Scripts assert its integrity (sha256 spot-checks
proved a GUARD triage touched nothing, 2026-09-07).

## 2. Detached execution

- Run under `nohup`/`tmux`/`systemd` on the box; log to a file
  (`progress.log` pattern) and to `status.json` after every stage.
- Pre-flight check BEFORE the long run: stack smoke query, disk space,
  credentials, one-item dry run through the real contract path (the seeded
  T1 smoke pattern from phase 07).
- Resume-safety: every stage is idempotent - re-running the pipeline after a
  halt continues from `status.json`, never re-does completed work (proven
  when two local shutdowns cost nothing, and again in the tier-2 GUARD
  resumes).
- Time-box environment setup (~3 h); if the setup fight exceeds it, report
  instead of pushing through. Runtime prognosis > 24 h = proposal to the
  owner, not silent scope reduction.

## 3. GUARDs (the honesty mechanism)

Thresholds are set in the brief, with two levels:

- **Report threshold** - log and continue (e.g. parse failures < 15 % of a
  stage).
- **Hard-stop (GUARD halt)** - the pipeline stops itself and asks (e.g.
  truncation 73/400 > 15 % on 2026-09-08: the pipeline halted, the owner
  picked cap-32768 option i, the resume continued).

A GUARD halt is a **success of the watcher, not a failure of the pipeline.**
Never tune thresholds after observation without recording it (phase-07 T1
rule: an exceeded budget on a healthy runner is a signal - find the cause,
do not widen the limit).

## 4. Cost discipline (owner directives 2026-08-26/28)

- Every estimate carries **both** server EUR and agent-token ~EUR
  (tokens >> server; the 18,265-embedding reindex cost EUR 2.83 list -
  measurable, tiny; the agent chats around it cost more).
- Prognosis first, measured actuals second: every run record carries a
  prognosis-vs-actual table (exemplary: `ops/tier2-final-reindex-2026-09-10.md`).
- Budget guards: monthly box ceiling (EUR 40, owner addendum); API spend per
  run estimated before, reported after.

## 5. Receipts and run records

A pipeline is not done when the last stage exits - it is done when:

1. the **run record** exists (`ops/<unit>-<date>.md`): what ran, counters,
   prognosis-vs-actual, GUARD events, evidence paths;
2. the **receipt** exists where data was written (machine-readable: counts,
   hashes, e.g. the L4 seed receipt with shard counts and 0 orphans);
3. sampling checks ran where the brief demanded them (A7 pattern: N random
   items re-checked end-to-end, results in the record);
4. the registrar closed (CHG entry, STATE, INDEX, handoff marked done) -
   register-currency check per `handoff-template.md`.

## 6. Failure modes this skill exists to prevent

- **Silent half-runs:** a pipeline that "ran" but wrote nothing verifiable -
  the receipt + sampling check are the counter.
- **Threshold drift:** tuning a GUARD after seeing it fire, without a record.
- **Chat as memory:** resuming from a conversation instead of `status.json` -
  sessions die; the state file survives.
- **Owner-attention leak:** interactive prompts mid-run (use `always allow`
  for local kicks, but prefer fully detached box runs), confirmations for
  every stage (batch decisions at GUARD points only).
- **Box clutter:** work dirs under `/opt/gkg/<unit>-work/` per unit, backup
  dumps per retention policy (freshest full dump kept; owner decides pruning).

## 7. Quick checklist for the next pipeline (tiers 3/4)

- [ ] Handoff with estimate (server + tokens), GUARD thresholds, receipt spec
- [ ] Pre-flight: smoke query, disk, credentials, one-item dry run
- [ ] status.json schema agreed (done/pending/evidence/counters/cost)
- [ ] Idempotent stages, resume tested once deliberately
- [ ] **Watchdog started with the pipeline** (scripts/pipeline_watchdog.py,
  CHG-136: --status <workdir>/status.json --log <workdir>/watchlog.txt
  --interval 300, tmux companion) - no agent polls; add --on-guard with
  guard_triage.py (stage B live since 2026-09-12, command in
  ops/watcher-pilot.md) so a GUARD halt writes the triage note itself
- [ ] Run record + receipt + sampling check at the end
- [ ] Register currency + commit bundle for the owner
