RETARGET 12 OUT-OF-DATE CHECKS NOW PARKED IN stable-known-red.txt (CEO 10-28 00:10; sorted by commit 4a5be82f7). Low priority, after the party is fine.
The quiet hud (v35.30 to v35.37) changed these on purpose, so each check now tests the old screen. Parked in tools/handoff/stable-known-red.txt so stable is not blocked; retarget each through fixq (lock.sh, edit tools/mkfixture.ps1, HELD=1 fixq.sh "retarget NN.NN: reason", unlock.sh) so it tests the new behaviour, then remove its known-red line.
- 9.09: aim at the pillager board, not the first minimise glyph (contracts card folds, v35.36).
- 9.66 and 12.80: the contracts card folds to 300x38 at rest; the note line shows only while the run info card is open (v35.36 change 3).
- 12.74: the "need $N" refusal goes to the left feed, not g.msg (v35.30).
- 13.08 and 32.24: the belt caption and its fire chip were deleted on purpose (v35.36 change 4); retarget or retire.
- 31.38 and 31.17: the stamina bar draws only below full stamina.
- 18.41: the posture word shows only when crouched or down. 18.49: the HIDDEN chip is a status icon now (cw-quiettext).
- 25.66: the boss-spotted alert replaces the location tag (one alert at a time at top centre); confirm with a probe first.
- 15.79: after an extraction out word a late position word no longer redraws the teammate (v35.37 cw-xsink, job 189).
TASK DONE when all 12 pass on the current build and their known-red lines are gone, or PARTIAL naming any that should be retired instead.
ADDED 10-28 02:00 (CEO; sorted from run corpus-1027-2310 by commit 35fcbf4d8), 5 more to retarget the same way:
- 16.43 and 16.46: they look for pinging only through NET.on, but pings work solo since v35.41 (task 139).
- 23.02: the ping label is a lower case plate since v35.43 (cw-cx-pingread); the check wants CRIER in capitals.
- 23.10: a finished goal now waits 4 s without a shot (v35.44 cw-msgroute); one line shows at once, the second 2.5 s later.
- 32.69: the stash item line is a fixed 160px box that always shows, since v35.42 (his stash hover order).
ADDED 10-28 04:00 (sorted from run corpus-1028-0157 on v35.58, the stable triage commit after 35fcbf4d8), 4 more to retarget the same way:
- 34.26: concealed and in cover are state icons with a brief word on the vitals now (v35.49), at the vitals scale (24 px at 1080p); the check wants the old 19 px chip.
- 27.35: the feed zone is 28 percent of the width since v35.53 (cw-hudsize, 20 px feed text); the check allows a quarter at most. Retarget to 28 percent and keep the controls list inside 47 percent.
- 13.32: the loaner hint draws on the answer line under the character since v35.52 (cw-answerline), not in the feed; read the answer line (G.ans) for "equip your own gun".
- 16.44: kid mode is applied through _hitMul in damagePlayer since v35.54 (o-120e); replace the source-text read for "amt*=netKidMul()" with a real hit on player 2 that proves the cut (check the damage taken, not the text).
ADDED 10-28 07:50 (sorted from run corpus-1028-0442 on v35.65), 3 more to retarget the same way:
- 31.50: it finds the score and clock plate by y0 at 1 or less; v35.64 (cw-cx-hudtvread) insets the plate 16 px (times the hud zoom) from the top edge. Find it by being centred at the top and holding the SCORE label, keep the label-overlap asserts.
- 30.96: it wants the plate hung from the top edge (y at or under 0); it is inset since v35.64. Keep the centred and covers-the-clock-row asserts, expect y near 16 times the zoom.
- 27.22: the empty gun key ghost is 0.1215 alpha in a raid since v35.64 (GHOST_A times 0.45, empty belt slots quieter for tv); allow that value and keep the carried gun opaque and the dragged-off key returning to its ghost.
ADDED 10-28 10:29 (sorted from run corpus-1028-0722; rerun alone on v35.79 in a fresh profile with normal motion), 1 more to retarget the same way:
- 26.46: part ONE wants a fresh profile on standard shake (1) stepping 1 > 1.5 > 0 > 0.5 > 1; every new profile starts on the new player set since v35.72 (cw-newpdefs, job 204), light shake 0.5, stepping 0.5 > 1 > 1.5 > 0 > 0.5 (check 35.72 needs it). Retarget part ONE's shake entry to that default and steps (the brightness and SHOW FPS rows and the later parts already pass), then remove its known-red line.
ADDED 10-28 12:31 (sorted from run corpus-1028-0934 on v35.76; rerun alone on v35.82 and v35.83, each with its own fixture), 5 more to retarget the same way:
- 33.01: its EVENT part reads evEligible() straight after arcadeDeploy and wants all five raid events; every demo start takes the new player set since v35.72 (cw-newpdefs, job 204), with debris, bounty and rampage off (xfEvDebris, xfEvBounty, xfEvRamp 1 = off). Just before was=evEligible(), set the five XF_EV keys on and call xfSnap(); keep the on and off asserts. Optional: also assert the demo starts with debris, bounty and rampage off and convoy and cool on.
- 27.37: part TWO wants debris and bounty planned over 240 seeds in a demo raid; the same new player set has them off. Switch the event rows on (CFG plus xfSnap, put back in finally) around the seed loop, or require only the kinds evEligible() returns while still asserting lockdown is never planned. Leave ONE, THREE and FOUR as they are.
- 26.47: part ONE wants a fresh profile on the standard crosshair (xhSz 1) stepping 1 > 1.3 > 1.6 > 0.8 > 1; every new profile starts on the large crosshair 1.3 since v35.72, stepping 1.3 > 1.6 > 0.8 > 1 > 1.3 (check 35.72 needs it). Retarget part ONE's xhSz entry to the row default and its steps, the same way as 26.46 (style, colour and parts TWO on already pass).
- 27.44: part FOUR wants the keyboard finisher prompt HOLD [V] FINISH; the finisher rides the melee key, on Z by default since v35.74 (cw-meleez, job 203, check 35.74 requires Z). Expect 'HOLD ['+keyName(keysOf('KeyV'))+'] FINISH' (Z by default) in the keyboard branch; the pad branch (HOLD [Y] FINISH) already passes.
- 27.36: the air strike plate stands 8 px over the drawn gun card (GUNCARD), right edges flush, since v35.80 (cw-clockcard, job 186h item 12); the 61b7616af retarget measures HUDBOX.gear, the mouse box that starts 46 px above the drawn card. Use GUNCARD for the overlap, flush and above tests (when GUNCARD.g===G and w, h are above 0), falling back to HUDBOX.gear only when no card is drawn (bag open), as check 35.80 does.
ADDED 10-28 14:01 (sorted from run corpus-1028-1057 on v35.80; rerun alone on v35.89 and v35.90, each with its own fixture, in a fresh profile; every retarget below was tried on a scratch copy of the v35.89 fixture and passes twice), 9 more to retarget the same way:
- 25.86: the demo takes the new player set at every start since v35.72 (cw-newpdefs, job 204, "and for arcade mode"), so it runs the long clock dial 900 against the reset career 540 and draws its first weather turn from a wider window. Call newpDials() just before rs0=CFG.raidSec so the career raid builds on the same list; keep the raidSec, weather and come back at leave asserts.
- 24.76: the same list puts the demo on forgiving hits (eDmg 0.7, 20 takes 14). Call newpDials() after __resetCfg() so the career hit is on the same dials; keep the equal hit assert (it still proves no kid mode half damage in the demo).
- 23.21: its dial assert accepts raidSec 0 or the career value, but the demo sets the new player clock 900 (it passes alone only because a fresh profile sits on 900 too). Also accept newpRow('clock').opts[NEWP_SET.clock].cfg.raidSec; leave the 10 minute raidLen, ring, kit and come back asserts as they are.
- 25.75: melee is on Z by default since v35.74 (cw-meleez, job 203); the compact list reads Z melee. Replace want.V='melee' with the Z key (keyName(keysOf('KeyV'))).
- 25.67: it presses the physical V key for the crowbar; V is drop now. Press keysOf('KeyV') (Z by default) for mkM.
- 18.27: the key list TEAM row for a teammate drop is V now. Look for keyName(keysOf('KeyZ')) instead of 'Z'.
- 18.17: same TEAM row read; it returns there, so retarget the row key to keyName(keysOf('KeyZ')) and the rest of the check (pad row, stash key bar, Party window, compact legend) already passes.
- 17.55: the party backpack line on keys says V drop for teammate. Match keyName(keysOf('KeyZ'))+' drop' instead of Z drop.
- 15.59: the raid backpack gun hint reads V drop one. Build the needle ZN from keyName(keysOf('KeyZ'))+' drop'+' one'; the raidKey('KeyZ') drop and the floor parts already pass.

