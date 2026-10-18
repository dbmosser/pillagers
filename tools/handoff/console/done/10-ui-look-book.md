THE UI LOOK BOOK AND STYLE GUIDE (his order 2026-10-18: "The weakest part of the whole game is still UI and presentation and
organization of menus etc." and "You should be checking for optimization of design aspects and style consistency across menus,
not just getting them right but making them actually look good"). Read the "UI work" section of your rules first.
This task changes no game code. Notes: tools\handoff\console\notes\ui\look-book.md (read it first; a later run continues from it).
1. Shoot every screen at 1080: tools/uishots.ps1 -Screens all -Out tools/handoff/console/notes/shots/all -Res 1080 -Port 9361
   (about 10 minutes). Then shoot 01,45,50,52,25,18 at 4k into notes/shots/all4k.
2. Run the critic on every 1080 picture, one per call: node tools/console-sdk/critic.mjs tools/handoff/console/notes/shots/all/NAME-1080.jpg
   (about 4 cents each; it is harsher and fairer than your own eye). Look at the pictures yourself too (view_image) for
   consistency ACROSS screens, which the critic cannot see. For each screen write in look-book.md: the critic's score, the three worst
   problems (be concrete: "header 44px, every other header 28px", "buttons left-aligned here, centred everywhere else"), and
   what it should look like. Note any screen that did not stage.
3. Find the visual language the game already uses in the code (grep the draw helpers for panels, buttons, headers, fonts,
   colors) and list the variants: every font size, every panel style, every button style, every accent color in use.
4. Write tools\handoff\console\notes\ui\style-guide.md, starting with a line READY when done. Tokens first (Anthropic's
   frontend-design advice): 4-6 named colors and 1-2 type roles before any layout; spend boldness in ONE place per screen (the
   title or the main action), keep the rest quiet; avoid the generic-template tells (identical rounded boxes with one shadow,
   gradient washes, everything the same weight). Put the tokens at the top as a block the code can copy. ONE type scale (at most 5 sizes at
   1080, with names), ONE palette (background, panel, line, text, muted text, one accent, the rarity colors, danger), ONE
   spacing grid, ONE panel, button, tab, list-row, header and close/back style, focus and hover states for mouse and pad, where
   titles and close/back sit on every screen, sentence case. Base it on tools\handoff\console\notes\ui\references.md FIRST (a study of the
   menus he loves: Halo Reach, Halo 4, Diablo IV, ARC Raiders, Fortnite, Destiny 2; his words "really compelling and smooth"),
   then the best-looking screens you found and his reference pictures in tools\handoff\ui-refs\ if any. Include its motion and
   sound rules: smooth is mostly motion, which a still picture cannot show. Map each existing variant to its replacement.
5. Write tools\handoff\console\notes\ui\index.html for him: a simple dark page (no external files) with every 1080 picture
   (relative paths ../shots/all/NAME-1080.jpg, width 100%, click opens full size), grouped (party demo, raid, end cards, pause and
   settings, Undercroft), each with its score and one plain sentence. Worst screens first in each group. Then an empty
   section titled "Changes" for later tasks.
TASK DONE when the style guide is READY and the page exists.
