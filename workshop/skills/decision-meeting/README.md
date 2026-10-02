# Skill: decision meetings (management meetings)

How to collect sporadic, cryptic decision points and run them as one prepared,
batched meeting with the owner. Distilled from the steering practice in
geo-knowledge-guide (2026-08), where owner decisions kept arriving scattered across
documents and phrased for engineers, not for a decision-maker.

**Use when:** several owner decisions are pending in different documents; work chats
escalate options that wait weeks for a pick; the owner should decide in one sitting
instead of being drip-fed.

---

## 1. Collect, don't drip-feed

The Coordinator keeps a **standing agenda** per project:
`decision-meetings/agenda.md`. Anything decision-worthy that surfaces goes onto it
immediately - escalations from work chats, decision-friction reports, option
proposals (like Q-ARC-###), deferred owner points from reviews.

Item states: `draft` -> `ready` -> `decided` -> `processed` (a follow-up unit exists).

**The blocker exception:** anything that blocks the critical path is escalated at
once, not batched. Batching exists to make non-blocking decisions cheaper, not to
delay urgent ones. When in doubt, ask the owner: "blocker or agenda?"

## 2. Preparation: management-ready, not engineer-ready

Each ready item follows this format (short, jargon-free; the owner decides, the
agenda does the homework):

```markdown
### M-### - <title as one plain question>
**Situation:** <2-3 sentences: what is the situation, why is a decision needed now>
**Constraints:** <max 4 bullets: budget, time, existing DECs that bound the choice>
**Options:**
- A) <...> - risk/impact: <one sentence>
- B) <...> - risk/impact: <one sentence>
- C) <...> - risk/impact: <one sentence>
**Recommendation:** <pick + one-sentence reason; "none" is acceptable, a hedge is better>
**Deadline:** <"Benötigt vor ..." - when the decision starts blocking work>
**Reversibility:** <high/medium/low + one sentence why>
**Prepared Q&A:** <2-4 questions the owner is likely to ask, each with a short answer
and a reference (REQ/DEC/OQ/SUB) so the answer comes without a research break>
```

Deadline and reversibility were added 2026-08-20: they are the two fields the
owner decides fastest on.

**Plain-language variant (management-tauglich, proven 2026-08-20 in
geo-knowledge-guide M-009..M-014):** for a non-engineer owner, replace the
Situation with **"Lage in Klartext"** - the same content in everyday language,
every technical term glossed in a half-sentence on first use (e.g. "FastAPI
ein Baukasten fuer die Web-Schnittstelle", "pgvector = ein Zusatzmodul der
Datenbank") - and add one line **"Was das fuer Sie bedeutet"** (consequences
for operations, cost, risk, in plain words). The bar: if the owner has to ask
what a term means, the item goes back to `draft`. A rework of already-ready
items into this format is legitimate meeting preparation, not scope creep.

The quality bar: **every question the owner is likely to ask is answerable from the
prepared notes without a research pause.** If the preparation cannot answer the
obvious questions, the item stays `draft`.

## 3. Running the meeting

Happens in the steering chat (or a dedicated meeting chat), one item at a time:

1. Present the item exactly as prepared - situation, options, recommendation.
2. The owner picks (A/B/C), asks a question, or defers.
3. Answer questions from the prepared Q&A. **If a question is not prepared: park it.**
   Say so, note it in the protocol, answer after the meeting. Do not improvise
   numbers or facts mid-meeting.
4. Record the verdict (pick + one-line owner comment) immediately in the meeting
   record - before moving to the next item.

### The moderator checklist (owner, 2026-08-30: every meeting runs the same way)

Past meetings drifted in style depending on the coordinator. Run every meeting
against this checklist, per item:

1. Present the item **verbatim from the agenda** (situation, constraints, options,
   recommendation) - do not re-phrase or extend mid-meeting.
2. Ask for the pick: A/B/C, question, or defer.
3. Answer only from the prepared Q&A; park everything else by name.
4. Record verdict + one-line owner comment in the meeting record **before** naming
   the next item.
5. After the last item: close formally - read back all verdicts, list parked
   questions, name the follow-up units to be briefed. Only then is the meeting over.

### Meeting record template (`decision-meetings/YYYY-MM-DD-meeting.md`)

```markdown
# Decision meeting YYYY-MM-DD
Facilitator: <coordinator> | Items: M-###..M-### | Duration: ~

## M-### - <title as in the agenda>
- Verdict: <A / B / C / deferred>
- Owner comment: <one line>
- Parked questions: <none / ...>

(repeat per item)

## Open after the meeting
- Parked questions (answered separately): ...
- Follow-up units to brief: ...
```
## 4. Protocol first, process after

- Verdicts go into a dated record: `decision-meetings/YYYY-MM-DD-meeting.md`
  (one section per item: the pick, the owner's comment, parked questions).
- **Nothing is edited in project artifacts during the meeting.** Deciding and
  executing stay separate - mixing them is how half-recorded decisions happen.
- After the meeting closes: the Coordinator briefs the follow-up units (handoffs)
  that write the DECs / amend documents, and marks agenda items `processed`.
  The processing unit logs the CHANGELOG entry; the meeting itself logs none.

## 5. What belongs on the agenda - and what does not

| Belongs | Does not belong |
|---|---|
| Genuine either/or choices with consequences | Tasks (spot-checks, reviews) - those get handoffs |
| Scope calls (in/out of a release) | Information the owner only needs to see - put it in STATE.md |
| Decision-friction reports (a DEC hurts) | Things derivable from existing DECs - derive, don't ask |
| Reopen-a-DEC proposals | Content work (drafting queries, writing prose) |
