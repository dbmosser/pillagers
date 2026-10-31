# 0p01-186f-hud-panel-consistency (lane a, 10-31)

Shipped (both ON HIS PC):
- v36.73 cw-hudinset (check 36.73): hudIns() = the right column's inset (16 x HUDZ.cond x hudRes, 17 px at 1080p). Roster (PADX), feed + medal spot (feedRect, so the controls list docks on it), status icons (ox), vitals bars (translate by _bsx inside the body zoom), ammo card (_wpR), teammate rows (NETTEAMBOX + shared hudPanel instead of the 62 percent blue-black box) all stand on it. Check measures five panels, spread must be 2 px or less (was about 15). Top centre: no score card = one card (CLKCARD k one) holding clock, sky icon, extract line, arrow (the clock draw is deferred into _clkJob and drawn on the card); score card present (career, arcade) = the extract line and its arrow share one card as wide as the score card (k row), arrow 4 px lower so it clears the words. Clock and score stay separate windows (his 10-28 order). YOU row of the board is tx-1, rivals tx-2.
- v36.76 cw-hudroster (check 36.76): board title and rows at TYPE.label (about 16.8 px on screen, were 14), LW 214 to 230, row pitch 11 to 14.

Pictures: shots/0p01-before (21 33 34 50), shots/0p01-after (after v36.73), shots/0p01-after2 (21 50, after v36.76).
Critic (2 runs): screen 21 after v36.73 = 2 (its P0s: controls list open, roster text; the roster is fixed in v36.76; the controls list is already the 18 px cw-ctrlchip panel and open only because the camera shot is the first 30 s); screen 50 after v36.76 = 3. Its top findings now: merge clock, score and extract into ONE plate (reverses his 10-28 order: separate clock and score windows), 48 px / 96 px margins (the style guide margin and his drag-able corner panels say otherwise), slim hp bar (his 08-25 note: the health bar bigger and more prominent), empty hotbar slots clutter (regression 35.64 keeps the full vacant tiles). Not taken.

Not done, left for a later job (each is a real item of the job text):
- bottom alignment of ammo card (bottom 32 px up), hp bar (13 px) and belt (18 px): the gear block anchors all on one `by` (H-34) shared with the vitals; needs the gear block split from `by`. Item 18.
- minimap and notes row corner is still the 10 px chamfer (mmPath, trPlate), not the 4 px radius; the minimap is off by default. Item 5.
- minimap size 240, hotbar selected slot hierarchy (9), hp label size (10), ammo card contrast P0 of o-00t, run info wrapping, how-to-play attract card show-through (12), P1/P2 tag contrast over light ground (6).
- extract card in career: the critic still sees clock card, score card, extract card as three boxes. Merging the extract row into the clock card needs arcadeScoreHud to know the pill (layout rework, rush mode too).
Check this by eye in the next play: the clock and the extract line on one dark card in the top middle, the left and right panels on one margin, the board text bigger.
