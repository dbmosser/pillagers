# 86h-pix-sets-wardrobe (lane b, 10-21)

- 10-21 run: not started. After-job 86g-pix-pillager-states is still open (parked in blocked/, waiting on 86c-pix-pillager, which is still in tasks/). Nothing changed.
- 10-21 lane c run: 86g-pix-pillager-states still open in tasks/. Nothing changed.
- Ready to go once 86g ships: read pixel-plan.md "The dress-up cut"; the rig and 27 looks are in v33.58 cw-pixbody and v33.65 cw-pixcrowd; the FASHION turntable (cw-cx-pixpreview, 4x) was drafted by lane o and may be in draft-cw-cx-pixpose / pixhub; rack tiles and sets are this job.

--- codex run 2026-10-21 12:57 ---
2026-10-21, lane o first implementation run, base v33.90.

Dependency: 86g is in failed/, not tasks/, waiting/ or a running status. Its rendering code shipped through v33.90; its last notes describe a camera-only second critic round. This draft uses those shipped pose, hurt, downed and death APIs. No 86g source was reverted or changed.

Prepared cw-cx-pixsets, listed in keys.txt. No tracked game or fixture file was edited. The self-contained mk has 25 unique anchors and reads MK_SRC / writes only its requested draft in MK_OUT_DIR, with the required real-repo fallbacks.

The three sets are original whole-pixel masks with four-tone shading on the existing 36x54 actor rig: exposed ribs, spine, skull and leg bones with a canvas pack strap; a broad armoured trooper with a full helmet and recessed gold visor; and a slim pale android with a white bob, blindfold band, short dark dress and tall boots. They use the existing standing, walk, sprint, crouch, roll, aim, reload, hurt, downed and topple paths. Melee retains the set body, with a cached art-resolution arm and crowbar on the existing punchT/barT clocks. No combat timing, reach, AI, collision, visibility, seeded randomness or network format was changed. Set hands use fixed set materials. Every set has the seat trim; roll and death cache keys include it.

FASHION keeps its current columns and turntable. Pixel mode replaces its old controls with four racks and thirteen controls: three heads, three skins, three clothes, three sets and off. Art tiles are nearest 2x; the existing turntable is 4x and turns through front and mirror. Kept ids are exactly the plan table. A pick writes only those ids; selecting a set never replaces the stored base picks. Off restores their rendering. The old nineteen groups, items and tabs remain behind xfPix=0. Unlock rules are unchanged, including old The Machine ownership granting trooper. Kept always-owned ids also survive cosWorn, saved looks and NET_LOOK; in particular the hood is not lost to the old warden requirement. Saved-look labels use the read-side cut. No restore format, profile fields or storage key was added or removed.

For the instruction that arcadeLook and the crowd pick evenly from twelve, the shared roller has twelve equal intervals: nine ordinary complete looks balance all three head/skin/clothes axes, followed by one skeleton, trooper and android. This gives twelve distinct complete looks rather than independently rolling thirty possible results. Surprise me uses the owned subset. Old unused profile fields are retained, not scrubbed. The current source has no cosmetic-unlock-toast enumeration to retarget; existing generic cosmetics callouts stay generic, and the new controls name only kept picks.

Found and fixed an own/remote disagreement while checking the draft: schemeOf applies the old seat scheme replacement, while the pixel plan wants clothes preserved with a seat band. Both sides of pxLookOf now resolve the raw scheme id, and the existing seat band and ring identify the seat. The local probe verifies all twelve rolls resolve identically for owner and wire look even when schemeOf proposes a different seat scheme.

Local validation passed: mk prints written; 25 anchors match once; candidate inline game script and new fixture check parse; the real masks/tones produce six front/mirror set bodies and 144 leg bakes; exact trim pixels are present; all thirteen setters change exactly their listed keys; all twelve complete rolls differ; every set ignores hidden base picks. Inspected sets-offline.png beside the approved style-test-play.png. This is local art inspection, not a critic score or browser evidence. All handoff text and scripts are ASCII.

The new fixture check fails immediately on v33.90 because pxSetUpper/renderPixWardrobe are absent. On the candidate it tests real sprite hashes against all 27 ordinary looks, set override/off behavior, all four seat colours, gait/roll/topple bakes, exact profile writes, locked sets, the real FASHION click, pad focus/B close, hood saved-look/net/restore-code retention, nineteen legacy groups, unchanged tables/profile key, 200 actual demo/crowd rolls, and ten actual raid-render poses per set. It pins xfPix=1 and restores it and all replaced state in finally. Browser execution remains the lane responsibility; no preflight or browser was attempted here.

