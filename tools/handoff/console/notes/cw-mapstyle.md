# cw-mapstyle (his Q6, Q7, Q43, Q1; the critic scored the opening map 2 of 5 for its art)

## What the sector map is now (v31.41, v31.48 and v31.55: cw-mapstyle, cw-mapstyle2, cw-mapstyle3)
One screen for both uses: the first screen of every raid (frozen until "click to start") and the map the player opens with M or the pad.
- A charcoal card, 90 percent of the screen (5 percent margin), 1px ui_line_hi border, 4px radius, on a solid ui_void backing (nothing of the HUD shows through, as v21.04 wanted).
- Header row (64 at 1080): the sector name (bold) and the muted words "sector map" on one baseline, the hour and the weather ("dawn . clear", a next weather after an arrow), "elites and keys are live intel" when the intel is on, and the X (48x48 ghost, 1px ui_line_hi). The X closes the map; on the opening map the X (any click) starts the raid, as the start button does.
- Footer row (same height, so the map stays centred up and down as it always was): the key hint (his words, drawn through the old header line, untouched), "surveyed n%", a close hint with its key (m, or b on a pad) at the right; on the opening map the start button (lime, bottom right) replaces the close hint.
- The map in the body with a 1px frame. Walls are a quiet dark neutral. Zone names are at the label size, bone at about 66 percent, over a dark halo. Every marker tag has the same halo. Tags are placed at their own mark (a tag is no longer pushed off by the mark it belongs to), clear of other marks, clear of other tags with a little air, and inside the frame with 10 px air.
- Marks use the style guide colours: extraction teal with the extraction glyph, hot ground danger with the warning glyph (the tag says only "hot ground"), forge/caches/strongbox/waypoint/locked rooms bone, open rooms and survivors ok green, elites r_elite, the seal ring lime progress.
- You are here: a chevron in the seat colour, lime for a solo raid and player 1, the ally blue for player 2, with a number badge (1, 2) in a two player game. The teammate dots use the same colours and badges.
- Contracts column at the right when the profile has contracts (all of them, nearest to done first, finished last): short name ("destroy crawlers", "search crates", "carry out data core", "haul over $1,200", rule contracts "no heals" / "out in 3 min"), reward in $, progress "3/5" with a bar on every row (lime, green when done; a rule contract has an empty bar while it holds, a full green bar when ready, a full red bar when broken, with the word holding / ready / broken). The header says "n of m done". A list that fills the column runs to the bottom of the map frame. The demo has no contracts (as the Run info box hides them there) so its map has no column and the map is centred.
- The corner credits column (cw-trcol) is not drawn over the card (it was drawn over the map as page text was); it comes back when the map shuts.

## Pictures and critic
- before: notes/shots/cw-mapstyle-before/60-mapfirst-1p-1080.jpg and -4k.jpg (the old map first screen).
- after, final (v31.55): notes/shots/cw-mapstyle-after3/ (60 keys, 61 pad, 62 waiting for p2, 63 map opened with M, 64 demo, 65 TV text size, 66 player 2; 1080 and 4k; lint 0 on all). Earlier passes: notes/shots/cw-mapstyle-after (v31.41) and notes/shots/cw-mapstyle-after2 (v31.48).
- recipes: notes/shots/cw-mapstyle-recipes.json (camera port 9382).
- critic: before 2, after v31.41 3, after v31.48 3, after v31.55 4 (the opening map at 1080 and at 4k). Three rounds. What it still wants (P1/P2, not blocking the 4): the crowded right edge of the map (the two caches and the strongbox in the locked rooms stack above their crates, "extract b" and "chill row" crowd each other), a calmer contracts list (fainter dividers, the reward smaller than the name), a thinner map frame (the thick grey frame is the outer wall of the map), bigger pickup and extraction rings, a pad focus ring on the X.

## Checks
- 31.41: the card (90 percent, 5 percent margin), the contracts column and its rows, the header and the X (click closes; on the opening map starts the raid), the opening start button bottom right in the footer, the demo has no contracts and a centred map, the TV text size keeps the rows apart, the seat colours and numbers.
- 31.48: one separator in the weather line, zone names a size under the extraction names, contract names in the main text colour with a smaller reward, the close hint (not on the opening map), no label within 8 px of the map frame.
- 31.55: the hot ground tag has no second line, marker tags sit within 12 px of a mark (at most three displaced in the packed locked-room corner), a bar on every contract row, a full list runs to the bottom of the map frame, zone names at the label size, the sector name and "sector map" on one baseline.
- 31.32 (cw-trcol, another lane) retargeted by fixture commit efdb1acc: the map header weather line keeps clear of the column on the old build and of the close button of the map card on the new build.

## Left
- The demo map shows no run goals either (his Q56 keeps the run goals in the demo HUD). If you want them on the demo map, say so; I did not invent a panel (open question in questions.md).
- Game toasts (a codex entry, "contract item nearby", the weather turn line) are still drawn on top of the map card, in the map or over its edge. They belong to the toast system, not the map; I did not touch them. Hiding them while the map is open is a small job for whoever owns the toasts.
- The packed corner of the locked rooms (two caches and a strongbox in one room) still stacks its tags above the room.
