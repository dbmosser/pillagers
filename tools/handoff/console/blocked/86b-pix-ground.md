86b-pix-ground : pixel ground for raids and the Undercroft at 2 units per art pixel (his art orders 2026-10-20 22:45 to 23:05)
Queue (coordinator 10-20 23:45): the full pixel art pass for the party build, job 2 of 10. 86a to 86j sort after his play-note jobs 79 to 86
and before 87; lanes pick by name. Not held for the party (his 23:00 order).
effort: high
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
1. With pixOn, bakeGround runs its same code into a canvas scaled 1/PIX_ENV, so every rr() draw stays in its old order. COLD STORAGE becomes 2100x1700, about 14 MB instead of about 57.
2. Then a posterize and texture pass in 256x256 chunks:
   - each pixel snaps to a 4 to 5 step ramp of its district hue (a29 A colours, value bands kept)
   - concrete gets slab seams and 1x2 and 1x3 strokes on a jittered grid; turf gets grass teeth on its edges
   - halos and floor fades become stepped bands
   - roads and dashes, 5 interior floors, water bands, manholes and rubble keep their places
   - all texture comes from grit() or the pass's own hash, never rr()
   - day and night ramps
3. Timing:
   - spawn chunks are done before the first frame; the rest at most 4 ms a frame during the ascend countdown
   - the context-restore rebake (onCtxRestored) uses the same queue
4. The slice blit halves the source rect: nearest when S*PIX_ENV is whole, smooth otherwise.
5. Blast scars (gfxScarReplay), footprints and decals snap to the ground grid.
6. bakeHubGround uses the same ramps.
7. The ground follows the switch at the next ascend or hub entry.

Check (new, must fail on the build before; it sets xfPix 1 and restores it in finally):
Fails before: no half-density ground.
Real (not sim) build of seed 4242 in both modes:
- the rr() position after the build is identical
- with xfPix 1, G.ground is half size
- a 64x64 sample per district holds at most 8 colours (over 20 before)
- no chunk step takes over 4 ms, and the whole bake is under 1.5 s on the VM
- xfPix 0 still gives the full-size canvas
- the 4242 fingerprint holds (ents 85/374, containers 165/593)
- the hub floor uses only ramp colours
Pictures: raid at 1080 and 4K, day and night, and the hub.

Party risk: medium: most of the screen, plus ascend load and memory in both windows. Watch line: any hitch at ascend, and pillagers or machines blending into the floor at night.
Size: about 1 lane-night. Small ships, each easy to undo.

TASK DONE when shipped with its check and pictures; TASK PARTIAL with what is left.
