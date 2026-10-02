# Skill: review gates and the decision loop

How to run a phase review gate, and how to drive the open questions that feed it. Distilled
from geo-knowledge-guide phases 01 and 02 (2026-07/08), where the method was worked out in
practice.

**Use when:** a phase is finished and needs a gate; a review produced findings that need
tracking; an open question is blocking and you need to close it properly.

---

## 1. The gate: two perspectives, one gate

A gate has two reviewers even in a one-person project, because they ask different questions:

| Perspective | Question | Who |
|---|---|---|
| **Content** | Is this the *right* thing? | the owner |
| **Formal** | Is it unambiguous, testable, traceable, owned? | the facilitator (the agent) |

Prepare the formal side **before** the owner starts, so their pass is judgement, not clerical
work. Pre-fill every formal finding; leave the content verdicts empty.

### The worksheet must be self-contained
The single most useful correction we made: the review worksheet originally referenced the
requirement IDs and expected the reviewer to open the requirements file alongside. **Inline the
full text of every item under review.** A reviewer who has to hold two documents open reviews
worse and stops sooner.

Per item: statement, acceptance criterion, the pre-filled formal note, and an empty verdict
field with a fixed vocabulary (`OK` | `CHANGE` | `REMOVE` | `QUESTION`) plus a comment field.

## 2. The four formal criteria

Whatever the phase, these are the exit criteria worth checking:

- **Complete** - nothing missing *and* nothing dangling. Open questions are fine; unassigned
  ones are not (see section 5).
- **Unambiguous** - two readers get the same reading. Fix terminology in a glossary, not in
  prose.
- **Testable** - every item has a decidable acceptance criterion. See the
  `testable-requirements` skill.
- **Owned + traceable** - someone answers for each item, and the traceability matrix covers
  all of them. Verify the count mechanically, not by eye.

## 3. Verdicts

`PASS` | `PASS-WITH-ACTIONS` | `FAIL`.

**PASS-WITH-ACTIONS is usually the honest outcome**, and it is not a weak PASS. The distinction
that makes it defensible:

> Open questions are not the same as incompleteness - as long as every one of them names the
> phase or release that must answer it.

Carried actions get IDs (`A-1`, `C-1`, ...) with a due phase, and are listed in the gate
record. The next phase inherits them explicitly rather than by memory.

## 4. Findings discipline

- Findings get IDs (`F-1`, `G-1`, ...) and a severity: *fix before the verdict* / *should fix*
  / *minor*.
- Each finding states: what, where, **why it matters**, and a suggested fix. A finding without
  the "why" gets argued about instead of fixed.
- State explicitly what you checked **and found sound** - a review that only lists problems
  gives the gate one side of the picture.
- After incorporation, run a **second pass** that reports the status of every finding from the
  first. Nine-of-eleven-fixed is information; "incorporated" is not.
- If the reviewer and the author are different agents, see the editing rule in the
  `consistency-sweep` skill - the reviewer reports, the holder of the file edits.

## 5. The decision loop for open questions

The loop that worked, per question:

```
open question  ->  closure proposal  ->  owner decision  ->  DEC record  ->  question closed
```

- The **closure proposal** is a dated working document: context, **named alternatives with
  their trade-offs**, a recommendation, and the open sub-points the owner must decide. Options
  the owner can pick beat prose the owner must interpret.
- The **DEC** records context, options considered, decision, consequences. "Alternatives
  weighed" is a gate criterion later - if the DEC has no alternatives, the gate has nothing to
  check.
- **Closing** means: mark it resolved in the register *and* write the answer in prose. A table
  row saying "resolved - see DEC-009" forces a second lookup; a paragraph saying what was
  decided and what follows does not.
- Keep answered questions in the register with their answers. Deleting them loses the reason.

### Reframe questions that cannot be answered
If the owner cannot answer a question, it is usually posed in the solution's vocabulary rather
than theirs. Restate it in terms of a consequence they can judge.

> *Unanswerable:* "Is OSM data a Collective Database or a Derivative Database?"
> *Answerable:* "Must the knowledge base be able to stay closed?"

Same decision, one sentence, and the owner answered it immediately. When a question sits open
for days, suspect the phrasing before the owner.

## 6. Close the gate properly

- Set the verdict **in the review record**, with the four criteria filled in and the carried
  actions listed.
- Update the phase status where it actually lives: `STATE.md` (the live "Where we are"
  block) - status, gate verdict, record reference. (The template's separate
  `ORCHESTRATION.md` phase board was retired 2026-08-22: a second, manually synced
  board goes stale; STATE.md is the single board.)
- Mark the phase output as **baselined** in its own header, and say that changes now go through
  the changelog with a reason.
- **Tag the baseline in git**: `phase-01-requirements-baseline`. Later phases need to know what
  they were built against, and a tag costs nothing.

## 7. Anti-patterns seen in practice

- **Deciding scope silently.** If a finding requires a scope decision, hand it to the owner as
  a choice. Fixing it either way makes the review look complete while a real decision was made
  by an agent.
- **A stale rationale outliving its reason.** "X is out of scope because open question Y is
  undecided" survives long after Y was answered. When you close a question, grep for its ID.
- **Priority legend vs. release membership.** If the legend says MUST = MVP, then a MUST that
  is not in the MVP release breaks the legend. Either annotate the priority or move the item.
- **Counting by eye.** Every count in a gate record ("25 requirements", "all MUSTs covered")
  should be produced mechanically. Two of our worst findings were miscounts that looked right.

## 8. Lessons from phase 03 (2026-08)

Three additions the validation-concept gate made stick:

- **Delegate the content review, keep the verdict.** From the implementation-oriented
  phases on, content review can go to an independent review agent (rule:
  `workshop/agent-roles.md`, "Content review by phase"; reviewer != author holds
  unchanged). What cannot be delegated: the gate verdict and the decision on findings.
  Our phase-03 content pass ran this way - 11 findings, fixed, reviewer-verified -
  and the owner decided only the two real choices plus the verdict.
- **Facilitator prepares the gate record; the owner only verdicts.** The pattern that
  made the gate a one-sitting decision: the facilitator fills the record completely -
  checklist with the evidence per done criterion, findings with their fixes and
  verification status, carried actions drafted - and leaves the verdict field empty
  until the owner decides. A record that arrives with the verdict pre-filled is the
  facilitator deciding by stealth.
- **Record protocol deviations honestly and promptly.** When a measurement or judging
  run deviates from the protocol (sample size, procedure, who judged), write it down
  where the evidence lives, with three parts: what deviated, whether the deviation
  still carries the decision, and what is kept for a later formal re-run. A deviation
  discovered at the gate that was visible during the run reads as concealment; the
  same deviation recorded the day it happened reads as engineering.
