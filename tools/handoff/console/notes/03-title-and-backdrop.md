# 03-title-and-backdrop notes
- before shots: notes/shots/03-before (01,44,45,46,56,57 at 1080) taken.
- Code map (dark_raiders.html line numbers, v28 build): title DOM `#title` (starts ~2290, `#titlestart` 2362), titleOn() 46303, titleSceneReady() 46304 builds HB=buildHub() under title (hub world drawn by drawHubWorld 45758 from main loop ~47435).
- Attract mode (v21.17 recorded clip) ~46309+; arcade attract board DOM id 'attract' created ~46275+ (before shift: grep `d.id='attract'`).
- Raid pieces: buildRaid(sim) 14410, simStep(dt) 32137 (headless: updateBot, updateEnts, updateBullets), render2D(dt) 36080, main loop ends 47757 `render2D(dt)`; main loop `if(state!=='raid'||!G||G.sim) return;` at 47509. var G at 8901, state var 46298.
- AVOID reading main loop 47500-47760 again (huge, costs a lot).
