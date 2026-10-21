# 86e-pix-props (lane a, 10-21)

Design (pixWrap, in the pixel kit region of dark_raiders.html, search "THE PIXEL ADAPTER"):
- pixWrap(key,w,h,d,paint,x,y,{up,kind}) returns the cached sprite (already blitted) or null. The caller keeps its vector painter as a closure and runs it when null.
- pixWrapBake: wc and shadowE are pointed at an art scratch (scale 1/d), painter runs, finally restores both. Bake then: alpha to 0/255 (a dark half see-through pixel = the painter's ground shadow, becomes one flat shadow tone PIXW_SHAD day/night), every colour snapped to the (at most 12) colours the painter used most, a darker bottom/right edge, cropped to the shape. Clip counter PIXW.clip if the shape touches the scratch edge.
- Live parts stay outside the closure: ground shadow, dim of an opened box, search bar, amber ammo tell, wreck smoke (wreckSmoke records its height while PIXW.on, drawContS draws it after the blit), barrel floor pulse / lid glow / idle sparks / pools.

Shipped
- v33.68 cw-pixprops: pixWrap + drawContS body (crate, locker, safe, camp safe, cache, jackpot, generic, body, carcass, botwreck, 9 wrecks, opened and closed). Check: 1 cached drawImage each, alpha 0/255, footprint, throw leaves wc, 0 readbacks in 60 frames, smoke moves, no fillText.
- v33.71 cw-pixbarrels: 4 barrel bodies per blink state; ?pixbench "props: loot, bodies, wrecks, barrels" sheet (stub raid inside the sheet function).

Not done yet (next runs): cover wrecks (cw-pixcover draft in progress), lamps, forge / seal slab / story desk, extraction ring, Undercroft posts and racks and the drop crate, live deer and birds. The strongbox label (drawContS fillText) and seal % / forge name move to the GFXWT hand-off with those.

cw-pixcover (cover wrecks, PIX_ENV, scene cache): draft written (scratchpad mk-cw-pixcover.ps1, draft-cw-pixcover.json). Preflight 1 failed: pipes fell back to vector because every piece had its own rust in the key (fixed: rust rounded to 4 buckets, warm-up 14 frames). Preflight 2 hit the dry-run TIMEOUT (check runs ~17 full frames per cover kind; if it times out again cut the warm-up to 8 frames and the kinds to 3). Preflight 3 was still running when this run ended. Not shipped.

Gaps said plainly
- No pictures: the camera (uishots) has no xfPix 1 stage; asked in questions.md by 86a / 86c. The bench sheet exists for when it does.
- Watch (his next play): opened and closed crates still read at a glance (opened is the same body dimmed to 62 percent, lid back). Wreck ground shadow is now one flat tone under the wreck instead of a soft 50 percent oval.