Five camera-recipes.json scenes are ready: ?pixbench set sprites at 4x with native samples and mirrors; the existing FASHION page at 1080; a skeleton in the real raid; and both real linked demo windows with skeleton/android. The pair recipes reuse 86c staging, wait for each actual wire look, verify both rendered sets and both seat bands in each window, and export full/cropped images. Development proof panels exist only in camera recipes. There are no changes to the player's UI for those proof panels. No recipe images or critic scores have been received yet.

Watch on next play: the skeleton's bone silhouette and trim during melee/roll/downed transitions, ownership of the three set tiles, switching a set off without losing base picks, and the same set/trim in both demo windows.

Remaining: the lane must run preflight, ship cw-cx-pixsets, capture all five scenes and run the critic. Fix any gate failure or P0/P1 finding on the next run; the task is not done until it ships and the required pictures reach the finish line.


--- codex run 2026-10-21 12:59 ---
2026-10-21, lane o preflight repair, base v33.90.

The lane reported the same new-check failure twice: off did not restore nineteen racks. The game edits were correct; the check incorrectly expected 38 top-level elements. The old wardrobe emits two elements for each of nineteen racks plus one colour-scheme note, so it has 39 elements.

Corrected only the fixture check in the same cw-cx-pixsets key. It now identifies direct tile containers by their actual data-kind values and requires the full ordered list of nineteen legacy rack kinds, with no pixel controls. A decorative note cannot affect the count. A missing, repeated or wrong rack still fails, and the failure now prints the kinds found. All 25 game edits and all five camera recipes are unchanged.

Regenerated the self-contained mk and draft. Local checks pass: written; 25 unique anchors; candidate game/check syntax; set raster, exact thirteen ID mappings, twelve rolls, own/wire agreement and set override probes. Added verify-legacy.js as an offline structural probe: the real old and candidate renderCosmetics functions emit identical off-mode markup with art thumbnails stubbed; it contains 39 top-level elements, nineteen tile racks and one scheme note. The corrected assertion passes that markup and rejects a removed or duplicated rack. This probe does not claim a Chrome preflight result.

Ready for the lane to retry preflight and ship cw-cx-pixsets, then capture the five requested scenes and run the critic. No new product change or visible-change log is needed for this test-only repair.


--- codex run 2026-10-21 13:03 ---
2026-10-21, lane o compatibility repair, base v33.90.

Preflight now reports one older-check failure: REGRESS 33.58, a set was drawn in pixels but is still the vector body. That check predates the set job and explicitly expected outskeleton to fall back to vector. The same loop also protects the staged plain fists and downed fallbacks.

Prepared fixture-retarget.json for the lane, under its lock, tied to cw-cx-pixsets and running version 33.58. It changes only that loop assertion and its outdated comment. Without pxSetUpper, the existing skeleton must still use vector, so the retarget can pass on the current v33.90 before the key ships. Once pxSetUpper exists, the same real four-frame draw must increment PIX.bodies or the check fails. The other staged fallback assertions remain intact. No old check was removed, and none of its 27-look, palette, muzzle, draw-count, forced-throw or readback assertions changed.

Local verification: both fixture anchors occur once; the complete retargeted 33.58 check parses; the assertion accepts the current vector set and the new pixel set, rejects the opposite behavior for each build, and still rejects pixel fallback violations for the other two cases. The retarget is ASCII and names its dependent key. The mk still prints written, all 25 game anchors match once, and the existing candidate syntax/art/ID/own-wire probes pass. Game edits, new check and camera recipes are unchanged from the prior repaired draft.

Remaining with the lane: apply and validate the fixture retarget on the current build, rerun preflight, ship cw-cx-pixsets, photograph the five scenes and run the critic. The job is not complete until shipping and picture review succeed.


--- codex run 2026-10-21 13:27 ---
2026-10-21, lane o visual follow-up 1, base v33.91.

SHIPPED cw-cx-pixsets in v33.91. The fixture retarget landed as 5086acf4 and check 33.58 passed first on the old v33.90 trial. All five round-1 scenes staged. Both linked windows reported real host/guest links, both sets, both seat bands and zero pixel faults. Images: tools/handoff/console/notes/shots/86h-pix-sets-wardrobe-recipes-1/.

