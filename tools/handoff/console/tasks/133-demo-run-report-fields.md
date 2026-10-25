# 133-demo-run-report-fields : each party run's report gets time to first kill, death place, input and preset, downs and revives, last screen
Queue (coordinator 10-25 14:00): his request "Conduct fresh deep internet research that you think will best help accelerate and improve development of this game" (Sun 10-25). Source: reports/Top down extraction shooter research.md and research_notes/Top down extraction shooter research/fit_*.md (line numbers read on v34.83; check them on HEAD). Party (Fri 10/30): his answer 66 (save each party run's report) and 10-12 #48 (telemetry on, anonymous).
Since v34.81 the SMOOTH look is the default: test and take pictures in the smooth look.
effort: medium

Do: demoReportEnd (about line 69635, cw-demoreport) posts seat, why, score, mate score, kills and frame stats to the local collector. Add per seat: time to first kill, each death's map position and cause, keyboard or pad and the pad preset, downs and revives, and the last screen before the run ended. No new screen for players; the fields only go in the report. Keep the report small (no per-frame data).

Rules: the seed 4242 fingerprint (ents 85/374, containers 165/593) must hold unless this brief says otherwise; the check must FAIL on the build before; both windows; player text all lower case. Say in DESIGN.md what he should watch for in a playtest.
TASK DONE when it shipped; TASK PARTIAL with what is left.
