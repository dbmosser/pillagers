51-corpus-old-b : 11 old checks (v15 to v19) red at v32.83, new since v32.16 (coordinator 2026-10-20, from tools/handoff/corpus-fails-v32.83.txt)
effort: medium

These passed at v32.16 and fail at v32.83, so a ship of 10-20 most likely changed or broke them: check git log since 1b8dc30b for the measured thing.

For each check: find it in tools/mkfixture.ps1 ({v:'NN.NN'), run it on the current fixture (runchk.sh; a check that passes on HEAD is FIXED SINCE), then decide:
- REAL: the game broke something no ship meant to change. Fix the game through the ship queue, with a new check whose control FAILS on the old build.
- STALE: a later ship changed it on his order or on purpose with its own check. Retarget the old check so it keeps its intent under the new rule
  (bash S/lock.sh, edit, runchk.sh, HELD=1 bash S/fixq.sh "MESSAGE", bash S/unlock.sh; short holds, a few checks at a time). Delete only if its feature was removed.
- HARNESS: flaky staging (window size, timing). Fix the staging.
Never weaken a check to make it pass. Write one line per check in tools/handoff/console/notes/51-corpus-old-b.md: version, REAL / STALE / HARNESS / FIXED SINCE, one-line reason.

The checks (version what it checks -> what it saw at v32.83):
v19.64 a map tag steps aside before it steps down: with the spot above taken and room to the side, a clashing CACHE tag moves sideways, not down onto its marker -> the CACHE tag was moved down to y 339, onto its marker, with room beside it
v19.10 the use bar clears the extraction lines: with extraction inbound and a bandage going on, the use bar panel ends above the EXTRACT INBOUND line -> the use bar panel (bottom 844) runs into the EXTRACT INBOUND line (top 827)
v18.78 text in the framed windows stays inside the frame: the text lines of the Terms, Party, gambler and bar windows are capped at 1060 like their lists, not the general 1180 -> termsmodal text lines are capped at 1400px; barmodal text lin
v18.69 zone names on the sector maps never print into each other: on every sector preview no two drawn names overlap -> COLD STORAGE: blast freezer prints into foreman office; COLD STORAGE: blast freezer prints into chill row; COLD STORAGE:
v18.25 the floor says how to trade while a party is on: the pause-box key line names the trade key, the stash idle text says how to offer when the windows are linked, and the Undercroft bottom line and H card gain the take line -> the stash
v18.03 the fog of war and darkness sheets draw at a fraction of the screen and are stretched back: the sheets are between half and three quarters of the screen width at full render resolution, smaller again at Low, and with a raid up the gr
v18.01 auto resolution: two seconds of slow frames step the render scale down one notch and the canvas shrinks on the next resize, smooth frames step it back up, it never goes under Low, Settings has the row, and with the row Off the scale 
v17.82 each sector row on the sector page is tall enough to hold its map (the map does not spill into the row below), and the zone names are 11 px -> the zone names are not 11 px
v16.65 player text tells the truth in his words: the PARTY window says the party ascends into the same raid, and the what is new card uses no retired word -> the PARTY window does not say the party ascends into the same raid
v16.13 three backcheck fixes: a restore code with no tally starts a clean one and the sector card reads the tally, so a restored character does not show the replaced character runs; a pillager killed by a friend is remembered after the gone
v15.86 a controller can choose a sector: on the sector page both sector cards are in the list of controls the pad can reach, beside DAY and NIGHT, and with a faked controller the highlight put on the second sector card stays there through a

TASK DONE when every check above is green on HEAD or explained in the notes; TASK PARTIAL with the ones left.
