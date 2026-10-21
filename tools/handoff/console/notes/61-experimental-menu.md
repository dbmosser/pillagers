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

--- codex run 2026-10-20 23:22 ---
2026-10-20, lane o, HEAD v33.18: refreshed the shipped flag map before building. Earlier notes and the task draft describe missing code that is already shipped (v32.99 to v33.06).

28 rows remain. Removed features stay removed: golden clue hunt, mimic crates, lockdown alarm, magnet, whisper and marksman. No duplicate damage-numbers control.

Refreshed entry points:
- xfGoals: goalsTick; xfGold: goldTick; xfHold: shTick; xfPwr: pwrKill.
- xfRoles: raiderRole; xfSupp: suppHit; xfFeud: machFoe and machine/pillager target routing; xfAffix: affixApply; xfOvPh: overseerTick and damage overheat multiplier.
- xfStyle: styleKill, styleTick and styleDraw; xfTeam: teamKill, arcadeTeamTake and teamDraw; xfFire: fuel-fire planning in fireTick.
- xfEvDebris, xfEvConvoy, xfEvBounty, xfEvCool, xfEvRamp: evEligible through XF_EV.
- xfWarden: directional armour damage branch; xfBarrel: brlPlace; xfRamp: waveTier; xfTell: aimLane plus landing-circle pass; xfSearch: scan/search helpers and stuck movement branches.
- xfDir: flowDir, flowAmbushOk and extraction-ring wave rule; xfAir: airScan, airKey, airCharge, pad chord, network air word and goalsMake pool.
- xfNeed: needRefresh; xfHaul: haulRevealStart; xfShop: shopStocked; xfSeed: arcadePartySeed and operator notes.

The 24 world switches already snapshot at startRaid. Found a requirement gap: the other four read CFG live, and netUpStart restores the guest CFG after building, so needed-item glow and haul reveal can disagree with the host. Plan: snapshot every key; use that snapshot for local-feature calls during a raid and for the result haul. Shop and party seed still read preferences outside a raid, when their controls act. Existing on/off checks explicitly call xfSnap, so their feature checks remain valid.

The task still needs an all-off seed-4242 fingerprint check and page pictures/critic at 1080 and 4K. Standalone camera recipes avoid editing the shared screen catalog and the old blocked screen-79 question.

Handed over cw-cx-expsnap: five unique anchors validated against v33.18. It snapshots all 28 keys, reads that snapshot for the four formerly local keys during a raid, and keeps the haul choice through the result card. The shop and party-seed preferences still act outside raids. No preference is switched off by this change.

Check: actual deployments on both sectors, seed 4242, all on and all off; expected 85/374 bodies and 165/593 containers, plus complete netUpFp equality on/off. Elite-affix properties are initialized during building and barrels have their own G.brl list; neither should change canonical geometry/body/container fingerprints. Actual needRefresh and haulRevealStart calls prove on behavior still works and mid-raid preference changes wait. Actual netUpStart calls with opposite guest preferences cover host-off and omitted/default host-on wire values after guest CFG is restored. The old build necessarily fails because the four local keys are absent from XF and use live guest CFG.

Local validation: script prints written, each of five draft anchors occurs once, complete candidate game JS parses, check JS parses, camera prelude and recipe JS parse, handoff files are ASCII. Chrome checks cannot run in this sandbox; lane preflight and ship remain required. Existing feature checks use xfSnap after selecting each value and should need no retarget.

Camera handoff: camera-recipes.json, five screens (top/middle/bottom plus host and player-2 windows) with default Res 1080,4k. The first three open the real Settings experimental row and verify controller B returns to main Settings. The pair recipes open a second fixture window, pass the host raid word through real netUpStart, verify host-off glow/haul despite guest on preferences, and photograph each named window. These stage the shared raid word across two real windows, not a live network transport session. Every popup is closed on pagehide. Critic results and any fixes remain pending.

Watch on next play: change glow or haul during a raid and confirm it takes effect on the next raid; in two windows, start with opposite experimental preferences and confirm the host choice wins. All-on should look and play as before.

--- codex run 2026-10-20 23:45 ---
2026-10-20, lane o, continued on refreshed v33.22.
Confirmed cw-cx-expsnap shipped as v33.21, commit 659bdb1b. Its actual Chrome check passed and verifySafe held: bodies 85/374, containers 165/593. Round-1 recipes staged every view with zero lint issues. Two real fixture windows took the same seed-4242 host word and both kept glow 0 / haul false after restoring guest preferences and changing next-raid preferences to on. Pictures 82 and 83 are the separate window evidence.

Viewed round-1 page pictures. Critic scored every view 2. Main defects: 288px reserved category gutter on a page without categories; description stretched away from its heading by the old flex-wrap/flex-basis combination; Back presented as a value row; no groups; weak idle state/value distinction. Same-layout follow-up cw-cx-expui removes the unused gutter only on the experimental page, adds four short group headings, puts the existing Back action in a 64px sticky header with a 28-feature count, names the page settings / experimental, uses the existing steppers with quiet on/off value chips, makes only focused arrows visible, uses 20px high-contrast names/effects and keeps the 48px control hit area. The detail pane stacks its existing title, value and effect at 16px gaps, with next-raid timing and the held raid value below. Main Settings layout remains the existing one on return. No gameplay values or switches change.

