# b-31-ui-undercroft run 14 (lane b)

Shipped this run: v31.62 cw-cardbox (terms, party, gamble, bar frames = the 90 percent card), v31.66 cw-uc-stash ($ going up, 16px floor), v31.69 cw-uc-stash2 (stash explaining sentences gone, Q8 reasons in notes/ui/changes.md), v31.70 cw-uc-stash3 (gun keys 16px, no build stamp), v31.72 cw-cardP30 (card stamp), v31.74 cw-uc-tr (corner readout one quiet label style).

Critic scores this run (before follow-ups): 04 stash, 14 racks, 65 codex, 08 shop all still under 4. Open findings I did not get to:
- 14 racks: buttons 1316px wide, cap near 640.
- 65 codex: centred 4-column grid.
- 08 shop: stat rows, tile grid fill, price colours.
- amber filler lines.
- Not yet shot or judged after the card: 13, 15, 39, 41, 43, 67.

Next run: reshoot 04,08,14,65 (shots dir b-31-f7), read the critic, ship racks (14) and codex (65) first.
Preflight tip: if it fails on the What's New stamp, copy mk-card-autoPN.ps1 (genP.sh N) into mk-cw-cardPN.ps1 with the draft name draft-cw-cardPN.json; shipq.sh refuses the card-auto name. Next unused is P31.