ADDED 10-28 (CEO): v26.72 is a flake, not out of date: its first part rolls elite affixes before it resets the settings, so a demo raid started by 26.74 or 26.73 just before it (demo has elite affixes off since v35.72) leaves them off. Cure: __resetCfg(); xfSnap(); before the affix rolls (passes twice alone and after a demo start). Then remove its known-red line.

ADDED 10-28 15:35 (JTPC Correspondent; red in every spare PC full run since v35.76, through corpus-1028-1346 on v35.89). Not in known-red: stable-baseline.txt already ignores them, so they block nothing, but while they stay red they guard nothing either. Retarget the same way:
- 10.64, 11.27, 11.38: they press F for the crowbar ("F did not swing", "melee count 0 to 0"); melee is on Z since v35.74 (cw-meleez, job 203, his order). Press keysOf('KeyV') (Z by default), as 25.67 does. 11.38's merc and hostile parts already pass once the swing lands.
- 11.26: the pause box key line wants "V melee"; it reads the melee key from keysOf now. Expect keyName(keysOf('KeyV'))+' melee'; keep the no literal entity assert.
- 23.56: an arcade valuable worth 70 pays 95 (pot, score and the +SP tag) because the full run's settings sit above default and every harder row pays 5 percent a step since v35.68 (his order). In arcade the pot is the score, so it multiplies with it. Stage the default settings (multiplier x1.00) before the pickup so the check still proves pot = score = value; or expect value times the live multiplier.
- 22.32: the Pillbox alert draws at 30px while the callout size computes 29.7px (from v35.54 on). Not visible. Compare the sizes within 1 px, keep the font family and the alert words.
