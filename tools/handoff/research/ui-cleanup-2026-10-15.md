# UI CLEANUP AUDIT, 2026-10-14/15 (his words: "the whole game just needs ui clean up", and "ui and player messaging just isn't as clean as it should be")

- **Base:** HEAD v27.17 fixture (`tools/shots/uic-fixture.html`, built from `git show HEAD:dark_raiders.html`). Baseline for comparison: v26.54 ("12 hours ago"), fixture `tools/shots/uic-base-fixture.html`.
- **Pictures:** `tools/handoff/shots/uic-audit/NN-name-1080.jpg` (all 78 screens at 1920x1080), the same at 3840x2160 in the scratchpad `uic/audit/NN-name-4k.jpg` (not committed, 38 MB), baseline at `tools/handoff/shots/uic-base-v26.54/`. Every picture was looked at. The 4K set shows the same problems as 1080 scaled up; where 4K differs it is noted.
- **Recipes:** `tools/handoff/shots/ui-screens-js.json` now has 78 screens (61-78 are new: item wheel, operator menu x3, codex, trophy case, stocked stash, six Settings sections, CHANGE PAD BUTTONS x2, haul reveal x2, pause with the full kit). Run: `powershell -File tools\uishots.ps1 -Screens all -Res 1080,4k -Url http://localhost:PORT/shots/uic-fixture.html` (the fixture MUST NOT be named fx[0-9]*.html: every ship deletes those).
- **The lint** (`__uiLint`) found almost nothing (clip, off-screen and overlap are 0 on 70 of 78 screens). The problems below are what the lint cannot see: layout, hierarchy, duplicate controls, stale text, wrong-mode information. Lint hits that are real: the haul card (note box over the buttons), the codex (9 name clips), stash chips (12.9 px text).

## Compared with the v26.54 baseline

