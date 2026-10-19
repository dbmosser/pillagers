1) MUST KEEP (live labels, from the 1080 screenshot and `/dark_raiders.html`)
- **Frame:** title "pre-raid" and an X. The close button's text must stay "close", because B, Esc and Tab find it by that word. Every change saves at once, so closing loses nothing.
- **Map:**
  - Only "cold storage" is offered; the cold mile is frozen. The selected map shows an "ascending here" tag.
  - The preview shows 5 zones (the long dock, packing floor, chill row, the sump, scrap line), buildings, landmarks and 3 extraction rings.
  - Stats line: "you have never raided here" (or "you: n runs here") · "420 by 340 metres, 14.3 hectares" · "5 named zones" · "2 keyed rooms" (blast freezer, foreman office) · "the test robot extracts 39.2% of its raids in cold storage."
  - A "seal tier n, x of y s cut" line appears only when a seal is in progress.
- **Surface:** day or night. Hints are "you go up in daylight." and "you go up in the dark. xp pays 1.2x." The lift resets it to day on every ascent.
- **Weather:** surprise me (default), clear, rain, fog, blackout, storm.
  - Default hint: "whatever the surface gives you."
  - Otherwise "{name}. harder going, so xp pays 1.1x." or "no bonus for an easy sky." Blackout and the blackout term have special hint lines.
  - The pick persists across raids.
- **Kit:** pick one of four. The pick falls back to my loadout after you go up.
  - my loadout / your pack
  - freebie kit / scav pistol · 4 items
  - random kit / 2 guns · 1 each
  - best kit / 3 guns · up to 3 each
- **Pack (my loadout only):**
  - Buttons "pack all" and "clear".
  - One chip per carryable stash item, showing packed count, "/held", "-", "+" and "max". Today's order: medkit /2, smoke canister /1, frag charge /2, armour plate /2, bandage /3, burst carbine (field) /1, compact smg (field) /1.
  - Tripwire, decoy and stim appear only when owned. Ammo and keys also appear when owned.
  - Data core slot: "no data core" (disabled) / "slot data core (n)" / "data core slotted". It burns on ascent.
  - The cash chip ("cash - all /900 + max") is being removed. Removal also touches `P.takeCash`, `P.takeCashRaid`, and the cash part of pack all and clear.
- **Going-up box:**
  - "going up with: a scav pistol", or the equipped gun plus ", and your x as gun 2".
  - Conditional: "your own gun is in your stash. close this and choose equip as your gun on it to take it up."
  - Armour warning: "you ascend with no armour equipped. equip armour plates on the surface. each absorbs 50% of every hit until it is gone, up to a cap of 60."
  - For a non-loadout kit the box reads "going up with: {kit} · {sub} · this raid only", and the armour warning is not shown.
- **Deploy:** "ascend to this sector" applies the kit and goes up.
- **Entry points:** lift E, the staging ascend, and the stash. The DEMO never opens this page.

2) RULINGS THAT BIND
- "change all text shown to player to lowercase only" (`pillagers-afternoon-orders-2026-10-18`). A global `::before/::after` lowercase rule and the TX text door enforce it.
- Lime accent: "Lime yellow accent, whichever is most visible" (answer 46, `pillagers-answers-1-78-2026-10-18`). Warn amber stays for warnings only.
- Windows: "centred card with an X, taking up nearly the entire screen" (answer 43, same file). That is a 90% card.
- Style guide §4 (`notes/ui/style-guide.md`): selected is a fill or check, different from the focus ring. Five type sizes only: 56/32/20/16/14. Toasts never sit over a modal.
- Critic: 4 for raid, waiting, pause and run-over screens; 3 elsewhere (`pillagers-answers-r2-r3-2026-10-18`, guidance only). This page scored 2 ("debug panel").
- "P1 is amber and P2 is cyan everywhere. Lime only means selected" (`pillagers-answers-r2-r3-2026-10-18`). Cold Storage only.
- Keyboard and mouse first (`pillagers-fifty-answers-2026-10-12`). Pad must also work; P1 on KB+M, P2 on a pad.
- `pillagers-orders-2026-10-19`: "remove the concept of taking cash 'into' a raid." Items, ammo, keys, guns and data core stay.
- Vocabulary: pillagers and pillager bots, never raider; $ for money. The "test robot" line breaks this.
- Answer 8 (`pillagers-answers-1-78-2026-10-18`) allows cutting lines he wrote if the reason is logged. Do not reword his edited lines unlogged (`dark-raiders-an-edited-line-is-a-key`).
- He asked for the pack row on this page ("quickly pick how much... of each wheel item", 10-15). It stays, even though `pillagers-one-control-per-job` argues against duplicating the stash's job.

