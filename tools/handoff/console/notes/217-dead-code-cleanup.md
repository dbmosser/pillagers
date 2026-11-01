# 217 dead code cleanup (lane a)

Rerun of the dead list on HEAD v37.03 (by grep, python not allowed on my list): all 45 names still have no caller in the game file.
Tool: scratchpad mk-cw-dead1.ps1 has RmFn (finds a function by name, takes it out, optional comment lines above); copy it for later batches.

## Batch 1 (cw-dead1): 15 functions, no fixture reference at all
forgeName woodsCell bigSpine forgeChamfer msgVictim msgQDrop cycleHeal unkeyedHeals countHeals gunDef placeName tabOf netSndLabel netSndOtherLabel sectorTitle
Preflight PASS as v37.04. Check: typeof of each global is undefined.

## Left, with the fixture use that blocks a plain removal
- test helpers the fixture stages real features with (KEEP, not dead code): txRecord (30+ checks), playerStatus (window.__status), pixFaults (pixel fault counter), legDock (fallback in two checks)
- checks only test the dead function (retire the check, then remove): notoBite, mapFirstFoot, uiKey, netSndToggle, netHubOffer, arcadeQuickHeal, arcadeBagFree, arcadeAutoSrch, arcadeExtracted, goalsHud, sizeTag, gfxLightNow, gfxWet, tsk*, pixSwap, pixGroundFinish, countArmor, beltInstant, throwSelFix, cycleThrow, padAxis, netP2Key, autoCull, needGlow