Most of what looks bad now looked bad then (Settings, title, hub, pause box, welcome pack, What's New card are identical). What got WORSE since v26.54:

1. **The run card with a haul** (`76-haul-reveal-mid`, `77-haul-reveal-done` vs baseline `38-extracted-card`): the reveal card is 160 px taller, scrolls, and cuts the bottom chip rows off behind the buttons; the note box sits on the buttons.
2. **The stash top bar** (`04-stash-terminal`, `67-career-stash-stocked` vs baseline `04-stash-terminal`): a second row of chips (ALL / MEDICAL / VALUABLES / LOCKED) under the tab row, plus SORT, ARMORY and TROPHIES in the same bar. Kit agent (v27.21 "one row on the stash" came after this fixture).
3. **Toasts** ("TROPHY EARNED", "CODEX ENTRY", "The welcome pack is in your stash.") sit over the belt, over the ASCEND button and over modal footers (`05-sector-page`, `41-hub-backpack`, `42-hub-pause-box`, `44-title-from-character-select`).
4. **Arcade HUD** (`47`, `50`, `53`): keeps career furniture (CREDITS/XP top right, a B/I BACKPACK plate) in the DEMO.

New screens that look finished: the item wheel (`61-raid-wheel-open`), the operator menu (`62`, `63`), the trophy case (`66`), the pad rebinding window (`74`, `75`).

## THE LIST, WORST FIRST

Owner: **ME** = menus (this chain, builds `uic1...`), **KIT** = career/kit agent (stash, shop, map select), **HUD** = feed/hud agent. "Build" is the key I ship it under.

| # | Problem | Pictures | Owner / build |
|---|---|---|---|
| 1 | **ABANDON CONFIRM OVERFLOWS THE PAUSE BOX.** Pressing Abandon run shows five buttons in one row (YES ABANDON THIS RUN (FREE THIS EARLY), RESUME RUN, SETTINGS, FEEDBACK, NO KEEP PLAYING): 1050 px of buttons in an 825 px box, hanging out of both frame edges. RESUME and NO are two controls for one job. | `59-raid-abandon-confirm` | ME, **uic1** |
| 2 | **THE RUN CARD IS HALF FEEDBACK.** 29 feedback chips (11 px) and a note box under every result. On the haul card they run past the screen and the last chip row is cut off behind LOG RUN AND RETURN; the note box overlaps the buttons (lint: overlap 192x27). KIA, extracted and abandoned cards all lead with a result then bury it. | `35-kia-card`, `38-extracted-card`, `60-abandoned-card`, `76-haul-reveal-mid`, `77-haul-reveal-done` | ME, **uic2** |
| 3 | **SETTINGS OPENS WITH THE WRONG CHIP LIT** (ACCESSIBILITY over a list that starts at THE RAID), because the section is measured while the window is hidden. | `18-settings-hub`, `26-settings-from-pause-top`, `68-settings-sec-the-raid` | ME, **uic3** |
| 4 | **TWO TAB ROWS DOING ONE JOB IN SETTINGS.** Top tabs "DISPLAY / SEND PLAY DATA" (DISPLAY is a stale name for the whole page) over section chips "THE RAID, AUDIO, CONTROLS, CONTROLLER, DISPLAY, ACCESSIBILITY": two controls named DISPLAY. The right-hand detail pane shows the first row again ("EDIT THE WORDS / OFF / Don't use this...") and stays there: 500x800 px of repeated text. | `18`, `26`, `68`-`73` | ME, later (the pane and the tab name) |
| 5 | **THE ANSWER LINE LANDS ON THE MAIN BUTTON.** The bottom-centre toast covers "ASCEND TO THIS SECTOR" on the map select screen (and the belt in the hub, "TROPHY EARNED" over belt cell 4). | `05-sector-page`, `41-hub-backpack`, `39-hub-after-raid` | ME, **uic4** (CSS in the toast); the map select screen itself is KIT's |
| 6 | **THE HUB PANELS ARE SEE-THROUGH.** The What's New card and the hub backpack let the station signs (SHOP, CRAFT AND HIRE / THE STASH / THE LAST POUR / FASHION) show through their text; the card also says "NEW IN v0.0345" while the game is v0.0347 (card refresh, ships on its own). | `40-whats-new-card`, `41-hub-backpack` | ME, **uic5** |
| 7 | **THE PAUSE BOX TELLS THE WRONG KEYS.** The hub pause lists raid keys (raid status, drop an item for a teammate, extraction); the DEMO pause ("RAID PAUSED") lists the backpack, ENTER equip, Z drop, N ping, ALT status: none of which a DEMO guest has. 25 keycaps in five rows on every pause. | `25-raid-pause-box`, `42-hub-pause-box`, `49-arcade-pause-box` | ME, **uic6** |
| 8 | **WELCOME PACK: A FULL-SCREEN WINDOW FOR SEVEN ROWS.** 60 percent empty; TAKE THE PACK and CLOSE at opposite corners; a two-line explainer; "to your stash" printed seven times (his vocabulary: never "stash" for the pack line? check the memory vocabulary before rewording; wording is NOT touched). | `02-welcome-pack` | ME, later |
| 9 | **TITLE: SETUP TEXT AND PLACEHOLDERS ON THE FIRST SCREEN.** Two "COMING LATER" mode rows (2 PLAYER CO-OP (SERVER), PVP (SERVER)) advertise what is missing; "Changing save reloads the game, which is why it leaves fullscreen." is a dev note; "First time out. Take the welcome pack..." is an explaining sentence; the key row is a tutorial; CREDITS/XP float over a main menu. The P2 window adds a four-line amber paragraph. | `01-title-mode-menu`, `44-title-from-character-select`, `57-title-2p-coop-picked`, `58-coop-player2-window-title` | ME, later |
| 10 | **CREDITS AND XP ON SCREENS THAT HAVE NO USE FOR THEM:** title, every run card, pause, party, terms, DEMO, and over the frame of full-screen windows (welcome pack, sector, Settings). In the hub header the same numbers are printed again in 9 px ("$900 . XP 0 . 12 items in stash . 0 runs"). | `01`, `02`, `03-hub-floor`, `35`, `38`, `53`, `58` | ME for menus (**uic7**); in the raid it is HUD's |
| 11 | **SETTINGS TEXT IS IN TWO VOICES.** THE RAID rows are sentence case; CONTROLS, DISPLAY, ACCESSIBILITY descriptions are ALL CAPS and run 90+ characters ("HOW FAR THE AIM TURNS FOR A MOVE OF THE MOUSE. 100% IS THE CURSOR AS IT IS. NOT WHILE THE BACKPACK, THE MAP OR THE WHEEL IS OPEN."). Terse AAA wants a three-word hint. | `70-settings-sec-controls`, `72-settings-sec-display`, `28`, `30` | ME, later |
| 12 | **SEND PLAY DATA IS A RAW CONFIG DUMP** ({"coneDeg":130,"viewFar":620,...} at 11 px, "Copy this and send it to Daniel", "best haul 0c"). | `31-settings-send-play-data` | ME, later (fold the JSON behind a toggle) |
| 13 | **CHANGE KEYS AND PAD BUTTONS USE HALF THE WINDOW.** The list is 1100 px wide in a 1920 px window; the right 40 percent is empty; a banner repeats what the title line says. | `32-keys-window`, `74-settings-change-pad-buttons`, `75-settings-pad-rebind-waiting` | ME, later |
| 14 | **THE DEMO SCREENS ARE A BLACK PAGE WITH THREE LINES.** Attract, board, run over: no background, a 400 px hole under the board, text only. The operator card is fine. | `45-arcade-attract-board`, `46-...how-to-play`, `52-arcade-run-over`, `64-arcade-board-seeded-night` | ME, later (a dimmed raid still behind the text) |
| 15 | **THE RAID MAP IS STILL IN THE OLD NAVY PALETTE** (periwinkle frame, Chrono blue) and its labels collide (CACHE over FOREMAN OFFICE, HOT GROUND over its circle, EXTRACT B over CACHE). The one full-screen view that was missed by the redesign. | `22-raid-map-open` | HUD (raid overlay) |
| 16 | **STASH: TWO FILTER ROWS, SMALL TEXT, THREE TEXT BARS.** Tab row plus chip row (the thing he hated); chips at 12.9 px; "Hover an item and press J ...", "Selling salvage here pays XP equal to the price." explaining sentences; "0c going up" in the loadout head; 30 percent empty under the stash grid. | `04-stash-terminal`, `43-stash-after-raid`, `67-career-stash-stocked` | KIT |
| 17 | **MAP SELECT: 400 PX HOLE, THREE EXPLAINER LINES.** One sector card then a black void, "Going up with: ..." three lines of sentences. | `05-sector-page` | KIT |
| 18 | **CODEX: TILES TOO SMALL FOR THE WINDOW, NEW BADGE ON THE NAME.** 19 tiles use a third of the height; the NEW badge sits on "MARKSMAN RIFLE"; names are cut by 2 px (lint: 9 clips); found and not-found tiles have different text heights. Trophy case: same, 8 cards in the top quarter; LOCKED text 2.1:1 contrast. | `65-codex`, `66-trophy-case` | KIT (career) |
| 19 | **MAINFRAME VOCABULARY AND DENSITY.** Reward "520 c" beside "$520"; PROFICIENCY and "Level 1" are back on YOUR STATS (hidden since v6.40); achievements as a plain list of LOCKED lines; RACKS is full-width buttons and paragraphs; REWARDS shows "7,200 to go" and "7,200" twice per row. | `12`, `13`, `14`, `15` | ME, later |
| 20 | **BACKPACK PANEL: "Integrity 100/100" for HP, 11 px stats, an empty half.** | `23-raid-backpack-open`, `41-hub-backpack` | HUD (raid) / ME (hub) |
| 21 | **PARTY AND TERMS: EXPLAINER PARAGRAPHS.** "Up to four pillagers, linked by invite code..." plus a 12 px TRADING paragraph; HOST A PARTY and JOIN A PARTY are two buttons misaligned around a textarea whose placeholder is an instruction. | `07-party-coop`, `06-terms` | ME, later |
| 22 | **WIRT: "LIMITED TIME OFFER" TWICE** (section head and the card's own title). | `11-wirt-gambler` | ME, later |

### HUD (not mine, for the feed/hud agent)

- Credits and XP (top right) printed in every raid and in the DEMO (`19`, `20`, `47`, `61`); the first-raid controls legend is 580x240 px on the bottom-left quarter of the play space (`19`, `20`, `61`) and stays up.
- Raid map in the old palette with colliding labels (`22`).
- The in-raid backpack: "Integrity", 10 px stats, a hollow lower half (`23`).
- DEMO HUD: B / I BACKPACK plate and CREDITS/XP (`47`, `50`, `53`); "MOVE TO START" cut by a wall (`48`, still, as in baseline).
- "1 ON THE MAP" / "GOLDEN ENEMY . SEARCH CIRCLE ON THE MAP" alert pair stacked on the same plate style as the weather line (`49`, `47`).
- The recipe `24-raid-controls-full-H` does not stage on this build (legendOn stays 1): the F1 list is covered by `32`.

## Fix order

`uic1` abandon confirm, `uic2` run card tags, `uic3` Settings chip, `uic4` toast placement, `uic5` opaque hub panels, `uic6` mode-aware pause keys, `uic7` credits readout off the menus. Then (as time allows) 4, 8, 9, 11-14, 19, 21, 22. KIT items (16-18) wait until their builds stop appearing in `git log` for 30 minutes. Results go in the report of the main session; the builds are named in the commit log as `v27.xx: ...` (the keys above are mine, the older `ui1`...`ui7` of 2026-10-12 are a different, finished chain).

## Planned: the EXPERIMENTAL section in Settings (his answer 1)

He wants "an experimental settings menu inside settings where I can turn new features on and off". Plan, not started: a seventh section **EXPERIMENTAL** at the end of the jump bar (SETSEC gets one more name, after ACCESSIBILITY; the chips and the head come for free from setSecsHtml), its rows are GAMEOPTS rows with `sec:'EXPERIMENTAL'` and an on/off pair, each one gating one feature through a single profile map `P.exp` (default ON, so nothing changes until he turns one off). Row text stays three words ("AIR STRIKE", "RAID EVENTS", "ITEM WHEEL"). The head carries a one-line amber note in the style of his "***EXPERIMENTAL FEATURE MAY GLITCH***" banner. Waits for the feature list from the main session and for the other agents to settle.
