
--- codex run 2026-11-08 17:49 ---
2026-11-08: HEAD v37.65 has permanent blast scar grit (gfxBlastScar, dark_raiders.html:23433; gfx26/v23.xx) but no loose floor litter reacting to movement or shots. Prepared cw-cx-floorbits.

Adds at most 240 papers, small boxes and bolts around existing loot sites. Placement uses a private integer hash, not the gameplay or cosmetic random streams. No entities, containers, collision, sound, noise or storage keys change. Scraps slide outward, tumble, slow smoothly and remain in this raid at rest. A cached 48-frame sprite atlas and viewport clipping keep drawing small. Impulses are capped at 12 per frame. Moving bodies are sampled every 0.08 seconds, including visible teammate snapshots; the existing shot-copy and blast-scar paths react in each window.

LOCAL: no linked review. No new packet or shared gameplay field. Host and join role camera recipes are isolated fixture views with networking disabled, rather than a live linked pair. The fixture check exercises both local and teammate shot effects.

Sandbox verification: mk prints written; all eight exact anchors match once; applying the edits in memory leaves the game script and new fixture check syntactically valid. Mk is ASCII. No tracked game or fixture file edited. The new check fails the old build by missing function and covers debris kinds/cap, outward hit and shot impulses, copied shots, roof exclusion, blast, sprint, settling/persistence, drawing, sim exclusion, workload cap and real 3840x2160 canvas update/draw submission timing below 0.3 ms. Timing includes resetting every scrap to moving each measured frame. GPU completion is not measured by JavaScript submission timing.

Watch text is in draft why for DESIGN.md: sprint past loot, fire beside litter, then blast it; scraps should slide away, remain, and never block movement or make noise. No old fixture retarget expected. Await lane preflight/ship, ON HIS PC confirmation and the two art reviews. Camera scenes use actual placed clutter, showing settled scraps in host and moving scraps in join.


--- codex run 2026-11-08 18:00 ---
2026-11-08 follow-up: preflight reached new check 37.66 and failed twice at impulse workload. Root cause was test staging: __deploy can leave frameN undefined before the first entity update. The check used g.frameN++, producing NaN; floorBitKick then saw a different frame on every call because NaN !== NaN. Changed the check to advance with (g.frameN||0)+1, matching the actual updateEnts counter at dark_raiders.html:33706. Applied the same fix to camera staging. Gameplay edits are unchanged.

Strengthened the cap check: after twelve accepted impulses, another call must return zero and leave velocities unchanged; advancing to the next valid frame must accept one impulse and reset the count to one. Mk again prints written, all eight anchors are unique, and the patched game script and fixture check parse successfully. Regenerated host/join camera recipes. Await lane rerun, ship, ON HIS PC and art review. LOCAL: no linked review.
