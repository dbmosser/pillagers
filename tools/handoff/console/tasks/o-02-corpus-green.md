MAKE THE FULL TEST RUN GREEN AGAIN (coordinator, 2026-10-19). The full regression run (corpus) has had 84 to 107 failing checks since
10-18 afternoon. The last run, corpus-1019-0129 at v31.82, had 114 failure lines, all listed one per line in
tools/handoff/corpus-fails-v31.82.txt ("version what it checks -> what it saw"). Because the run is never clean, the stable build
has been stuck at v29.09, and his play window loads that old stable (his Q12 of 10-18). This job unsticks it.

Most of these are probably STALE checks: older checks whose behaviour a later ship changed on purpose (the UI redesign of 10-18,
lower case everywhere, the HUD rework, the party screens, "pillager" for "raider"). Some may be REAL regressions. For each line:
1. Find the check in tools/mkfixture.ps1 (search for its {v:'NN.NN' id) and the later ship(s) that changed what it measures
   (git log -S on the measured thing, and tools/handoff/console/notes/).
2. Decide:
   - STALE: the change was ordered by him, or was made deliberately by a ship with its own check. Retarget the old check so it
     holds on the old AND the new build (keep its intent, follow the new rule), or delete it only if its feature was removed.
   - REAL: the game broke something a ship did not mean to change. Fix the game, with a new check whose control fails on the old build.
   - HARNESS: the check is flaky or the run was broken (window size, timing; see RULES.md "Fixture gotchas"). Fix the staging.
3. Write each decision as one line in notes-new.md: version, STALE / REAL / HARNESS, and one-line reason.

How to deliver: retargets and deletions go in .codex-work/o-02-corpus-green/fixture-retarget.json (the lane applies it under
the ship lock and checks it; see RULES-codex.md step 5). Game fixes go in mk scripts as usual. Work in batches of about 15
checks per run, oldest version first, so each run lands something. Never weaken a check to make it pass: a retarget must still
catch the bug the check was written for.

TASK DONE when a fresh full run (the runner starts one on each new HEAD) shows 10 or fewer failing checks and every remaining
one is explained in notes. Otherwise TASK PARTIAL with the count left; the coordinator puts the job back.

## RE-QUEUED 10-20 03:55 (coordinator, in the VM). Read first; where it disagrees with the text above, this block wins.
- The fresh list: tools/handoff/corpus-fails-v32.16.txt (corpus-1019-2343, commit 1b8dc30b, v32.16, every slice finished, 132 failing).
  Compared with the v31.82 list: 108 are still red, 6 are fixed, and 24 are NEW since v31.82. The 24 new ones are listed in
  tools/handoff/corpus-fails-v32.16-new.txt: triage those FIRST (a ship of 10-19 night most likely broke or changed them, and
  some may be REAL regressions), then the rest oldest version first.
- The game has moved on since (HEAD is v32.66): before deciding, run the check on the current fixture; the lane's retarget trial
  runs your listed checks on the committed game anyway, so a check that already passes on HEAD is "FIXED SINCE", not a retarget.
- The lane applies fixture-retarget.json itself now (RULES-codex.md step 5): a trial copy first, then the commit under the lock.
  Keep batches to 15 checks or fewer per file (RETARGET_MAX_CHECKS is 30).
- A new full run started 03:51 on v32.66 (ends about 08:00); the coordinator will add its list when it finishes.

## NOTE 10-20 05:15 (coordinator)
The 03:51 full run on v32.66 was stopped at 05:02: it crawled (66 of the first 120 checks in 65 min, about 10x slower than the
v32.16 run) while its page grew to 1.9 GB and every helper waited on memory. There is no v32.66 list. Work from
tools/handoff/corpus-fails-v32.16.txt and its -new file, checking each on HEAD first as the block above says.

## RE-QUEUED 10-20 06:05 (coordinator): round 2, fresh thread
Why: it used its 5 runs while still making steady progress (a long list is expected to take several rounds), not because it was stuck.
Done so far (keep, do not redo): fixture commits 544cba9f (ten stale or mis-staged checks) and fe9c6c5a (15 checks: 9.74 9.76
10.17 10.19 10.21 10.32 10.33 10.34 10.35 10.36 10.39 10.41 10.45 10.46 10.47, all PASS on the lane trial), plus cw-cx-padlostlegend.
Your full state is in tools/handoff/console/notes/o-02-corpus-green.md: read it first; this is a fresh thread with no memory of round 1.
Next: continue the v32.16 list from the next unresolved entries (10.64, 10.73, 10.92, 10.96 and on), 15 or fewer per batch, each
checked on HEAD first. Stay on old checks: pad screen pictures belong to o-07, o-10 and o-11, not to this job.
There is still no list newer than v32.16: the 03:51 full run was stopped (the shadow store crawl, task 00-perf-shadow-store).

## PARKED 10-20 07:58 (coordinator): waits for the fresh full run
Round 2 used its 5 runs with steady progress (fixture commits 1c23909e, 957b28f1, d712c0d1 on top of round 1). A fresh full run
started 07:25 on v32.82 and ends about 11:30; working on from the two-day-old v32.16 list now would retarget checks the new list may
not show. The coordinator moves this back to tasks/ with the new list (round 3, fresh thread) when that run ends.

Coordinator 10-20 08:40: the 07:25 run was stopped (the corpus page piled up loop chains; fixed in the fixture at 2235ddae). The fresh full run is now corpus-1020-0828 on a588d210; requeue this as round 3 with its list when it finishes.
Coordinator 10-20 08:45: slice 0 now takes about 5.5 min (was 59). Its summary line is lost every run: a failure with a stack trace is several lines and the CDP read keeps only the last. After this run ends, fix tools/corpus-slices.sh line 30 (flatten whitespace in each fail) and rerun slice 0 alone before building the round 3 list.

## RE-QUEUED 10-20 09:50 AS ROUND 3 (coordinator). Read first; where it disagrees with anything above, this block wins.
- The fresh list: tools/handoff/corpus-fails-v32.83.txt (corpus-1020-0828 at v32.83, a588d210, every slice finished, 113 failing; the
  run now takes about an hour, so every new HEAD gets a fresh list quickly). 57 are not in the v32.16 list: tools/handoff/corpus-fails-v32.83-new.txt.
- Split with the Claude lanes, so never touch their checks: 49-corpus-figure-art (8 figure checks), 50-corpus-old-a (16 checks v8 to v13),
  51-corpus-old-b (11 checks v15 to v19). Yours, in this order: first these 22 new ones (v20 and later), then every other line of
  corpus-fails-v32.83.txt that is not in the -new file (the old reds), oldest version first.
- Fresh thread (round 2's is thread-r2.txt). Batches of 15 or fewer per fixture-retarget.json.

Your first 22:
v31.71 Settings focus row has the bar and no ring, the detail pane is wide, and the pause box puts feedback and what is new side by side -> detail pane is 405 wide; feedback is 73 tall
v31.52 the end cards have a 48px close X top right that leaves like the primary, copy report is off the card, and a haul tile not yet shown stays an empty slot (his Q43, the critic on 35 38 60 76 77) -> the X is not in the top right corner 
v31.48 cw-mapstyle2: on the sector map card the weather line has one separator, zone names are a size under the extraction names and not bold, the contract names are all in the main text colour with the reward in the smaller type, the foote
v31.25 the career corner readout is one row: credits, XP, stash and bag sit on the same line, the stash and bag figures are not a second line under it (his answer Q58) -> the one row lost a label ("$65,00011,177 XP STASH 0 BAG 0")
v30.51 the demo hides credits, XP, stash and bag in the top right; career keeps them (his Q55, 10-18) -> career shows no credits in the corner: $65,00012,479 XP STASH 0 BAG 0
v28.49 cloud-coop-volatile-boom-seen: a VOLATILE elite that dies on the host blows up in player 2 window too, with the spark, puff, flash, blast and a shake of 6 the host frame shows; a plain body death in his window still shakes nothing ->
v27.36 strikeplace, his playtest note (air strike bar in a weird place, colliding): the air strike plate sits over on the right, at the right end of the gun bar and past the power-up chips, clear of the keys, the chips, the item in hand and
v27.20 kit1, his word that the kit is part of the map select screen: a KIT row of four on the sector page (MY LOADOUT, FREEBIE KIT, RANDOM KIT, BEST KIT) with caps details, one on at a time and kept, ASCEND TO THIS SECTOR applies it and goe
v26.92 flow12, his answer that the golden enemy appears every raid: every raid gilds one machine or hostile pillager at least 700 from the drop (the same one for the same seed), it has three times the health, is drawn gold, and leaves a gol
v26.50 settings9, his order 2026-10-14: ACCESSIBILITY has REDUCED FLASHING (off by default): on, a flash light is smaller and shorter, a burst has half the sparks, the lightning sheet is dimmer, and the muzzle flash drawn on the gun is dimm
v26.16 wheel1, his order: a gun that comes into his hands cannot fire until it is ready, and the time is the gun class: pistol 0.25 s, SMG 0.4, rifle 0.55, shotgun 0.6, marksman 0.7, sniper 0.85, machine gun 1.0; a fresh raid starts with th
v24.88 his #50 (UI redesign ui5q1x, from the visual QA of the Mainframe RACKS and REWARDS tabs): the RACKS and REWARDS panes start on the left edge of the tabs, not centred -> opane_mf is held to none; opane_rew is held to none
v24.79 his #50 (UI redesign ui5q1o, from the AAA judge of the Last Pour shot): a drink name is 19px or more in caps, its price 20px or more, and INGEST is at least 46px tall with a 16px label, amber when it can be bought and never in the fa
v24.47 graphics program gfx6: the quality ladder: slow frames shed the extras before the resolution (post pass off, soft sheets at two thirds, HIGH lighting drawn as STANDARD, one rung a second) and only then step the render scale down; smo
v24.38 graphics program gfx25: a round going north that stops on the south face of a plain wall leaves a mark painted into that wall baked sprite in place (the pixel at the mark is 12 or more darker than before), the mark survives a flush a
v24.29 his answer 39: darker moodier nights, the streets away from him darker while the ground at his feet reads as before -> the night away from him is not darker than the old night (94.9 percent of it)
v24.07 graphics program gfx7: the coloured light map: at night under LIGHTING HIGH a warm sodium lamp tints its pool (red over blue at least 6 above CLASSIC) and STANDARD does too, the pool holds the CLASSIC brightness within 20 percent, an
v23.67 his #45, pro sound mix: each kind of sound rides its own bus, the world runs through a compressor and then a limiter into BUS, the HUD sounds skip them, and BUS stays the master (player 1 left, player 2 right kept) -> BUS no longer r
v22.16 the lift sector map draws each extraction ring where the raid puts it, and the world size left by the last raid does not move them -> the lift map drew 9 rings for the 3 in the raid
v21.84 a wrapped line draws his words: the CONDITIONS panel and the sector map zone names split his rewording, not the original -> (then SKIP: the staged zone name Zq yard was not drawn on one line, drawn ["zq yard"])
v21.66 his note: the single shot guns hit harder, so they keep up with the automatics -> threw: TypeError: Cannot read properties of undefined (reading 'dmg')     at sus (http://localhost:8806/fxcorpus.html?slice1200=1:119346:33)     at htt
v20.95 the sector maps on the lift page are drawn at the screen resolution: with the menus at twice size each map holds twice its page size in pixels, keeps its 420 page width, and is drawn out to its far corner -> sector 0 map is 960 wide 
