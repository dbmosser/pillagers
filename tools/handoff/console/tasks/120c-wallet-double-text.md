# 120c-wallet-double-text : the top right money box prints two layouts on top of each other
Queue (coordinator 10-25 11:50): HIS NOTE on the photo of v34.78, Sun 10-25 about 11:47: "Text collisions on the menu thing". Party fix.
effort: medium

The picture: notes/his-photo-notes-1025/wallet-double-text-zoom.png (and the full frame bulwark-and-wallet-v3478-1080.jpg, top right).
The canvas rows (trColDraw and trRow, about line 5770 to 5795: cash, xp, stash, backpack in two columns) draw correctly, but a second
copy sits on top: a one line "cash $900 xp 0 stash $0 bag $1,220" and a larger "$900" and "0". Something else (an older page element,
the demo or arcade wallet, or a second call) draws the same figures in the same box.
It shows on v34.71 and v34.78 in the camera recipe notes/his-photo-notes-1025/recipes-bc.json, screen gfx-b-machine-damage (backpack
worth $1,220), and did NOT show in the reload staging (empty backpack). Find which state turns the second copy on.
Do: one layout only. Keep the canvas rows (his corner design); remove or hide the other drawer for good. Then check it in real play, not
only the camera: a career raid and the demo, with an empty and a full backpack, both windows, 1080p and 4K. If the second copy turns out
to come only from the camera staging, fix the staging AND say so plainly in the ship notes.
Check (must FAIL on v34.78): with that recipe staged, only one text element or draw names the cash figure in the top right box.
Player text rules hold (all lower case, $ for money).
TASK DONE when it shipped with pictures; TASK PARTIAL with what is left.
