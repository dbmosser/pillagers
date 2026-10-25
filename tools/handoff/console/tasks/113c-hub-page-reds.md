113c-hub-page-reds : ten checks newly failing on v34.53 on the pre-raid page, racks, haul, rewards and the body art pass again
Queue (coordinator 10-24 21:10): the full test run corpus-1024-1829 on v34.53 has 46 failing, 40 newly (14 on v34.18); split by
screen so the helpers work them at once after the reset. Feed order: checks newly failing in the newest full run.
effort: medium

Source: tools/handoff/stable-status.txt (checked 10-24 19:51). Run file:
C:/Users/VMOCT2~1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad/corpus-1024-1829.txt
Your FAIL lines (check -> what it saw):
- v32.51 pre-raid page critic fixes -> "the going up line has 2 chips, not one"
- v32.45 rewards intro hidden, bar 28px -> "bar h 36px"
- v32.19 racks column centred in the card -> "the build button centre is at 628, the window middle is 942"
- v31.57 racks page one centred 672px column -> "racks child 1 max-width is 1344px, not 672px; racks child 2 the same"
- v31.58 haul tile not yet shown is a plain slot -> "a tile not yet shown has a rgb(74, 82, 87) bar, not the plain slot colour
  rgb(46, 51, 55)"
- v30.07 welcome pack inside the card frame -> "the welcome pack intro starts at 0 above the card top 105"
- v32.95 daily restore one primary action -> "restore is not the 56px primary action; undo competes with the primary action"
- v28.13 vest and shoulder racks -> "the big pauldron does not stand out at the shoulder"
- v28.12 pack and boot shapes -> "the bedroll does not change the outline; the fuel can does not stand out; the frame pack does not
  change the outline; the hero draws the racks differently from a body that carries them (1763)"
- v26.30 the other ways a gun turns up -> "the hover rows of the twin are 6 against 7 for its model"
Likely ships: v34.31 to v34.45 (hub and card polish), v34.47 to v34.50 (pixel floor, building kinds, sets wardrobe from 86h).

Steps:
1. Run each check alone on the current build; drop any that pass (the run went short on memory at times, two robots at once).
2. For each left, find the ship that broke it (git log v34.18..HEAD; the last full run where it passed was corpus-1023-2304 on v34.18)
   and say which of two it is:
   a. the game really broke (a player sees it wrong): fix the game in an mk script;
   b. a newer ship changed the screen on purpose (a critic job, his later order) or the check reads an old layout: re-aim the check at
      what the screen draws now and name the ship and the order in the DESIGN.md section. Never loosen a check just to make it pass;
      where a newer critic change goes against one of his own orders named in the check, his order wins: fix the game back.
3. One batch per cause, through preflight.sh and shipq.sh as usual. For anything a player sees, take pictures (tools/uishots.ps1) and look.
Pictures: the pre-raid page, racks, the haul screen, rewards and the welcome pack at 1080p, both windows.

TASK DONE when the ten pass on the drafted build or are fixed in a shipped batch; TASK PARTIAL with the ones left and why.

--- COORDINATOR 2026-10-24 21:25: step 1 is done for you. Each check was rerun alone on v34.53 (fresh tab of the corpus Chrome, as a full-run slice runs it).
Fail alone (real, start here): v32.45, v32.19, v31.57, v31.58, v30.07, v32.95, v28.13, v28.12.
Pass alone: v32.51, v26.30. A check that PASSES alone but failed in the full run is led astray by a check run before it (state left behind); it still blocks stable, so make it set up its own state (never loosen), after the real ones.
--- COORDINATOR 2026-10-25 00:45: the second full run on v34.53 (corpus-1024-2302, done 00:10) failed 44, all from the first run's 46, none new. v32.51 and v26.30 passed in it as well as alone, so they stay last, after the real ones, as the line above says (they fail only after some other check runs first).
