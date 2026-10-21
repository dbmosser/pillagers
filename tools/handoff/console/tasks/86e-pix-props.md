86e-pix-props : the pixel adapter: containers, barrels, wrecks, cover, lamps, landmarks, wildlife (his art orders 2026-10-20 22:45 to 23:05)
Queue (coordinator 10-20 23:45): the full pixel art pass for the party build, job 5 of 10. 86a to 86j sort after his play-note jobs 79 to 86
and before 87; lanes pick by name. Not held for the party (his 23:00 order).
effort: medium-high
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
1. Add pixWrap(key,w,h,density,paint) on the rimOpen pattern:
   - points wc at an art-res scratch and keeps shadowE on the world
   - restores wc in finally, and nests with rimOpen and goldBodyBegin
   - hardens, snaps to the nearest ramp tone, adds the edge
   - caches by kind, state, variant and day
2. At PIX_ACT:
   - drawContS: crate, locker, safe, strongbox, cache, jackpot, generic box, body, carcass; opened and closed
   - barrel bodies
   - the 9 machine wrecks and the legacy botwreck
   - deer and birds, alive and dead, as art-res frames
3. At PIX_ENV:
   - cover wrecks: car, skip, barrier, pipes, pallets
   - lamps; the forge, seal slab and story desk
   - the extraction ring
   - Undercroft posts, racks and the drop crate
4. Kept live on top: wreckSmoke, the barrel pulse and pools, lamp flicker, the forge mouth and embers.
5. Text drawn inside these painters (meridian strongbox, seal %, forge name) moves to the GFXWT hand-off.
Furniture is left to 86i.

Check (new, must fail on the build before; it sets xfPix 1 and restores it in finally):
Fails before: no adapter.
- after warm-up each listed kind is 1 drawImage
- cached sprites hold only alpha 0 and 255
- opened and closed are both cached
- footprints are unchanged (crate 16, locker 12, cache 26)
- a forced throw inside pixWrap leaves wc as the world context
- 0 readbacks over 60 frames, and wreck smoke still animates
- no wc.fillText for the moved labels
Pictures: a ?pixbench props sheet, and a raid street at 1080.

Party risk: low to medium: loot containers. Watch line: opened and closed still read at a glance.
Size: about 0.8 lane-nights. Small ships, each easy to undo.

TASK DONE when shipped with its check and pictures; TASK PARTIAL with what is left.
