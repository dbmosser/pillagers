83-raid-corner-compact : the raid corner money column takes much less of the screen (his order 2026-10-20 evening)
Queue (coordinator 10-20 21:40): renumbered from 74 so the pick order follows the plan (his 10-20 evening play notes go first, camera first, then the sizes, the minimap before the corner block).
effort: medium

Source (his words, 10-20 about 21:45, verbatim): "this takes up way too much of the screen, figure out how to make it much more company" then "compact*"
His picture: tools/handoff/console/notes/his-shots/2026-10-20-raid-corner-too-big.png (the four plates $202,288 / xp 287,505 / stash $163,950 /
backpack $5,835, each a full chamfered plate with a gap between).
Where: dark_raiders.html about lines 5296-5365: trGeo (row height 16+LH(13), gap 8), trPlate, trRow, trColDraw (four rows in career, a fifth
"notes logged" row when notes exist). The column's width (trBW, 300 px at 1080p) also sets the minimap width under it, and trBox / topRightBottom
tell the extraction badge and the map header where the column ends. This newer order replaces the menu-survey look (cw-trcol2) for the rows.

My call (he said "figure out how"; take it, do not wait):
1. One plate instead of four, holding the figures as a 2 x 2 grid on two short lines: "$202,288   xp 287,505" and "stash $163,950   backpack $5,835",
   labels small and dim (UIC.tx_2), figures bright (UIC.tx_1), $ on money (his Q59), all lower case. The "notes logged" figure, when there is one,
   is a third short line in the same plate.
2. The block's height drops to about a third of today's (four plates plus gaps) at 1080p and 4K. The width stays, so the minimap keeps its size.
3. Everything that keeps clear of the corner (trBox, topRightBottom, the extraction badge, the map header, the conditions box) follows the new
   height, so nothing jumps into the freed space on top of something else and nothing is left floating.
4. The demo still hides these figures (his Q55, trDemo).
Check (new, must fail on the build before): in a career raid at 1920x1080 and 3840x2160 the corner block's height is at most 40% of the old four-row
height, all four figures are drawn (the v33.xx cw-raiddollar check's $ rules still hold), and the minimap's top sits under the new block with the
same gap as before; the seed 4242 fingerprint holds.
Pictures: raid corner at 1080 and 4K, before and after (tools/uishots.ps1, a career raid screen such as 21-raid-hud-calm); run the critic on the after picture.
Cut-off: FEATURES. Ship before Mon 10/26.
Party risk: low (corner text only). Tell the coordinator to ask him if the two-line block reads at a glance.

Order (coordinator 10-20): 82-minimap-off-by-default goes first. If 82-minimap-off-by-default is still in tasks/ or a lane holds it when you start,
end at once with TASK WAITING: 82-minimap-off-by-default (that is not a try). Once 82 is in, the minimap is off by default: run the check's minimap
gap part with the minimap turned on in Settings, and with it off check that the run info panel sits under the new block with the usual gap.

TASK DONE when shipped with its check and pictures; TASK PARTIAL with what is left.
