# Skill: box evidence drivers (headless UI evidence through the SSH tunnel)

How to prove an owner-visible UI change on the VPS ("the box") with scripted,
measurable evidence instead of "looks good" - and how to deploy that change
without disturbing anything else that runs on the box. Distilled from 5+
geo-knowledge-guide units 2026-09-08..11 (mobile-sheet, map-interaction,
locate-button, mobile-polish, map-polish2; run records
`ops/r1m-mobile-polish-2026-09-10.md`, `ops/r1m-map-polish2-2026-09-10.md`).

**Use when:** any owner-visible UI change must land on the box and the owner
needs proof, not impressions. Mandatory once the owner has reported concrete
findings (e.g. from a live test on a real phone): the driver must REPRODUCE
those findings before the fix and show them gone after.

---

## 1. Why a driver, not a screenshot session

"Looks good" is not evidence and does not survive a session boundary. A
driver script is re-runnable, diff-able, and its numbers land in the run
record verbatim. The mobile-polish unit proved the point: the BEFORE run
measured the header at **85.4 px**, not the ~52 px everyone assumed from the
layout calcs - the real driver was a default `<p>` margin on `.lang-toggle`,
which the assumed-cause fix would never have touched. Measuring first found
the actual root cause (record: `ops/r1m-mobile-polish-2026-09-10.md`,
stage-2 "evidence-driven correction").

## 2. Driver anatomy

One self-contained script per unit: `frontend/tests/<unit>-evidence.mjs`
(pattern: `frontend/tests/mobile-polish-evidence.mjs`,
`map-polish2-evidence.mjs`). Playwright headless Chromium, run with
`node tests/<unit>-evidence.mjs [baseUrl]`.

- **Tunnel, not exposure.** The box serves HTTP on an internal port; the
  driver targets `http://localhost:18080` (SSH tunnel `localhost:18080 ->
  box:8080`). Reuse an existing tunnel when one is up, but ALWAYS verify it
  answers with the box's own bundle before trusting it (leftover listeners
  from previous sessions exist; both polish records carry this verification
  note). Never open a new public path for evidence.
