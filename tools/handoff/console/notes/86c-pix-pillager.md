# 86c-pix-pillager (lane b, 10-21)

## Plan (ships, each easy to undo)
1. cw-pixbody: the pixel body for every plain pillager, in layers (legs per walk frame, upper body with pack and chibi head, gun and arms in 32 steps), front view plus baked mirror, bot variant in the red ramp, hook in drawOp, check. Payload source: notes/86c/body.js, mk script S/mk-cw-pixbody.ps1.
2. Later ships: the Undercroft crowd, hub and FASHION previews (they draw on other canvases, figOn() false today), polish from the pictures, anything the critic names.

## Design numbers
- Grid 36 x 50 art px, ink ring +1 each side (38 x 52), anchor (19,51): the soles' bottom edge sits on the entity point, the ink row hangs 1 px below. Drawn height about 50 (45..52 by head). Vector figure was about 42 plus hat; the task asked for 45 to 57.
- Gun pivot 22 px above the feet (vector 20): the shoulder of the taller figure. The aim dots (drawAimMark) still start at the vector muzzle, so the first dot sits about 2 px off the pixel muzzle. Tracers come from the sim, untouched.
- Layers: legs (s, w 6 frames, r 6 frames, c) | upper (pup -1/0/1, arms, lamp, band) | gun (id, fk, el, rc, step, flip, sleeve, hand, ext, low). Bob is a whole pixel shift of the upper layer, lean 1 px walking and 3 px sprinting.
- Stays vector for now: armour tiers (bulk), hurt (0.3 s), low health, fists, downed, death, invulnerable, sets, peddler, survivor, other outfits, roll is pixel. A forged gun (fk) and a reload keep the vector gun on the pixel body (shine, arm to the magazine).
- Cost: getTransform + 2 shadows (2 calls each) + legs + upper + gun = 8 canvas calls for a standing pillager with a gun.

## Dev loop (no camera for xfPix on)
The camera cannot set xfPix (the fixture pins it 0). Dev check cw-pixdev (never shipped) writes a sheet PNG to the test Chrome local storage; S/mk-cw-view.ps1 decodes it from the leveldb log into notes/86c/sheet.png and crops v-looks, v-bots, v-poses, v-guns, v-strip.
Ask in questions.md: a uishots screen that sets xfPix 1 (done below).

## Status
- 02:30 written: body.js, mk-cw-pixbody.ps1, mk-cw-pixdev.ps1, mk-cw-view.ps1. Blocked: the ship queue has v33.57 applied and uncommitted from lane a (86b), so preflight cannot run (no p3357.ps1). Alarm logged by lane a.
- 10-21 SHIPPED v33.58 cw-pixbody (d1a3a0c0). Fixes found in preflight: pixRing returns a wrapper (use .c); the check overrides pixDrawOp by its binding, not window; the 8-call limit counts draw calls only (getTransform reads from the rim and ground helpers, 8 of them, are not counted; the draw calls were 5).
- Left: Undercroft crowd, hub and FASHION previews (other canvases, figOn false); pictures (?pixbench, raid 1080 and 4K, 2-window) need a camera stage with xfPix 1 (asked in questions.md); critic against style-test-play.png; armour, hurt, downed, sets still vector.
- (older) tree still dirty (dark_raiders.html modified, HEAD 9bb8fa57). Still blocked; resume from the dev loop above.
