# o-225 ads-zoom-toward-the-aim : aiming zooms toward where you aim, not onto your pillager
HIS WORDS 10-29 about 02:20 (in the Gameplay Edit Intaker chat), verbatim: "when player ADS, the zoom should happen 'towards' their scope, not zoom in on the player avatar -- maybe it needs to hit half way between the cursor and the character as like the focal point for the zoom? I don't know, research best zoom practices in 2.5d shooters and improve ADS"

WHAT IS ON HEAD (v36.23), dark_raiders.html:
- ~36576 ADS_ZMIN 1.25; zoom target ADS_ZMIN+(optic-1)*CFG.adsZoom eased in render2D (~40923, G.adsZ, rate 11), read by ZOOM() for w2s, mouseWorld, pad aim and the camera.
- ~40941-40948 the camera: anchor eases to the player, lean = 0.30 (0.46 scoped) of the cursor's offset from screen centre in SCREEN pixels, camX=anchX-(W/2-leanSX)/Z. So the player is pinned to a screen spot and the zoom magnifies around the PLAYER: when ADS starts, everything near the crosshair slides outward away from the cursor while it zooms. That is his complaint.

WHAT GOOD TOP-DOWN SHOOTERS DO (short research, 10-29):
- Aiming in top-down games is mostly a camera SHIFT toward the aim (look-ahead toward the cursor, capped as a share of the screen, eased), with zoom a smaller part. Centering fully on the cursor makes people sick and a heavy lerp feels sluggish, so a partial offset (about a third to a half of the way) is the norm; long guns get more.
- Zoom must pivot on the point you care about (zoom-to-cursor): with screen centre c, zoom z and cursor offset m, the world point under the cursor is w=c+m/z; at the new zoom z' put c'=w-m/z' so that point stays under the cursor. Do the offset in WORLD units, not screen pixels (the usual bug).
Sources: opengameart ranged-camera thread (lpc.opengameart.org/node/134166), Godot "favor mouse direction" (ask.godotengine.org/87044), Godot lookahead camera (gemforgegames.itch.io/godot-3d-action-camera), webgl2fundamentals zoom-from-mouse.

BUILD (render layer only; the sim, AI, LOS and seeded streams are untouched):
1. FOCAL POINT: while ADS the camera's pivot is the AIM POINT F = player + share x (cursor world point - player), share 0.5 for unscoped guns and 0.6 for scope 2.5+ (his "half way" idea, longer for long guns). Pad: F follows the aim stick direction at the gun's reach the same way.
2. ZOOM ABOUT F: as G.adsZ eases in or out, solve the camera each frame so F keeps its screen spot through the zoom (c'=F-mF/z'), then ease F toward screen centre with the existing camera ease, so the picture punches in TOWARD the crosshair and the target under it does not slide away. Letting go reverses it smoothly back to the normal hip look-ahead.
3. KEEP YOUR PILLAGER IN VIEW: clamp so the pillager stays at least about 12% of the screen from any edge at every zoom; the world clamp (camClamp) still holds.
4. NO AIM JUMP: the world point under the mouse must not jump on the frame ADS starts or ends (mouseWorld is derived from the same camera; check it). The crosshair stays where the mouse is.
5. Party: each window frames its own pillager; the split/shared screen rules stay as they are. Reduced effects: same framing, no change.
Check (must FAIL on the current build): cursor 400 px right of the pillager, ADS with a 2x scope: after the ease, the world point that was under the cursor at the start is still within 6 px of the cursor, and the pillager is on screen; at hip fire the framing is unchanged from today.
Rules: seed 4242 fingerprint must hold; both windows; never touch the pickup stack, loot sounds or loot rows. Take pictures (uishots: hip, ADS unscoped, ADS 4x scope, pad ADS) and look at them. DESIGN.md watch line: "aiming zooms toward the crosshair; watch that it never feels seasick and your pillager never leaves the screen". Model: Opus high (camera feel).
TASK DONE when it shipped and is ON HIS PC.
