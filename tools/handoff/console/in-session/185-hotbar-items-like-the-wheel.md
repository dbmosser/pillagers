# 185-hotbar-items-like-the-wheel : drag items from the wheel onto the hotbar, and a belt item works like a wheel pick
Queue: two orders of his, 10-27 evening in chat (verbatim):
1. "i should be able to drag items from the wheel to the hotbar"
2. "if its on the hotbar, then it should work like the wheel... e.g you click the number to equip, then you still gotta click the mouse to use it"
His own orders, so an exception to the no-features-until-11/1 rule, and part of his items-on-hotbar order of 10-27 (memory pillagers-items-on-hotbar-2026-10-27; that build made a number key use the item at once, which order 2 reverses).
effort: high
Worked in: his orders thread (Claude session), not a lane. Lanes skip in-session/.

Where: the raid item wheel (hold Q): wheelOpen, wheelTick, wheelRelease, wheelPick, drawWheel near dark_raiders.html line 24113; the hub wheel near line 48010. Belt item use: beltInstant, beltPickCell, useBeltHeal, quickPlate.
Order 1: with the wheel open, press on an item and drag it onto a hotbar slot; dropping assigns it there exactly as a backpack drag does (the gun on that slot goes to the backpack, refused with a callout if the backpack is full). Releasing off the hotbar does nothing. Releasing Q or a plain click keeps today's wheel behaviour.
Order 2: a number key (or pad pick) on a belt item puts it in hand the way a wheel pick does; the left mouse button (pad trigger) then uses it: a heal starts, a grenade throws. The key never uses it at once.
Checks: drag from the wheel onto slot 3 binds the item to slot 3; pressing 3 then holds the item and nothing is spent until a click; both must FAIL on v35.20. Control: a plain wheel pick still works as before.
Rules: player text lower case; both players; no storage key change; take pictures.
TASK DONE when shipped and his main PC reports the build (spare/JUL26/status.txt party=VER).
