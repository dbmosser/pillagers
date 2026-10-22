86g-pix-pillager-states : hit, low health, downed, death, armour tiers, roles, elite, gold and seat trim (his art orders 2026-10-20 22:45 to 23:05)
Queue (coordinator 10-20 23:45): the full pixel art pass for the party build, job 7 of 10. 86a to 86j sort after his play-note jobs 79 to 86
and before 87; lanes pick by name. Not held for the party (his 23:00 order).
effort: high
After: 86c
If a job named in After is still open (in tasks/, waiting/ or running in a status file), end with TASK WAITING: its file name and what for.

Source (his words, verbatim, tools/handoff/art-survey/answers.md "10-20 evening"):
- "I want to do it all now before the party", then "if we need to reduce the customization to a smaller amount of items/classes etc, that is fine" (10-20 22:45)
- "3 head options, 3 skin options,  3  clothing (with pack) options, and 3 unique full sets" (22:50)
- "lets use that same art style to add more furniture and details inside buildings so as to give the buidlings more identity -- e.g. is this a house, an office, a warehouse, etc" (22:55)
- "quit queuing stuff for after the party -- just do it all as it naturally arises" (23:00)
- "the 3 unique sets i want to be the skeleton, the trooper (heavily inspired by master chief), and the android (heavily inspired by 2b)", then "those should be like full body skins that override whatever else the player had set in terms of customization" (23:05)

Read first: tools/handoff/console/notes/pixel-plan.md (the approach, the dress-up cut table, the switch, the speed budget, the risks).
Style test to match: tools/handoff/art-survey/style-test/ (pix.js, pillager.js, machine.js, ground.js and their preview pictures, style-test.png, style-test-play.png);
his machine lineup: tools/handoff/art-survey/ref-his-lineup.webp. Line numbers in the plan are from v33.17: grep by name.
Rules that bite here: grit() and the job's own hashes only, never rr(); simulation, AI, collision and line of sight untouched; the key stays
salvagerun:profile and the cut writes nothing to the profile; no WebGL, no libraries; player text lower case.

What to do:
Hurt and death states:
- hit flash white then red (a12 B) from the silhouette mask; recoil as 1 px
- low-health body and edge pulse (a13 D) from the outline ring, with the INK swap in the cache key; shoulders drop, blood stains
- downed kneel with the pulsing ring (a14 B)
- player death: fall and turn to light (a15 B) as 8 art-res topple frames
- pillager bot death: fall and fade with no corpse (a23 B, raiderFallDraw)
- the see-through ghost
Bots and specials:
- armour tiers 1 to 3 (st.bulk) as plate overlays
- role marks (drawRoleMark0) re-anchored to the pixel head
- exclamation mark plus body tell (a22)
- elite purple ring (a20 A)
- golden pillager bot as a baked gold palette
Others:
- party seat trim band in SEATCOL, with the ring and number (a06 A)
- peddler and survivor suits
- one shared constant replaces the FIG_SCALE copies in drawRoleMark, drawAimMark and raiderFallDraw
- hooks opWash, opKneel and opDeath

Check (new, must fail on the build before; it sets xfPix 1 and restores it in finally):
Fails before.
- the hit frame is white then red, only inside the silhouette
- low health draws the outline ring, and the pulse alpha varies over 1 s
- ctx.filter is never set while drawing the golden bot
- tier 1 and tier 3 bots differ in sprite width
- the role mark sits within 1 art px of its anchor
- downed, death and fall draw from the cache with no blended colours
- in a 2-window raid the seat 0 and seat 1 trims are SEATCOL[0] and SEATCOL[1]
- a staged fight draws no vector pillager body
Pictures: a hit, low, downed and death strip at 1x and 4x; a raid with 6 bots, an elite and the golden one; a 2-window picture.

Party risk: medium to high: fight readability. Watch line: hits and low health still read in a busy fight, and red bots stand out at night.
Size: about 1 lane-night. Small ships, each easy to undo.

TASK DONE when shipped with its check and pictures; TASK PARTIAL with what is left.
