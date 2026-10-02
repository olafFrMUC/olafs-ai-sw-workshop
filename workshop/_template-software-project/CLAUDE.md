# Project: <NAME>

> Copy this template to apps/<project-name>/, then fill in the sections below.

## What this is
<One paragraph: app / web / combination, target users, purpose.>

## Working method - V-model lifecycle
Left branch top-down (decomposition), right branch bottom-up (verification):

    01 Requirements ----------------------------->  08 System Validation
       02 Solution Concept
          03 Validation Concept -----------------> (defines 08 tests)
             04 Architecture ------------------->  07 Integration & Test
                05 Module Specification -------->  06 Module Design & Test

## Rules
- Stable IDs: REQ-###, ARC-###, SUB-###, IF-###, TC-###, RISK-###, DEC-###, OQ-###.
- Traceability is mandatory - update TRACEABILITY.md on every change.
- Log every change in CHANGELOG.md with reason.
- Record structural decisions in DECISIONS.md (ADR).
- Track open questions in OPEN-QUESTIONS.md - never leave one without a phase or release
  that must answer it.
- Schedule work in RELEASES.md by referencing REQ IDs, never by restating requirement text.
- Do not close a phase until its review gate passes (ORCHESTRATION.md).
- Record reviews in reviews/.

## Project-specific instructions for Claude
<Coding conventions, tech stack, constraints.>

## Method support (workshop skills)
Roles (who does what): see workshop/agent-roles.md - five roles across all phases;
one editor per file, reviewer != author. Skills (how): per phase, distilled from
practice - a skill is written *after* its phase has been lived, never before.

| Phase | Skill (workshop/skills/) | Status |
|-------|--------------------------|--------|
| 01 Requirements | testable-requirements | exists |
| 02 Solution Concept | decision-research (+ closure-proposal pattern in review-gates) | exists |
| every gate | review-gates | exists |
| cross-cutting | consistency-sweep | exists |
| 03 Validation Concept | - | distill after the phase |
| 04 Architecture | architecture-design | exists |
| 05-08 | - | distill after the phase |
