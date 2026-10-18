# UI look book (task 10-ui-look-book, 2026-10-18)
Shots: notes/shots/all/NAME-1080.jpg (78 screens, all staged except 24). 4k: notes/shots/all4k (01,45,50,52,25,18).
Scores are in notes/ui/accept.json (critic). Format below: screen | score | 3 worst | should look like.

## Recurring defects (seen on almost every menu screen, so fix once in the shared helpers)
R1. Tiny type: body 11-14px grey on near-black, below couch size. Floor should be 16px.
R2. Explaining sentences / flavor lines on screen (intro paragraphs, "Hover an item and press J", footer quotes).
R3. Close/back is a small outlined button bottom-right (x~1517), title top-left; no fixed place, no pad glyph, no focus ring.
R4. No visible pad focus: Sign/Host/Close all look identical.
R5. Currency block top-right: "900 Credits / 0 XP / Stash 3,750 bag 0" crammed, mixed baselines, big numbers beside tiny labels.
R6. The toast "The welcome pack is in your stash." sits over modals (top or bottom) in a different border style.
R7. Panels are flat dark rectangles with 1px border and a tiny amber corner tick: generic, no identity.
R8. Content packed in the top half, dead black lower third (shop, craft); cream detail card brighter than everything else.
R9. Stray capitals in labels: "Host A party", "Create A new save".
R10. Amber used for everything (buttons, credits, warnings, tutorial banners) so it means nothing.

## Raid HUD recurring defects (19, 21, 33, 22, 23)
H1. Permanent controls cheat-sheet (WASD list, ~12px, duplicate LMB row) in the middle of the lower screen. Show it only on F1 or the first 30s.
H2. Minimap: no frame, cut by the screen edge, purple zone label "The l..ng" drawn over it and clipped (P0 on 21, 33).
H3. Run info/contracts: 7-8 lines at 12-13px, ragged wrap. Cap at 3 tracked, 16px+, right-aligned counts.
H4. Panels: five styles (chevron, resize grip, orange tab, bare translucent, red banner). One HUD panel: 1px line, 85% fill, 2px accent tab, no grips.
H5. Weapon card bottom-right: no fill, "B / I backpack" bigger than a hint, ammo 12/24 duplicates hotbar 24. Ammo hero 40px.
H6. Same alert shown 3 times (banner + toast + chip). One event, one place; dedupe in 3s.
H7. Hotbar: empty slots drawn as ghost weapon icons; two selection colours (gold + blue). One selected style.
H8. Typo seen in toast: "Equlp" / "Scav plstol" (probably the screenshot font at small size; check).

