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

## Left
(see end of file, updated each ship)