- **Viewport matrix.** Both form factors, every time: MOBILE 390x844 with
  `isMobile`/`hasTouch` (de-DE locale) and DESKTOP 1280x800 as the
  counter-check. The desktop run is not optional: it pins that the mobile
  fix did not break the other form factor (e.g. "sheet inert on desktop:
  display:contents, no inline height").
- **Findings as checks.** Each owner finding becomes one or more named
  `check()` calls with measured detail: px geometry from ONE in-page probe
  (`getBoundingClientRect` + computed style), clickability via
  `document.elementFromPoint` (a button under the sheet fails this),
  interactions scripted (mouse-step drags of the sheet handle, canvas
  keyboard pans, scripted geolocation via `context.setGeolocation`).
- **BEFORE / AFTER.** The same driver runs against the old deploy (must
  FAIL - reproducing the owner's findings with numbers: mobile-polish
  BEFORE 7 FAIL / 6 PASS) and against the new deploy (must PASS: 13/13).
  A driver that never failed proves nothing; a fix without a failing
  BEFORE is a guess.
- **Artifacts.** `frontend/tests/evidence-<unit>/` with `evidence.json`
  (all checks + raw probe values) plus dated screenshots per state
  (peek / dragged / after-pan / desktop). Exit code = failure count, so a
  green claim is machine-checkable.
- **Headless limits, honestly.** Some mechanisms need real device chrome
  (the mobile URL bar). The mobile-polish record says so explicitly and
  shows the reproduced mechanism instead (header-overshoot scroll, same
  visible symptom); the construction-side fix then removes the whole
  class. Report the limit, never silently widen the claim.

## 3. The deploy pairing (the box is NOT a git clone)

`/opt/gkg` has no git history - files arrive by copy, and the copy must be
provable. Pattern: `ops/deploy_marker_seam.sh` (born from the re-measure
unit's EOL lesson: verify by content, normalized).

1. **LF-normalize + sha256 every file.** Local hash over
   `tr -d '\r' < file`; push through the same normalization; compare the
   remote `sha256sum`. CRLF working trees and LF-only boxes otherwise
   produce "identical" files that are not (the 2026-09-05 review finding:
   sha256 deploy evidence is EOL-sensitive).
2. **Rebuild ONLY the changed service.** `docker compose build frontend &&
   docker compose up -d frontend` - never a bare `up -d`. Record the
   container's healthy-after-up time.
3. **Prove the untouched stayed untouched.** Other services' uptimes
   before AND after (`backend`, `db`, `geo` at 4d/8d/4d in both
   measurements). If a running pipeline exists, its state file must be
   byte-identical before and after: `tier2-work/status.json` sha256 quoted
   verbatim in both records.
4. **Verify the served bundle.** The box serves its own Docker-build hash;
   compare against the local build. Same hash = ideal (mobile-polish:
   `index-DzuRkYte.js` identical). Different hash is NOT automatically a
   failure - the Docker toolchain differs from local (map-polish2):
   then verify honestly - grep the served bundle for the new code paths
   (`onLoadMore`, `preventScroll`), match the css hash byte-exactly, and
   rely on the AFTER driver checks against the served bundle. Record which
   of these you did.
5. **No commits from the box unit** when the handoff says so - the deploy
   is verified by hashes and evidence, the commit is a separate owner-gated
   step.

## 4. Failure modes observed (what this skill exists to prevent)

- **Measuring the assumed cause instead of reproducing the finding
  first.** The header was "obviously" ~52 px because the calcs said so;
  the BEFORE run measured 85.4 px and found the `<p>` margin. Run the
  driver BEFORE touching CSS; let it fail; fix what it shows.
- **Skipping the desktop counter-check.** A mobile-only pass would have
  missed nothing here - this time. The matrix is cheap; run both.
- **Deploying by scp without hash verification.** The EOL lesson: content
  drift invisible to `scp` exit codes. LF-normalize, hash both sides,
  print OK/FAIL per file.
- **Restarting more than the changed service.** `docker compose up -d`
  without a service name recreates what it feels like; a running pipeline
  on the same box does not forgive that. Name the service; verify the
  others' uptimes and the pipeline's `status.json` hash after.
- **Trusting a stale tunnel.** A leftover `localhost:18080` listener might
  not point at the box anymore. Verify it answers with the box's own
  bundle before the BEFORE run and again after the deploy.
- **Infra flakes reported as test results.** Mobile neg-path/a11y flakes on
  one runner were pgserver startup timeouts - infrastructure, not test
  logic. Say so in the record ("Infra, nicht Test-Logik", WORKLOG
  2026-09-10) instead of retrying until green or quietly dropping the
  check. Honest failure beats convenient green.
- **Transient states the live evidence cannot catch.** The pill's
  in-flight disable happens faster than the driver can observe on a fast
  box; map-polish2 pins it hermetically in vitest and says exactly that in
  the record. Split: live driver for geometry/behavior, hermetic tests
  for transients - never claim the driver covered what it could not.

## 5. Quick checklist for the next box UI unit

- [ ] Owner findings numbered; each mapped to at least one named check
- [ ] Driver `<unit>-evidence.mjs`: tunnel base URL, mobile 390x844 touch
      + desktop 1280x800, in-page probe, scripted interactions
- [ ] Tunnel verified against the box's own bundle answer
- [ ] BEFORE run: failures reproduce the findings (numbers in the record)
- [ ] Deploy: LF-normalized scp + sha256 per file; build/up ONLY the
      changed service; untouched uptimes + state-file hash before/after
- [ ] Served bundle hash compared (identical, or honestly cross-verified)
- [ ] AFTER run: all checks pass; `evidence.json` + screenshots stored
- [ ] Run record quotes the numbers verbatim, incl. headless limits and
      any infra-vs-logic flake classification
