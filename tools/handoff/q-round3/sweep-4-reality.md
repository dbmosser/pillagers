# sweep 4: what he said versus what the game does

Snapshot: HEAD 76bf6ae6 = v30.86, Sun 10-18 about 16:05 EDT. Helpers land a build roughly every 3 minutes (178 builds today, 351 since 10-15), so an item marked "in progress" may have landed since. A few edits sat uncommitted in the game file while I read; I treated HEAD as the truth.

How I checked: read his orders in the 12 memory files, grepped the game file for the code comments that quote them ("HIS ORDER/ANSWER"), read the commit for each, read the helpers' own notes (tools/handoff/console/notes), and looked at 4 screenshots. I did not run the game, did not open a browser, did not touch :8802, wrote nothing but this file.

Counts: matches 63, gaps 14, helper changes to confirm 12.

Two orders appear in the code and commits but in none of the 12 memory files. I counted them as his, because the code quotes them as his: "i don't like the multiplier next to the reticule, get rid of that" (cw-nomult) and "add a rocket launcher as '0' ... 30 ammo per rocket ... reload after 2 rockets" (cw-rocket). A third, cw-downgain (a hit on a downed player gives half a second back, "his words 2026-10-18"), is in a fixture commit with no game ship yet. Worth adding all three to memory.

---

## part 1: matches (done as he said)

Afternoon orders, 10-18 (his first look at two windows)
- M1. All text lower case -> v30.72 c66dfd9e (ncFix lower-cases everything, NCLOWER=1, CSS text-transform off); the all-caps removal began at v29.11 and v29.14.
- M2. Keys go to the window in front -> v30.68 8e7759af (the player 2 window plays its own keys and hands none to player 1).
- M3. First pad plugged in is player 2, second is player 1, one pad alone is player 2 -> v30.70 a3a44aff.
- M4. Key and pad prompts switch live with the last input used -> v30.66 fe3bb868, v30.75 f44a74a2, v30.77 49a0578e (player 2 window too).
- M5. A name typed on the title goes into "create a new save" -> v30.80 8b50cbc2 (newNameKeep / newNameTake: same slot, only a save with no raids, within 2 minutes, once).
- M6. Players 1 and 2 see each other in the Undercroft -> v30.84 1996cc57 and v30.86 76bf6ae6 (the other window is drawn over the pair channel with a name; player 2 arrives beside player 1). Needs a real two-window look; the lane tested with its own harness.
- M7. "Get rid of the multiplier next to the reticule" -> v30.81 12de1421 (the ring stays, the number is gone; the multiplier still shows by the score).
- M8. "100 new questions like last time" -> Desktop\dark raiders\questions-100-round2.md (13:23).

