
--- codex run 2026-10-20 16:56 ---
2026-10-20: Prepared cw-cx-alerttop. The HUD already moves its mark baseline down at the top edge; the world nameplate now uses the same screen-distance correction, divided by world zoom. The plate, crew block and health pip stay together. The mark draw is untouched. Idle bots and marks away from the edge retain their positions; winding Criers still get no mark correction.

Sandbox validation: both source anchors matched once; the mk script printed written and generated a two-edit draft. Applied both edits to an untracked copy for JavaScript syntax checking; node --check passed for the complete game script, regression check and all three camera stages. The mk script is ASCII. A local geometry probe confirms that the old top-edge boxes overlap, the new boxes clear, and middle/idle positions stay unchanged at zoom 1, 1.5, 2 and 3. No tracked game or fixture file was edited.

The browser regression stages a real pillager bot named afk_in_the_bushes at 1080p, tests investigate/chase/alarm at the edge and in the middle, compares mark ink including outline to the entire name backplate, and checks unchanged middle and idle positions. It uses the existing fixture preparation and restores its visibility stub in finally. No old fixture check needs retargeting.

Handed the lane one key and a camera recipe with three p1 pictures: alert-top-question, alert-top-bang and alert-middle-control. The recipe uses screen 37 extraction setup and existing fixture hooks, with paused simulation and a clear visibility segment list for deterministic presentation. Remaining: lane preflight/control/ship, camera staging, picture review and critic result. No browser or queue was run in the sandbox.

