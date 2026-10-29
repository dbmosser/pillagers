# o-00o-233 missed-extract-no-call-again : the missed extraction notice drops "hold x to call again"
HIS WORDS 10-29 about 02:55 UTC (via the Reporter chat, relayed to the Intaker): "missed extraction notice -- 'hold x to call again' makes no sense, bc often the player isn't in the circle -- get rid of it"

What is on HEAD (v36.26): dark_raiders.html ~29307, say('EXTRACTION MISSED','ext',{... sub: '' when the exit is closing, 'No time to call again' when the clock is too short, else 'Hold [X] to call again'}).
Build: the notice keeps its headline "extraction missed" and never shows the "hold [x] to call again" sub (the sub is simply empty in that case). Keep "no time to call again" (it tells him the raid is over for that exit, not an instruction to stand somewhere). Same in player 2's window, the feed copy and any pad version (keyLabel would show the pad button). Calling again with X still works as now.
Check (must FAIL on the current build): miss an extraction with time left: the alert and its feed line contain no "call again" text.
Rules: seed 4242 fingerprint must hold; both windows; never touch the pickup stack, loot sounds or loot rows. Retarget older checks that read the old sub (fixq). DESIGN.md watch line: "missed extraction no longer says hold x to call again". Model: Sonnet 5.5 high (text).
TASK DONE when it shipped and is ON HIS PC.