3) PROBLEMS
- **Wasted space:** the map banner is about 370px tall with a mostly empty left half. A dead band sits below it, because `#sectorlist` flexes to fill. The map is about 420px wide and its zone text is 8–11px.
- **Hierarchy:** the map has no framing and four rows of equal weight follow. Pack chips wrap raggedly over two rows with no grouping and no item icons or rarity. The deploy button is a full-width bar, away from the controls.
- **Lime means everything:**
  - All inactive buttons have lime text, so selected differs only by a faint border and tint.
  - The pad focus ring is also lime, so focus and selected look alike.
  - The armour warning is lime instead of `--warn`.
  - The CSS alias `--amber` is lime #e6ff3d, which misleads designers.
  - Hard-coded old amber `rgba(255,192,74,.10)` tints the map card, kit and condition buttons, giving a brownish banner.
  - The map preview is still on the old navy palette: ground #55647A, zone stroke periwinkle, canvas #0b1020, rings #4de3d0.
- **Type:** about eight sizes (30, 28, 17, 16, 15, 14, 13, 12), against the guide's five. The kit sublines are 12px and the row labels 13px. At 4K from a TV this is the least readable part.
- **Sentences:** the hints and the 3-sentence summary explain mechanics, against "short callouts".
- **Toast:** "the welcome pack is in your stash." sits across the header.
- **Pad flow:** about 41 stops (the screenshot lint counted 41 controls).
  - Pack alone is about 26 stops (3 per item).
  - Focus starts on the map card, not on deploy.
  - There is no A/B/Y prompt strip.
  - Navigation is spatial (`padStep`), so it jumps unpredictably across the ragged chips.

4) CAN MOVE OR COLLAPSE
- **Map picker:** with one map offered, drop the pick function (keep it for future maps) and show a header strip.
- **Stats line:** cut "never raided", "hectares" and the "test robot 39.2%" line. That figure comes from the dev sim and means nothing to a guest. Show "420 x 340 m · 5 zones · 2 keyed rooms · 3 exits".
- **Surface and weather:** merge into one conditions row. Show the xp bonus as a badge ("+20%", "+10%") instead of a sentence, with the detail on focus.
- **Kit:** keep it as a 4-way segmented control. Show what each non-loadout kit actually resolves to.
- **Pack:** make it a grouped tile grid. Drop "max" and the always-visible minus buttons in favour of one stepper per tile. If the stash is empty, collapse the pack to "edit pack".
- **Summary box:** reduce it to chips for gun, gun 2, items and armour. Make "no armour" a `--warn` chip. Replace the "equip as your gun" sentence with a "no gun equipped" chip.
- **Toast:** hide while the page is open, or give it a reserved slot.

**Two-player**
- Today the page has no seat colour, and the pad focus ring is lime in both windows.
- Keys follow the front window. The first pad drives the P2 window and the second drives P1.
- Only the host's ascend starts the raid. A guest who presses ascend is told "only the host can start the raid. you ascend with them."
- The host's map, surface and weather are sent to the guest. A guest's own surface and weather picks are discarded and should show read-only.
- After the host ascends, the page closes at once. Each teammate gets a kit card, "keep my kit", with a 15 s auto-ascend. The host sees no waiting state on this page.
- The ?party=1 demo never reaches this page, so it is a Career and release page.

5) PALETTE AND FONTS (from `UIC` and `:root`)
- **Confirmed unchanged:** every colour you listed matches the code.
- **Extra tokens:**
  - ui_void #0b0c0d, ui_hover #272c30, tx_off #55524c
  - acc_dim rgba(230,255,61,.16), acc_hover #f0ff7a, acc_press #c8e22c
  - ally #9cc7ff, armour #7fa6c9, danger_bg
- **Rarity colours:** common #9da3a8, uncommon #5fbf6a, rare #3f9de9, elite #a866e0, gold #ffc72e.
- **Corrections:**
  - Seat colours are not UIC tokens. `SEATCOL` is P1 #ffb02e and P2 #38d6ff, not warn #f5b73b or extract #47d8c6.
  - `--amber` in the CSS means lime.
- **Fonts:**
  - Barlow Condensed (500/600/700/800) for h3, buttons and labels (`--f-cond`).
  - Barlow (400/500/600) for body (`--f-body`).
  - Both are embedded as woff2 data URIs, falling back to Bahnschrift.
  - The map canvas draws zone names in Barlow Condensed bold at 8–11px.
- **Sizes and shape:** five-size scale 56/32/20/16/14, 8px spacing grid, radius 4, buttons 56/48/40px high.