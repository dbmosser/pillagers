READY
# Pillagers UI style guide (task 10-ui-look-book, 2026-10-18)
Built from: references.md (Halo Reach, Halo 4, Diablo IV, ARC Raiders, Fortnite, Destiny 2), the 78 screens in notes/shots/all (critic scores in accept.json, per-screen notes in look-book.md), and the draw code. No ui-refs pictures exist yet in tools/handoff/ui-refs.
Rule of the guide: the code already HAS most tokens (CSS :root at line ~40, UIC and HUDC and TYPE in the script at ~10717-10762). The problem is that screens ignore them. So this guide mostly says which existing token to use and which variants to delete. Fix the guide, not a screen, when the guide is wrong.

## 1. Tokens (copy this block; names match the existing CSS vars, new ones marked NEW)
```
/* colors: one palette */
--ui-void:#0b0c0d;  /* behind everything                          */
--ui-bg:#111315;    /* page / window background                   */
--ui-panel:#16191b; /* panel fill (NEW rule: the ONLY panel fill)  */
--ui-raised:#1e2225;/* detail pane, focused row fill               */
--ui-line:#2e3337;  /* 1px line, row divider                       */
--ui-line-hi:#4a5257;/* panel border, idle button border           */
--tx-1:#efe9dc;     /* text                                        */
--tx-2:#aaa498;     /* muted text (floor: 4.5:1 on panel, never dimmer for anything read) */
--acc:#e6ff3d;      /* THE accent (his Q46, 10-18): lime yellow. Focus, selected, the one main action, hero number. 15:1 on --ui-panel, 16:1 on --ui-void (same at 1080 and 4K: contrast is colour, not size) */
--acc-ink:#11150a;  /* text on an accent fill, 15:1                */
--acc-hover:#f0ff7a; --acc-press:#c8e22c;   /* main button hover and pressed                */
--warn:#f5b73b;     /* the OLD amber, kept only as warning text/glyph so a warning never reads as the accent */
--danger:#e5482f;   /* KIA, Abandon, hostile, "cannot afford"      */
--ok:#76b97c;       /* signed, built, recovered                    */
--extract:#47d8c6;  /* extraction only (Extracted card, countdown) */
--r-common:#9da3a8; --r-uncommon:#5fbf6a; --r-rare:#3f9de9; --r-elite:#a866e0; --r-gold:#ffc72e;  /* rarity only */
--scrim:rgba(6,7,8,.80);  /* NEW: behind every modal/card (was .82 and .6 and .45 in places) */
/* type: two roles */
--f-cond:"Barlow Condensed","Bahnschrift SemiCondensed","Arial Narrow",sans-serif; /* scan: titles, tabs, buttons, labels, numbers */
--f-body:"Barlow","Bahnschrift","Segoe UI",system-ui,sans-serif;                    /* read: descriptions, tooltips (sentence case) */
/* type scale: FIVE sizes at 1080p (scale by height/1080); nothing else */
--fs-hero:56px;  /* NEW: one per screen: SP result, extract timer, ammo      f-cond 800 */
--fs-title:32px; /* screen title, card title                                 f-cond 700 */
--fs-body:20px;  /* row names, button text, detail text                      f-cond 600 / f-body 400 */
--fs-label:16px; /* labels, tags, stats, key hints, minimum for anything read f-cond 600, +.04em */
--fs-fine:14px;  /* version stamp, legal, footer legend only                 f-body 500 */
/* space: 8px grid */
--sp-1:8px; --sp-2:16px; --sp-3:24px; --sp-4:32px; --sp-5:48px;  /* NEW; nothing else, margins 5% of screen */
--rad:4px;       /* NEW: every panel, button, tile (was 2/3/5/8) */
/* motion (existing --m-* kept, two added) */
--m-fast:90ms; --m-med:160ms; --m-in:240ms; --m-out:140ms;
--m-ease:cubic-bezier(.2,.8,.2,1); --m-ease-in:cubic-bezier(.4,0,1,1);
```
Boldness goes in ONE place per screen: the title or the main action, never both. Everything else is quiet (tx-2, line, panel). Lime (--acc) is for focus, selected and the one primary action, so lime text on a body paragraph and lime credits all go (use tx-1). Keep it apart from its neighbours: rarity gold (#ffc72e, hue 44) is a 3px bar, never a fill; warn amber (hue 40) is a small glyph or short word; danger red (hue 10); ok green (hue 125); extract teal. The accent is 24 degrees of hue from gold, so never put the two side by side as fills.
His taste, 10-18 (Q40, 42, 44, 45): clean and modern. No pixel or arcade font anywhere (Barlow Condensed and Barlow only; the tabular f-mono is for numbers in a table, never a headline). Straight copy: no arcade wink, no "Insert coin", no "Game over" jokes; say what it is ("Run over", "Press any button" stays because it is the action). No single model game: borrow per element (Halo Reach/4: the calm column menu and the focus bar; Diablo IV: the dark inventory grid with rarity bars; ARC Raiders: the flat dark panel with one hot accent; Fortnite: big bold bouncy CTA and punchy confirm; Destiny 2: the hero number and the quiet type; see references.md).
Avoid the template tells: no identical rounded boxes with one shadow, no gradient washes (the .panel linear-gradient goes), no everything-same-weight rows. Hierarchy comes from size (hero 56 vs body 20), weight (800 vs 400) and brightness (tx-1 vs tx-2).

## 2. Components (one of each)
Panel P: fill --ui-panel at 90%, 1px --ui-line-hi border, --rad, padding 24px, NO double frame, NO corner tick, NO gradient, NO shadow. Optional 3px accent tab on the left edge or a 2px top tab 36px wide when the panel is "the star" (the existing hudPanel tick is this). Detail pane: same panel in --ui-raised. The cream paper card (--ui-paper) stays ONLY for the one-question ask dialog (#askmodal); shop, craft, hire, contracts detail panes become dark detail panes.
Window (his Q43, 10-18: "centred card with an X, taking up nearly the entire screen"): every WINDOW (Settings, stash, shop, craft, hire, contracts, codex, trophies, mirror, board, what's new, welcome pack, party) is one centred card at 90% of the screen width and height (the 5% margin on every side), on --scrim, header row 56px high (title left 32px, the X right), body, footer action row 72px. The content inside keeps its own measure, centred in the card (list rows max 900px, a grid fills the card). Replaces the old 960x680 cap and the full-screen slabs. A DIALOG (ask, confirm, pause 480, end card 720) is NOT a window: it stays a small card sized to its content (480x240 for a question), centred, with the same X.
Header H: title left at x = margin (5%), --fs-title f-cond 700, tx-1, sentence case, optional muted count on the same baseline in tx-2 20px ("10 of 20 found"). Never a sentence, never currency (currency lives in the one top-right currency block).
Close / back: ONE place: top-right of the modal header, a 48x48 square ghost button with the uiIcon "close" glyph, plus the pad glyph "B" beside it and Esc. Where a footer exists the primary sits right and a "Back" ghost sits left of it; no third close style. In-raid panels close with the same X.
Primary button: 56px high (44px minimum in dense lists), fill --acc, text --acc-ink --fs-body 700, padding 0 32px, min-width 200px, --rad. One per screen. Hover: --acc-hover #f0ff7a. Pressed: --acc-press #c8e22c, 1px down.
Secondary (ghost) button: same size, transparent, 1px --ui-line-hi, text tx-1. Hover: --ui-hover, border tx-2. Danger button: ghost with --danger border and text, never filled except on its confirm dialog. Disabled: 40% opacity, never see-through grey on cream, and say why in the label ("Need 29,100 more").
Tab: text --fs-body f-cond 600 tx-2, 48px high, 24px side padding; active = tx-1 with a 3px --acc underline. ONE tab strip per screen (settings has two nav systems today: delete one). Tabs carry words, never icon-only. Pad: LB/RB glyphs at the strip ends.
List row: 56px pitch (48 min), padding 0 16px, name --fs-body tx-1, value right-aligned --fs-label tx-2 (lime only if it is the focused value), 1px --ui-line divider. Rows fill the panel width up to 900px; label and control stay within 400px of each other (no stepper 900px from its label).
Tile (grid cell): square, --ui-raised fill, 1px --ui-line, --rad, rarity as a 3px bar on the bottom edge (not a name colour), count as a corner badge --fs-label, gutter 8px. Locked: 40% opacity, silhouette. Unfocused tiles at 70% brightness.
Chip / key cap: 28px high, 1px --ui-line-hi, --fs-label, padding 0 8px. A key hint is a cap plus a word ("E  Loot"), never a bare letter. Pad glyphs replace key caps when the last input was a pad.
Toast: ONE component. Top-centre, 40px high, 4px left bar (accent info, ok gain, danger threat), --fs-label, 3s, max 3 stacked, de-duplicated within 3s (the same event never shows as banner + toast + chip). Toasts never sit over a modal; they wait.
Currency block: one, top-right, one row: "Credits 900 · XP 0" 20px with an icon; on raid cards "SP" only. Never "$" (his rule: score is SP). Never repeated inside a modal that has its own cost line.
Progress bar: 6px high, --ui-line track, --acc fill (extract timer --extract, health stays on the HUD scheme).
End cards (Extracted, KIA, Abandoned, Run over): one shell: centred 720px card on --scrim 80% with the HUD hidden. Title --fs-title (extract --extract, KIA --danger, other tx-1), ONE hero line --fs-hero (haul or SP), stats as one row of 4 (24px value over --fs-label), items as a uniform tile row, one primary button 56px + one ghost. 
Backdrop: the live world dimmed to ~55% (scrim above), baked once on open. Never a flat grey wall.

## 3. Placement (every screen)
- Margin 5% of screen on all sides; nothing but a toast or the HUD crosses it.
- Title top-left; close top-right; currency block top-right (left of close); primary action bottom-right of the card; back/secondary left of it; key-hint strip along the bottom edge (--fs-label), live to the last input device.
- ALL LOWER CASE everywhere, his order 2026-10-18: "change all text shown to player to lowercase only -- i don't like how you have random words capitalized" ("host a party", "create a new save", "sp", "esc"). One text door (ncFix, cw-lowercase) lowers every canvas line, text node and tooltip, and a CSS line lowers stylesheet words. Never write code that re-capitalizes. A box the player types in shows what is typed.
- No explaining sentences. A label or a short callout; help goes on focus in the detail pane, one line.
- Min text 16px (14 only for fine print). Contrast: tx-2 on panel is >= 4.5:1; never dimmer text for anything a player has to read.
- Space: panel padding 24, gap between sections 32, between rows 0 (dividers), between tiles 8, title to body 24. Content packs to the TOP of its panel and the panel is sized to content or the grid fills it; never 50% dead black.

## 4. States
- Hover (mouse) = focus (pad): ONE look. 3px --acc left bar on rows (or a 3px --acc outline on tiles), --ui-raised fill, text to tx-1. The existing .padfocus (3px lime outline + glow) is the tile style; rows get the bar. Mouse hover and pad focus must look identical.
- Something is focused whenever a window opens; if it vanishes jump to the nearest. Selected (equipped, chosen) = filled badge/check or --acc fill, DIFFERENT from focus (ring).
- Pressed: scale .98 or 1px down for 90ms. Disabled: 40%.
- Two players: focus ring tinted per player (P1 lime, P2 --ally).
- Destructive (Abandon, Sell all): hold 500ms with a filling ring, or a confirm dialog 480x240 (title "Abandon run?", one line, Abandon danger ghost + Keep playing primary focused).

## 5. Motion (smooth is mostly motion; targets from references.md, time-based)
- Focus move: highlight eases to the target, 95% in 120ms (x += (t-x)*(1-exp(-dt/.04))); focused tile scale 1.05.
- BOUNCE (his Q47, 10-18: "livelier, with bounce"): position moves use ease-out-back, c1 = 1.5, which runs 8% of the travel past home and settles (his band is 6 to 10%; never above 10%). Opacity never overshoots. Code: UIM.E.back.
- Open: 240ms, alpha 0 to 1 (ease-out) with a 24px rise on ease-out-back (1.9px past home, then settles); each row 16px rise, 35ms apart. Close: 140ms ease-in, no stagger, no bounce (a close must feel instant).
- Tab change: 200ms cross-fade + 24px slide in the travel direction, ease-out-back.
- Stagger: 35ms per card, at most 8; whole entrance under 500ms.
- Confirm: scale 1 + .08 sin(pi t) over 120ms (peak 1.08). Deny: 6px shake over 100ms.
- A press mid-animation retargets from the current value; never ignored.
- Counters: --m-count 450ms ease-out. Never linear, never over 300ms for a common action, never overshoot more than 6%.
- Never static: slow backdrop drift on title and hub menus; new items get one 600ms glimmer sweep.

## 6. Sound
- His Q48 (10-18): SOFT ticks on focus (quiet, 30-80ms, high and short, never a click you notice on a fast scroll), PUNCHY hits on confirm and on score (a low thump with a short bright tail, louder than the tick by about 6 dB; the SP count-up and a purchase get the same hit, the biggest on the extract sting).
- Focus tick 30-80ms, 3-4 variants, pitch +-3%, at most one per 40ms. Confirm deeper; back lighter and shorter; deny a dull thud; open/close a soft sweep; purchase, unlock, extract a bigger sting. Max 3 copies of one sound. Play on the input frame. (All via the existing sfx(), no new audio files.)

## 7. Map: every existing variant to its replacement
Type sizes seen: 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 20, 22, 24, 25, 26, 28, 36, 40, 44, 48, 56, 72.
- 9-13 (tags, helper lines, stats, hints, .row .vl 15, .itag 13, .panel h2 13, .cosnote 13) -> fs-label 16 (fine print only 14)
- 14-15 (button 14, --t-body 15, .row .vl) -> fs-label 16 for chips, fs-body 20 for button text
- 16-18 (.row 16, --t-button 16, --t-lead 17, --t-h3 18, .invtab 17) -> fs-body 20 (rows, buttons), fs-label 16 (tabs sub-labels)
- 20-28 (--t-h2 24, .pausebox h3 25, TYPE.title 26, centred titles 28) -> fs-title 32
- 36-48 (--t-h1 40, window titles 36, 44, --t-num-xl 48) -> fs-title 32 when a title, fs-hero 56 when THE number
- 56-72 (--t-display 72 on title logo) -> logo may stay 72 (the one brand mark); fs-hero 56 everywhere else.
Canvas TYPE (HUD): micro 10(13) -> label 16; label 12(15.6) -> label 16; head 15(19.5) -> body 20; title 20(26) -> title 32; huge 30(39) and num 34(44) -> hero 56 only for the one number (ammo 40 at 1080 on HUD is allowed as the HUD hero). One tracking: +.04em, never above .08em.
Panels seen: .panel double frame with gradient (5px radius), .modal slab with ::before inset frame, cream paper card, hudPanel (chamfer + amber tick), hudPlate (rounded, left bar), rounded dark glow card (end cards), bare translucent text (arcade HUD, minimap labels), orange tab banner (raid info), red banner (alerts) -> Panel P (HUD panels: hudPlate with 1px line and 85% fill; hudPanel keeps the 2px tick; delete grips and chevrons from default view; danger variant = P with --danger bar).
Buttons seen: global `button` (14px uppercase-style outline, coolant focus ring), #root button (40px, 2px radius), .deploy/#oc_btn/.ui-btn.pri (44px amber), .ghost, plain beige-on-cream buttons, tiny outlined "Rebind"/"Ingest"/steppers, list-style Back, 62/52/40px title buttons, Close bottom-right -> Primary, Secondary, Danger (three only). Rebind: the key cap is the button. Steppers: 32px chevron arrows.
Colors seen: amber (title, CTA, credits, warnings, tutorial banners, all hover, selected, tab) -> amber only for focus and the one action; credits tx-1; warnings danger; teal (extracted, outlines in the global focus-visible) -> extraction only, focus ring becomes amber; purple (zone names, elite) -> rarity only, zone names tx-1 at 70%; red (KIA, hostile) -> danger; cream paper (detail cards) -> ask dialog only; blue (armour, ally) -> data: P2 and armour only; green -> ok.
Radii seen 2 (buttons), 3, 5 (panel), 8 (avcv) -> 4.
Paddings seen 6/8/10/12/14/18/22/28/45/133 -> 8/16/24/32/48.
Close styles: bottom-right outline button, list Back button, none (end cards), key hint only (HUD) -> top-right X + B.
Titles: top-left 26, centred 28, centred 20, 22 over a card -> top-left 32.
Toasts: screen-bottom pill, top banner, in-footer text, orange tab -> one toast.
Screen-wide (look-book R1-R10, H1-H8) are fixed by changing these shared things once: .panel and .modal CSS, button CSS, hudPanel/hudPlate, the toast function, applyMenuZoom type floor.

## 8. Order of work (highest value first, for later tasks)
1. Global shell: .panel/.modal into Panel P, close X in the header (affects ~25 screens).
2. HUD: hide cheat-sheet except on F1/first 30s, fix minimap label clip (P0), one toast, dedupe alerts.
3. Title screen (01, 57, 58): left column, 4 main items, one button height, hero backdrop.
4. End cards shell (35, 38, 60, 77, 52, 55).
5. Detail panes (shop, craft, hire, contracts, gambler): dark detail pane, fill the height.
6. Settings: one nav level, row width 900, focus bar.
7. Grids (codex, trophies, mirror): bigger cards, focus ring, detail pane.
8. Remove profane/placeholder text on screen (screen 14 racks).
9. Motion and sound pass: focus easing, open/close, tick variants.
Check each with uishots + critic; done at 4 or more.
