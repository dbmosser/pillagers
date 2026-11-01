# 254-retarget-1031-reds : retarget 16 out-of-date checks that went red in runs corpus-1031-1034 and corpus-1031-1437 (v36.89, v36.95)
Queue (check-in sort 11-01). LOW, no player change; tests only. They are parked in tools/handoff/stable-known-red.txt so they stop blocking stable; this job brings them back to guarding the new behaviour.
effort: low to medium (Sonnet high; edit tools/mkfixture.ps1 through fixq only; grep each check id, read about 150 lines around it)

Each check pins the layout or text of a screen that a shipped polish pass changed on purpose. Re-aim each so it proves the same claim on the new screen. Keep every assertion that still makes sense; never loosen one until it passes.
- 18.78 (about line 74855): Terms window rebuilt in v36.57 (heading text capped 1400, list 1632). Compare text caps only inside the windows that still share one cap (party, gambler, bar); give the Terms window its own pair.
- 23.12: v36.59 lower-cased the recording callout detail ("saved to downloads"). Match it case-blind or in lower case.
- 8.93 (about line 2772) and 21.55: v36.76 pillager board reads at 16 px: the default board is 388x218 at the default size; the board ends under its last name by less than a row at the new row pitch.
- 30.73 (about line 31039): the gun card right edge moved from 8 to 16 in with v36.73; find it by hudIns() as check 34.89 now does (commit ade2820eb).
- 31.25 (about line 28269): v36.84 replaced the .trsub span with labelled text (STASH and BAG as small.trl); assert the one row and the three $ figures at one size.
- 18.63: v36.84 put the experimental caption on the last pour sign plate; assert it is inside the sign plate and clear of the name.
- 32.12 (about line 25013): v36.73 one card for the clock and the extract line; assert the extract words stand inside the clock card rect (the card is drawn before the words), not a plate fill right before them.
- 35.84 (about line 10931) and 35.83 (the next check): v36.75 one danger at a time: the same keyed danger does not show again for 10 s, so the second seat sees no final rush banner or g.alert. Clear the danger memory (or advance g.t by 11 s) between seats; in the real game each window has its own state.
- 34.41: v36.80 the self-revive key is a hudKey keycap; assert the keycap (the shared chip) is drawn with the word beside it.
- 16.30 (about line 81526): v36.79 the inbound line reads EXTRACT, two spaces, ring letter, two spaces, INBOUND; match the two-space INBOUND text in the source.
- 26.69 (about line 45866) and 23.37 (about line 60897): v36.87 the first demo pack (waveN 0) lands 480 to 640 away and brings no ambush extras. Set ARCADE.waveN (or the wave state the code reads) to 1 or more before the ambush and the 700 to 1200 landing assertions, and add an assertion for the first pack (11 s, 480 to 640).
- 32.30 and 32.33 (search the ids): v36.91 and v36.92 the map words sit closer to their icons by design; assert the new gap (read it from the code) and keep the contract track alignment.
Do: lock.sh, edit tools/mkfixture.ps1, HELD=1 fixq.sh "retarget NN.NN: reason", unlock.sh (as in job 243). Then delete the 16 lines of the 11-01 block from tools/handoff/stable-known-red.txt.
Rules: tests only, never edit dark_raiders.html; seed 4242 fingerprint unchanged; never touch the pickup stack, loot sounds or loot rows. If a check turns out to guard a real bug once re-aimed, stop and write a job for it instead.
TASK DONE when the 16 pass on the current build in a full run and their known-red lines are gone.

COORDINATOR 11-01 14:20: confirmed all 16 PASS on the current fixture (v37.13, runchk.sh, one run, 35.83/26.69/23.37 included); deleted the 11-01 block (header plus 16 lines) from tools/handoff/stable-known-red.txt. DONE.
