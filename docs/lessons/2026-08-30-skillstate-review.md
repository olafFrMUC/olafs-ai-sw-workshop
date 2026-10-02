# Study: SKILL.state (Google, arXiv 2608.26263) - review and adoptions

2026-08-30, methods chat (owner request). Status: **reviewed - adoption points
proposed.** Related: `2026-08-23-graph-export-concept.md` (the static twin),
`2026-08-30-vps-agents-study.md` (where a state-driven runtime is implementable),
`2026-08-23-linkedin-graph-engineering-review.md`.

## 1. What the paper does

**SKILL.state: Scalable Long-Horizon Agent Skills** (Badhe, Tiwari, Chung -
Google LLC / Purdue, arXiv 2608.26263v1, 2026-08-26).

A runtime architecture that replaces append-only conversational history with an
explicit, mutable, structured **execution state**. Per step the model receives
only three inputs: the immutable skill specification `P`, the current
structured state `Σt`, and the latest observation `Ot`. Intermediate reasoning
is discarded after each validated state update; a deterministic runtime
validates patches (rollback-retry on malformed output).

Results across benchmarks (SkillExecBench, InterCode CTF, Sierra τ-Bench):
bounded O(1) prompt footprint (~1,800 tokens flat) instead of quadratic growth;
**16.2x token reduction at T=100** (65k vs 1.06M); better accuracy than
history- and compression-based baselines; zero recovery steps on external
state drift; robust to heavy irrelevant noise. Error taxonomy on small
open-weight models: 68 % of failures are **premature state overwrite** during
patch generation, i.e. structured-output adherence, not reasoning.

## 2. The central mapping: it is the dynamic twin of our graph concept

| | Our graph-export concept | SKILL.state |
|---|---|---|
| What | **Static knowledge**: queryable relations between registers (REQ/DEC/SUB/TC) | **Dynamic process**: execution state of a running agent task |
| Problem | "what depends on REQ-053?" (manual grepping) | transcript grows O(T^2), poisons context |
| Solution | generated graph from markdown sources | schema state instead of transcript, discard reasoning |
| Layer | knowledge store | runtime |

They compose: in the paper's terms our `graph.json` is the **P** (immutable
knowledge specification), our `STATE.md` / `handoff-coordinator-current.md` is
the **Σt** (current state), and new work is the **Ot**. **Our handoff-rotation
pattern is the manual variant of SKILL.state** - we discard chat history and
carry only the validated structured state forward. The paper quantifies why
that instinct was right (16x tokens, better accuracy).

## 3. What the paper does better than us

1. **Deterministic validation of state updates** (rollback on bad patches).
   Our "coordinator made false claims" problem (owner, 2026-08-30) is exactly
   an unvalidated bad state update. We have the evidence rule (convention);
   the paper has enforcement (mechanism).
2. **Bounded prompt per step** - our long unit chats (L4 type) are precisely
   the O(T^2) risk the paper quantifies (1.06M vs 65k tokens at T=100).
3. **One schema per domain, authored once** (CTF: 5 fields) - our handoffs
   have this implicitly, but not as a fixed schema for *running* units.

## 4. What we do better

1. **Two-track design:** the paper's limitation (3) is that history is needed
   when the objective is auditing/provenance - **exactly our case** (DECs,
   reviews, CHANGELOG). We have both: mutable state (STATE/handoffs) *and*
   append-only truth (CHANGELOG/WORKLOG). SKILL.state alone could not provide
   our audit trail.
2. **Multi-agent write conflicts:** the paper leaves concurrent writes open -
   our one-editor-per-file rule is the pragmatic answer it lacks.
3. **Deterministic generators:** the 68 % premature-overwrite finding on small
   models confirms our rule "registers are generated (build_index), never
   prose state" - our critical state updates are already deterministic.

## 5. Adoption points (ascending effort)

1. **Unit-state schema for long units (small):** long units carry a fixed
   structured state block (5-7 fields: done/pending/evidence/blockers/cost)
   that the coordinator reads instead of chat history. Extends the session
   registry + progress.log into a schema.
2. **Token math into cost discipline (nothing to build):** O(T^2) vs O(T) as
   the argument for early rotation and against "one long unit chat" - backed
   by the paper's numbers.
3. **VPS/CI agent runtime following SKILL.state (the real win, mid-term):**
   in option C (GitHub Actions) or A (the box) of the VPS-agents study **we
   control the runtime ourselves** - the pattern is directly implementable:
   the runner keeps `state.json`, prompts per step with (handoff, state.json,
   latest log tail), validates patches by script, never builds a transcript.
   That makes autonomous agents cheap (linear cost) and robust (no context
   decay on e.g. 100k-seed runs).
4. **Caution for model routing:** the mechanical class must not own **prose
   state maintenance** (68 % patch-error rate on small models) - mechanical
   units' state lives in generated files or simple validated JSON schemas.

## 6. Verdict

Worth adopting as a **pattern**, not as a product. Zed gives us no runtime
hook to discard reasoning per step - but (a) our rotation discipline is the
proven manual approximation, and (b) on the VPS/CI path we control the
runtime and can implement it properly. The graph concept stays the static
complement (the P-provider: its `briefing` query is literally what a
state-driven runner would fetch as immutable context).
