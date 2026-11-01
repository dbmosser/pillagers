# 134-picture-store-total-and-soak : a running total of the pictures the game keeps off screen, then a 3-hour two-window soak
Queue (coordinator 10-25 14:00): his request "Conduct fresh deep internet research that you think will best help accelerate and improve development of this game" (Sun 10-25). Source: reports/Top down extraction shooter research.md and research_notes/Top down extraction shooter research/fit_*.md (line numbers read on v34.83; check them on HEAD). Party (Fri 10/30): crash or freeze is his second party fear; the party runs about three hours and one picture store grew once before.
Since v34.81 the SMOOTH look is the default: test and take pictures in the smooth look.
effort: medium

Do: the game counts each of its off-screen picture stores but keeps no total. Add one running total (count and estimated bytes) to the flight recorder and the frame telemetry. Then run a 3-hour two-window soak of demo raids on a scratch port (never 8802; tools/fuzz.ps1 or the robot runner, 1080p, the VM only when free RAM is at least 4 GB, otherwise leave it for the coordinator's night run) and write the total over time in notes/134-soak.md. Any store that keeps growing is the fix.

Rules: the seed 4242 fingerprint (ents 85/374, containers 165/593) must hold unless this brief says otherwise; the check must FAIL on the build before; both windows; player text all lower case. Say in DESIGN.md what he should watch for in a playtest.
TASK DONE when it shipped; TASK PARTIAL with what is left.
