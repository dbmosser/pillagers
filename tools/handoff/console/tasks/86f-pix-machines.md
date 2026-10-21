86f-pix-machines : all 9 machines through the adapter at job 80's size (his art orders 2026-10-20 22:45 to 23:05)
Queue (coordinator 10-20 23:45): the full pixel art pass for the party build, job 6 of 10. 86a to 86j sort after his play-note jobs 79 to 86
and before 87; lanes pick by name. Not held for the party (his 23:00 order).
effort: high
After: 86e, 80
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
1. Paint sentry, crawler, crier, bulwark, howler, listener, pillbox, warden and overseer through pixWrap at PIX_ACT. The title skit's sentry is included.
2. FIG_MACH (job 80) and the overseer's r/30 are applied inside the art, never as a canvas scale on a finished sprite.
3. Pose key: kind | step frame (4) | aim angle (16) | mirror | eye state (4) | elite | gold. A miss draws the nearest cached pose.
4. Effects:
   - hit flash from the silhouette mask
   - elite ring from the outline ring in its colour
   - the golden enemy as a baked gold palette, replacing goldBodyBegin's per-frame filter
   - the windup ring (a27 B), eye halos and weak-point glows drawn live after the body
   - 'lighter' blends kept out of the cached body
5. ALARM moves to the HUD hand-off. The listener comes off its per-frame radial gradient.
6. Designs stay as now (a24 to a26 A).

Check (new, must fail on the build before; it sets xfPix 1 and restores it in finally):
Fails before: machines are drawn by vector painters every frame.
- per kind, the second frame is a cache hit
- bounds equal job 80's within 1 art px
- with 12 machines on screen: at most 2 builds a frame, and 0 readbacks after 3 s
- no wc.filter while drawing a golden body
- hit-flash pixels fall exactly on the opaque mask
- no ALARM fillText on wc
- the title skit draws the pixel sentry
Pictures: ?pixbench next to ref-his-lineup.webp, and a raid day and night.

Party risk: medium. Watch line: machines read against the pixel floor and do not pop while turning.
Size: about 1 lane-night. Small ships, each easy to undo.

TASK DONE when shipped with its check and pictures; TASK PARTIAL with what is left.
