86d-pix-walls-trees : pixel walls, doors, windows, stronghold walls, trees, bushes and hard shadows (his art orders 2026-10-20 22:45 to 23:05)
Queue (coordinator 10-20 23:45): the full pixel art pass for the party build, job 4 of 10. 86a to 86j sort after his play-note jobs 79 to 86
and before 87; lanes pick by name. Not held for the party (his 23:00 order).
effort: medium
After: 86a
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
Walls:
- wallSprite bakes at a fixed 1/PIX_ENV, so it never rebuilds on zoom or Auto resolution.
- wallPaint uses stepped district ramps: one lit top row, one INK bottom row, brick or panel courses by grit, and bullet marks as pixel chips.
- The same treatment for doors, windows, kerbs, ruins, the stronghold shutter, barricade, fence and gate (shWallDraw), and the Undercroft's copy of the wall renderer.
Trees and bushes:
- VEGSPR canopies and bushes use the test's 3-tone plant ramps, hard alpha, and a bottom and right edge in their own dark tone.
- Trunks are drawn live at art pixels.
Shadows: shadowE stamps become hard pixel shadows (a09 B bigger and darker).
Day and night palettes are kept.

Check (new, must fail on the build before; it sets xfPix 1 and restores it in finally):
Fails before: no pixel walls.
- with xfPix 1 a wall sprite is (w/2, h/2) times k
- colours come only from the district ramps, and the lightness bands hold (wall 54-60, top 72-78)
- the sprite count is unchanged when Render resolution changes
- tree, bush and shadow stamps hold only alpha 0 and 255
- the tree list and seg grid are identical with the switch on and off
- with xfPix 0, sizes and hashes are unchanged
Pictures: 4 districts day and night, and the hub.

Party risk: low to medium: everywhere on screen, but drawing only
Size: about 0.7 lane-nights. Small ships, each easy to undo.

TASK DONE when shipped with its check and pictures; TASK PARTIAL with what is left.

REQUEUED 10-21 05:40 (coordinator): 5 runs shipped v33.66 (pixel walls) and v33.69 (trees, bushes, shadows); its last words were TASK PARTIAL. Left, in order: pixel doors, windows, kerbs, ruins, the stronghold wall and the Undercroft wall copy, then the four districts day and night and the hub pictures, and the critic on them. Read the 1021-0405 run log first; do not redo the walls or trees. Its earlier runs are renamed 86d-pix-walls-trees-r2, so it has its full runs again.
