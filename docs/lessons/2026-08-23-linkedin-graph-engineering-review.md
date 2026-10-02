# Source review: "Graph Engineering" LinkedIn post (2026-08-23)

Owner request: check the publication and assess its relevance for this workspace.

## What the post claims

LinkedIn post by Sanjeev Sharma (2026-08, ~868 likes) about a concept "Graph
Engineering" for multi-agent systems, attributed to Andrej Karpathy. Six steps:
(1) generate-critique-revise loop, (2) parallel agents on separate worktrees,
(3) a knowledge graph accumulating entities/decisions/facts, (4) an evaluator
grounded against the graph instead of "looks right", (5) the graph as shared
memory for all agents, (6) stop rebuilding context every time. Core line:
"The model is the intelligence. The graph becomes the institutional memory."

## Source criticism - handle with care

1. **The post's title is AI-generated** (labelled "summarized by AI" by LinkedIn).
2. **The Karpathy attribution is unverified.** A commenter (Mahed Javed, PhD)
   analysed the referenced "PDF": a disclaimer on top, no authors in the first
   section, inconsistent heading formats, an unsupported "1000x" claim, no
   methodology, unclear figure provenance - his verdict: likely "AI slop".
   No Karpathy original source could be verified.
3. It is an opinion/marketing post, not a publication; the comment thread is
   largely self-promotion.

**Verdict:** content discussable, attribution doubtful. Usable as inspiration
and external confirmation - **not as a source for decisions**.

## Relevance assessment for this workspace

High - because we already practise steps 1-6:

| Post step | Our equivalent |
|---|---|
| 1. Loop (generate/critique/revise) | Author -> Reviewer (reviewer != author) -> findings incorporation with a verifying second pass (skill: review-gates) |
| 2. Parallel agents, separate worktrees | work chats / sub-agents with disjoint write-scopes; one editor per file |
| 3. Knowledge graph accumulating | the register system: typed entities (REQ/DEC/OQ/RISK/TC/SUB/IF) linked by ID; DECs connect decisions to reasoning; TRACEABILITY as derived view |
| 4. Grounded evaluator | cross-checks against the registers (consistency-sweep: missing/false/circular/stale); mechanical verification via build_index.py (e.g. 50/50 allocated, 14/14 IFs) |
| 5. Shared memory | WORKLOG + STATE.md + handoffs across chat boundaries |
| 6. No context rebuild | STATE -> INDEX -> targeted grep; coordinator handoffs; the token-cost strategy |

The strongest comment in the thread (Sergio Wermuth) describes what we also
already have: claims need provenance, confidence, freshness, ownership and an
invalidation path; an append-only log with a derived graph. That is our
CHANGELOG (append-only), the provenance discipline, DEC-supersedes instead of
silent correction, and INDEX/TRACEABILITY as derived, never-hand-edited views.

## Takeaways

1. **Confirmation, no action needed** - the celebrated "next step" of agentic AI
   is our daily practice since phase 01.
2. **One genuine gap the post names:** our graph is implicit (ID references in
   Markdown). A machine-readable relation layer would let agents *query* it -
   concept: `2026-08-23-graph-export-concept.md`.
3. The "grounded vs. ungrounded" axis (Kaliuzhna thread): structure without
   grounding fails more elaborately. Our gates with measured values (T1 budget,
   EUR/1000 items, gold set) are exactly that grounding - keep it that way.
