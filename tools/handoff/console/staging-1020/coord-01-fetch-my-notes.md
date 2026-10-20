coord-01-fetch-my-notes : bring his notes and run reports from the main PC copy into the VM (planner draft 2026-10-20)
effort: medium

COORDINATOR OR A SESSION AGENT (d, g, h) ONLY. Do not move into tasks/: lanes may not write tools/bridge, tools/nightly.sh or
tools/devdash (RULES.md "Your permissions are an exact list"), and a lane with an empty list takes any file in tasks/.
Source: tools/handoff/q-process/answers.md 14 (how his notes reach me now): 'a) Add a "fetch my notes" job to the main PC link'.
Not done (planner, 10-20): tools/bridge/jobs.mjs allows only ping, stats, kit (ollama-status, play-status, host-verify, vm-address-hint),
share-list, share-get and share-put (kit at line 65, share-* at 75-96); share-* read only the one share folder.
tools/migrate/party-host-copy.ps1 line 13: run reports "go to the copy's own exports folder". The VM's newest exports/ file is
consumed-feedback-20261018-154736 and the newest run report is consumed-run-20260911-210932.

Why first: his notes are the input for every tuning batch (CLAUDE.md workflow rule 1), he uses the note key often (his 17 a), and the demo
run reports of job 59 land in the same folder on the night.
1. A new signed bridge job (same signing and allowlist pattern as kit and share-*), read-only on the main PC side: list and copy the copy's
   exports/feedback-*.txt and .png and run-*.txt into the VM's exports/. Never overwrite, dedupe by name, never write into the copy,
   never touch port 8802.
2. The runner calls it every few minutes while he plays (at-the-PC mode) and once after he stops; the dev dashboard shows "last fetch
   hh:mm, n new".
3. Test: a note made on the copy shows up in the VM's exports/ within minutes (a file placed in the copy's exports by the bridge test
   path is fine; do not ask him to type one unless nothing else works).
4. While there: find out why no career run report has arrived since 09-11 (his text edits and frame timings ride in them). Is the copy's
   collector on :8799 up, is autoExport posting, or is it falling back to his Downloads folder? Fix it or report it in one line.
Party risk: low (tools only, no game change).
Done when: a note from the copy reaches the VM's exports/ by itself, and the dashboard shows the last fetch.
