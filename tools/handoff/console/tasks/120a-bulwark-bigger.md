# 120a-bulwark-bigger : the bulwark is drawn too small next to a pillager
Queue (coordinator 10-25 11:50): HIS NOTE on the photo of v34.78, Sun 10-25 about 11:47: "Player too big vs the bulwark which is too
small". Party fix (his notes come first). Sorts ahead of the graphics jobs on purpose.
effort: medium

The picture: notes/his-photo-notes-1025/bulwark-and-wallet-v3478-1080.jpg and bulwark-vs-player-zoom.png (zoom 3, 1080p, pixel look).
The bulwark body is about as tall as the player and only a little wider. A bulwark is the heavy shield machine; it should read as clearly
bigger than a person.

Do: draw the bulwark 1.5 times bigger than now (about 2x its old base size), around its foot point, the same way FIG_MACH does it
(var FIG_MACH, machMul, machScaleBegin near line 37837 of dark_raiders.html; drawBulwarkS about 38575; drawWreckBulwark about 39054,
the wreck must match the new body). Add a per kind extra on top of FIG_MACH (one named number for the bulwark), not a new FIG_MACH.
- The hit radius follows the drawn body, as his 10-20 "33% larger" rule does: rounds hit what you see. Walking radius, doors and the nav
  grid keep the old radius, so it never sticks in a doorway. Write in DESIGN.md that the bulwark is now an easier target (that is the
  balance change; say what he should watch for in a playtest: does it feel too easy to hit or too big for the streets).
- The name plate, alert mark and health pip already ride spriteTop() through machMul; check they still sit just above the bigger body.
- The shield arc (bulwarkArc) and any muzzle or shield fx must line up with the bigger art.
- Do NOT shrink the player. (Logged question for him: does he also want the player smaller.)
- Seed 4242 fingerprint (ents 85/374, containers 165/593) must hold. Both looks (pixel and vector) and both windows.
Pictures: the camera recipe that made his picture is notes/his-photo-notes-1025/recipes-bc.json, screen gfx-b-machine-damage
(tools/uishots.ps1 -Recipes that file). Take before and after at 1080p and 4K and look at them: the bulwark must read as about one and a
half times the player's height. Check (must FAIL on v34.78): the bulwark's drawn height on screen against the player's.
TASK DONE when it shipped with pictures; TASK PARTIAL with what is left.

Coordinator 10-25 12:55: his notes "Pillager still too big. Bulwark still too small" were shipped by the coordinator in cw-smoothlook (v34.81 if the gate passed): BULWARK_BIG=1.5 in machMul (drawn, plated and hit 1.5x the other machines, walking radius unchanged) and FIG_SCALE 0.8 for every human. Do only what is left: the wreck (drawWreckBulwark) and the shield arc must match the bigger body, and pictures at 1080p and 4K in the SMOOTH look (his 10-25 order turned the pixel look off). No second change to BULWARK_BIG or FIG_SCALE unless the pictures show a defect.
