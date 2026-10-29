
--- codex run 2026-10-29 00:10 ---
2026-10-29, first implementation run, starting v36.28.

Prepared cw-cx-aimfocus. Only the render camera changes. The hip camera retains the existing player anchor, screen lean, zoom settings and world clamp. ADS uses a world focal point halfway along mouse aim, 60 percent for optics of 2.5 or more. Pad focus uses the aim angle and the existing chosen aim reach. The local G.player drives every view; no shared-camera or network rules change.

The task asks for both a halfway pivot and an unchanged aimed ground point. A literal halfway zoom pivot cannot preserve the target under a stationary cursor. The solver therefore calibrates the focal point's screen slot at entry, then eases the world focus as aim moves. This keeps the original mouse target fixed during the zoom and reverses the zoom on release. Pad framing centres toward the partial world focus and reprojects its endpoint through the camera in the same frame. The existing 11/second zoom ease and 9/second camera ease are retained.

The ADS camera clamps the pillager to the middle 76 percent before applying the existing world clamp. At the extreme map boundary, an existing world-clamp limit can take priority over the approximate 12 percent player margin; both constraints cannot always hold when the permitted outside-world padding is only 80 world units. No world boundary rule changed.

Validation available in the sandbox: mk prints written; both anchors match once; all patched inline scripts and the new fixture check parse; all output is ASCII. validate-camera.cjs evaluates the actual new helper and the actual old camera block with numerical projection inputs. With the cursor 400px right of the pillager, the old camera drifts 153.43px at the gate size. New entry, settled ADS and release stay within floating-point precision for unscoped, 2x, 2.5x and 4x at 1888x977, 1920x1080 and 3840x2160. Hip framing returns. A 1000-frame rotating pad/moving player audit stays finite and inside the safety margin. This is a numerical audit, not the browser fixture gate. ESLint dependencies are absent in this worktree; the lane must run its normal lint/preflight gates.

The shipped regression uses real __frame calls and mouseWorld/w2s projections, tests the 400px target case for host and join roles, unscoped and 4x, unchanged hip framing and release, pad endpoint alignment, 60 percent long-gun focus, reduced effects, and diagonal edge aim. No older checks need retargeting. The seed 4242 simulation fingerprint remains the lane gate's responsibility.

Six camera recipes are ready: player 1 hip, unscoped ADS, 4x ADS, pad ADS; player 2 2x ADS and hip. They use separate fixture pages (including the existing p2 URL) and freeze simulation only inside those camera pages. They cover host/join rendering, not a live connected two-window network session. The static sentry marks the aimed ground point. Custom recipes have no before pictures under the lane protocol.

The exact requested watch line is in the draft why text so the normal generated DESIGN entry includes it: aiming zooms toward the crosshair; watch that it never feels seasick and your pillager never leaves the screen.

Still required from the lane: preflight, ship, seed/regression gates, ON HIS PC confirmation, six pictures and critic review. Do not mark this task done yet.


--- codex run 2026-10-29 00:23 ---
2026-10-29, v36.29 review and camera round 2 request.

cw-cx-aimfocus SHIPPED v36.29. ON HIS PC v36.29 confirmed by the lane, 50 seconds after ship. The requested watch line is present in DESIGN.md:40031. No further game key is needed for the camera behavior.

Opened and inspected the round-1 4x, pad and player-2 pictures with the image viewer; also reviewed all six attachments. The camera reports every recipe staged at 1080p and 4K. Target drift is below 0.001px, including unscoped, 2x and 4x; pad endpoint drift is zero. The scoped pillager is visible at the left, inside the screen. The expanded pad controls partly cover the pillager. All shots were made with p.iv=9999, which can blink the body; that is unnecessary because simulation is frozen in the camera pages.

Round-1 critic scores by image 01-06: 3, 2, 2, 2, 2, 2. The reviews mostly concern existing HUD design. Their repeated open-controls P0/P1 findings expose an inaccurate fixture state: __deploy forces legendOn=1 unless keepLegend is true. The fixture also pins the minimap on, contrary to the current game default. The 4x review says there is no visible zoom, but the props are 2.3 times their hip size and the camera data confirms adsZ=2.3; adding a new scope overlay or extra reticle numbers would expand this camera task unnecessarily.

Updated all six camera recipes for a second review. They now use an experienced career profile (P.runs=10) with keepLegend:true, the actual default minimap setting, the existing user-folded scoreboard preference, and p.iv=0. These are explicit test-page settings only. No HUD feature or default is disabled in the game. The same scene, cursor offsets, weapons, local host/join roles and target checks remain. The revised recipes should show the pillager clearly and let the critic assess the framing without the fixture-forced expanded panels.

Remaining existing HUD findings are handed to the coordinator separately, without mixing HUD redesign into camera feel. Finish still awaits the revised camera pictures and critic result. Round-1 pictures remain at tools/handoff/console/notes/shots/o-00h-225-ads-zoom-toward-the-aim-recipes-1/.

--- codex run 2026-10-29 00:33 ---
2026-10-29, camera round 2 review and station-label follow-up.

Main camera remains shipped and ON HIS PC v36.29. Inspected all attached round-2 views and opened the pad/player-2 images with the image viewer. With normal folded controls, the pad pillager is clearly visible; mouse 4x also keeps the pillager inside the left edge. All six stages still have less than 0.001px target drift (pad zero). Round-2 critic scores for 01-06 are 3,2,3,3,2,3, with every verdict saying better than before. The numeric scores remain below the raid finish line.

