REBUILD THE PRE-RAID PAGE AS DESIGN A, "MAP FIRST" (his pick 2026-10-19, verbatim): "por-raid redesing -- i pick A, but give the
map some different color so it breaks up the monotny/overwhelmingness of the screen". The page is #sectormodal (camera screen
05-sector-page). Read first, all in tools\handoff\preraid-design\mockups\:
- mk-a-picked.html: THE PICTURE HE CHOSE, a 1920x1080 mockup (open it in a page at 1920x1080 to look at it). It already has the
  ice-blue map he asked for. design-a.txt: what changes, the pad flow and the trade-offs. pre-raid-redesign.html: all four, side by side.
- inventory.md: everything the page does today, the rulings that bind it, and the game's palette and fonts. Nothing on that MUST
  KEEP list may be lost.
- review.json (key "a"): the checker's notes. Its fixes are already in mk-a-picked.html.
Also read notes\ui\style-guide.md and the "UI work" rules.

What to build (the mockup wins over older layout orders, his Q7 of 10-18):
1. Layout as in mk-a-picked.html. The map panel takes the left two thirds. Beside it is a conditions list: day or night, then
   weather, with the xp bonus as a small +20% or +10% badge, and "host sets" shown read-only for player 2. The right column holds
   the kit as 2x2 tiles, the pack as grouped rows with one stepper each, the going-up chips (the amber "no armour equipped" one only
   when it is true), and the big lime ascend plate pinned at the foot. The x and "close" stay top right.
2. THE MAP IS ICE BLUE (his words above). Draw the REAL cold storage map, from the game's own map data: its real zones, buildings,
   the 3 extraction rings and the 2 keyed rooms, never the mockup's made-up shape. Use the mockup's colours:
   - ground #0c1a28; each zone a slightly different blue (#14304a, #152e3f, #182c47, #172a40, #112538), edges #2f5e86;
   - buildings #0a1622 edged #4a7aa3; zone names #e6f1fb at 20px;
   - exits stay teal (#47d8c6) and keyed rooms stay purple.
   The rest of the card stays the neutral greys. Lime only ever means selected or ascend, and amber only means a warning.
3. Stats shrink to "420 x 340 m · 5 zones · 2 keyed rooms · 3 exits", from the real numbers. The test-robot line and the hectares
   go, and so do the hint sentences that the badges replace.
4. Pad: focus opens on ascend, so a normal ascent is one press. Lb and rb jump between the conditions, the kit tiles and the pack. The
   d-pad moves up and down inside each one. (a) presses, (b) closes, (x) packs all and (y) clears. Keys work too. The hint strip at
   the bottom shows live key and pad prompts.
5. No cash control anywhere. Task o-01 removes taking cash in; do not bring it back here.
6. All text lower case. Seat chips: p1 amber, p2 cyan. A long pack (many item kinds) scrolls inside its own list; never let it
   push the ascend plate off the card.

Checks (the control must FAIL on the old build):
- at 1920x1080, the map draws at least 800 px wide, and its ground pixel colour is in the blue family (blue channel well above red),
  not the old grey;
- with pad focus fresh, one A press ascends (the old page needs many presses);
- lb and rb move focus between the three panels;
- no element in #sectormodal is a cash stepper, and the page still offers every MUST KEEP item in inventory.md;
- the ascend plate stays inside the card with the biggest pack a save can hold.

Pictures (camera, your lane's port): the page at 1920x1080 and 3840x2160, before and after, and in both windows of a 2-player game wherever 2 players see this page.
The critic must score it 4 or more (never your own grade). TASK DONE when shipped, the checks pass and the critic gives 4.
TASK PARTIAL otherwise, with what is left.