Q8 text reasons: remove repeated event: prefixes because the five rows now sit under events; show pillager bot roles and machines vs pillager bots to follow his AI-human terminology; breadcrumb identifies the sub-page when scrolled; shorter keyboard/pad footer accurately says Back while inside the sub-page. Kept the existing list/detail design and controls. Did not add a category rail or introduce a different screen design. State chips stay quiet when idle because the style guide reserves lime for focus.

Updated recipes: sticky header is included in scroll calculations; middle view temporarily switches orbital debris off only in the fresh camera fixture to photograph both states. Pair views focus needed-item glow and show next-raid on beside this-raid off; the guest also says host choice. The two-window staging still passes the actual raid word through netUpStart, rather than staging a live transport connection.

Local checks: five unique anchors, script prints written, complete candidate game JS parses, UI regression check and all camera recipes parse. New UI check covers all 28 rows/defaults, four groups, removed left padding, Back outside the toggle rows, top-aligned visible state/effect, off click/save/on restoration, and ordinary Settings layout restored on Back. No old fixture retarget appears necessary.

4K is still owed by the lane: tools/codex-lane.sh hardcodes -Res 1080 in its recipe runner. Logged an alarm requesting a manual 4K round or optional resolutions support; recipe now explicitly includes resolutions: 1080,4k. Round 1 contains only 1080 images despite the task requirement. Need lane preflight/ship of cw-cx-expui, round-2 photographs and critic, plus 4K coverage. Watch on next play: Back/B should return to ordinary Settings and values changed mid-raid should wait for the next raid.

--- codex run 2026-10-21 00:01 ---
2026-10-21, lane o, continued on refreshed v33.28.
cw-cx-expui shipped in v33.28. Round-2 pictures staged all five screens with zero lint issues; repeated two-window host-choice verification passed. Critic: top/middle/bottom/host 2, guest 3. Viewed the host image and confirmed the remaining defects. The hidden group labels were not a text mistake: old cw-setsechd sets height, min-height and padding to zero with !important on every section header, defeating the first follow-up. The focus glow and white bracket are the global outline/box-shadow !important rule at 1068-1071. The first UI check proved group nodes existed but did not measure their visibility; the new one measures it.

Prepared cw-cx-explayout as the second UI follow-up. Same Settings list/detail layout. Four unique game anchors. The one existing list node moves into an experimental-only flex column with the existing Back/count header above it; Back is physically outside the scroller, and leaving the sub-page moves the same list node back to its ordinary parent. This preserves listeners and prevents rows showing above the Back band. Scoped important overrides give the four group labels an actual 48px height and 16px text. Value focus drops the inherited glow, outline, bracket and nested chip border; the row bar/fill remains. Default on values become quiet unboxed text, off keeps a warning outline, arrows stay tx-2. Detail value chip hides; its pane fits its content with the existing 32px heading and 20px effect/timing text. Count and footer are 20px for couch reading. The existing scroll fade remains, with a 12px top fade only inside the clipped list.

Fixture handoff: fixture-retarget.json changes only v33.28, accepting the existing visible state in either the row or the detail pane. It passes on the old page (detail state visible) and new page (row state visible), instead of requiring a duplicate chip. One exact anchor found once. The file names cw-cx-explayout as its dependent key and asks to run 33.28 before shipping. The new check measures visible group labels, fixed header vs scroller geometry, computed focus outline/box-shadow, control height within its row, hidden duplicate detail chip, short detail pane, 20px notes, all 28 rows, off/on clicks and restoration of ordinary Settings.

Local validation: maker prints written, all four game anchors unique, candidate game/check/retarget JavaScript parse. Chrome preflight, actual v33.28 retarget run, ship and round-3 critic remain the lane work. Existing two-window recipes still apply: scroll math no longer finds an in-list header, because that header now lives outside the scroller. No feature guard, default, profile field or map-building behavior changed.

4K remains pending from the coordinator. The previous alarm identifies the recipe runner hardcoding -Res 1080; the recipe already requests resolutions 1080,4k, but round 2 again supplied 1080 files only. No duplicate alarm or question added. Finish the 4K capture on lane o port 9364 using the same recipe after the last UI ship.

Before pictures: tools/handoff/console/notes/shots/61-experimental-menu-recipes-2/79-experimental-top-1080.jpg and 80-83. Current best views are round-2 guest (critic 3) and round-2 top/host (critic 2); keep round-2 and upcoming round-3 as the comparison if the next follow-up cannot raise the score. Watch next play: all four group labels must show, Back/B must return to Settings, and a focused value must stay within its row without glow or a bracket.