Prepared a separate rendering-only follow-up, cw-cx-adsstationtags, for the repeated P0 clipping of forge/seal names. Those two existing labels now carry a station flag and use the already established cache-label 24px screen margin and shared panel. Completely offscreen station names are still culled instead of becoming new edge locators. Cache labels, other queued labels, text wording, camera math, zoom timings, simulation and loot are unchanged. This keeps the rendering correction separate from camera feel.

Validation: all four anchors match once and mk prints written. All patched game inline scripts and the browser check parse. validate-stationtags.cjs runs the actual old/new queued world-text blocks: eight left/right edge cases across 1080p, 4K, hip scale and 2.3 ADS scale; every old case fails and every new case passes. Cache and other nonstation label output is identical. Far-offscreen station labels remain culled. The browser check independently records actual _wtA text and shared-panel pixel bounds at those sizes/zooms.

One compatible fixture retarget is supplied for 36.13. That existing cache-label check assumes the first world uiPanel belongs to the cache. Station labels now have their own panels, so the check instead finds the panel containing the recorded cache text. It still requires the same cache text, panel, padding, contrast and margins. This retarget also passes the old build and must run before the dependent key. Its exact anchor occurs once.

The remaining critic suggestions are broad existing HUD redesign (HP bar, hotbar, panel margins, labels and ammo hints) or adding a new scope overlay/reticle readout. These have already been handed to the coordinator; no camera feel numbers were changed in response. The minimap remains at its existing default OFF, despite the critic calling its absence a defect. The exact scope rating remains on the existing weapon card. Neither new HUD features nor unrelated raid restyling were added.

Next lane work: apply the compatible 36.13 retarget under the lock, preflight/ship cw-cx-adsstationtags, confirm ON HIS PC, and capture camera round 3. Compare the unscoped/right-edge forge name and player-2/right-edge seal name with round 2. Existing best camera pictures so far: tools/handoff/console/notes/shots/o-00h-225-ads-zoom-toward-the-aim-recipes-2/03-ads-4x-player1-1080.jpg and 04-ads-pad-player1-1080.jpg, both critic 3. Round-1 versions remain in the parallel recipes-1 folder.

--- codex run 2026-10-29 00:43 ---
2026-10-29, final review, v36.30.

BOTH KEYS SHIPPED. cw-cx-aimfocus shipped v36.29 and was ON HIS PC after 50s. cw-cx-adsstationtags shipped v36.30 (66025f772), ON HIS PC v36.30 after 33s. The compatible cache check retarget is committed as 500a3d29c; the lane first ran 36.13 successfully on a trial v36.29 build. All requested code is in keys.txt and shipped. No game file was edited directly.

Opened the round-3 unscoped, mouse-4x, pad-4x and player-2 pictures in the image viewer and reviewed all six attachments. Forge and seal names now stay whole with their backing. The pillager remains visible in each view, including the left side of the 4x mouse/pad views. All six camera stages passed at 1080p and 4K. Mouse target drift remains below 0.001px; pad target drift is zero. Hip framing is retained. The real browser checks and ship gates passed; the camera code does not touch AI, LOS, streams, networking or loot. Separate fixture pages exercise the local host and join window roles; this was not a live linked network session.

Critic scores, pictures 01-06:
- Round 1, v36.29: 3,2,2,2,2,2.
- Follow-up 1, round 2, v36.29: 3,2,3,3,2,3 (corrected camera staging).
- Follow-up 2, round 3, v36.30: 3,2,3,3,2,3 (station label fix).
The overall best score remains 3 after two follow-ups; the latest verdicts all say same. The raid score-4 finish line was NOT reached. Stop further camera-job polish under the two-follow-up stalled-review rule. The remaining findings are existing HUD design and have an explicit owner in open task 186f-hud-panel-consistency, including the CEO handoff commit 6b8d279e3. That task covers health label size, hotbar, panel insets, timer hierarchy and ammo padding. This task is complete as a shipped camera improvement, not a claim that the whole raid HUD passed visual review.

The critic P0 for capital I in run info is unsupported: NCLOWER=1 at dark_raiders.html:5309 and ncFix lowers all player words; the actual chip reads run info. The requested 48px edge margin differs from the established 24px world-label margin, which the station-label fix now uses. The seal label is whole and backed in the new image. The critic also requests new scope framing/readout and changes to the sight-light art; these were not added to a camera-motion task. Keep the minimap default OFF and keep the owner-prescribed contract notice wording; 186f explicitly preserves both despite critic requests.

Retained two best reviewed versions, with full six-picture sets and both local window roles:
1. v36.29, round 2, scores 3,2,3,3,2,3. tools/handoff/console/notes/shots/o-00h-225-ads-zoom-toward-the-aim-recipes-2/ . Representative mouse/pad views: 03-ads-4x-player1-1080.jpg and 04-ads-pad-player1-1080.jpg. This has the correct camera and quiet fixture state but still clips station names.
2. v36.30, round 3, scores 3,2,3,3,2,3. tools/handoff/console/notes/shots/o-00h-225-ads-zoom-toward-the-aim-recipes-3/ . Representative fix views: 02-ads-unscoped-player1-1080.jpg and 05-ads-2x-player2-1080.jpg; scoped/pad views are 03-ads-4x-player1-1080.jpg and 04-ads-pad-player1-1080.jpg. This is the shipped choice because the camera remains correct and station names are whole.

DESIGN.md includes the exact watch line: aiming zooms toward the crosshair; watch that it never feels seasick and your pillager never leaves the screen. Main practical limit remains documented: the existing 80-world-unit outside-map camera padding can take priority over the approximate 12 percent player margin at extreme map edges. Camera safety keeps the pillager onscreen.

TASK DONE. No unshipped key and no further camera round requested.
