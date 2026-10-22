
--- codex run 2026-10-21 11:15 ---
2026-10-21, run 1: both dependencies are done (80-machines-a-third-larger and 86e-pix-props). Prepared cw-cx-pixmachines for all nine existing machine designs, including the title sentry. The adapter bakes FIG_MACH and the overseer r/30 inside the art canvas, at PIX_ACT. The key includes four gait frames, sixteen aim angles, mirror, four eye states, elite, gold, size and appearance. A budget miss selects the closest cached pose of that appearance. Cold kinds retain their existing vector fallback.

Hit flash uses the exact opaque body silhouette. Elite colour uses an outline-only mask. Gold is a baked palette. Sensor cores retain their original shapes inside the cached body, including the pillbox iris and warden slit. Additive eye halos, crier rotors and alarm rings, muzzle light, vent heat, windup rings, affix effects and weak points remain live. The listener reuses one cached halo instead of constructing a radial gradient every frame. Alarm text goes through the existing cache-tag HUD hand-off. Nothing reads rr, writes the profile or changes simulation, collision, AI or sight.

The new check measures second-frame cache hits for every kind, bounds against the existing painters at job 80 size (one art pixel tolerance), hard alpha and exact flash masks, twelve animated machines under the shared two-build cap, zero readbacks after three seconds, nearest-pose reuse, baked gold without filters, real-render alarm HUD delivery and the real title-sketch dispatcher. Camera recipes request a benchmark beside his lineup, plus day and night raids. These still need the lane's Chrome gate and critic.

Watch on next play: machines should read against the pixel floor and should not pop while turning.

Local validation: the mk script prints written, all 22 anchors match exactly once, the edited game script and the new check parse, the check reports failure against the old build, and all three camera recipes parse. All handoff files are ASCII. The game file is untouched.


--- codex run 2026-10-21 11:18 ---
2026-10-21, run 2: preflight rejected the first draft because several body bounds grew by 1.5 or 2 art pixels. Two causes: odd bake widths made half-pixel foot anchors, and the prop adapter preserved faint dark antialias pixels as ground shadows before the added ink outline expanded them again. Machine bake widths are now even. An optional actor flag in pixWrapBake uses the opaque alpha cutoff of 128 and bypasses prop ground-shadow recovery; other adapter users retain their existing behavior. The one-art-pixel bounds tolerance stays unchanged. The check now also rejects fractional anchors and reports both measured rectangles when bounds fail.

Also corrected the elite mask: pixRing with keepArt 0 returns a grown silhouette, so the machine edge now explicitly subtracts the original body. The check verifies no elite outline pixels cover opaque body pixels. Existing keys and three camera recipes remain ready for the lane.


--- codex run 2026-10-21 11:44 ---
2026-10-21, run 3: cw-cx-pixmachines shipped at v33.89; the new check passed. Viewed all three first-round pictures. The benchmark reference URL failed because the fixture serves from tools/, so a relative tools/handoff URL doubled the path. The next recipe embeds the local reference as a data URL and now requires naturalWidth > 0 before staging succeeds. The benchmark uses equal cells, a shared ground line within each row, centered 20px names with 16px roles, a 56px header, close control and 36x2 accent tab. Every machine stays at the same 2x magnification; no relative size or design changes.

The raid critics only addressed the existing HUD. Logged those findings for the coordinator. Next photos copy the actual rendered world into a labeled development proof at 2x, preserving the full-resolution machine/floor/lighting pixels while removing unrelated HUD overlays from the art review. Runtime staging disables automatic resolution scaling for these photos and chooses dry scenery with fewer wall/bush overlaps. It does not ship a HUD or gameplay change. This is camera follow-up 1; no new ship key is required.

First-round pictures: tools/handoff/console/notes/shots/86f-pix-machines-recipes-1/86f-machines-lineup-1080.jpg, 86f-machines-raid-day-1080.jpg, 86f-machines-raid-night-1080.jpg. All scored 2; next camera round still required.


--- codex run 2026-10-21 11:56 ---
2026-10-21, run 4: viewed the second-round pictures. Scores: benchmark 2, day 3, night 3. The new reference loads. The benchmark grid was about 60px too tall because the cropped source pictures included extra shadow/halo margins. It now displays the actual cached body canvases, on the same 2x scale and baseline, removing those margins rather than scaling machines individually. Names are 24px, roles 20px and grid gaps 16px. The title remains the required explicit 32px/700. The close control now uses a centered SVG cross with zero inherited button padding, and only shows its focus outline when actually focused.

