# 131-gun-impact-sound-caps : cap how many gun and impact sounds play at once
Queue (coordinator 10-25 14:00): his request "Conduct fresh deep internet research that you think will best help accelerate and improve development of this game" (Sun 10-25). Source: reports/Top down extraction shooter research.md and research_notes/Top down extraction shooter research/fit_*.md (line numbers read on v34.83; check them on HEAD). Party fix (Fri 10/30 first): his worst party problem 1 is "stutter or harsh sound" (Q27).
Since v34.81 the SMOOTH look is the default: test and take pictures in the smooth look.
effort: medium

Do: guns and impacts in blip (about line 9775) have no per-kind or overall cap, while the newer SNDA noises are rate-limited (sndAGate about 8729) and the siren is capped (alarmOk about 8149). Add a cap per sound kind (guns, impacts, explosions) and an overall voice cap, stealing the oldest voice first, so a two-player firefight with an LMG and a shotgun never stacks into a harsh wall of sound. Keep every single shot sounding exactly as now when nothing else plays. Measure the voice count in a 2-player fixture firefight before and after and write the numbers in notes/131-sound-caps.md.

Rules: the seed 4242 fingerprint (ents 85/374, containers 165/593) must hold unless this brief says otherwise; the check must FAIL on the build before; both windows; player text all lower case. Say in DESIGN.md what he should watch for in a playtest.
TASK DONE when it shipped; TASK PARTIAL with what is left.

HIS PRIORITY 10-27 (priorities page, r-voicebudget): LOW