His answers 1-78, 10-18
- M9. Q5 raider rises up from underground and rare drops get light shafts -> v30.34 d99bcb15.
- M10. Q5 small art touches (pack buckle, boot laces, jersey shadow) -> v30.31 90f3bf0c.
- M11. Q9 problem report text box in the pause menu -> v30.37 d1a90622.
- M12. Q18 75 percent of overnight robot time on the real 2-player demo -> tools/fuzz.ps1 -P2Share default 75.
- M13. Q21 TV-size text on by default in the demo -> v30.29 a8cc0df4 (HUD scale 1.5, menu zoom 1.25 in the demo profile).
- M14. Q29 a pause stays paused until a player unpauses -> v30.42 65a00a29.
- M15. Q30 all settings reachable from the demo pause menu -> the pause box has the Settings button in the demo too (pausesetbtn -> openSettings).
- M16. Q31 no operator volume or end-run controls -> the operator card is two rows, New party and Exit demo (v30.14 722af49c).
- M17. Q44 no pixel font -> fonts are Barlow and Barlow Condensed; no pixel face anywhere.
- M18. Q46 lime yellow accent -> v30.61 2f5a22dc (--acc #e6ff3d).
- M19. Q47 livelier motion with bounce -> v29.60 (motion layer) then v30.85 9957088f (windows rise 24 px and overshoot 8 percent, confirm pulse 1.08, deny shake).
- M20. Q50 and Q53 keep the normal title, no raiders beside the logo -> no party title exists; party mode skips the title entirely.
- M21. Q51 story paragraph and step cards replaced by one line -> v30.41 f639c53a, v30.43, v30.48, v30.60.
- M22. Q55 demo hides credits, XP, stash and bag -> v30.51 931d4420 (trDemo, syncTopRight).
- M23. Q56 demo also hides the item-value line and backpack hint, keeps run goals -> v30.53 6041e470.
- M24. Q57 ammo is the hero number -> v30.59 d510a90d (ammoDraw: rounds big, reserve small). The "redesign the whole HUD" half is gap G6.
- M25. Q59 SP for score, $ for money -> arcadeCr gives "N SP", arcadeMoney gives "$N"; v28.71. One leftover in the Career corner (G4).
- M26. Q61 keep the feedback line, button and Send play data -> the pause feedback box (v30.37) and the Send play data chip in Settings.
- M27. Q62 and Q63 one board entry per player, block rude initials -> v30.36 f77f1b3b (ARCADE_INI_RUDE).
- M28. Q64 keep the low-ammo box marker -> ammoTell(ct) still marks the box.
- M29. Q65 in 2P the run ends when both players are out -> v30.33 7f039f5c.
- M30. Q66 the game asks about easy mode -> v30.32 3462496c (asked once, after a player's second death; yes = a third less damage).
- M31. Q67 same kit all night, new kit after NEW PARTY -> v30.47 7fdcc80b.
- M32. Q68 vault guns drop from golden enemies, the Overseer, and rarely anywhere -> v30.26 bfe3674e.
- M33. Q69 Whisper and Marksman removed -> v29.58 098560a9 (no weapon row, no class key).
- M34. Q70 no tutorial prompts -> v30.50 16e9200e (arcadeCardOn returns 0; the how-to page and F1 keep the rows). Note: lane d still restyled that dead card in v30.10 and v30.12, wasted work, nothing visible.
- M35. Q71 no live rank, no scoreboard until the run is over -> v30.45 f1ae6039.
- M36. Q72 hide PvP -> v30.25 0201346b.
- M37. Q73 drawn gear replaces the marks over pillagers' heads -> v30.27 4a3c8d16 (cw-rolegear).
- M38. Q76 clean the swearing, keep the attitude -> v30.28 bb8907ba.
- M39. Q77 do not hide Liquor and Blotter -> both are still in the shop and the effects code, nothing hides them.
- M40. Q78 every gun on its own key -> read as option a, the class keys fixed it: GUN_CLASSES has 9 classes plus the rocket on key 0 (v29.15 21ff980d, v29.18 7d995208).
- M41. Q35 first real 2-player test today -> he did it around 12:00.
- M42. Q13 to Q15 dates -> Desktop\dark raiders\party-day-stop-list.md exists (10:35); I did not read it line by line.
- M43. Rocket launcher on key 0, 30 ammo per rocket, reload after 2 -> v29.18 (rocket: mag 2, reload 3600, rkt:1).

Polish answers 10-15 and the 10-14 picks
- M44. Halo Reach DMR bloom -> v27.79 7a61785d; the bloom resets with a snap v27.80.
- M45. LMG fires faster once spun up -> v27.52 d2ffe360; heat spread added v29.23.
- M46. Active reload bar has a clear red zone -> v27.81 f0fdd5cc.
- M47. A prompt tells how to do the finisher -> v27.83 d4353a8b.
- M48. Golden clue hunt cut, golden enemy stays every raid -> v27.47 dbc61064.
- M49. Halo-style medals, all of them -> v27.38 to v27.40 (emblems, sounds by tier).
- M50. Weak spot shows its multiplier -> v28.22 edaa12c6 (weakTxt, "weak spot 2.4x").
- M51. Damage numbers coloured by weak spot or element -> v27.85 92d1fb5a.
- M52. Power-ups are big floating icons; magnet gone -> v28.27 ea9048fe and v27.92 ea508bdd.
- M53. Strongholds are real buildings only -> v27.46 cf6ed973 (and v29.09 keeps one off the forge).
- M54. Lockdown alarm gone for good -> v27.37 df2f7403 (EV_IDS lists five events).

Older rulings, spot-checked
- M55. 4th fifty: demo board 20 rows (v27.97), bigger clock (v27.99), random character (v28.00), What's New is a pause button (v27.93), camera zooms out on sprint (v28.24), no headshots (nohead).
- M56. Item wheel is the fixed 8-slot ring in his order (WHEEL_ORDER: medkit, smoke, frag, tripwire, plate, decoy, bandage, stim).
- M57. Gun keys by class, ghost silhouettes for empty class keys (gunghost), rarity variants 20 percent at x1.25 damage only (RV_PCT, VARIANT_DMG).
- M58. Random kit (2 guns, 1 of each wheel item) and best kit (3 guns, up to 3 of each) are rows on the map select screen; pre-raid cash and item picking (v28.91, v28.94).
- M59. Starter guns removed (v26.35), Scav Pistol spawn-only, no loaner guns.
- M60. The Forge: station in every raid (v26.20), MK II 2,500 / MK III 6,000, four elements, forged guns stay forged when dropped.
- M61. 10-12 night NEVER BRING BACK list: no 3-2-1 start (v25.00), no pillager words (notaunt), no "carrying medical" line, no tonal hums (v25.11), no machine count on SIEGE INCOMING (v25.62), no backpack-size words, no "search resumed", no spoken announcer (noannouncer), "spotted by the overseer" named, one low siren. All grep clean.
- M62. 10-12 fifty: no Halloween dressing (only old comments mention it), Cold Storage only and the bigger map disabled, DEMO and CAREER play the same (demounify).
- M63. Career leaderboard after every match (his 10-15 order, which reversed the 10-13 "personal best only") -> v28.05 1b59c727, P.careerBoard.

---

## part 2: gaps (not done, partly done, done differently, or undone)

### G1. The critic's finish line of 4 is far away, and three lanes wait on answers he already gave
- He said: Q6 "The critic finish line is 4 everywhere" and Q7 "The style guide can overrule his existing guidance (layout and size)", Q8 helpers may shorten or delete his lines "if it overrides my language, it better have a damn good reason" (pillagers-answers-1-78-2026-10-18.md).
- Game does: console/notes/ui/accept.json scores 57 screens: 0 at 4 or higher, 36 at 2, 20 at 3, 1 at 1. The raid HUD (screens 21 and 50) is still 2. Lane b-31 (Undercroft) wrote runs 4 to 8 "waiting on his word" on three rulings: centred card with a close X, the "$ price", and "explaining sentences" (b-31-ui-undercroft.md). His Q43 (centred card with an X), Q59 ($ for money) and Q7/Q8 (override layout, shorten his lines) already answer all three. Lane c-31 lists the same pattern: stuck screens whose critic asks contradict each other ("asks for a 55 percent dimmed world and also hide HUD").
- Why it matters: the Undercroft and Settings are one-third of the 56 screens and the lanes are idle on them, with 8 days to the 10/26 cutoff.
- Two parts. (a) No question, just finish it: tell lanes b-31, c-31, e that Q7, Q8, Q43 and Q59 settle their three open rulings, and let them proceed (ONE GRID and the bottom CLOSE button give way to the centred card with an X).
- (b) Draft question: "The AI picture judge sometimes gives a screen 3 no matter what the helpers try, and sometimes contradicts itself. If a screen sits at 3 after two honest tries, can you just look at the picture and say it is fine?  a) Yes, send me the pictures in a batch and my yes counts as a 4   b) No, keep trying until the judge says 4   c) Yes for party screens (the ones guests see), 4 for the rest."  My pick: c, because the guests only see the party screens and credits spent chasing a noisy judge on the Undercroft come out of the same weekly allowance.

### G2. Q43 windows are not "nearly the entire screen", and some got smaller
- He said: Q43 "Centred card with an X, taking up nearly the entire screen" (answers-1-78).
- Game does: the X exists (pause v29.96, operator v29.91, settings and keys v29.98, arcade cards v30.78, welcome pack v30.00) but cards are small: Settings is about 765 by 765 at 1080p in the latest picture (shots/c-31r3c-after/72-settings-sec-display-1080.jpg), pause is 480 wide, the what's-new card 720, the board card 560 (it was 845, narrowed in v29.41), the welcome pack 960. The style guide says 90 by 90 percent and the task cw-cardwide ("Q43 windows") is still unshipped (04-style-guide-update.md). The helpers have been shrinking cards because the critic marks full slabs down, which is the opposite of what he said. The bottom CLOSE button is also still on the stash and hub windows.
- Why it matters: this is the biggest visual difference between his answer and the game, and the critic and he want opposite things here.
- No question, just finish it: build cw-cardwide at 90 percent and send him one picture of Settings and one of the stash. If he then says it is too big, that is a new call.

### G3. Q1: only half done, the contracts left the raid and are not on the map
- He said: Q1 "Option b, but ALL contracts move to the map screen" (answers-1-78); the code comment says "the map screen lists all".
- Game does: Run info shows the 3 closest contracts (v30.49 01c580eb, runInfoCap, RUNINFO_MAX=3). drawMapOverlay (about line 44257) has no contract list at all, so mid-raid the player can see 3 contracts and cannot see the rest anywhere (the hold-Alt raid status shows the pillagers board, score, clock, extraction and teammates, no contracts).
- Why it matters: players lose information with no place to get it back.
- No question, just finish it: add a contracts list to the map screen (task 02-raid-hud-redesign).

### G4. Q58 one-row corner is not done, and the Career corner still shows "credits" without a $
- He said: Q58 "Career top-right goes into one row" (a: one row, nothing removed); Q59 "$ for money".
- Game does: syncTopRight still writes "900 credits  0 xp" plus a second line "stash n bag n" (.trsub, line 4392; the CSS puts the second line 40 px lower). The credits there are a plain number, not "$900". A separate agent called "Top-right HUD as one column" is running right now (named in this session's task list), so someone is already on it; I could not tell if "one column" matches his "one row".
- Why it matters: the lane's note said the corner was part of the raid HUD pass; the critic called it loose text.
- No question, just finish it: one row with stash and bag kept, money with a $. Check that the running agent builds a row and not a column.

### G5. Q60: ending a run early does not halve the score
- He said: Q60 "Ending early halves the score, the same as dying" (option b).
- Game does: arcadeRunEnd halves only for 'dead' and 'burn' (line about 61504: why==='dead'||why==='burn'). 'menu' (End run in the pause menu) and 'idle' pay in full; abandoning in Career pays x0.25 (separate rule, lines about 30800 and 31330).
- Why it matters: at a party a guest can bank a high score by ending the run instead of dying, which makes dying pointless.
- No question, just finish it: add 'menu' to the halving rule in the demo. One small thing to decide while there: does a player who extracts keep the x2, and does "idle" (walked away) also halve? My reading of his words: halve 'menu' only. I will leave 'idle' alone unless he says otherwise.

### G6. Q57 the raid HUD redesign is only partly done
- He said: Q57 "Ammo must be prominent. Ideally redesign the whole raid HUD."
- Game does: ammo is the hero number (v30.59) and the lime tab sits on the gun card only (v30.73), but 02-raid-hud-redesign.md says the critic still gives screens 21 and 50 a 2: hatched resize grips (now hover only, v30.62), no 1 px border, the 5 percent / 96 px margins are unmet (the minimap sits flush to the top and right), a "$" in the ammo panel, gradient vitals bars, toasts on the left.
- Why it matters: he told the helpers to do the raid screen first (Q49) and it is the weakest of the three.
- No question, just finish it.

### G7. Q52 and Q54: "live map with REAL pillager-vs-robot combat" was done differently
- He said: Q52 "Behind the title, scoreboard and how-to pages: the live map, dimmed, with real pillager-vs-robot combat in it"; Q54 "No attract clip. Use the live map."
- Game does: the backdrop is the dimmed Undercroft floor with a scripted two-fighter show (tskInit, tskStep, tskDraw: 2 pillagers plus robots, its own random numbers, no raid simulation), v30.69 be0a2a4c; the dimming was lightened at v30.65 dea3d542 and the fight made visible behind the scoreboard and how-to pages at v30.82 00c7596d. The lane note says a real fight "is a big engineering task, not started", and that 4K at 60 fps is not measured. The question to him is H2 below (part 3), not a second one.

### G8. Q48 "soft ticks, punchy hits on confirm and score": half done
- He said: Q48 "Soft ticks, punchy hits on confirm and score."
- Game does: the soft focus tick exists (SND_UI move: 22 ms, four pitches, at most one per 40 ms, v29.60); "ok" is a 90 ms triangle blip and I found no separate hit for the score count-up or the run-over card.
- Why it matters: small, but the run-over moment is the party's high point.
- No question, just finish it: a heavier "ok" and one hit per score tick on the run-over card.

### G9. Afternoon order 6: "p1 and p2 inconsistencies" is still in progress
- He said: "there seem to be a lot of inconsistencies between p1 and p2 games, please coordinate them better" (afternoon-orders).
- Game does: the lane note (p1p2-consistency.md) lists 10 differences, 8 of them marked OPEN when I read it: welcome pack shows under the player 2 attract, no run-over card in the player 2 window, names show as "Pillager" instead of "Player 2" over heads and in the teammate bar, a "You are hosting..." line only in player 1's pause box, settings dials that differ between the two saves, a "join your team" strip drawn behind the how-to card, and wording at the drop. Only the Undercroft sighting (M6) and the glyph switching (M4) have shipped. An agent is on it right now.
- No question, just finish it. After it ships, ask him for the next two-window look rather than guessing.

### G10. Q28: the one-click party shortcut is not usable yet
- He said: Q28 "one-click shortcut that opens both windows full screen on attract, with Career and stash out of reach".
- Game does: the game side shipped (v30.79 c67cad02: ?party=1&pair=CODE, no title, Career and saves out of reach, reload returns to the party attract). But tools\party\party.cfg still says URL_OPTIONS=0, so the shortcut does not use it and opens the plain title, where Career is one click away. And its only logged start (tools\party\party.log, 15:36) ended "the game server did not come up on http://localhost:8802/dark_raiders.html. Nothing opened."
- Why it matters: guests reaching Career or the stash is exactly what Q28 was meant to stop; and a shortcut that fails to start on the night is worse than none.
- No question, just finish it: set URL_OPTIONS=1 and have him double-click it once while he is at the PC, watching for the server start (the failure was the script starting its own server; the server may be fine when :8802 is already up).

### G11. 10-12 ruling: "the title highlights DEMO first" no longer holds
- He said: 10-12 answer 14, "The title highlights DEMO first", and the arcade-primary direction "Arcade first" (pillagers-fifty-answers-2026-10-12.md, pillagers-arcade-primary-2026-10-12.md).
- Game does: the title lists "1 player" (Career) first and highlights it; "2 player arcade demo" is third, "1 player arcade demo" fourth (lines about 2362 to 2370; the 1080 picture 01-title-mode-menu-1080.jpg). On 10-18 he said keep the normal title (Q50) and added the party shortcut that skips it, so the title now matters only for his own play and any outside player. Nobody has decided which row comes first since.
- Draft question: "Which row should the normal title highlight first?  a) 1 player (Career), as now   b) 2 player arcade demo   c) 1 player arcade demo."  My pick: b, because you ruled DEMO first on 10/12, the demo is the polished mode, and the party shortcut skips the title anyway, so nothing else depends on it.

### G12. Q12: stable builds exist only as a stale snapshot
- He said: Q12 "Tag builds as stable or intermediate, and his play window always loads the latest stable. Tell him what counts as stable."
- Game does: tools\stable.sh and stable.html exist, tag stable-v29.09 (10:23 today); HEAD is v30.86, about 177 builds later, and I found no written definition of "stable" or any automatic promotion.
- Draft question: "What should make a build 'stable' (the one your play window loads)?  a) a build that passed all the automatic checks and one 2-player test by you   b) the last build of each night that passed all the checks   c) only builds you name stable yourself."  My pick: b for now and a for the 10/29 lock, because b keeps your play window fresh without you doing anything, and a gives the party build a human check.

### G13. 10-15 polish #1: the EXPERIMENTAL settings section was never built
- He said: polish answer 1 "Create an EXPERIMENTAL section inside Settings where he can turn the new features on and off" (pillagers-polish-answers-2026-10-15.md); Q17 "After the rehearsal, switch off janky raid features rather than polish them."
- Game does: no such section; only the 30-switch plan exists (tools/handoff/research/experimental-flags-2026-10-15.md), and the drafts exp1 to exp4 were held for him.
- Why it matters: Q17 needs a way to switch a feature off in one place after the rehearsal; without it each switch-off is a code edit on the party's last days.
- Draft question: "After the party rehearsal, how do you want janky features switched off?  a) the full EXPERIMENTAL list in Settings (30 switches)   b) a short list for the 8 riskiest (air strike, fuel fires, raid director, events, strongholds, golden enemy, power-ups, mimics)   c) no menu, the helpers switch them off in the code when you say so."  My pick: b, because the plan says three of the 30 are the risky ones and the rest are safe, and a short list is quick to build and test before 10/26.

### G14. Bigger character art (Q5, Q74, and his 10-15 pick): only small touches shipped
- He said: 10-15 "Refined Chibi with Gear-heavy raider as may be appropriate" after "right direction but I want bigger art upgrade"; Q5 "bigger character art"; Q74 "The Chibi art goes in only if it is solid by the cutoff."
- Game does: the art lane found most of the gear details already existed and shipped smaller work: chipped paint and stripes on the Heavy and Raider sets (v29.43, v29.45, v29.46), a soft cast shadow under operators (v28.85) and under the held gun (v28.82), a smaller helmet crest (v28.79). The notes list "c. bake each look per facing and walk frame (biggest, riskiest)" and "d. before and after pictures" as not done, and say no picture was taken of a worn set.
- Draft question: "The art helpers added chips, stripes and shadows to the current characters but have not redrawn them in the chibi look. Do you want a picture first?  a) Yes, make one picture of one character today and one redrawn chibi version, and I pick   b) Keep what shipped   c) Build the full chibi redraw now."  My pick: a, because the cutoff is 10/26 and a redraw is the biggest and riskiest art job, so a picture costs little and can save a day of the wrong work.

---

## part 3: helper changes to confirm (made on their own, player-visible)

Format: what changed in plain words, then a keep question with my pick.

### H1. Screen kick per gun, and how far a hit body is shoved (10 builds)
- Commits: v30.35 c783bfae (Riot Scattergun), v30.40 6dcb9817 (Compact SMG), v30.44 ac0ae3c6 (Scav Pistol), v30.57 80d0b3c8 (Auto Rifle), v30.63 5970bbfb (Magnum), v30.64 8eb65cea (Support MG), v30.71 5e66f850 (Longshot); shoves v30.46 4841908d (Crawler), v30.52 57164807 (Raider), v30.54 8d330cb2 (Sentry).
- What changed: before, every light gun kicked the camera the same and every heavy one the same. Now: Scattergun 2.2 to 6.5, Longshot 4.5 to 7.0, Magnum 4.5 to 5.5, Scav Pistol 2.2 to 3.6, Auto Rifle 2.2 to 2.7, Compact SMG 2.2 to 1.9, Support MG 2.2 to 2.0 (the last two are lower so a held trigger does not climb into a heavy shake). In pixels at 1080p the biggest kick is about 4 px. A hit Crawler jumps back 8 px (was 5), a hit Raider 6.5 (was 5), a hit Sentry 3 (was 5).
- Question: "Keep the new per-gun screen kicks and the hit shoves?  a) Keep all   b) Keep the gun kicks, undo the shoves   c) Undo all."  My pick: a, because you asked for gun and enemy feel (Q5), every change is small, and tonight's 2-player test is where you will feel it.

### H2. The title and scoreboard backdrop (v30.65, v30.69, v30.82)
- Commits: dea3d542, be0a2a4c, 00c7596d.
- What changed: the dark scrim behind the title is lighter (centre .9 to .58, blur 3 to 5 px) so the world shows through, and a scripted fight (two pillagers and a robot) plays at the sides, now also behind the scoreboard and how-to pages. It is a show, not a real raid, so the winner is fixed and nothing reacts to anything.
- Question: "The title backdrop shows a staged pillager-and-robot fight, not real combat. A real one needs a mini-raid running under the title and could cost frame rate on a 4K TV.  a) Keep the staged fight   b) Build the real thing (about a day, risk to frame rate)   c) Take the fight out and keep the dimmed world."  My pick: a, because it is cheap, it already reads as a fight, and the party is 12 days away with 4K speed unmeasured; revisit after the rehearsal.

### H3. A Settings button on the title, the Display tab renamed Game, F1 on the key line
- Commits: v29.36 3ec59893, v29.28 d8f95401, v29.30 06c93213.
- What changed: the title now has a Settings button next to Go fullscreen (before, Settings was reachable only inside a game); the first Settings tab is called Game (was Display); the title key line says "f1 controls" (it said H, but H is heal).
- Question: "Keep the Settings button on the title and the tab name Game?  a) Keep both   b) Keep the button, bring back the name Display   c) Remove the button."  My pick: a, because a guest or a friend with a wrong volume needs Settings before a game, and the button is hidden in party mode.

### H4. The controls list folds to a one-line hint 30 seconds into a raid
- Commit: v29.29 96a269f8. It used to stay open for the first three raids. F1 opens it again.
- Question: "Keep the controls list folding away after 30 seconds?  a) Keep   b) Leave it open the whole first raid   c) Never fold."  My pick: a, because it was crowding the HUD, and Q70 says the game must explain itself without a card.

### H5. Settings window redesign (v29.63 to v30.21, about 20 builds)
- What changed: a slimmer card with a detail strip along the bottom, tabs on one row, section label rows hidden, a 20 px key-hint line under the card, the little confirmation toast after a change hidden (v29.78), "send play data" as a chip in the tab strip, backdrop 98 percent dark, pad focus follows the row in view. The critic gave screen 72 a 3.
- Why ask: it is smaller than his Q43 "nearly the entire screen" (see G2), and a hidden toast means a change gives no feedback.
- Question: "Keep the new Settings layout (and bring back the confirmation toast), but make the card 90 percent of the screen?  a) Yes   b) Go back to the old Settings   c) Keep as is."  My pick: a, because that follows both your answer 43 and the critic.

### H6. Pause card and Keys window
- Commits: v29.55 e6851fe8, v29.56, v29.96 85e74922 (header X that resumes), v30.30 33140602 (the plain "esc resume" hint is gone), v29.42 d8d06405 (Keys intro sentence hidden).
- What changed: the pause card is a column of five equal buttons 480 wide with an X in the corner; the hint line under it is removed; the Keys window drops its intro sentence.
- Question: "Keep the cleaner pause card with the X, no hint line?  a) Keep   b) Bring the hint line back."  My pick: a, because the X now says "close", Esc and B still work, and his answer 70 says no explaining text.

### H7. End cards, run over, abandoned, what's new, abandon question (v29.47 to v29.99, about 20 builds)
- What changed: the run-over card is one centred column with one solid button; the PILLAGERS wordmark steps out of the way; stats are cells; the title is muted so the score leads (v29.76, v29.79, v29.94, v29.49); the abandoned card shows loot left behind as a 56 px figure instead of a sentence (v29.99); the what's-new card is a 720 px flat panel with one "got it" button (v29.90); the abandon question is "abandon this run", with keep playing as the one highlighted button (v29.89); welcome pack is a centred 960 card (v30.00 to v30.11).
- Question: "Keep the new look of the run over, abandoned, what's new and welcome cards?  a) Keep   b) Show me before and after pictures first."  My pick: b for run over only (it is the party's high point), a for the rest, because the critic scores still sit at 2 or 3 and a picture costs little.

### H8. Raid HUD restyle by the critic
- Commits: v30.62 afe14e0b (resize hatch only when the pointer is over a panel), v30.73 764ad01d (only the gun card keeps the lime tab; the demo gun card is shorter), v30.67 8ead6504 (run info title white), v29.61 a7a6e9d7 (run info on the shared palette), v29.31 ec493a3f (credits and backpack cue made quiet), v30.83 7a874eef (the score block moved down 10 px so the label is not cut off).
- Question: "Keep these HUD changes?  a) Keep   b) Show me a before and after of the raid screen first."  My pick: a, because they are small and in line with Q57, and G6 covers the rest.

### H9. Operator menu is two rows, no Back button
- Commits: v29.44, v29.88, v29.91, v30.14 722af49c, v30.16. New party (amber) and Exit demo (ghost), a close X, solid backdrop. The Back button is gone because X and Esc close it.
- Question: "Keep the two-row operator card?  a) Keep   b) Put Back on it."  My pick: a, because it matches Q31 (nothing else in the card) and you are the only one who sees it.

### H10. Party attract pages (board, how to play, run over) redone
- Commits: v29.65 to v29.69, v29.93 to v29.97, v30.01, v30.24 f1e365bb, v30.78 5768aa9f. Spotlight backdrop, smaller logo in the corner, key caps in the how-to table, a 48 px X on the cards, and an empty board now shows one centred line instead of ghost rows (v30.24, after v29.93 had drawn five ghost rows).
- Question: "Keep the empty board as a single line, not five ghost rows?  a) Keep   b) Ghost rows back."  My pick: a, because a first guest sees a clean board and the rows fill as people play.

### H11. Operators and the held gun cast shadows; gear chipped (art)
- Commits: v28.85 5bfd6fe2 (soft shadow to the lower right), v28.82 995b327f (shadow under the held gun), v28.79 3620a47c (Heavy helmet crest is a low steel ridge and a small brow lens), v29.43 212d9689, v29.45 ca6aec5a, v29.46 6c1b97bd (chips and stripes on Heavy and Raider sets).
- No picture was taken of any of these (the notes say no screen shows a worn set), so I cannot say they look right.
- Question: "Keep the shadows and the worn-gear chips?  a) Keep   b) Show me one close-up picture of a Heavy and a Raider first."  My pick: b, because there is no picture on file, and one close-up settles it.

### H12. Pillager and machine loot, and the "polish pass" lines
- Commits: v28.89 a0f507b5 (cw-hardloot; this one is his 10-15 order "hard enemies drop better loot", listed so he knows it shipped), and 16 of today's 178 builds are only a "what's new names polish pass N" stamp (the card line, shown once since v30.08 0fc9a359).
- Question: "Is it all right that every build quietly adds a 'polish pass' line to the what's-new card?  a) Fine   b) Only list real changes on the card."  My pick: b, because guests and friends will read that card and a long list of "polish pass" lines tells them nothing; helpers can still stamp the version number elsewhere.

---

## how to use this file

- Gaps with "no question, just finish it": G2 to G6, G8, G9, G10, and part (a) of G1. That is 9 things the helpers can do now without bothering him.
- Gaps that need his call (5 questions): G1b, G11, G12, G13, G14. Helper changes with a keep question: H1 to H12 (12 questions; many can be sent as one batch with pictures).
- The question for G7 is H2.
- Things I could not check: whether the stop list's contents match Q13 to Q15 (only the file's existence), whether the helpers' notes about "his word" in the b-31 file predate his 10-18 answers (the lane notes carry no time stamps), and anything about how it looks (4 pictures only).
