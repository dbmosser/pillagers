86j-pix-fx-guard : pixel sparks, blasts and power-ups, party guard, night check, corpus pass with pixel on (his art orders 2026-10-20 22:45 to 23:05)
Queue (coordinator 10-20 23:45): the full pixel art pass for the party build, job 10 of 10. 86a to 86j sort after his play-note jobs 79 to 86
and before 87; lanes pick by name. Not held for the party (his 23:00 order).
effort: medium
After: 86c, 86f, 81. The corpus pass runs last, over whatever of 86a to 86i has shipped.
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
1. Effects:
   - sparks, blood, puffs and debris as whole art-pixel squares (a34 B)
   - blast and scorch stamped in pixels (a35 B)
   - muzzle flash and tracers as now (a33 A)
   - power-up medallions baked per kind at job 81's half size, drawn with pixBlit on the HUD canvas
   - extraction, downed and seat rings stroked at whole art pixels
2. Party guard: a kind that throws 3 times in a raid draws in vector until the raid ends, with one flight-recorder line. It never turns the switch off.
3. Night readability: if the measure in the check fails, tune the night ramps of ground and walls (a30 B, a31 B).
4. Corpus pass:
   - run the newest 80 checks once with xfPix 1; log the reds, and retarget through fixq those that measure positions or hit boxes
   - robots (tools/fuzz.ps1) with pixel on
   - the 2-window budget run

Check (new, must fail on the build before; it sets xfPix 1 and restores it in finally):
Fails before.
- particles draw as whole-unit fillRect with no arc per particle
- the medallion edge has no blended pixels at a whole scale
- an injected throwing bake leaves the body drawn in vector, and after 3 throws the kind stays vector with one recorder line
- at night, the lit-side luminance of a standing pillager against the floor is at least 1.8:1 in all 4 districts
- the perf budget lines hold: 0 readbacks and no filters after warm-up, the call caps, and caches under their caps
Pictures: a firefight strip, and a night raid at 1080.

Party risk: low: effects and a safety net
Size: about 0.8 lane-nights. Small ships, each easy to undo.

TASK DONE when shipped with its check and pictures; TASK PARTIAL with what is left.
