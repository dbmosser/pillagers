# 217 dead code cleanup (lane a)

Rerun of the dead list on HEAD v37.03 (by grep, python is not on my command list): all 45 names had no caller in the game file.
Tool: scratchpad mk-cw-dead1..6.ps1 each have RmFn (finds a function by name, takes it out, optional comment lines above it).
Fixture side: checks that only asserted a dead function were trimmed (fixq commits 9683fbc5d, b12050a24, cfca1dcb9, 07c7457e1); lists and results in notes/217-list*.txt and 217-out*.txt.

## Shipped (all with the 4242 fingerprint unchanged: ents 85/374, containers 165/593)
- v37.04 cw-dead1: forgeName woodsCell bigSpine forgeChamfer msgVictim msgQDrop cycleHeal unkeyedHeals countHeals gunDef placeName tabOf netSndLabel netSndOtherLabel sectorTitle
- v37.05 cw-dead2: gfxLightNow gfxWet sizeTag countArmor uiKey goalsHud arcadeBagFree arcadeQuickHeal arcadeAutoSrch
- v37.06 cw-dead3: notoBite mapFirstFoot autoCull needGlow netSndToggle netP2Key legDock pixSwap
- v37.07 cw-dead4: the title fight (tskInit tskStep tskDraw plus its helpers tskRnd tskSpark tskShot). tskOn and var TSK stay (live floor-label check and two checks read TSK).
- v37.08 cw-dead5: the two gun jam branches in the fire code (player and bot) and the JAM CLEARED tick. The p.jam<=0 guards and the JAMMED hud words stay (checks set p.jam=500 to test the trigger block; they are harmless).
- v37.09 cw-dead6: beltInstant padAxis

## Left on purpose (8 of the 45), why
- txRecord, playerStatus, pixFaults: test instruments, not dead code. 30+ checks read the text a frame draws through txRecord, window.__status wraps playerStatus, and pixFaults is the pixel fault counter the pixel checks compare. Removing them blinds the gate.
- throwSelFix, cycleThrow: ten or so checks stage the throw pouch with them (v25.xx belt, pouch and key checks). They are the old U cycle, but the checks that call them also guard live throw rules; retiring them is a check rewrite for each, not a cleanup.
- arcadeExtracted: 10 calls in the arcade demo checks, staging the extraction. The live path is arcadeX2; each of those checks needs the stage rewritten onto it.
- pixGroundFinish: two ground bake checks call it as the bake step.
- netHubOffer: the Undercroft gift check stages the offer with it ("the offer plumbing is tested through its own door"); the gift door netHubGiftTake is live.
A later job can rewrite those checks one by one, then remove the functions; none costs the player anything.

## Mistakes worth knowing
- A check that greps document.scripts for a string must not contain that string itself, not even in its own message or `what` text (the first cw-dead5 preflight failed on that three times).
