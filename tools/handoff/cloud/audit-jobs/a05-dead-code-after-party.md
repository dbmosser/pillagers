# a05-dead-code-after-party : 45 functions the game never calls (start after the party, Sat 10/31 or later)
From the cloud audit of 2026-10-28 (tools/handoff/cloud/audit-2026-10-28.md, item 10). Cleanup, no change a player can see.

What: on v35.39, 45 top-level functions (about 420 lines) are never called by the game. 28 of them are still called by checks, so
those checks pass on code no player runs. Listed by tools/cloud/audit/dead.py (rerun it on HEAD first; it prints name and line):
  forgeName txRecord woodsCell bigSpine forgeChamfer notoBite mapFirstFoot uiKey padAxis throwSelFix cycleThrow msgVictim msgQDrop
  cycleHeal beltInstant autoCull unkeyedHeals countHeals countArmor gfxLightNow gunDef needGlow playerStatus legDock tskInit tskStep
  tskDraw placeName pixFaults pixSwap pixGroundFinish gfxWet tabOf netP2Key netSndToggle netSndLabel netSndOtherLabel netHubOffer
  arcadeQuickHeal arcadeExtracted goalsHud arcadeAutoSrch arcadeBagFree sizeTag sectorTitle
Also dead: the gun jam branches in the fire code (p.wep.jam is always 0: the only wear band, CLEAN, carries jam:0, and his veto says
guns never jam) and the JAM CLEARED line.

Do: remove them in small ships (one area each), retire the checks that only call them (fixq.sh), and keep the seed 4242 fingerprint.
Never remove a function a check uses to stage a real feature. TASK DONE when the list reads empty on HEAD.
