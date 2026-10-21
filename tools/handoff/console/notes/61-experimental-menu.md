# 61-experimental-menu notes (lane b)

## Refreshed flag map (HEAD v32.97, 2026-10-20). Detail per feature: tools/handoff/research/experimental-flags-2026-10-15.md section 4 (re-grep each function, line numbers are stale)
Dropped (gone from the file or vetoed): golden clue hunt (clueTick gone), mimic crates (gone v30.94), lockdown alarm (EVENTS.lock gone v27.37), magnet inside power-ups (already removed), whisper and marksman guns (not a switch anyway).
Still present, 26 switches left to build:
- WORLD: xfDir (flowDir, flowAmbushOk, arcadeWaveOk ring), xfRamp (waveTier), xfAir (airKey, airScan, airCharge, pad chord, flowNetWord air, goalsMake pool air1), xfFire (fireTick plan block only), xfEvDebris/Convoy/Bounty/Cool/Rampage (evEligible loop, XF_EV map), xfBarrel (brlTick area), xfRoles (raiderRole), xfSupp (suppHit), xfFeud (machFoe, machHuntRaider), xfSearch, xfTell (aim lanes), xfAffix (affixApply), xfWarden, xfOvPh (overseerTick + overheat 1.5 line), xfStyle (styleKill, styleTick calm block, styleDraw ring), xfTeam (teamKill, arcadeTeamTake, teamDraw)
- LOCAL: xfSeed (arcadePartySeed + two ARCOP texts), xfNeed (needItems), xfHaul, xfShop (shopStocked)
No second control: none of these has a Settings row already (dmgNumbers is the damage-numbers row, left alone).

## Design as built (v32.99, cw-expmenu1)
- XF_ROWS table next to DEF (add a row above `// XF_ROWS_END`, trailing comma). Each key is a DEF key (on = 1). xfSnap() in startRaid before buildRaid; xf(k) for world switches; xfL(k) for local.
- Rows are GAMEOPTS entries with sec 'EXPERIMENTAL' (not in SETSEC): the main list never draws them; SETSUB='exp' draws expPage. closesettings (esc, B) leaves the page first.
- Check in draft cw-expmenu1 covers rows, defaults, clicks, all-on runs, all-off does not run.

## Shipped
- v32.99 cw-expmenu1: menu + run goals, golden enemy, strongholds, power-ups.

## Pictures
- shots/61-experimental-menu-after1/73-settings-sec-accessibility-1080.jpg: the open row (was lead of accessibility; moving it to the end of the raid section).
- The sub-page itself cannot be shot until screen 79 is allowed (question in questions.md).

## STATUS 10-20 (end of run): all 28 switches shipped
Ships: v32.99 menu + goals, gold, strongholds, power-ups. v33.00 roles, suppression, machines vs pillagers, elite affixes, overseer phases (and the open row moved to the end of THE RAID). v33.01 style medals, team combo, fuel fires, five raid events. v33.02 warden armour, barrels, waves grow, aim lanes, search rings. v33.03 raid director, air strike. v33.04 what is new card (polish pass 40, only because the stamp went stale). v33.05 needed-item glow, haul reveal, shop re-roll (local). v33.06 party seed (local).
Dropped as gone: golden clue hunt, mimic crates, lockdown alarm (30 minus 3 = 27, plus the five events counted one by one = 28 rows).
Each ship: preflight pass, gate pass, fingerprint ents 85/374, containers 165/593 with all switches on.
Fingerprint with switches off: the affix check proves the body count of seed 4242 is unchanged with affixes off; barrels go in G.brl (not ents or containers). No other switch touches map building (the map says the rest run after buildRaid). A single all-off fingerprint check was not written (a check needs a game change to ship in).
Not tested by a check: the pad chord guard (xfAir), flowNetWord 'air' guard, the overheat 1.5x line (xfOvPh), the stuck-rule lines (xfSearch). All are one-condition edits next to guarded code.

## Pictures and critic: NOT DONE
The camera has no screen for the experimental page (adding one needs his OK, question logged in questions.md). Only the open row was shot (shots/61-experimental-menu-after1/73-settings-sec-accessibility-1080.jpg, taken before the row moved to THE RAID).
Left: add screen 79 (SETSUB='exp'; renderSettings()), shoot 1080 and 4K, run the critic (finish line 3).

## Run 10-20 evening
Shot screen 68 (the raid section) at 1080: shots/61-experimental-menu-after2/68-settings-sec-the-raid-1080.jpg. The "experimental / open" row sits at the end of THE RAID, matches the other rows, lint 0 issues. The sub-page itself still cannot be shot: screen 79 needs his OK (question already in questions.md, not asked again). When allowed: add 79 (open settings as screen 18 does, then SETSUB='exp'; renderSettings()), shoot 1080 and 4K, run the critic (finish line 3).

## Run 10-20 late (lane a)
Checked HEAD: menu, all 28 switches shipped, nothing to build. Question for screen 79 still open (questions.md line 47), no answer yet, so the sub-page picture and critic stay undone. When allowed: add 79, shoot 1080 and 4K, critic (finish line 3).
