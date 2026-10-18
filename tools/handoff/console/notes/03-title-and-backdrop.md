# 03-title-and-backdrop (lane a)

## Shipped
- v30.41 cw-title-line: story paragraph and the 3 step cards gone, one line "Ascend. Pillage. Extract." (id titletag). No raiders beside the logo (none there). PvP row already hidden by task 01. Fixture checks 29.35 / 18.11 retargeted (dd2a1841) to allow zero cards.
- v30.38 cw-cardP18 (What's New stamp).
- v30.43 cw-title-gap: margin 24/16 but I dropped the inline margin:0 auto, so THE LINE IS LEFT-ALIGNED (critic P0, score 2).

## Pending (draft ready, preflight PASS)
- S/mk-cw-title-centre.ps1 -> draft-cw-title-centre.json: auto margins, centred, 20px tx-2. Ship STOPPED 3 times "uncommitted changes" (another worker's edit of tools/mkfixture.ps1 uncommitted). NEXT RUN: first `bash S/shipq.sh cw-title-centre`, then shoot 01,44,45,46,56,57 after and run the critic.

## Not done
- Q52/Q54 live backdrop with real pillager-vs-robot combat behind title, scoreboard, how-to (screens 45, 46, 56). The title now shows the dimmed hub world (blurred near black). Real combat needs a raid sim running under the title at 60fps 4K: big engineering task, not started. Look at runSim (~line 32095), titleSceneReady/titleOn (~46239), render2D (~36020), arcadeAttShow (~60783).
- Critic findings on screen 01 (score 2 before the centre fix), for the next run: three explaining sentences on the title (Best in fullscreen..., First time out..., Changing save reloads...); flat hierarchy; save block as loud as the modes; key legend small; '$900' in the save row (line ~65645, credits; left alone, not sure it is a score); logo gradient + shadow; backdrop too dark (try ~55% scrim).
- Screens 44, 45, 46, 56, 57 not scored yet.