The raid obstruction is the forge landmark, which was not covered by the map-wall collision score. The next camera recipe explicitly avoids forge, seal and story desk footprints, strongly rejects water, and avoids a bush at the player position. It keeps all map objects in the world. The real raid crop now fills the available frame, includes 20px name tags for all nine machines, and marks the elite and gold captions with 3px colour strips. The footer is shortened to elite sentry + golden warden. No game code or feel values changed. Camera follow-up 2 is ready; the lane still needs to photograph it.

Best current proofs: tools/handoff/console/notes/shots/86f-pix-machines-recipes-2/86f-machines-lineup-1080.jpg and 86f-machines-raid-day-1080.jpg and 86f-machines-raid-night-1080.jpg. The original full-HUD raid views remain in recipes-1. The machine key shipped at v33.89 and the check has passed.


--- codex run 2026-10-21 12:01 ---
2026-10-21, run 5: viewed round 3. The benchmark reached 3, meeting its non-raid finish line. Its remaining requests to remove the owner's reference, resize individual machines or add a new interactive catalogue conflict with the explicit task and were already logged. Kept the required reference, existing designs, shared PIX_ACT and job 80 sizes. The passing benchmark is tools/handoff/console/notes/shots/86f-pix-machines-recipes-3/86f-machines-lineup-1080.jpg.

Day and night both remain 3. Preparing the fourth and final camera round only for these two views. They now explicitly say machine art proof and dev only, since these are camera annotations, not a shipped player screen. Caption plates have a 4px radius, 1px line-hi border, 90% void fill, 20px text, 8px horizontal padding and a full 3px rarity bar. Captions move onto one common baseline per row below the largest shadow. The image gets a 4px panel inset. No game change or new key; all nine bodies and their check already shipped in cw-cx-pixmachines at v33.89.

The critic's requests for a flat background without the floor, props or player would defeat the requested day/night raid context. The task's actual world lighting is preserved. The screenshot is marked dev only instead of adding a new player-facing codex/list or day/night switch. Night readability findings are handed to the coordinator/86j. The older full-HUD pictures in recipes-1 and the two best corrected art versions in recipes-2 and recipes-3 remain available. If the last round stays at 3, two further camera refinements have not raised that score and the no-more-polish rule applies; record the result and finish with that limit stated.


--- codex run 2026-10-22 10:03 ---
2026-10-22, closeout: read the prior run notes and viewed the passing lineup and both final day/night pictures. cw-cx-pixmachines shipped at v33.89 with its check passing; its machine paths and fixture check are present in the current v34.16 worktree. No new ship or game edit is needed.

Final critic results: lineup 3/5, pass (needs 3); day 3/5 and night 3/5 (need 4). Both final raid captures staged successfully with zero camera lint findings. The final two camera refinements did not improve the day/night scores, and all four camera rounds have been used. Closing under the explicit stop-after-two-follow-ups-without-improvement rule, not claiming that the raid score reached 4.

Remaining critic findings concern the proof framing (player touching the crier caption, building behind the overseer, caption styling) and machine/floor contrast at night. Earlier notes already handed night readability to the coordinator/86j. Replacing the raid floor with a neutral backdrop would remove the day/night world context requested by this task. No simulation, light strength or machine size is changed to address proof layout.

Keep these two best proof versions: tools/handoff/console/notes/shots/86f-pix-machines-recipes-3/86f-machines-raid-day-1080.jpg and 86f-machines-raid-night-1080.jpg; tools/handoff/console/notes/shots/86f-pix-machines-recipes-4/86f-machines-raid-day-1080.jpg and 86f-machines-raid-night-1080.jpg. The passing lineup is tools/handoff/console/notes/shots/86f-pix-machines-recipes-3/86f-machines-lineup-1080.jpg. The original full-HUD views remain in recipes-1. All versions are retained for review.

Watch on next play: machines should read against the pixel floor and should not pop while turning. All nine kinds, the title sentry, baked sizes, cache budgets, masks and live effects remain covered by the shipped key. Task complete with the visual review limit stated above.
