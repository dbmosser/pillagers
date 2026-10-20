54-corpus-reds-c : 18 old checks (v29.55 to v31.67) red at v32.83 and already red at v32.16 (coordinator 2026-10-20, from tools/handoff/corpus-fails-v32.83.txt)
effort: medium

These have been red since 10-19 or earlier (they are in tools/handoff/corpus-fails-v32.16.txt too), so most are likely STALE after the 10-18
UI redesign, the lower case text, the HUD rework or the party screens. Codex (o-02) worked older checks in rounds 1 and 2: look in
tools/handoff/console/notes/o-02-corpus-green.md for any of these it already decided, and never touch its 22 (o-02 task, "Your first 22").

For each check: find it in tools/mkfixture.ps1 ({v:'NN.NN'), run it on the current fixture (runchk.sh; a check that passes on HEAD is FIXED SINCE), then decide:
- REAL: the game broke something no ship meant to change. Fix the game through the ship queue, with a new check whose control FAILS on the old build.
- STALE: a later ship changed it on his order or on purpose with its own check. Retarget the old check so it keeps its intent under the new rule
  (bash S/lock.sh, edit, runchk.sh, HELD=1 bash S/fixq.sh "MESSAGE", bash S/unlock.sh; short holds, a few checks at a time). Delete only if its feature was removed.
- HARNESS: flaky staging (window size, timing). Fix the staging.
Never weaken a check to make it pass. Write one line per check in tools/handoff/console/notes/54-corpus-reds-c.md: version, REAL / STALE / HARNESS / FIXED SINCE, one-line reason.

The checks (version what it checks -> what it saw at v32.83):
v29.55 the pause card is a title and one column of 56px sentence-case buttons at the menu width, with no key legend or feedback sentence on a keyboard card -> the pause buttons are a row, not a column; Abandon is not set apart (0px)
v29.61 the run info panel is on the shared palette: accent headings and tx_1 goal rows, not the old off-palette amber and grey -> the run info heading is #efe9dc, not the accent #e6ff3d; the run goals heading is #aaa498, not the accent #e6f
v29.63 Settings and Keys are centred cards with one 48 by 48 close X in the header row -> the Settings list starts at 44, a full width wall; the Settings list ends at 1840; the Keys list starts at 44
v29.64 Keys hides its idle hint bar and capitalises action names; Settings fades the list bottom -> Keys action names do not start with a capital
v29.67 Settings is a 960 card: the detail text is a strip under the list, steppers are plain until pointed at, the header X is drawn strokes -> detail pane is beside the list, not under it
v29.72 Settings: the stepper sits within 400px of its name and the card is 17 x 48; the pause title is left-aligned over the button column -> settings list is 908px wide (limit 830)
v29.75 Settings: each stepper is right-aligned in its row, the card is 15 x 48 wide, and the toast is not at the bottom while Settings is open -> stepper is 41px short of the row edge (limit 40) DBG iw=1884 row=640 bl=340 bw=288 ml=0px html
v29.77 Settings: the section strip is one row (the seven tabs share one top) -> tab 1 (AUDIO) wraps to a second row
v29.80 Settings and Keys cards are centred and about 720 tall, not full height -> Settings title sits at 44px (needs 98); Settings list ends at 897px, past the card; Keys title sits at 44px (needs 98)
v29.94 the run over card shows kills, extractions and deaths as cells (a 32px value over a 16px label, three in a row for one player, a row each for two) and hides the run-on text row, and the welcome pack never opens while the arcade is up
v29.98 the header X buttons are ghosts with a tx-2 glyph, the Keys section labels are tx-1 -> the settings X border is rgba(0, 0, 0, 0), not line-hi; the Keys section label is rgb(170, 164, 152), not tx-1 rgb(239, 233, 220)
v30.20 the attract backdrop blurs the world by 16px (the 16px spacing token): at 8px the hub labels read through the card scrim as ghost words (critic on v30.18: 56 back to 2; screens 46 52 55 56 64) -> the backdrop blur is 2px: under 16px 
v30.24 an empty board draws no ghost rows, one centred line; the operator New party is the amber primary and Exit demo a ghost (critic 56 64 62) -> the empty line is not centred: left
v30.37 the pause menu has a problem-report text box (his Q9): text typed in it and the Feedback button save the note with the version and a screenshot through the same save the Feedback window uses, and the pause menu stays up -> the box is
v30.91 cw-downgain, his words on the downed bar: a hit gives half a second back at once with +0.50s shown, one hit a pass, the clock shows two decimals, a miss locks the trigger, a held trigger and a standing player do nothing -> SIX: the d
v30.97 the operator card hides tonight 0 runs and rings the focused New party in amber, not white (critic 62) -> the focus ring is not amber: none
v31.04 cw-shkey, his note (2026-10-18) "superhot mode needs a toggle key": the key left of 1 turns Superhot on and off in a raid once per press and moves the same dial as the one Settings row, the line on screen always says the state just s
v31.67 Keys table spans the card and settings steppers box only the row in focus -> 3 idle steppers still boxed

TASK DONE when every check above is green on HEAD or explained in the notes; TASK PARTIAL with the ones left.