Reviewed all five attached images. Critic scores were bench 2, fashion 3, raid 2, player 1 pair 3 and player 2 pair 3. FASHION had a real P0 despite reaching 3: worn tiles had no visible border, and its set row was below the fold. Legacy button CSS overrode the early pixel CSS. The empty tab strip, roomy tiles, gradient stage and small save controls also need correction. These are not accepted final pictures.

Prepared cw-cx-pixrackfit as a separate six-edit follow-up, after the shipped key in keys.txt. New CSS is scoped to a pixel-only class and appended after the legacy styles. Worn tiles get a 2px lime border, a 4px inset bar and a lime 16px worn label. Pad focus gets a distinct outer 2px outline. The three ordinary racks fill their rows; set uses four columns. Tiles use an art column plus adjacent name/status, with the original nearest 2x pixels. Tile height is 128px, or 120px below 1000px viewport height. Both keep all four racks visible. No kept id, profile writer, set unlock or random roller changed.

FASHION hides the unused tab strip and the explaining sentence in pixel mode. The player pane is called your pillager, following his naming rule. Panel headings are quiet 20px text. The turntable stays exactly 4x, now in a flat 320-square canvas instead of a 380x470 gradient. Its shallow shadow uses the original shadowE hook, and linked seat rings are retained. The temporary preview ground painter and wc are restored in finally. Saved-look text is 16px and save buttons are 48px tall; repeated save-to-keep explanations are hidden. The existing surprise/save/wear controls and their handlers remain the only controls. The new check measures actual selected/focus styles, all thirteen visible controls, equal tile heights, font/button sizes and the legacy-style reset.

Kept the corner totals: the critic request to delete xp, stash and bag conflicts with his 10-15 everywhere order. Kept the worn skeleton in the preview: it is correct, because his set order explicitly overrides the base picks. The new visible set row should remove the apparent contradiction. Logged these rulings once in questions-new.md. Retained the required exact 4x and native samples rather than adopting inconsistent scale suggestions.

Round-2 camera presentation is prepared in camera-helper.js and regenerated camera-recipes.json. These helpers remain camera-only. The bench is now three compact panels, each grouping actual front/mirror 4x art and labeled 1x samples. The 16px labels and 32px title use explicit scoped rules. Raid and linked views have a factual read-only side column, a separate full game thumbnail including HUD, and a tighter nearest crop. No thumbnail overlaps the crop. Camera staging chooses a shared clear rectangle, moves the two real players through the existing fixture stand route, and waits for their real network positions, so the second character is not behind a wall. Actual scene colours, lighting and sprite pixels are unchanged. There are no equip/select buttons, fake tabs or additional player-facing proof screens.

Local validation passed: mk prints written; six anchors match once; candidate inline game script and fixture check parse; all five async recipes and helper parse; handoff files are ASCII and fallback paths are correct. A local failure-injection probe confirms drawAvatarCanvas restores wc and opGround, and keeps both the shadowE hook needed by check 33.75 and linked seat rings. Browser layout and critic results still belong to the lane.

Remaining: lane preflight/ship cw-cx-pixrackfit and round-2 photographs/critic. Watch the set-row fit at 1080 and smaller gate height, visible selected/focus states, and saved-look controls. No simulation, combat timing or world art changed.


--- codex run 2026-10-21 13:29 ---
2026-10-21, lane o cw-cx-pixrackfit check repair, base v33.91.

Preflight reported two failures twice: worn skeleton lacks its lime selected border, and pad cursor is invisible. Both failed assertions compared computed line widths to an unscaled literal 2. The worn label colour assertion and the other layout/control assertions were not reported as failures.

The game uses menuScale/titleRes to zoom modals below 1080p; the gate viewport is 1888x977. Chrome quantizes border and outline widths under that zoom, so a declared 2px line can report less than 2 in computed style. Corrected the check to create a temporary 2px lime border/outline reference in the same picker, measure its used widths, and compare the actual selected tile and pad cursor against those widths. It still requires the pressed state, exact lime colour, a non-none stroke and at least the reference thickness. It refuses a missing reference and removes it immediately and in finally. Any remaining failure now includes the actual colour, style, width and reference width.

Only the check changed. The six game edits, CSS, keys and five camera recipes are unchanged. Regenerated the self-contained mk and draft; written, six unique anchors, candidate script/check syntax, preview failure cleanup, original shadow/seat hooks, recipe parsing, ASCII and fallback-path probes pass locally. This does not claim a browser pass; the lane must retry preflight and then photograph/review round 2 after the follow-up ships.

