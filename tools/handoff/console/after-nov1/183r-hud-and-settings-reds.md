# 183r-hud-and-settings-reds : three checks newly failing on v34.96 pass again (raid corner list, pillager size, Settings detail pane)
Queue (check-in 10-27 07:40): party blocker, before any screen polish job. His 10-27 order: "Ok no new features until Nov 1. Resources should now be spent polishing, bug fixing, etc". This is bug fixing.
Since v34.81 the SMOOTH look is the default: test and take pictures in the smooth look.
effort: medium

Source: the spare PC full test run corpus-1027-0155 on v34.96 (f63d472b1), failing 15, new 14. Eleven of the 14 sit in jobs 117r, 118r, 119r, 119s and 119t, whose fixture fixes landed 10-27 07:15 to 07:28 (after this run). These three have no job. Read it with: git fetch origin spare-results; git show origin/spare-results:spare/DESKTOP-82BKOP4/corpus/corpus-1027-0155.txt
Why now: the stable build is still v34.53. The party copy on Fri 10/30 is the newest build that passed a full run, so these reds are the party blocker.
Your FAIL lines:
- v34.89 cw-hudcorner (his note of 10-25, "in raid, right hand lower corner menu and minizmized controls f1 key are awkward take a look") -> "career 720: the opened list 488,317 266x266 reaches past the middle of the screen (640); demo 720: the opened list 495,267 266x266 reaches past the middle of the screen (640); career 768 and demo 768 the same (683)". At small windows the opened corner list grows past the screen middle.
- v34.90 cw-thirdsize (his note of 10-25 on build 33.17, the pillager figure was too big) -> "staging: a hostile pillager (lean) aiming -0.5 pi: 581 gun pixels, 2352 mark pixels, 2 unsteady, mark placed ...". Since then his 10-25 smooth look order set the pillager to 0.8 (memory: pillagers-smooth-look-2026-10-25) and v34.98 made the frozen redraw steady: check whether it still fails on HEAD first.
- v30.17 the Settings detail pane and its focus look name the first row in view after the list scrolls -> "the pane names "Auto resolution" but the first row in view is "Render resolution"". Suspects: the auto resolution and render resolution rows of v34.82 and v34.83 (rows added or moved above the scroll point).

Steps:
1. Run each check alone on the current build (v34.99 or newer); drop any that pass and say so.
2. For each left, say which of two it is: a. the game really broke: fix the game in an mk script; b. the check went blind or the change was on purpose and within his orders: re-aim it so it proves the claim again. Never loosen a check until it passes.
3. One batch per cause, through preflight.sh and shipq.sh as usual. Note the cause per check in the ship's DESIGN.md section.
Rules: player text all lower case, short; HUD and Settings only; no new feature; no change to the storage key salvagerun:profile.
TASK DONE when every check here passes on the drafted build or is fixed in a shipped batch; TASK PARTIAL with the ones left and why.
