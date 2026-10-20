# 20-party-rig-perf notes (lane a, 2026-10-20)

Shipped
- v32.44 (cw-drsfloor): auto resolution floor 0.5 to 0.75, step 0.1 to 0.05 (his 2.44 b: never under 75 percent). Check drives drsTick with slow frames and reads the lowest scale. Fingerprint held.

Confirmed already so (no rebuild)
- 2.11 a / 2.57: the world canvas draws at the screen pixel ratio (DPRH, capped 2) times the render scale; the HUD canvas always at DPRH. Frame cap default is Off, so the loop runs at the display refresh rate; cap rows go up to 240. Each window sizes to its own getBoundingClientRect.
- 2.44 b ladder order: post fx off, then soft sheets at two thirds, then lamp shadows off, then scale. Effects go first. The settings preset "Low" (gfxScale 0.5) is his own choice in Settings, left as is.

Not done
- 2.43 a (measure 2 windows at 4K) and 2.27 b (player 2 extra delay over player 1): need two real windows on the TV with a display; the headless gate has no 4K display or refresh rate. Nothing in the code gives player 2 a different path (cw-p1p2 made the windows identical). Left for his next play on the TV; watch for stutter in the second window.
