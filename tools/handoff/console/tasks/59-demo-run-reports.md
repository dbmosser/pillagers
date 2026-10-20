59-demo-run-reports : every finished demo run saves its run report on the local collector (planner draft 2026-10-20)
effort: medium

Source: q-process/answers.md 66 (save each party run's report): "b) Yes, and screen recordings too"; q-round3/answers.md 2.92: "b: The game logs everything automatically".
Not done (planner, 10-20): grep -n "autoExport()" dark_raiders.html -> only 4537 (text edits), 66011 and 66026 (ocCommit, the career
outcome card). arcadeRunEnd (64373) calls neither autoExport nor buildExport, so a demo run writes nothing. Task 21-party-sheets, which
held the 2.92 logging list, was cut 10-19 before his answer 66.

Why: the party is the demo (his 10-19 order), and his #1 worry is stutter or harsh sound (his Q27). The run report's gfx p50/p95/slow line
is how stutter on his two TVs becomes real numbers (2.43 a: under 60 for more than a few seconds counts as janky).

What to build (one control per job: reuse buildExport, autoExport and telemetryDest; do not write a second exporter):
1. At the end of each demo (2 player arcade) run, in BOTH windows, post the run report to the local collector (telemetryDest), tagged demo
   and the window's seat (p1 or p2), so the two windows' reports can be told apart.
2. No Downloads fallback for demo runs: if the collector does not answer, drop it quietly (no file lands in Downloads, no "run report not
   saved" banner, nothing a guest sees). Off localhost (itch) do nothing at all for demo runs.
3. It must not delay the run-over card: post after the card is up, fire and forget, with a short timeout.
4. The demo must never write its sandbox profile over his career save (check which profile the demo uses today; do not change the
   storage key salvagerun:profile).
Screen recordings (the rest of his answer 66): do NOT build them in this job. Recording two 4K windows costs frame time and stutter is his
#1 worry. Add one question to questions.md: "screen recordings of demo runs: record each run on the main PC (costs some frame rate),
or only run reports for now?" with "only run reports for now" as the pick shown.

Checks (control must FAIL on v32.90): a demo run ending makes one post with the demo and seat tags (stub fetch); when the post fails no
download link is created; a career run end is unchanged.
Note for the coordinator: on the night the demo runs on the main PC copy, whose collector writes to that copy's own exports folder;
coord-01 (fetch my notes) brings the reports into the VM.
Party risk: low to medium (a network post at run end). It is a FEATURE: it must ship by Mon 10/26, otherwise it waits until after 10/30.

TASK DONE when shipped and the checks pass; TASK PARTIAL with what is left.
