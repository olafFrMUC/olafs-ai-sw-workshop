# Skill: architecture design - submodules, interfaces, allocation

How to turn a validated concept into an architecture that phase 05 can specify from
without a single clarification round. Distilled at the start of geo-knowledge-guide
phase 04 (2026-08), from what the earlier phases made painful and what the phase-03
gate handed down as carried actions.

**Use when:** a phase-03-style concept exists and you must decompose it into submodules
with contracts; when a traceability generator needs a machine-readable allocation
source; when an "architecture" document is prose and nobody can say which requirement
lands where.

---

## 1. Submodules: one responsibility each, no shared ones

Decompose into submodules `SUB-###`. The rule that keeps the register honest:

> **One clear responsibility per submodule - and no responsibility shared between two
> submodules.**

If two submodules "both handle" something, neither owns it, and every later defect in
that area becomes an argument about whose it is. Split until each submodule's
responsibility fits one sentence that names no other submodule. A submodule with two
sentences of responsibility is two submodules.

Give each SUB-### in the register: the one-sentence responsibility, the interfaces it
provides/consumes (IF-###), and the sub-requirements allocated to it. Nothing else -
design detail belongs to phase 05.

## 2. Interface contracts: IF-###, explicit or broken

Every seam between two submodules gets an interface contract `IF-###`. "They just call
each other" is how implicit interfaces are born. A contract must name:

- **Parties** - which SUB-### provides, which consume(s).
- **Data shapes** - the typed inputs and outputs, including units and encodings, not
  "a result object".
- **Error and empty cases** - what the consumer sees when there is nothing, something
  went wrong, or the answer is partial. This is the part everyone skips and everyone
  later needs.
- **Versioning** - how the contract changes without silently breaking consumers
  (version field, additive-only evolution, or an explicit breaking-change rule).

Concrete pattern worth copying: **a typed status vocabulary belongs in the interface
contract, not in the UI.** If a retrieval can legitimately return `no_results`,
`partial`, or `source_missing`, those are values of the contract's status enum, defined
once in IF-### with their exact meaning - and every consumer (UI, audio, tour mode)
maps them to presentation. When the vocabulary lives in the UI instead, each channel
invents its own variant and they drift apart by phase 07. (This one came down as a
carried gate action; write it into the contract the first time, not as a fix.)

## 3. Sub-requirements: every requirement allocated, none orphaned

Parent requirements (`REQ-###`) are decomposed into sub-requirements, each traced back
to its parent. Two directions must both hold - check them mechanically, never by eye
(see the `consistency-sweep` skill):

- **No orphans:** every sub-requirement names its parent REQ-###.
- **No drops:** every parent REQ-### has at least one sub-requirement allocated to at
  least one SUB-###. A requirement that appears in no allocation row is architecture
  that forgot a requirement - the single most dangerous finding at this gate.

## 4. The allocation table: the binding, machine-readable artifact

The allocation is not prose. It is one Markdown table in `architecture.md`, and it is
the artifact the traceability generator parses to fill the TRACEABILITY columns
ARC/IF and SUB:

```
| REQ-### | SUB-### | IF-### |
|---------|---------|--------|
| REQ-001 | SUB-003 | IF-002 |
| REQ-001 | SUB-005 | -      |
```

Format rules (a generator depends on all of them):

- Header exactly `| REQ-### | SUB-### | IF-### |`, one data row per allocation.
- **Multiple rows per REQ are allowed and normal** - a requirement realized by several
  submodules gets one row each.
- One SUB-### per row; one IF-### per row. `IF-###` is `-` when the allocation crosses
  no interface (purely internal to the submodule).
- IDs only - no prose in the cells. Explanations go in the SUB/IF registers.

Because the table is machine-readable, the two coverage checks from section 3 reduce
to: every REQ-### in the requirements register appears in column 1, and every SUB-###
and IF-### used in the table exists in its register. Run both before the gate.

## 5. Failure modes seen and expected

- **Interface implicit instead of explicit.** Two submodules agree in chat how they
  connect; nothing is written. By integration, each remembers a different agreement.
  If there is no IF-### row, there is no contract.
- **Overlapping responsibility.** "SUB-002 and SUB-004 both do caching." Nobody owns
  the defect. Split or reassign until the overlap is gone.
- **Requirement double-allocated or not at all.** Double allocation hides a scope
  decision an agent made silently; zero allocation hides a dropped requirement. Both
  are found only by the mechanical column-1 check, not by reading the document.
- **"Architecture" as prose without allocated registers.** A narrative with boxes and
  arrows but no SUB/IF registers and no allocation table cannot be gated - there is
  nothing to check a requirement against. Registers first, prose to explain them.

## 6. The gate: Architecture Review before any implementation

- The gate is an **Architecture Review with an independent reviewer** (reviewer !=
  author), held **before implementation begins**. Record it in `reviews/` like every
  other gate - see the `review-gates` skill for verdicts and findings discipline.
- Exit criteria: SUB register with single responsibilities, IF register with complete
  contracts (parties / data shapes / error and empty cases / versioning), allocation
  table present, both coverage checks run mechanically, no orphans, no drops, no
  double allocations without a recorded reason.
- Carried actions from previous gates that name phase 04 (e.g. a typed status
  vocabulary) belong on the review checklist - they are the first things an
  independent reviewer should look for.

## Checklist

- [ ] Every SUB-### has exactly one responsibility, shared with no other submodule?
- [ ] Every submodule seam has an IF-### with parties, data shapes, error/empty
      cases, versioning?
- [ ] Status vocabularies (empty, partial, failure) typed in the contract, not left
      to consumers?
- [ ] Every sub-requirement traces to a parent REQ-###; every REQ-### appears in the
      allocation table (both checks mechanical)?
- [ ] Allocation table in the exact `| REQ-### | SUB-### | IF-### |` format, IDs only?
- [ ] No double allocation without a recorded reason?
- [ ] Architecture Review held with an independent reviewer, before implementation?
- [ ] Carried actions naming this phase on the review checklist?
