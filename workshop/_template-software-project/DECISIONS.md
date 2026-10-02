# Decision Records (ADR)

Structural decisions and why - separate from routine changes. Newest first.
Machine-readable marker per record (read by tools/build_index.py; keep under the heading):
`<!-- DEC-### | <status> | links: ID, ID ... -->`

    ## [DEC-###] YYYY-MM-DD - <title>
    <!-- DEC-### | <status> | links: ID, ID ... -->
    - Supersedes: DEC-###[, DEC-###]   (optional machine-readable relation line,
      parsed into graph supersedes edges; `- Amends:` analogue. Relation ids
      must ALSO appear in the links: list above.)
    - Status: proposed | accepted | superseded by DEC-###
    - Context: the problem forcing a choice
    - Options considered: A, B, C (trade-offs)
    - Decision: what was chosen
    - Consequences: implications, follow-ups, risks (link RISK-###)

---

## [DEC-000] YYYY-MM-DD - Adopt V-model lifecycle
<!-- DEC-000 | accepted | links: -->
- Status: accepted
- Context: need a rigorous, traceable development process
- Options considered: ad-hoc; agile-only; V-model with review gates
- Decision: V-model with review gates and full traceability
- Consequences: phase discipline; upfront specification effort
