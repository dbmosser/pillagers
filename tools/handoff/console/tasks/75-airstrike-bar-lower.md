75-airstrike-bar-lower : the air strike bar sits much lower, just over the belt (his order 2026-10-20 evening)
effort: low

Source (his words, 10-20 about 21:50, verbatim): "airstrike bar needs to be much lower"
His pictures: tools/handoff/console/notes/his-shots/2026-10-20-airstrike-bar-too-high.png (close up: the "air strike 35%" plate floats well above
the belt's right end, a gap about as tall as the plate twice over) and 2026-10-20-camera-good-distance.webp (whole screen, same placement).
Where: airPlateAt(bw,bh,z), dark_raiders.html about line 62938: y = top - 64*z - g8 - bh, where top is the belt's top. The 64 px is the clearance
that lifts it; the loop after it moves it clear of the hand panel, the gun panel, the pick and feed boxes (v28.xx cw-cx-airhandclear).

My call: drop the 64 px lift, so the plate stands on the belt with the usual 8 px gap at the same x (right end of the belt). The clearance loop
still moves it up only when the item-in-hand panel or another box is really in the way. Keep the plate's size and look.
Check (new, must fail on the build before): in a career raid with the air strike charging, at 1920x1080 and 3840x2160, the gap between the plate's
bottom and the belt's top is 8 px (times the HUD zoom) when nothing else is in the way, and it never overlaps the belt, the hand panel or the gun
panel (stage an item in hand too). The seed 4242 fingerprint holds.
Pictures: before and after at 1080 and 4K (a raid screen with the air strike showing, demo and career).
Cut-off: FEATURES (a placement fix, low risk). Ship before Mon 10/26.

TASK DONE when shipped with its check and pictures; TASK PARTIAL with what is left.