## Per screen
19 raid HUD first raid | 2 | H1 cheat-sheet, H3 contracts, duplicate hint toast ("welcome pack" + equip hint) | one toast style, 4 key hints max.
21 raid HUD calm | 2 | H2 minimap label clipped, H1, H3 | tier scale 32/20/14, one panel spec.
22 raid map | 2 | labels overlap icons on the right edge (Cache struck through by rings), zone names ~2:1 contrast, "Hot ground / richer, and busier" 11px orange on red-brown; no close glyph | zone labels 60-70% white 20px with outline; 32px title; close chip top-right; thinner frame.
23 raid backpack | 2 | panel 1190px wide with 3 slots hugging left, 11-13px stats, title 20px with 12px "B or I to close" | 720-800px panel, 6x4 slot grid with empty slots dimmed, label/value stat table 18px, key-chip footer, title 28px; rarity as a bar, focus = gold 3px.
25 pause box | 2 | five-row keybind wall is the largest element; HUD cheat-sheet shows through the dim; "Please provide feedback..." 13px sentence above a Feedback button; Abandon run next to What's new | dim 75% + hide HUD, delete wall and sentence, title 36px, buttons stacked 320x56, Abandon apart with confirm, Resume focus ring.
26 settings from pause | 2 | same shell as 18 (two nav rows, empty detail panel, 13px descriptions) | see 18.
32 keys window | 2 | all rows same weight; two intro sentences; 28 identical ghost Rebind buttons, 360px dead strip right | key cap is the button, labels sentence case 18px, label column 260px, full-width scroll, Close primary.
33 raid fight alerts | 2 | minimap clipped H2; alert 3x (H6); contracts H3 | one 28px threat banner, toasts only for info.
01 title | 2 | one centred column of lore + 3 cards + key legend + 7 buttons, no hero; button heights 62/52/40 mixed; save form 898px wide vs 558px button column, "Create A new save" | left column: title + 4 main items (Play, Co-op, Arcade, Saves) on a lit art backdrop, one 56px row height, key hints at 18px in a bottom bar, version bottom-right 12px.
02 welcome pack | 2 | full-screen slab with seven rows hugging the left, 1600px of dead width, CTA 144x44 bottom-left and Close bottom-right 1600px away; intro paragraph; item name colours inconsistent, gun icons 32px dark | centred 900x640 card, two big gun tiles over five small tiles, rarity as a bar not name colour, one 280x56 CTA, close X top-right.
03 hub floor | 2 | eight identical black label plates, "Enter raid!" no bigger than "Settings"; "***Experimental feature may glitch***" under The last pour; hotbar of nine empty slots overlaps stations, HUD text 12-14px | Enter raid label 36px accent with ring, others 22px at 60% and only near; hotbar only equipped slots; one currency panel 24px; toast top-centre.
04 stash terminal | 2 | five stacked text bands (key hints, two paragraphs, freebie banner "You cheap bastard.", toast) push Close into a corner; loadout column 9-10px type; no item detail card, 60% of stash area empty | delete paragraph strips, one 28px hint row, item detail card 320px, 16px min labels, section headers one style.
05 sector page | 2 | banner 370px tall holding two lines with a dead band below; pack steppers all identical in a ragged two-row wrap, Cash row mixes All/None; three lines of explaining text bottom, amber warning | banner 220px, map 520x340, 4-per-row cards 200x72 grouped Consumables/Guns/Cash, one status line; selected chip = solid amber, focus = white ring; CTA 480x56 right-aligned with Close beside it.
06 terms | 2 | no pad focus, every Sign button identical, no signed state; two-line intro paragraph is the biggest text; footer buttons 28px outside content margin (403/1517 vs 431/1489) | amber focus outline + row tint, Signed = filled amber; reward +25% 22px amber right column; name 20px, desc 15px; Close primary, Sign nothing ghost; align footer to content edge.
07 party | 2 | two paragraphs + trading how-to dominate; Host/Join row misaligned, input holds an instruction as placeholder; "Host A party"; no party slots | modal 560x320, Host a party filled amber, Join row (input "Invite code" + Join) one baseline, 4 slots 200x72, invite code with Copy.
08 shop | 2 | content stops at y667, 330px dead; currency block cramped; cream detail panel brightest object, stepper beige-on-beige, "$660" vs Credits, flavor footer pill | cards ~220px filling to y980, dark detail panel #1c2026 with gold border, credits icon not $, prices 16px with coin glyph, hint bar A Buy / B Close / LB RB.
10 hire | 2 | red "***Experimental feature may glitch***" banner is the loudest thing; cream detail panel 60% empty, no portrait/stats, Hire button beige-on-cream reads disabled; every card repeats "30,000" | remove banner (or small "Experimental" tag), dark detail panel with 160px portrait + 2-3 stats, amber Hire / outlined disabled with "Need 29,100 more", prices only in detail.
11 gambler | 2 | Gamble/Buy are the lowest-contrast fills and read disabled, red "Need $X" louder than verbs; "Current credits" line and sentence duplicate HUD; "Limited time offer" 3 times, 16px hero item name, 56px icon | amber filled primary, one dimmed unaffordable state, item name 22px with 96px icon, price once on button, no result-box filler.
12 mainframe contracts | 2 | cream detail card off-palette and brightest, "Not finished" button dead grey-on-beige; rows all identical with repeated "Standard" tag, 12px data lines; filler subtitle "Stuff for you to do." and a 12px parenthetical rule strip | dark detail panel, 40px icon + price right at 20px amber, 2px progress bar, tier shown only when not standard, list capped at ~900px.
13/15 mainframe rewards, stats | not run | same shell as 12 (shares its defects).
14 mainframe racks | 1 | profane placeholder helper text on a button row ("This is some shit Claude came up with"); four 13px helper sentences at 1320px line length; disabled buttons ~2:1, "Build A rack"/"Slot A data core"; rack strip slots 34x12px outlines | remove the line, 48px rack tiles (built = amber), two-column progress card + cost/action card, "Build a rack" single amber 56px primary.
16 bar last pour | 2 | two identical full-yellow Ingest buttons, no focus; title centred while body left (two axes); flavor lines ("Shit's about to get real.") 12-13px, unequal rows | only focused row filled, title left 32px, 16px min, equal row height, Close in header or footer bar aligned to row edge x=1473.
17 fashion mirror | 2 | operator list clipped ("Eyes / Brown") with its own scrollbar; ~30 identical 195x155 tiles, 60px thumbnails, unlock text repeated on every locked tile; equipped = brown fill is the only emphasis, no focus ring | 5 columns with 96px renders, unlock text only for focused item, 3px focus ring plus check badge for equipped, character hero 1.6x with spotlight; delete "Cosmetics do not impact game mechanics."
18 settings hub | 2 | two stacked nav systems (underline tabs + chips, both say Display); detail panel repeats row title/value/description, 500px wide and empty below y360; rows 1300px wide, stepper 900px from its label, arrows 6px, no focus state | one nav level (left rail or one tab strip), rows ~900px, arrows 16-20px, focus = 3px amber left bar + 8% fill; delete subtitle "So you are too good for default settings, eh?"; sizes 36/22/17/14.
09 craft | 2 | 40% empty lower half; cream detail card with grey-on-beige "Hold to craft"; title "Shop, craft, and hire" lists features, "You hold $900" repeats credits | title "Workshop" 32px, grid fills to y940, dark detail panel with CTA 56px, quantity as corner badge, flavor line plain 13px or gone.
