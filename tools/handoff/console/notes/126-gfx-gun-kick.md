# 126 gun kick
- Shipped v34.73 (cw-gunkick): pxKick(muzzle, gun id) gives the pixel body 1 art px of kick back on a shot, 2 for shotgun, magnum, sniper, dmr, lance. EFFECT INTENSITY: HALF keeps 1, OFF none. Offset only (no new draw, so no frame cost and no quality-ladder step needed). Reads the muzzle value, so the linked window shows it. Check covers rest, rifle, shotgun, sniper, half, off.
- Not done: before/after pictures and 4K frame numbers (muzzle lasts 0.06 s; the camera has no mid-shot stage). Cost is one subtraction per body.
- Watch on next play: automatic fire (smg) should read as a steady 1 px lean, not jitter; shotgun should step back 2 px.
