52-corpus-reds-a : 19 old checks (v20.89 to v26.38) red at v32.83 and already red at v32.16 (coordinator 2026-10-20, from tools/handoff/corpus-fails-v32.83.txt)
effort: medium

These have been red since 10-19 or earlier (they are in tools/handoff/corpus-fails-v32.16.txt too), so most are likely STALE after the 10-18
UI redesign, the lower case text, the HUD rework or the party screens. Codex (o-02) worked older checks in rounds 1 and 2: look in
tools/handoff/console/notes/o-02-corpus-green.md for any of these it already decided, and never touch its 22 (o-02 task, "Your first 22").

For each check: find it in tools/mkfixture.ps1 ({v:'NN.NN'), run it on the current fixture (runchk.sh; a check that passes on HEAD is FIXED SINCE), then decide:
- REAL: the game broke something no ship meant to change. Fix the game through the ship queue, with a new check whose control FAILS on the old build.
- STALE: a later ship changed it on his order or on purpose with its own check. Retarget the old check so it keeps its intent under the new rule
  (bash S/lock.sh, edit, runchk.sh, HELD=1 bash S/fixq.sh "MESSAGE", bash S/unlock.sh; short holds, a few checks at a time). Delete only if its feature was removed.
- HARNESS: flaky staging (window size, timing). Fix the staging.
Never weaken a check to make it pass. Write one line per check in tools/handoff/console/notes/52-corpus-reds-a.md: version, REAL / STALE / HARNESS / FIXED SINCE, one-line reason.

The checks (version what it checks -> what it saw at v32.83):
v20.89 the answer line in a station window sits clear of its panels: in Fashion (and the shop, where its grid reaches the footer) the line box starts below the bottom edge of the panels, stays off CLOSE and stays on the screen -> in traderm
v21.53 the attract titles read over any footage: each sits on a dark band, and PRESS ANY KEY is clear of the recorded belt row -> PRESS ANY KEY sits on the recorded belt row (897 of 975)
v22.88 the map story on a lore card: standing at the story sets the read flags once and draws its name and its whole body wrapped on a card inside the screen, while no feed row, alert or line said holds the story; 400 away the card is gone 
v23.30 arcade9, his order 2026-10-11: an arcade drop is shielded, a shielded hit takes nothing, the shield tag shows, moving drops the shield and the next hit lands -> no SHIELD tag drawn on the shielded player
v23.42 arcade19, his order 2026-10-11: the controls card, arcadeCardRows gives 8 rows with a keyboard and a pad label, the HOW TO PLAY page draws them, the card shows MOVE at the left while shielded and is gone after the shield drops plus 5
v23.44 arcade21, his yes 2026-10-11: the operator lock, in an arcade raid ESC and a click on every visible pause button never leave the arcade, the box shows only RESUME and END RUN, the attract has no pause box, and only Ctrl+Shift+F10 lea
v23.81 the what is new card never lists the same line twice (the Tripwire Mine line went in twice) -> line 10 repeats line 7: POLISH PASS 30. More fixes to the screen; line 20 repeats line 18: POLISH PASS 20. More fixes to the screen; line 
v23.85 his #50 (UI redesign ui3): the menu type scale: window titles in the condensed family, and in Settings, the pause box and the title no text tracked past .145em or set under 13px -> Settings: #closesettings "close" 0px tracked NaNem
v24.21 his #50 (UI redesign ui6): one window frame: in the shop, the Mainframe, Settings, Fashion, the stash, Wirt and the Last Pour CLOSE sits in a footer at the bottom right of its frame (within 48 of its right edge and 96 of its foot), t
v24.27 his #50 (UI redesign ui7): a world prompt draws its key as a keycap: hudPrompt([E] SEARCH) still fills the whole line once (his wording and the word editor see it whole) but clips the [E] out of it and draws a key shape with the lett
v24.65 his #50 (UI redesign ui5q1e, from the AAA judge of the stash shot): on the stash the answer line sits in the footer bar, level with CLOSE (within 6px), and not across the footer hairline -> the answer line is 911px off the level of C
v24.87 his #50 (UI redesign ui5q1w, from the visual QA of the Keys window): the Keys list is at most 1100px wide, its action names are drawn in caps at 17px or more, and each key is a keycap with a thicker lower edge -> the Keys list has no
v24.98 his #50 (UI redesign ui5q2o): Settings has a detail pane right of the list that shows the row under the mouse (its name and description) -> the detail pane does not show the row under the mouse (Dev cheat box); the detail pane does n
v25.01 his order 2026-10-12, the lock-on beeping is annoying and inconsistent when machines get together, make it a low siren: with 1, 3 and 6 machines on him there is one siren voice that wails (pitch inside 200 to 400 Hz, period inside 1.
v25.57 forge12: a gun forged MK III cryo and extracted is kept on the armoury model and comes up forged on the next deploy, a forged gun carried out in the backpack is kept too, a death loses it with the armoury gun, an abandon keeps an old
v25.70 his orders (scopes 2x minimum, a minor zoom without a scope): no scope below 2x remains (no 1.25), the scopes are 2, 2.5, 3 and 4 in order, and aiming zooms the camera about 1.25 without a scope, 1.60 with the 2x, 2.30 with the 4x an
v26.26 his order (2026-10-14): a green, blue or purple gun is found one rarity up about one time in five (the Compact SMG as a blue one, the Magnum, Burst Carbine, Riot Scattergun and Auto Rifle as purple ones, the Support MG, Marksman Rifl
v26.30 his order (2026-10-14), the other ways a gun turns up: a pillager carries the twin one rarity up about one time in seven and his body drops it, an elite pillager about one in six, the Peddler stocks it at one stall in five, Wirt gamb
v26.38 settings1, his order 2026-10-14: Settings reads in sections (THE RAID, AUDIO, CONTROLS, CONTROLLER, DISPLAY, SAVES AND TOOLS) under a jump bar, each row in its own section, and AUDIO carries UI VOLUME, FOOTSTEPS VOLUME and MONO AUDIO

TASK DONE when every check above is green on HEAD or explained in the notes; TASK PARTIAL with the ones left.
