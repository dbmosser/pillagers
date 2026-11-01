# 01-241-redraw-not-steady (lane c, 2026-11-01)

## Finding
- The latest spare full run (spare-results, DESKTOP-82BKOP4 corpus-1030-1445) fails 9.07, 34.90, 33.51 (8.85 and 8.89 passed that run): one per slice.
- v34.90's message says "1 unsteady" in EVERY staging: two direct drawOp calls of the same figure object, no frame loop, no __frame, no clock between them, differ by exactly 1 pixel.
- Ruled out in the game: every real-clock read in the draw path is on the HUD canvas (hcv: status pulses, hp pulse, stamina fade, HUD fade, low-hp ring) or eases to the same value at rest (bodyJiggle, curved build only). The world draw (wc, cv) reads only G.t. The auto resolution (drsTick) was already taken out of dt-0 redraws in v34.98 (cw-steadyframe, notes/119t). Caches (gunBake, SHADSPR, PIX budget) give the same pixels hit or miss; the PIX build budget is pixel look only (off).
- The machine split: the full runs are on PCs with a real graphics card (spare, main PC idle runs). The VM draws canvases on the processor, and there these checks pass every time (119t: 5 of 5). So the frozen redraw is not pixel exact on graphics card raster; the game code is.

## Fix (fixture only, commit a673cf901, cw-steadyraster)
- tools/mkfixture.ps1 inserts at the top of the test copy's script: on a page opened with a query (check pages: ?sliceN=1, ?kzN=1, ?count=1), every 2D getContext gets willReadFrequently:true (processor drawing). Robots (fuzz.ps1, no query) and the camera keep the graphics card.
- No game change, no player-visible change, fingerprint untouched.

## Results on the VM after the change (notes/241-out.txt)
- 8.85, 8.89, 9.07, 33.51 PASS.
- 34.90: "the survivor tracer is drawn 19.1 over the round, his flash 21.6 up": a lineTo capture, not pixels, so a separate real red that the full run's 400 char cut hid. Logged in alarms.md for its own job.

## Left
- Confirm in the next spare full run on a build with a673cf901 (the next ship pushes it).
- Coordinator removes the stable-known-red.txt lines (I may not edit that file); alarm written 11-01.
