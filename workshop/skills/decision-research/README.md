# Skill: decision-grade research

How to research so that an open question can actually be closed afterwards. Distilled from
geo-knowledge-guide phase 02 (2026-08): the OQ-001 source research (three passes) and the
OQ-002 LLM research (measured corpus, priced options).

**Use when:** an open question needs facts before the owner can decide (sources, prices,
rate limits, licences, corpus sizes); when a second research pass over the same ground is
needed; when a cost or feasibility claim should be checked rather than believed.

---

## 1. Verify at the source - or say you didn't

Mark every load-bearing claim with its verification state:

- `✓` checked at the source, with the date,
- `~` documented by a credible third party,
- `?` not verified - **verify before anyone builds on it**.

A research document that does not distinguish these gets trusted uniformly - and distrusted
too late. Examples from practice: NewsAPI's free tier being development-only was a suspicion
until the pricing page confirmed it; the tagesschau API's empty `geotags` field was visible
only in a **live call** - no documentation carried that fact. Where a live check is cheap,
do it: an afternoon of API calls beats a week of reading vendor marketing.

## 2. Quantify the load before comparing costs

A cost or feasibility comparison without a measured load is estimation theatre. Measure
first, price second:

1. **Measure the corpus/load** (counts, sizes, churn) with real queries, not assumptions.
2. **Price every option against the same numbers.**
3. State the answer at the decision's actual scale, not at an imagined one.

In OQ-002, measuring the R0 corpus first (~2,000 articles, ~10 M tokens) turned "external
LLM vs. self-hosted?" from an argument into arithmetic - and the honest answer was *"money
does not decide this question at this scale"*, which redirected the decision to the axes
that actually mattered (quality, sovereignty). Without the measurement, that answer is
unavailable.

## 3. Content/data sourcing: keep the three legal layers apart

When the research touches content rights, do not stop at "licence":

- **Copyright** - facts are free; wording is protected.
- **Database right** - protects an archive against extraction of a *substantial part*, even
  of unprotected facts. Per-item legality does not imply legality at volume.
- **Contract / terms of use** - bind separately; attribution does not cure a terms
  violation.

A sourcing answer that only names the licence misses two of the three ways it can be wrong.

## 4. A second pass over the same ground is a supplement, not a duplicate

When research already exists:

1. **Reference it explicitly** and state the relationship up front.
2. **Verify its claims live** where cheap; **reconcile differences in the open** ("the
   earlier pass said X; verified today as Y") - never leave two silently contradictory
   documents.
3. **Add only what is new.** If the earlier pass already answered it, point, don't repeat.

A duplicated pass that mostly agrees wastes the reader twice; a reconciled supplement makes
both documents more valuable.

## 5. End with "what has to be decided" - not with a recommendation alone

Research is **input, not a decision** - mark it as such in the document header. Close every
research piece with:

- the sub-decisions the owner must make, as a list of options where possible,
- the follow-ups that became visible during the research (new questions, with the
  phase/release that must answer them),
- what would change the conclusion ("this recommendation flips if the corpus grows 10x").

The owner can then decide in one sitting instead of interpreting prose. The DEC is written
by the owner/gate loop - see the `review-gates` skill.

## 6. Register the research so later sessions find it

- Log it in the project's change log with what was verified and what was concluded.
- Index it (e.g. `research/README.md`) with the coverage of each pass, so the next agent
  knows what exists before starting a duplicate.
- Date artifacts with the **calendar day they were written**. If a session crosses
  midnight, note it - don't let a document carry yesterday's date silently.

## Checklist

- [ ] Every load-bearing claim marked ✓ / ~ / ?, with dates for the ✓s?
- [ ] Live checks done where they were cheap (APIs, pricing pages, policies)?
- [ ] The load measured before options were priced?
- [ ] All three legal layers considered where content rights are involved?
- [ ] If a second pass: framed as a supplement, differences reconciled explicitly?
- [ ] Ends with the decisions the owner must make + what would change the conclusion?
- [ ] Marked "input, not a decision"; logged and indexed; calendar-dated?
