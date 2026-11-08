
--- codex run 2026-11-07 17:18 ---
2026-11-07, first run at v37.55.
Prepared cw-cx-eliteelements (14 exact anchors) and keys.txt. No game or fixture file was edited.
Elite selection uses roll/rate under 0.25 and four equal element bands, with forgeApply at fk 2. Damage follows the forged gun. No random draw was added. Enemy rounds keep no element and warning red, already present from cw-redtracers.
The death body records only its held unpaid gun with gk/fk/el. Loot consumes its forge once for the matching exact key. A body gun still consumes the old quality roll, but keeps the model and field baseline that the enemy actually held. Other guns keep their existing rolls.
Party container words validate/carry forge metadata. Loot words carry the current ownership of the one forged copy and reserve it on the host; left words preserve use state for takeover. Held-entity words carry forge tier/element so the remote gun has the same finish.
Local validation: mk prints written; all 14 anchors unique; patched game script and regression check parse. Isolated real blessElite/forgeApply functions with weapon fixtures, seeds 1-200, gave 252 forged / 984 elites (25.6 percent), exactly two draws per blessing. This is a local logic check, not a browser/preflight pass.
Regression check stages a real raid, samples elite blessing across seeds 1-200, checks two draws, damage/tint, plain red enemy rounds, kills a real mkRaider, verifies death-body metadata, round-trips body and entity packets, grants body loot locally and from the remote body copy, and proves one matching forged copy plus host reservation. It fails the old build at the zero-forged share before touching new helpers.
Two custom camera recipes request a naturally blessed elite fighting and the recovered gun comparison in the backpack, smooth look at 1080p. They use actual blessing/death/grant paths; the gun card stays in the backpack and no pickup popup is restored. Pictures and critic result are pending the lane. These recipes are solo staging, not evidence of a real two-window link.
Watch line is in draft why for DESIGN.md: element finds may make forge MK III feel less special; forged elites hit harder; watch find frequency.
LINKED REVIEW NEEDED: synced. Fields: cont.fw, loot.fw, ent.fk/fe. Need a real host/peer fight and body search in both windows, including partial body search/takeover and confirming the forged copy cannot go to both seats. Ship, ON HIS PC, camera critic and linked review remain with the lane/coordinator.
No known older check requires retargeting. tools/mkfixture.ps1 untouched.

--- codex run 2026-11-07 17:37 ---
2026-11-07, run 2 on v37.56. cw-cx-eliteelements shipped and ON HIS PC v37.56 confirmed (51 seconds after ship).
Both round-1 images show the title, not the requested scenes; they cannot count as visual evidence and the critic correctly refused them. Cause: custom recipe prelude omitted window.__uis, which tools/uishots.ps1 requires before it calls U.prep().
Updated camera-recipes.json to include the standard __uis helper prelude and use U.dep, which clears the title and modals before deploying. No game changes or additional ship key. Request another camera round for the elite fight and recovered body gun card. Existing linked review request remains pending.

--- codex run 2026-11-07 17:46 ---
2026-11-07, run 3, v37.56 already shipped and ON HIS PC.
Round-2 body picture successfully shows magnum mk iii, shock, and the backpack element details after the actual death/body grant. Both recipes staged, but each critic score was 2. Best current body picture: tools/handoff/console/notes/shots/o-h11-174-elite-element-guns-recipes-2/174-body-gun-card-1080.jpg.
The round-2 fight picture does not visibly show the elite: the staging chose a location to the left, behind the controls, while live mouse aiming turned away. Its old expectation proved a forged entity existed but did not prove it was visible. Fixed the camera only: prefer a clear position to the right, maintain aim at the elite, fire its real gun periodically, and require a living, seen elite inside the gameplay area for staging to pass.
Both recipes now fold the existing controls, pillager board and run info through their existing state, and clear transient feed/labels and kill streaks. This avoids staging unrelated HUD clutter when reviewing the feature. No game settings default or game code changed.
Critic review notes: extract 152m is a distance, not a countdown. Its extra waypoint and the general controls/contract/roster presentation predate this job. The body screenshot has both panels at the same top y=360, and the elite text is neutral grey rather than danger red; those quoted findings do not match the image. The new recipes clear the transient kill text/buffs for a cleaner feature review. No broad HUD redesign was added to this gun feature.
Updated camera-recipes.json plus camera-stage.js/update-camera.cjs are ready for round 3; both parse locally. No new key to ship. Critic finish line and the previously requested real linked-window review remain pending.

--- codex run 2026-11-07 17:53 ---
2026-11-07, run 4 on v37.56. Feature remains shipped and ON HIS PC (confirmed in run 2).
Round 3 successfully stages both scenes at 1080p and 4k. The fight image now visibly shows the living shock elite holding the forged gun, with warning-red enemy rounds. The body image visibly shows magnum mk iii, shock, and the recovered gun in the backpack. Camera lint reports zero issues. Critic scored both 2 again; this is the first scored follow-up, not the six-try stop rule.
Best evidence so far:
- Fight: tools/handoff/console/notes/shots/o-h11-174-elite-element-guns-recipes-3/174-element-elite-fight-1080.jpg (score 2; visible elite and red shot).
- Body: tools/handoff/console/notes/shots/o-h11-174-elite-element-guns-recipes-3/174-body-gun-card-1080.jpg (score 2; clean recovered shock MK III card).
Earlier comparison version: the corresponding recipes-2 images (body score 2, fight score 2 but elite not visibly established). Round 1 is invalid title-screen staging and is not evidence.
STOP on the requested shared-HUD removal: the critic P0 says delete the c 152m exit arrow. The current code at extEdgeArrow and the cw-extpill comment explicitly implements a separate directional arrow, and fixture check 35.50 requires it. This task says do not alter tools/mkfixture.ps1 and stop if a check must change. No fixture edits or game changes were made in this run.
Exact conflicting old check (35.50, TWO) begins:
  if(!EXTARROW.on||!o.length) bad.push('no edge arrow "'+lab+'" for an exit just off the right edge');
Its following else block requires the edge position and no collisions. If the coordinator authorizes the critic request to remove that arrow, the whole if/else assertion block must be replaced with:
  if(EXTARROW.on||o.length) bad.push('secondary exit edge arrow still draws');
Keep the later closed-exit assertion and the separate top-pill state assertions. This is conditional retarget guidance only, not a request to reverse the existing design without owner direction.
The style guide section 0 specifically says screen tasks leave the top-right HUD alone. Section 2 says rarity is a 3px tile bar rather than a name color; the existing neutral tag plus rarity bar should be reviewed in that context. The critic also alternated between asking to remove empty slot boxes and asking to add equal boxes, so no unrelated quickslot redesign was made here.
No new key or camera round submitted: another identical HUD review would repeat the same conflict. Remaining work is with the coordinator: settle the shared HUD/critic conflict, any approved fixture retarget, and the previously requested real two-window review with one picture from each window. The supplied pictures and packet regression do not prove a real linked session. Keep this job partial until those requirements are resolved.
