86c-pix-pillager : the pixel pillager: 3 heads x 3 skins x 3 clothes, gun and arms, red bots (his art orders 2026-10-20 22:45 to 23:05)
Queue (coordinator 10-20 23:45): the full pixel art pass for the party build, job 3 of 10. 86a to 86j sort after his play-note jobs 79 to 86
and before 87; lanes pick by name. Not held for the party (his 23:00 order).
effort: high
After: 86a, 79a (its measured standing height sets the grid)
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
Body:
- Port the style-test generator inline: parts, ramp(), tones(), stamp(), and the face grid redrawn for the smaller grid.
- One body at PIX_ACT, sized from 79a's measure (about 45 to 57 art px; never a shrunk test sprite), with the chibi head (a01 D).
- 3 heads x 3 skins x 3 clothes with packs.
- Front view plus a separately baked mirror that keeps the top-left light. The pack sits on the side away from facing, as today.
Poses:
- stand (2 breath frames), walk 6, sprint 6, crouch (a17 A), roll 4
- the a11 B bounce becomes 1 px bob frames with today's timings
Gun and arms:
- each gunBake shape painted at art density and pre-rotated in 32 steps at art resolution
- flipped when aiming left; behind the body when sin(face) < -0.3
- the muzzle point is read from the rotated sprite, so tracers start where they did
- the aim line and the rare-gun laser are unchanged (a16 B); pupils shift 1 px toward the aim
Who it draws:
- drawOp routes everyone: you, player 2, hires, the Undercroft crowd, and the FASHION previews (whole-number 4x, smoothing off)
- pillager bots: head, skin and clothes come from raiderLook's own hash, drawn in the red ramp with angry brows and red eyes (a18, a19)
Fallbacks:
- Not pixel yet, so drawn as today's vector body: armour tiers, role marks, hurt, downed, death, elite, gold, sets, peddler, survivor.
- A throw falls back to drawOpB and logs DRAWERR.
- Shadow, seat ring and number are unchanged.

Check (new, must fail on the build before; it sets xfPix 1 and restores it in finally):
Fails before: no pixel body.
- a standing pillager costs at most 8 wc calls
- the 27 looks give 27 different sprite hashes
- drawn height is within 2 px of 79a's measure, with the foot point at the entity point
- a bot's clothes pixels are all in the red ramp, and its brow pixels exist
- at all 32 steps the pixel muzzle is within 1 world unit of today's vector muzzle
- a forced throw still draws a body
- 0 getImageData over 60 frames after warm-up
Pictures:
- ?pixbench with the 27 looks at 1x and 4x, next to style-test.png
- raid at 1080 and 4K, 8 aim directions
- the 2-window demo (rule 2.86 a)
- the critic compares against style-test-play.png

Party risk: high: every body, both players and the demo. Watch line: whether the heads, skins and clothes read at raid size, whether the aim reads in 32 steps, and the stepped walk bounce.
Size: about 1.3 lane-nights. Small ships, each easy to undo.

TASK DONE when shipped with its check and pictures; TASK PARTIAL with what is left.
