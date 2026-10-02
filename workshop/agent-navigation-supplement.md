# Supplement: token efficiency beyond navigation

2026-08-07, owner request. Status: proposal. **Supplements
[`agent-navigation-concept.md`](agent-navigation-concept.md)** - it does not replace it.

**Agreed and not repeated here:** the three-layer model (STATE → INDEX → targeted read), the
navigation rules in `AGENTS.md`, the reasoning against a graph database at this scale, and the
fetch discipline. That concept is sound; adopt it.

This document adds four things it does not cover, and one uncomfortable one.

---

## 1. Diagnosis addendum: measure first

The register sizes in geo-knowledge-guide today (`wc -c`, ~4 bytes per token):

| File | Size | ≈ tokens | Needed how often? |
|---|---:|---:|---|
| CHANGELOG.md | 62 KB | ~15.5k | almost never - only for "why did X change?" |
| DECISIONS.md | 35 KB | ~8.8k | often, but one record at a time |
| requirements.md | 31 KB | ~7.8k | often, mostly as a table |
| OPEN-QUESTIONS.md | 18 KB | ~4.4k | often |
| solution-concept.md | 16 KB | ~3.9k | phase-bound |
| SOURCES / RELEASES / RISKS / TRACEABILITY | 24 KB | ~6k | occasionally |
| **Control files together** | **186 KB** | **~46k** | |

Two things follow that the navigation concept does not draw out:

**The largest file is the least needed.** The changelog is a third of the whole weight and is
consulted for one question only. It does not belong in any read path.

**It grows monotonically.** 52 entries after two phases, six phases to go. Navigation makes
reading cheaper; it does not stop the growth. Both are needed.

## 2. Addition A - frontmatter is what makes the generator trustworthy

The navigation concept's index is generated. Everything depends on that generator being
**robust**, because a silently wrong index is worse than no index - the agent then reads
confidently in the wrong place.

Parsing prose headings and markdown tables is brittle: our own registers use three different
row shapes and several priority spellings (`MUST`, `MUST (knowledge graph, DEC-002)`,
`COULD (post-MVP)`). A generator regexing that will break quietly on the next edit.

**Give every record a structured block the generator reads instead:** YAML frontmatter for
per-file records, and for table registers a fixed column contract documented in the file
header. Then the index is a projection, not a parse.

This is also the cheapest way to make the index carry *edges*: `links: [DEC-012, OQ-010]` in
the frontmatter is the adjacency list, written where the fact lives.

## 3. Addition B - generate the derived views, not just the index

This is the point with the most leverage, and it connects the token problem to the quality
problem.

The same fact - *which requirement, which priority, which release, covered where* - is
currently written by hand into **four** places: the requirements table, the concept's coverage
table, `TRACEABILITY.md`, and `RELEASES.md`. That is why every change costs four reads and four
writes, and it is why **every single finding of both concept cross-checks was a seam between
those documents**: stale counts, false traceability entries, circular coverage, a release plan
contradicting the concept.

Generating them removes the whole defect class:

- `TRACEABILITY.md` ← from frontmatter/links. Never hand-edited.
- Coverage tables in phase outputs ← from the same source.
- Release membership lists ← from `release:` fields.
- Header with `<!-- GENERATED - do not edit -->` and the generating command.

The consistency-sweep skill then guards a much smaller surface: instead of checking whether
four documents agree, it checks whether the generator ran.

## 4. Addition C - split what is prose-per-record, keep what is tabular

The navigation concept deliberately leaves the prose documents untouched ("the owner's
readability does not change by a comma"). That is right for the *content* and, I think, too
conservative for the *file layout*. Splitting improves owner readability rather than harming
it - a decision record becomes a document instead of a paragraph in a 500-line pile, and its
diff shows the decision alone.

The line to draw:

| Split into one file per record | Keep as one file |
|---|---|
| `decisions/DEC-012.md` | requirements table (66 rows, already compact) |
| `changelog/2026-08.md` (per month) | `SOURCES.md`, `RISKS.md`, `TRACEABILITY.md` |
| reviews (already one file each) | `OPEN-QUESTIONS.md` while it fits on a screen |

**Why it matters even with good navigation:** grep-plus-line-range needs you to guess how many
lines to read around a hit, and ADRs here run from 12 to 60 lines. "Read `decisions/DEC-012.md`"
is exact and bounded. The cost is more files and more path noise - real, but small against
eight phases of growth.

Honest caveat: this is the one addition that touches existing structure. If only one thing gets
done, do Addition B instead.

## 5. Addition D - archive what is closed

Nothing in either concept retires anything. Closed material should leave the live set:

- answered open questions → an `archive/` section or file, referenced from the register,
- superseded decisions → keep the file, mark `status: superseded by DEC-###`, exclude from the
  index's default view,
- changelog months older than the current phase → `changelog/archive/`.

Rule: the live set holds what is *decision-relevant now*; history stays reachable and out of
the read path.

## 6. Addition E - the uncomfortable one: we write too much

Output tokens cost roughly five times input. The registers did not write themselves, and on
this project the agent side of the ledger is heavier than the reading side.

Concretely, from my own output in phases 01-02: decision records of 40-60 lines where 15 would
carry the decision; three research documents covering partly overlapping ground because each
pass wrote a full standalone report; review documents of 150-200 lines.

Discipline that costs nothing:

- A DEC is **context, options, decision, consequences** - each a few lines. The essay belongs
  in the closure proposal, and only if someone needs convincing.
- A second research pass **supplements**; it does not restate the first (the `research/README`
  convention already says this - it was written after we had already broken it twice).
- Findings before prose: a review is a list with locations, not a narrative.
- Do not re-read a file you just wrote.

## 7. Why not embeddings over our own documents

Sharper than "semantic search does not pay on a small corpus": **the queries here need
completeness, not similarity.** "Which MUST requirements have no coverage" and "which documents
cite OQ-002" must return *all* matches or they are wrong - and top-k similarity is structurally
incapable of that guarantee. Stable IDs plus grep give exactness for free.

Note the symmetry with the product being built: the *product's* knowledge base needs a graph
plus vectors, because it answers fuzzy questions over unbounded content. The *project's*
meta-layer needs an index plus grep, because it answers exact questions over a bounded, fully
enumerated set. Same repo, opposite retrieval strategies, for good reasons.

## 8. Measure before, not only after

The navigation concept's acceptance test (answer a DEC-012 question without opening DECISIONS
in full) is good but relative. Take the baseline **before** changing anything: on the next real
task, record which files were opened and their byte counts. Without that number, "it feels
better" is all you will have.

Suggested target: a typical continuation task should read **under 15k tokens** of project
documents, against the ~46k that reading the control files whole costs today.

## 9. Sequencing

1. **Addition B** - frontmatter plus a generator for TRACEABILITY and the coverage tables.
   Largest effect, removes a defect class, touches no prose.
2. The navigation concept's **STATE.md + INDEX.md** on the same generator.
3. **Addition D** - archive the changelog and the answered questions. One hour, removes a
   third of the weight.
4. **Addition C** - split the decisions and the changelog, once the generator exists to keep
   the index correct across the move.
5. Fold the result into `_template-software-project/` via `setup.ps1`, per the workspace rule.

Additions A and E cost nothing and apply from the next task onwards.
