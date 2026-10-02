# skills
Generic, reusable skills and tooling shared across projects.
One skill per subfolder; document its purpose and usage in the subfolder`s README.

Agent-neutral by design: any agent working in this workspace can be pointed at them. For a
skill you want an agent to load automatically, add a thin pointer under that agent's own
skill location rather than duplicating the content here.

**Claude Code pointers exist** at `ZED/.claude/skills/<name>/SKILL.md` for **every
skill below** - frontmatter with the trigger, a compact summary, and a link back here for the full
playbook. Because the ZED root is not a git repo, `setup.ps1` generates a minimal version of
each pointer from its `$skills` table (`Write-DocOnce`, so the maintained summaries are not
overwritten) - that keeps them reproducible from this versioned repo. **Adding a skill = adding
one row to `$skills` in setup.ps1** (plus the index row below).

| Skill | Use when |
|-------|----------|
| [decision-research](decision-research/) | An open question needs facts before the owner can decide; a cost/feasibility claim should be checked, not believed; a second research pass over the same ground is needed. Covers source verification (✓ / ~ / ? marks), quantify-the-load-before-pricing, the three legal layers (copyright / database right / terms), the supplement-not-duplicate rule, and ending with what has to be decided. |
| [review-gates](review-gates/) | A phase needs a gate; findings need tracking; an open question is blocking and must be closed properly. Covers the two-perspective gate, the four formal criteria, PASS-WITH-ACTIONS with carried actions, findings discipline, and the closure-proposal → DEC → close loop (including how to reframe a question the owner cannot answer). |
| [testable-requirements](testable-requirements/) | An acceptance criterion says *appropriate, sufficient, relevant, fast, measurably* - or names no number. Covers the what/under-which-conditions/where-is-the-line rule, formula plus test vectors, stability rules, gold sets with a baseline uplift, and latency reference scenarios. |
| [consistency-sweep](consistency-sweep/) | Before a gate, after incorporating review findings, or after two agents worked the same material. Covers mechanical extraction, both-direction comparison, the four failure modes (missing / false / circular / stale), the drift pairs to check, and the multi-agent editing rule. |
| [architecture-design](architecture-design/) | A validated concept must become submodules with contracts, or an "architecture" is prose and nobody can say which requirement lands where. Covers one-responsibility SUB-###, IF-### contract contents (parties / data shapes / error+empty cases / versioning - incl. the typed status vocabulary rule), sub-requirements traced to parent REQ-###, the machine-readable allocation table, and the independent Architecture Review before implementation. |
| [autonomous-pipelines](autonomous-pipelines/) | A workload runs longer than ~15 minutes, the owner's machine must not stay on, or a job must survive disconnects auditable afterwards. Covers the status.json-as-state pattern (SKILL.state), detached execution with pre-flight checks, GUARD halts with report/hard-stop thresholds, prognosis-vs-actual cost accounting, and receipts/run records as the done definition. |
| [decision-meeting](decision-meeting/) | Owner decisions arrive sporadically and cryptically instead of batched and prepared. Covers the standing agenda (draft/ready/decided/processed), the blocker exception, the management-ready item format (situation / constraints / options with one-line risks / recommendation / prepared Q&A), protocol-first-process-after, and what belongs on the agenda. |
| [module-specification](module-specification/) | The SUB-###/IF-### registers exist and each submodule needs data models, algorithms and test cases before code - or a "spec" restates the architecture instead of refining it. Covers the three spec contents (field schemas / processing steps / error-case mapping onto contracts) and the three exclusions (no language/framework/library, no code, no contract repetition), behavioral TC-### against the IF-### contracts with mandatory negative paths, the machine-readable `| TC-### | REQ-### | SUB-### | IF-### |` allocation table with both mechanical coverage directions, and the independent Spec Review before implementation. |
| [module-implementation](module-implementation/) | The specs and TCs exist and the submodules must now become code that proves itself against them. Covers the kickoff artifacts (DEC-019 licence discipline: LICENSE file, per-file headers, docs licence note), one module per SUB-### with IF-### as the only seams, contract-first implementation with testable error mapping, TC-### -> executable test mapping (TC-ID stays findable in the test), unit vs. integration placement, and the draft -> independent review -> fixes -> verify -> owner gate loop. |
| [integration-testing](integration-testing/) | The modules each pass their contract tests and the question shifts to whether the assembled system works. Covers the four phase-07 additions (the mechanical per-IF integration matrix, a few outermost end-to-end flows, the deployment shape smoke-tested in CI without stealth rollout, budget smoke checks distinct from the phase-08 load harness), and the phase-06 failure modes applied forward (CI-is-the-only-truth incl. verifying the leg actually ran, timing nondeterminism, integration claims without a crossing test). |
| [system-validation](system-validation/) | The system is integrated and the last V-model phase must validate it against the original requirements - while some validation assets depend on inputs that do not exist yet. Covers the execute-what-is-honestly-executable pattern, the deferral register as the gate deliverable (named home + unblock condition, pre-approved), measurement honesty under substitute conditions, asset groundwork (skeletons + runners dry-run on synthetic data), and the failure modes applied forward from phases 06/07 (gate review checks the concept, executable halves shrinking quietly, skeletons claiming execution). |
| [contract-evolution](contract-evolution/) | A shipped `IF-###` contract needs new observable behavior and the question is "extend or break?". Covers the additive-only rule (optional field with absent/default semantics), when a new contract/version is required instead, the mechanics (schema pins, drift guards on both sides, bit-identical default, DEC/CHG registrar steps), the contract -> producer -> consumer sequencing, and the observed failure modes. |
| [versioned-enrichment-passes](versioned-enrichment-passes/) | A bulk re-derivation must run over the versioned store. Covers the six mandatory mechanics (versioned guid suffix + stripping, material-change skip before the store write, honest fallback, dry-run -> apply -> idempotency gate, stratified audits seed 42, regression pins), the pre-flight checks (one-writer gate, cache-shape verification, baseline, backup), and the five observed failure modes (NO_OP swallow, half-fix across two config surfaces, cache-shape mismatch, version noise, fabricated fallbacks). |
| [box-evidence-drivers](box-evidence-drivers/) | An owner-visible UI change lands on the box and must be proven, not asserted. Covers the driver anatomy (SSH tunnel verification, 390x844 + 1280x800 viewport matrix, findings-as-checks, BEFORE/AFTER discipline, evidence.json + screenshots), the deploy pairing (LF+sha256 copies, single-service rebuild, untouched-uptime + status.json byte-identity checks, bundle-hash comparison), and the observed failure modes. |

The first four were distilled from geo-knowledge-guide phases 01 and 02 (2026-07/08);
architecture-design was distilled at the start of phase 04 (2026-08); decision-meeting
was distilled from the steering practice (2026-08, owner request); module-specification
was distilled at the start of phase 05 (2026-08), after the phase-04 gate closed PASS;
module-implementation was distilled at the start of phase 06 (2026-08), after the
phase-05 gate closed PASS - stack-neutral on purpose, as the stack decision lands in
the phase-06 decision meeting; integration-testing was distilled at the start of
phase 07 (2026-08), after the phase-06 gate closed PASS; system-validation was
distilled at the start of phase 08 (2026-08), after the phase-07 gate closed PASS
and the owner decision meeting 2026-08-24 approved the phase-08 concept
(M-015..M-021); autonomous-pipelines was distilled from the T4 LLM pass, the
tier-2 pre-fill and the final reindex (2026-09, owner request); contract-evolution,
versioned-enrichment-passes and box-evidence-drivers were distilled from the
R1-minimal build and the 2026-09-11 housekeeping review (2026-09-13, owner
request).
All describe what actually worked and what actually went wrong, not theory.
