86h-pix-sets-wardrobe : skeleton, trooper and android sets, and the 4-rack wardrobe (his art orders 2026-10-20 22:45 to 23:05)
Queue (coordinator 10-20 23:45): the full pixel art pass for the party build, job 8 of 10. 86a to 86j sort after his play-note jobs 79 to 86
and before 87; lanes pick by name. Not held for the party (his 23:00 order).
effort: high
After: 86g
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
Sets, on the same rig and every pose:
- skeleton: bare bones with a pack strap
- trooper: big armoured space soldier, full helmet, gold one-way visor
- android: slim pale figure, short white bob, black blindfold band, dark short dress over boots
- Inspired only: own shapes, no names, logos or traced art.
- A set overrides head, skin and clothes while worn, and the team trim band shows.
FASHION screen in pixel mode:
- 4 racks: head, skin, clothes, and set with an off tile
- pixel tiles at a whole-number scale, and the turntable (front and mirror)
- same layout as today, so no new design and no mockups
- tiles write only the listed old ids; saved looks and restore codes keep working
- arcadeLook and the crowd pick evenly from the 12
- unlock toasts never name a cut item
- pad routes and B back work as on the other pages
- with xfPix 0 the screen shows today's 19 racks
Critic finish line 3, at most 6 tries.

Check (new, must fail on the build before; it sets xfPix 1 and restores it in finally):
Fails before.
Sets:
- the 3 set sprites differ from each other and from the 27 looks
- wearing a set ignores the head, skin and clothes picks, and taking it off restores them
- the seat trim shows on a set
- every pose bakes for each set
Wardrobe:
- pixel mode shows 4 racks and 12 tiles plus off
- each tile writes exactly its listed ids
- xfPix 0 shows 19 racks
- the key is salvagerun:profile
- 200 arcadeLook rolls give only the 12
Pictures: ?pixbench with the 3 sets at 4x, FASHION at 1080, a raid, and the 2-window demo.

Party risk: medium: his own look is the skeleton, and the demo's random look comes from arcadeLook
Size: about 1.3 lane-nights. Small ships, each easy to undo.

TASK DONE when shipped with its check and pictures; TASK PARTIAL with what is left.
