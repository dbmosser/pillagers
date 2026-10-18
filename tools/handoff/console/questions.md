# Questions for him

## Cleared (coordinator, 10-18 evening)
- The two URGENT ship-queue notes (gen-draft failed since v30.69, and .git/index.lock left by v30.64) are stale: ships have run cleanly through v31.16, and there is no index.lock.

## Open (asked in chat 10-18)
- The title's mode list has two "coming later" online rows in the middle of the rows that work. Move them to the bottom, or hide them? (c-30-ui-menu-map)
- The empty scoreboard (before anyone has played) shows five faint placeholder rows. Keep them, or show one line such as "No scores yet"? (12-ui-party-screens)
- In the 2 player arcade demo the Undercroft is only a blurred picture behind the party screen (nobody walks there; a press drops straight into a raid), so the two players cannot see each other in it. In the 2 player co-op (same machine) mode they walk the Undercroft and now see each other (v30.84). Should the arcade demo also let the two walk the Undercroft before the drop, or keep the straight drop? I changed nothing there. (cw-p1p2)
- In the 2 player arcade demo each window plays on a copy of its OWN save, and the sandbox keeps the HUD layout and the kid damage setting of that save (your 10-11 order). If your save has a custom HUD layout or kid mode on, the two TVs differ from each other (player 2 is a fresh save). Should the demo put BOTH windows on the default HUD layout and normal damage, so the two TVs always match? I changed nothing. (cw-p1p2)
- The player 2 attract and run over card say "Player 2: press A" while player 1 says "Press any key" (or button). Lane g set that on purpose (player 2 is the pad window), but player 2 now has its own keys since v30.68. Should player 2 read the device it last used like player 1 does? I changed nothing. (cw-p1p2, for the glyphs lane)
- The shop shows a rotating trader line in a pill ("Everything here works. Cannot say the same for you.", from VENDOR_LINES, SPEC 3.1). Q45 wants straight copy, no jokes. Keep the vendor voice lines, or drop them from the shop card? I changed nothing. (04-style-guide-update)

## Resolved by his answers of 10-18 (memory pillagers-answers-1-78-2026-10-18.md); helpers act on these
- HUD (b-30): ammo becomes prominent and the whole raid HUD is redesigned (Q57); the career top-right becomes ONE row with nothing removed (Q58 a); $ for money, including the bag line, haul values, prices and the pillagers board; SP only for score (Q59 a); Run info shows the 3 closest contracts, and ALL contracts go on the map screen (Q1). The work is now task 02-raid-hud-redesign.
- Pause box line "Please provide feedback anything that went or felt wrong.": KEEP it, along with the button and Send play data (Q61 b).
- Undercroft (b-31): windows become a centred card with an X that takes up NEARLY THE WHOLE screen (Q43 a; not a 960x680 cap). The style guide overrules his older layout orders (Q7). Helpers may shorten or delete his explaining lines, but only with a good reason logged in notes/ui/changes.md (Q8 a).
- Title on screen 58 and the rest: the title redesign is task 03 (Q50-Q54).
- The 10-17 note about a dirty game file is stale; ships have run cleanly since.
- The sector map (the raid screen under M) is now the first screen of every raid (cw-mapfirst, v31.09, v31.23), and the critic scores it 2 because of the map art itself, not the new start button: navy void with a thick periwinkle frame and walls, no card, header row or X, labels over their own icons, zone names (the long dock, packing floor, chill row, the sump, scrap line) dark grey on dark grey, two small grey lines at the bottom left ("what you walk stays on the map" is an explaining sentence). Restyle the whole map to the style guide (charcoal card, 1px border, header with an X, label halos, readable zone names) as its own UI job? It is a big change to a screen you did not ask me to touch, so I changed only the start button. (cw-mapfirst)

## Open (cw-trcol, 10-18 evening)
- The upper right column (v31.32) is done as you ordered: one item per row, one width, one height, all lower case. The picture critic scored the corner 3 of 5 (career) and 2 of 5 (demo) and keeps asking for things that would undo the order: fewer or shorter rows, dropping "notes logged", a smaller minimap (it wants 240, the column makes it 321 at 1080p; your survey picture had 300), and a 5 percent screen margin (the whole HUD sits 16 px from the edge today). Keep the column as it is, or do you want the minimap narrower (the whole column would shrink with it)? I changed nothing more. (cw-trcol)
