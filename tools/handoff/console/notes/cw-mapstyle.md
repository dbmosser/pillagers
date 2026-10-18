# cw-mapstyle (his Q6, Q7, Q43, Q1; the critic scored the opening map 2 of 5 for its art)

## What the sector map is now (v31.41 and v31.48, cw-mapstyle and cw-mapstyle2)
One screen for both uses: the first screen of every raid (frozen until "click to start") and the map the player opens with M or the pad.
- A charcoal card, 90 percent of the screen (5 percent margin), 1px ui_line_hi border, 4px radius, on a solid ui_void backing (nothing of the HUD shows through, as v21.04 wanted).
- Header row (64 at 1080): the sector name (32px bold), the muted words "sector map", the hour and the weather ("dawn . clear", a next weather after an arrow), "elites and keys are live intel" when the intel is on, and the X (48x48 ghost, 1px ui_line_hi). The X closes the map; on the opening map the X (any click) starts the raid, as the start button does.
- Footer row (same height, so the map stays centred up and down as it always was): the key hint (his words, drawn through the old header line, untouched), "surveyed n%", a close hint with its key (m, or b on a pad) at the right; on the opening map the start button (lime, bottom right) replaces the close hint.
- The map in the body with a 1px frame. Walls are a quiet neutral, zone names are tx-1 at about 66 percent over a dark halo (5 px at 1080, grows with the screen), every marker label has the same halo. Labels are placed clear of the marks first (icon boxes with 5 px air), then clear of other labels, and inside the frame with 10 px air.
- Marks use the style guide colours: extraction teal with the extraction glyph, hot ground danger with the warning glyph, forge/caches/strongbox/waypoint/locked rooms bone, open rooms and survivors ok green, elites r_elite, the seal ring lime progress.
- You are here: a chevron in the seat colour, lime for a solo raid and player 1, the ally blue for player 2, with a number badge (1, 2) in a two player game. The teammate dots use the same colours and badges.
- Contracts column at the right when the profile has contracts (all of them, nearest to done first, finished last): short name ("destroy crawlers", "search crates", "carry out data core", "haul over $1,200", rule contracts "no heals" / "out in 3 min"), reward in $, progress "3/5" with a bar (lime, green when done), a rule contract says holding / broken / ready. The header says "n of m done". The demo has no contracts (as the Run info box hides them there) so its map has no column and the map is centred.
- The corner credits column (cw-trcol) is not drawn over the card (it was drawn over the map as page text was); it comes back when the map shuts.

## Pictures and critic
- before: notes/shots/cw-mapstyle-before/60-mapfirst-1p-1080.jpg and -4k.jpg (the old map first screen).
- after, v31.41: notes/shots/cw-mapstyle-after/ (60 keys, 61 pad, 62 waiting for p2, 63 map opened with M, 64 demo, 65 TV text size, 66 player 2; 1080 and 4k; lint 0 on all). After, v31.48: notes/shots/cw-mapstyle-after2/ and the final set listed in the report below.
- recipes: notes/shots/cw-mapstyle-recipes.json (camera port 9382).
- critic: before 2, after v31.41 3 (labels crowding, zone names as loud as the extraction names, uneven contracts list). See the end of this file for the later rounds.

## Checks
- 31.41: the card (90 percent, 5 percent margin), the contracts column and its rows, the header and the X (click closes; on the opening map starts the raid), the opening start button bottom right in the footer, the demo has no contracts and a centred map, the TV text size keeps the rows apart, the seat colours and numbers.
- 31.32 (cw-trcol, another lane) retargeted by fixture commit efdb1acc: the map header weather line keeps clear of the column on the old build and of the close button of the map card on the new build.

## Left
- The demo map shows no run goals either (his Q56 keeps the run goals in the demo HUD). If you want them on the demo map, say so; I did not invent a panel.
