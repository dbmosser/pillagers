# 120k two player frame cost (lane c, 10-31)

## Shipped
- v36.89 (cw-framegarbage): drsTick no longer copies and sorts its 2 s window twice a frame with array sorts (reused number buffers, native sort; same percentiles, checked). The vignette gradient is built once per canvas size and strength, not every frame. Fingerprint held (ents 85/374, containers 165/593). On his PC.
- Watch for in a playtest: nothing should look different. The edge darkening must look the same on both windows, also after a window resize and while auto resolution moves. Auto resolution should step down and up as before.

## Numbers (gate Chrome, 1888x977, no graphics card, one window, seed 4242, 150 frames per run, pass marks forced on every frame)
Before (v36.88) -> after (v36.89), post fx on, first run:
- frame 3.55 -> 2.83 ms (a second run: 3.21 -> 2.64 ms)
- world 2.02 -> 1.61, hud 1.19 -> 0.97, light 0.13 -> 0.09, fog 0.16 -> 0.13, weather 0.02 -> 0.02
- Pass split at HEAD: world about 55 percent, HUD about 33 percent, light + fog + weather under 10 percent (post fx on). Same shape as failed/94 (world 50, HUD 34).
- Post fx off cost MORE in the probe (4.2 to 4.5 ms, light 1.2 to 3.4 ms): the "off" path draws the classic darkness sheet. So post fx on is the cheaper rung here; the ladder step "post fx off" does not save the light pass in this build. Worth a look by whoever owns the ladder.
- Honest limit: this VM is shared and has no graphics card; repeat runs swing 2.6 to 6.7 ms. The before/after gap is about 0.6 ms in both pairs but is inside that noise, so it is a direction, not a proof. Per frame garbage could not be read (the heap counter is off in this Chrome).

## What I could not do (and why)
- v34.18 against HEAD: a mk script check can only run the current build, and my command list has no way to start an old build in a Chrome. The suspect ships (v34.24 to .30 HUD, .48 decals, .50 furniture, .73 gun kick, .74 smoke and sparks, .76 glow pools) are therefore NOT ranked by measurement. The spare PC robot log (tools/handoff/spare/DESKTOP-82BKOP4/fuzz.log) only starts at v34.83 and swings from 4 to 19 ms p50 per raid, too noisy to rank anything.
- 4K two window numbers: tools/handoff/spare/perf-4k.txt does not exist yet (no file in tools/handoff/spare/), so no 4K figure and no job 127 glow cost at 4K.
- The 127 glow with the forge and burning bodies in view: the probe does not stage them (camera screens 81 to 92 do, but shoot pictures, not times).
- render2D closures (24 DR.push sites with bind and closures): left alone. Roughly 50 to 150 small objects a frame; no measurement shows they matter and 24 edit sites is a big risk for an unmeasured gain.

## Rerun 10-31 10:06 (lane c)
- v36.89 is in the log (0b8be5a6a). tools/handoff/spare/perf-4k.txt still does not exist (searched the whole spare folder), so the 4K two window and job 127 glow numbers are still open. Nothing new could be measured within my command list; no second ship. Not repeating the probe: it would only add noise to the pair above.

## Rerun 10-31 (lane a)
- HEAD is still v36.89. tools/handoff/spare has no perf* file yet. The open parts are already in alarms.md (line 5, for the coordinator). Nothing new to measure or ship; closed as done, since the brief's ship happened.

## Left for a run that can start an old build and read perf-4k.txt
1. Build v34.18 and HEAD in two lane Chromes and compare GFXP passes on the probe (probe script: scratchpad/mk-cw-passprobe.ps1, run with preflight.sh c cw-passprobe; it fails on purpose and prints the numbers; never ship it).
2. Read perf-4k.txt for the 4K two window frame time per build once the file exists.
3. Jobs 128, 129 and 130 in waiting/: they can go now on rung 1; the pass split above says world is the big spender (about 2 ms), HUD 1.2 ms.
