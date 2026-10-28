# 135-pad-poll-guard : a blocked pad read can never stop the game
Queue (coordinator 10-25 14:00): his request "Conduct fresh deep internet research that you think will best help accelerate and improve development of this game" (Sun 10-25). Source: reports/Top down extraction shooter research.md and research_notes/Top down extraction shooter research/fit_*.md (line numbers read on v34.83; check them on HEAD). Release fix (itch.io, Thanksgiving): the friends and family link plays inside the itch frame.
Since v34.81 the SMOOTH look is the default: test and take pictures in the smooth look.
effort: low

Do: pollPad calls navigator.getGamepads() with no try (about line 19623) and the frame loop calls pollPad() with no try (about line 53747). A browser that blocks pads in a frame throws there, which would stop every frame after the pad poll. Guard both so a throw means no pads this frame and the game runs on with keyboard and mouse. The check stubs navigator.getGamepads to throw and proves frames keep drawing.

Rules: the seed 4242 fingerprint (ents 85/374, containers 165/593) must hold unless this brief says otherwise; the check must FAIL on the build before; both windows; player text all lower case. Say in DESIGN.md what he should watch for in a playtest.
TASK DONE when it shipped; TASK PARTIAL with what is left.
