# z-163-burn-ash-and-red-glow
v37.11 shipped. burnFx(wc,dt,W,H) is called after drawBolts and before the HUD in render2D. BURN={ash,k,fl}. Ash count scales with GFXQ.detail (70 down to 28). Job 137 (reduce motion) has not shipped: it should switch the ash off and keep the glow. Watch: the red and ash must read as the burn coming without hiding machines in the last minute or costing frames at 4K with two windows. Left: pictures (need camera stage, see alarms.md) and critic score.

11-01 evening re-run (lane a): code and DESIGN.md v37.11 section checked on HEAD, nothing to change. Pictures and critic score still wait on a camera stage (alarms.md line 599). No stage exists in ui-screens-js.json for G.timeLeft=45 or 5. Parked on the coordinator.
