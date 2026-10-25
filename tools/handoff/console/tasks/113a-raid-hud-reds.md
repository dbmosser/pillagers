113a-raid-hud-reds : ten checks newly failing on v34.53 on the raid HUD pass again, each fixed in the game or re-aimed
Queue (coordinator 10-24 21:10): the full test run corpus-1024-1829 on v34.53 has 46 failing, 40 newly (14 on v34.18); split by
screen so the helpers work them at once after the reset. Feed order: checks newly failing in the newest full run.
effort: medium

Source: tools/handoff/stable-status.txt (checked 10-24 19:51). Run file:
C:/Users/VMOCT2~1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad/corpus-1024-1829.txt
Your FAIL lines (check -> what it saw):
- v8.93 HUD panel corner grip -> "the default board is 361x175, it should be about 384x186"
- v9.14 sector map writing follows the monitor -> "control: the vitals panel is 517px wide at 1080p, it should be 532"
- v31.50 cw-trcol2 right column order -> "career 1080p: the nameplate is drawn in the middle of the minimap (x 1753, y 243), over the HUD"
- v31.32 cw-trcol right upper column -> "corner plate width or right edge differs; minimap is not a column-width square" (1080p and 4k)
- v31.03 flat HUD fill, demo gun card -> "the demo gun card is not drawn"
- v30.73 gun card has the lime tab -> "the gun card panel is not drawn (career false, demo false)"
- v30.75 prompts follow the last device -> "the idle question reads "" with the keyboard in use", the same with the pad and for the run
  ends callout
- v27.36 air strike bar place -> "3840 host: the plate overlaps the power-up chips; 3840 join: the same"
- v17.49 THE OVERSEER drawn to its size -> "a plain warden was drawn at scale 1.33; the boss was drawn at scale 1.95, not about 1.47"
- v18.01 auto resolution -> "smooth frames did not step the scale back up (still 0.75)" (may be the short memory: rerun alone first)
Likely ships: v34.28 raid hud type is couch size, v34.29 one hero, v34.30 i dots, v34.39 to v34.44 the downed card.

Steps:
1. Run each check alone on the current build; drop any that pass (the run went short on memory at times, two robots at once).
2. For each left, find the ship that broke it (git log v34.18..HEAD; the last full run where it passed was corpus-1023-2304 on v34.18)
   and say which of two it is:
   a. the game really broke (a player sees it wrong): fix the game in an mk script;
   b. a newer ship changed the screen on purpose (a critic job, his later order) or the check reads an old layout: re-aim the check at
      what the screen draws now and name the ship and the order in the DESIGN.md section. Never loosen a check just to make it pass;
      where a newer critic change goes against one of his own orders named in the check, his order wins: fix the game back.
3. One batch per cause, through preflight.sh and shipq.sh as usual. For anything a player sees, take pictures (tools/uishots.ps1) and look.
Pictures: the raid HUD in career and demo at 1080p and 4K, both windows.

TASK DONE when the ten pass on the drafted build or are fixed in a shipped batch; TASK PARTIAL with the ones left and why.

--- COORDINATOR 2026-10-24 21:25: step 1 is done for you. Each check was rerun alone on v34.53 (fresh tab of the corpus Chrome, as a full-run slice runs it).
Fail alone (real, start here): v8.93, v9.14, v31.50, v31.03, v30.73, v27.36, v17.49.
Pass alone: v31.32, v30.75, v18.01. A check that PASSES alone but failed in the full run is led astray by a check run before it (state left behind); it still blocks stable, so make it set up its own state (never loosen), after the real ones.
