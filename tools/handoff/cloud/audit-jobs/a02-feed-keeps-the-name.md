# a02-feed-keeps-the-name : a feed row that is too long cuts the name and keeps the detail
From the cloud audit of 2026-10-28 (tools/handoff/cloud/audit-2026-10-28.md, item 7). Polish of what the game already has.

What: feedParts (dark_raiders.html, "too long for the zone: the first piece gives way") shortens the FIRST piece of a feed row, which
is the name. In the player 2 window of the 2-player demo the row "select a heal / bandage, medkit or armour plate." came out as
"select a ... / bandage, medkit or armour plate." (picture: tools/handoff/cloud/audit-2026-10-28-shots/2p-player2-select-a-cut.jpg).
The same row fits in player 1's window at 1080p, so the player 2 feed zone or font differs; find out why while you are there.

Do: when a row is too long, cut the detail (the sub or tag) and keep the name whole; cut the name only when the name alone does not
fit. Check: a row whose name plus detail overflow the zone keeps its name whole and ends its detail with the mark. Both windows.
Player text stays lower case. Pictures before and after from the player 2 window.
TASK DONE when shipped and ON HIS PC.
