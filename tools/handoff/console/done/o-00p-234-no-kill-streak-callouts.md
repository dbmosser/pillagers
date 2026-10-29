# o-00p-234 no-kill-streak-callouts : double kill, triple kill and the rest are gone; beast mode replaces them
HIS WORDS 10-28 about 23:00 EDT (in the Gameplay Edit Intaker chat): "get rid of all the double kill 2x triple kill 3x etc -- beast mode replaces all that"
DEPENDS ON o-00f-223 (steady hand and beast mode): ship after it, or in the same build, so there is never a build with neither.

What is on HEAD (v36.26), dark_raiders.html:
- ~68383-68398 the arcade streak (v23.38 arcade15): kills under ARCADE_STREAK_GAP 4 s apart chain into DOUBLE KILL x2, TRIPLE KILL x3, MULTI KILL x3, RAMPAGE x4, UNSTOPPABLE x5; the multiplier scales the kill's points (arcadeStreakX at ~68522 and ~68549), the callout is said in the alert lane with 'x'+mx as its sub (~68528) with a climbing medal sound, and a badge with the multiplier shows beside TEAM SCORE while a streak is live.
- The style medals (~68571): MULTI-KILL (three kills inside 1.5 s) and GRENADE DOUBLE (two kills in one blast) are the same kind of kill-count reward.
- FEEDMEDALS (~23455), SPK_MEDALS (~9922), ANN_STREAK (~8083) list them.

Build: remove the kill-count streak entirely: no DOUBLE KILL / TRIPLE KILL / MULTI KILL / RAMPAGE / UNSTOPPABLE callout, no x2-x5 multiplier on kill points, no streak badge beside the team score, no streak medal sound; and remove the MULTI-KILL and GRENADE DOUBLE style medals. Keep the other medals (long shot, melee kill, untouched...) and the plain per-kill points and popups. Beast mode (o-223) is now the only reward for kills in quick succession, in arcade and career alike. Clean the What's New/help text that promises streak multipliers. Note in DESIGN.md that arcade scores will run lower than before the change (the leaderboard nights before it had streak points).
Check (must FAIL on the current build): in an arcade raid, 5 kills 1 s apart: no streak callout, each kill pays its base points, no badge; a grenade killing two gives no GRENADE DOUBLE.
Rules: seed 4242 fingerprint must hold; both windows; never touch the pickup stack, loot sounds or loot rows. Retarget older checks on the streak (fixq). DESIGN.md watch line: "no more double or triple kill callouts; beast mode is the streak". Model: Sonnet 5.5 high.
TASK DONE when it shipped and is ON HIS PC.
