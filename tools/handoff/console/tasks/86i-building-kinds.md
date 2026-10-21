86i-building-kinds : building kinds: pixel floors, furniture skins, flat details, then solid pieces (his art orders 2026-10-20 22:45 to 23:05)
Queue (coordinator 10-20 23:45): the full pixel art pass for the party build, job 9 of 10. 86a to 86j sort after his play-note jobs 79 to 86
and before 87; lanes pick by name. Not held for the party (his 23:00 order).
effort: high
After: 86b, 86e
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
His 22:55 and 23:00 orders. Two ships.
Ship 1:
- Each building made in makeBuilding gets a kind (house, office, warehouse; shop or workshop if they fit) from grit() of its id and position, never rr().
- The kind picks the interior floor in the pixel ground bake.
- It re-skins the 7 existing furniture kinds through pixWrap at PIX_ENV.
- It bakes flat details into the ground (rugs, desk papers, pallets, oil stains, shelf lines) that never block movement or sight.
Ship 2, right after ship 1 (his 23:00 order allows solid furniture now):
- A few solid pieces per kind (beds and sofas, desk rows, rack rows), placed in a later seeded draw that touches no counted thing.
- The reachability repair keeps every door, room and loot spot reachable.
- If the fingerprint would move, retarget it in the same ship with the reason.
Kinds and solid pieces are world content, the same in both windows. Floors, skins and details follow the switch.

Check (new, must fail on the build before; it sets xfPix 1 and restores it in finally):
Fails before: no kind.
Ship 1:
- every building on seed 4242 has a kind, and at least 3 kinds appear
- the fingerprint holds (ents 85/374, containers 165/593)
- the rr() position is identical with and without kinds
- the nav grid and sight segments are byte-equal
- no flat detail is in a wall, collision or sight list
Ship 2, over 20 seeds:
- every door, room and container is reachable from the spawn
- no piece sits on a doorway or loot spot
Pictures: one building of each kind.

Party risk: low for ship 1. Medium to high for ship 2, which changes paths and sight lines; it may land after the lock, in the game file but not the party copy.
Size: about 1 lane-night. Small ships, each easy to undo.

TASK DONE when shipped with its check and pictures; TASK PARTIAL with what is left.
