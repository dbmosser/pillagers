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

COORDINATOR 10-20 13:35: premise checked. The main PC relay holds 8802 and 8799 (host-verify items 3 and 4) but answers 502: the VM has no "Pillagers pad route" rule, so the main PC cannot reach the VM game or collector at all. Once he adds the rule (for-you.md), notes and run reports flow to the VM collector by themselves. What stays of this job: the party-night copy's exports only (fetch after 10/30).
COORDINATOR 10-20 13:56 CORRECTION: his 10-19 22:45 decision (memory pillagers-all-dev-in-the-vm, synced today from the User1 folder) is NO pad route: the party runs from the main PC copy and the vm-verify pad-route WARN is expected. The pad-route step was taken off for-you.md. So this job stands as written: bring the copy's notes and run reports to the VM (after the party at the latest).

COORDINATOR 10-20 16:59: built, VM side live, main PC side waits for his one step (for-you.md step 1). No new bridge job: the
main PC's minute check (host-night-memory.ps1 -GameCheck, item 7) copies new feedback-*.txt/.png and run-*.txt from
C:\claudecode\pillagers-party\exports into the share as pcnote-NAME (once; pruned after 3 days); tools/fetch-notes.mjs (runner, every
5 min) takes the new ones into exports/ with share-get and a sha256 check, never overwriting (it skips NAME and consumed-NAME).
Status: tools/handoff/notes-fetch.txt and a health.sh line. Tested: the mirror on fake folders (5 files, no repeats, other.txt and a
file younger than 20 s skipped); the fetch end to end with a share-put NOT-REAL note (arrived once, not again; it is gitignored).
The setup now keeps the recorded day size when run again (run at night it would have taken the night size as the day size).
Left: after his step, confirm a pcnote- file appears in share-list and reaches exports/ (step 3), and read whether run-*.txt reports
come from the copy at all (step 4: if notes arrive but no run reports, the copy's collector or autoExport is the gap). Dashboard line not
added (health.sh shows it).

Status 10-20 17:40 (coordinator): his setup rerun took. The main PC's minute check now writes "notes=on" into gaming.txt, and
tools/handoff/notes-fetch.txt shows "main PC copying: ...". It reads "C:\claudecode\pillagers-party\exports is not there": no note or run
report has been saved in the party copy yet (the collector makes that folder on the first report). Step 3 is left: see the first real
pcnote- file arrive. Step 4 answered: the copy's collector (party-host-copy.ps1 -Start) writes run-*.txt into that same folder, so they
are mirrored too. Side fact: right now localhost:8802 on the main PC is the play relay answering 502 (the VM's pad route is his WAIT item);
today's run-*.txt files in the VM's exports are test corpus reports (fxcorpus.html), not his. His last real note here is from 10-18.
