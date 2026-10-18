# Sweep 3: his newer rulings (Oct 13-18), checked for clashes, stale points and open details

Written 2026-10-18 (evening). Read-only sweep; nothing else was edited.
Sources read: the 17 memory files named in the brief, the menu survey (answers-2026-10-18.txt + survey.json, option text and the 132 reviewer notes), round 1 (questions-100-2026-10-18.md), round 2 (Desktop\dark raiders\questions-100-round2.md, read in full so nothing below repeats it), the helper notes under tools\handoff\console\ (questions.md, notes\01, 02, 03, 05, p1p2-consistency.md, style-guide.md), the HUD spec, his 10-15 evening orders, the 2-player test sheet on the Desktop, and greps of dark_raiders.html (never read whole).

Each finding: type, his words quoted with file and date, what conflicts, why it matters, a draft question (plain words, 2-4 options), and my recommended pick.
Priority: 1 = could hurt the Fri 10/30 party or blocks work this week; 2 = matters, can be decided by Tue; 3 = can wait or be left to a helper if he skips it.

Count: 36 findings. Section lists: round-2 premise problems, dropped near-duplicates, helper-only notes.

## Index

| id | type | pri | topic |
|----|------|-----|-------|
| S3-01 | contradiction | 1 | Start button "when both are ready" vs instant drop-in |
| S3-02 | undecided | 2 | Guests never see the title screen; where does the "front door" work go |
| S3-03 | contradiction | 1 | "No tutorial prompts" vs the finisher prompt and live key prompts he ordered |
| S3-04 | unclear | 3 | Death tip and near-miss line were never answered |
| S3-05 | contradiction | 1 | The pad has no one-press heal; the keyboard does (P1/P2 parity) |
| S3-06 | unclear | 1 | "Coordinate P1 and P2 better": which differences first |
| S3-07 | undecided | 2 | A setting changed in one window: does the other follow |
| S3-08 | unclear | 2 | "See each other in the undercroft": demo, career co-op, or both |
| S3-09 | unclear | 2 | Which colour is player 1 and player 2 |
| S3-10 | unclear | 2 | Feedback tile in the party pause menu; the pad player cannot type |
| S3-11 | unclear | 3 | Controls tile vs F1 page vs Settings keys list |
| S3-12 | contradiction | 3 | What's New: corner card, pause tile, both, and not for guests |
| S3-13 | follow-up | 1 | How did the first real 2-player test go on stutter, sound, crash |
| S3-14 | contradiction | 1 | What a death costs in a 2-player run |
| S3-15 | contradiction | 2 | Forge price shows "$" but is paid in score |
| S3-16 | contradiction | 2 | Board: 20 rows vs the top-ten picture vs big text |
| S3-17 | contradiction | 2 | "Every gun on its own key": ten guns, nine keys |
| S3-18 | contradiction | 1 | Goals pill "hold Tab" collides with Tab, D-pad up and the raid-status peek |
| S3-19 | contradiction | 2 | Goals pill hides how-to-score from walk-up guests |
| S3-20 | contradiction | 2 | "Countdown clock needs to be bigger" vs the picked HUD (clock smaller than score) |
| S3-21 | contradiction | 2 | Ammo pips plus a ring at the cursor (cursor already carries rings) |
| S3-22 | undecided | 1 | Partner status and team score have no place in the picked 4-corner HUD |
| S3-23 | unclear | 3 | "Show all the loot": how, when the haul is huge |
| S3-24 | unclear | 3 | Career run card: where do the leaderboard and ledger go after the loot-reveal pick |
| S3-25 | contradiction | 2 | The lime: picked #c4f12e, built #e6ff3d, "most visible" is #e4ff2e |
| S3-26 | contradiction | 2 | Bounce: "livelier" and the style guide's 8% vs picks of 2-5% |
| S3-27 | contradiction | 1 | Couch-first text sizes stacked on the demo's 1.5x scaling |
| S3-28 | undecided | 2 | Frosted glass and blurred backdrops on two TVs at once |
| S3-29 | reconfirm | 1 | 34 of 36 survey picks were made on pictures a reviewer flagged |
| S3-30 | reconfirm | 3 | "Real" combat behind the title is a staged fight |
| S3-31 | unclear | 2 | Lower case vs button pictures and key caps |
| S3-32 | reconfirm | 3 | Lower case vs the logo |
| S3-33 | reconfirm | 2 | "All-in Thu to Sat" for the allowance is stale |
| S3-34 | contradiction | 2 | Is the 10-15 polish freeze still on for audio and HUD/meta picks |
| S3-35 | follow-up | 3 | Round-1 Q89 (itch page private?) was skipped with the launch section |
| S3-36 | follow-up | 1 | Which address do the party windows load on the night |

---

## A. Party start, first minutes, the two windows

### S3-01 | contradiction | priority 1 | Start button "when both are ready" vs instant drop-in
**His words**
- Survey pick q15 C, "Two ready slots" (menu-survey/answers-2026-10-18.txt, survey.json, 10-18 PM): "Two cards for Player 1 and Player 2 with a green check when each is ready; start when both are." Spec: a lime 'Start' button "at 40 percent opacity (disabled until both ready)".
- pillagers-arcade-demo-2026-10-11.md (10-11): "instant drop-in (any key or pad button on the demo video starts it; player 2 joins with A)".
- Round 1 Q27 (10-18): worst problems in order are "stutter or harsh sound; crash or freeze; P2 pad or window fails; guests can't tell how to start."
- The 2-player test sheet (build 30.70) says "Either can go first. The one waiting sees JOIN YOUR TEAM."

**What conflicts:** the picture makes a Start button that stays dead until player 2 has pressed A. The 10/11 order and the shipped game start the run the moment anyone presses. They cannot both be true. It also leaves open what a lone guest does when the second guest has not arrived (the 1-player demo is a different row, not on the party shortcut).

**Why it matters:** this is the very first thing every guest does, and "guests can't tell how to start" is on his worry list. Round 2 Q7 ("how long into a run may player 2 still join") assumes instant drop-in; if the ready-slots picture wins, Q7 is moot.

**Draft question:** "When a guest walks up and presses a button, should the game start for them right away, or wait until both players are signed in?"
a) Start right away for whoever presses first; the other player joins whenever they press A. The two cards just show who is in.
b) Wait: nothing starts until both cards show ready, then one Start press (as in the picture).
c) Start right away, but the screen first shows "player 2: press a" for 10 seconds, then goes ahead with or without them.

**Recommended: a.** It keeps your 10/11 walk-up order, never strands a lone guest, and still gives you the two-card picture as a status display.

### S3-02 | undecided | priority 2 | Guests never see the title screen; where does the "front door" work go
**His words**
- Round 1 Q50 (10-18): "Keep the normal title screen. No party version."
- Q49: "Do the raid screen first, then run-over, then title."
- Survey q11 D, q12 B, q13 C, q14 C (10-18 PM): menu column on the right, lime wordmark, "Player switch plus three rows", dark teal grade behind the title.
- Helper note tools/handoff/console/notes/05-party-launch-mode.md (v30.73): "Host with pair: title never shown (html.partyhide + display none), arcade entered at boot"; "Player 2: no title, arcade attract at once".

**What conflicts / unclear:** the party shortcut boots straight into the waiting screen (scoreboard, how-to, "press any button"). The title, which four survey picks and Q51-Q54 are redesigning, is only seen by you, on the plain address. So "no party version" is true of the title, but guests get a different first screen anyway.

**Why it matters:** the guests' first impression is the waiting screen, and the week is short. The title work is real effort for a screen the guests skip.

**Draft question:** "On party night guests go straight to the waiting screen, not the title. Where should the new logo, tagline and background effort go first?"
a) The waiting screen first (it is what guests see); the real title after the party.
b) The title first, as ordered (raid, run-over, title); the waiting screen just inherits it.
c) Both before Monday 10/26, even if that squeezes other work.

**Recommended: a.** Same wordmark, tagline and live-map background, on the screen the guests actually stand in front of.

### S3-03 | contradiction | priority 1 | "No tutorial prompts" vs the prompts he asked for
**His words**
- Round 1 Q70 (pillagers-answers-1-78-2026-10-18.md): "No tutorial prompts. The game must be completely self-explanatory." (The question defined prompts as "one-line prompts at the moment they matter (the first box, the first time you get hit, low health) that vanish after use".)
- pillagers-polish-answers-2026-10-15.md #14 (10-15): "Finisher: keep. 'i didn't see a prompt telling me how to do the finisher', so add a prompt."
- pillagers-afternoon-orders-2026-10-18.md #5 (10-18): "player should get key prompts if that is the last input they used -- xbox controller prompts should only pop up if player is actively using the controller -- e.g. real time glyph switching -- fortnite does a great job with this".
- Same 10-15 file #30, #37, #38: he never noticed events, the combo ring or power-ups, so they "need clear alerts".

**What conflicts:** a finisher prompt and live "hold e / hold x" prompts are exactly the "prompt at the moment it matters" that Q70 removed. Helper task cw-notutor (v30.50) already took the controls card off the drop. No one has said which on-screen help is still allowed.

**Why it matters:** guests have no one to ask (no cold-guest test is allowed, Q37). If every prompt goes, a guest may never find the finisher, the heal wheel or hold-to-loot; if prompts stay, they break a ruling.

**Draft question:** "Which on-screen help should stay?"
a) Only "do it now" prompts: a short hold-e-to-loot style line that appears while you stand at something you can use, and nothing that teaches or explains.
b) None at all: not even hold-to-loot or finisher lines; the how-to page is the only help.
c) The "do it now" lines, plus a one-time reminder for the three things guests miss most (heal, throwing, finisher).

**Recommended: a.** It is how Fortnite does it, it is what your live-glyph order needs, and it is not a tutorial.

### S3-04 | unclear | priority 3 | The death tip and the near-miss line were never answered
**His words**
- Round 1 Q70 options were a) both, b) prompts only, c) tip only, d) neither (a "tip" is a line on the run-over card by how you died, like "Crouch to search quietly"); his answer: "No tutorial prompts. The game must be completely self-explanatory."
- Q71 options: a) both, b) readout only, c) near-miss line only, d) neither (near-miss = "412 below your best" on the run-over card); his answer: "No live rank readout, and no scoreboard until the game is over."

**What is unclear:** each answer kills one half (the in-run prompts; the live readout). Neither says anything about the run-over card lines, which appear after the run is over. Helpers shipped the rank-readout removal (cw-noliverank) and left the card lines out.

**Why it matters:** the near-miss line is the cheapest "one more run" hook and fits "no scoreboard until it is over"; the death tip is a tutorial.

**Draft question:** "After a run, the card could add (1) a tip based on how you died and (2) a line like '412 below your best'. Which?"
a) Neither.
b) Only the near-miss line.
c) Both.

**Recommended: b.** It shows only after the run (so it respects "nothing until it is over") and gives guests a reason to queue again; a tip is a tutorial and you ruled those out.

### S3-05 | contradiction | priority 1 | The pad has no one-press heal; the keyboard does
**His words**
- pillagers-arcade-demo-2026-10-11.md (10-11), his yes to the five extras: "the one-button quick heal (D-down / G)".
- dark_raiders.html, comment on the pad wheel (his order 2026-10-14): "HOLD D-DOWN opens it (the button that was the arcade quick heal ...) ... The arcade quick heal is gone: the wheel is the only way to a heal."
- Key list in the game: ['KeyH','heal (tap), armour plate (hold)'], ['KeyG','air strike (when charged)'].
- pillagers-afternoon-orders-2026-10-18.md #6: "there seem to be a lot of inconsistencies between p1 and p2 games, please coordinate them better".
- pillagers-ten-answers-2026-10-15.md #8: "controller mapping is going to need a revamp, just do what you think is best." / "a pad revamp comes later."

**What conflicts:** player 1 (keyboard) heals with one tap of H; player 2 (pad) has to hold D-down, flick the right stick to the item, and let go, in the middle of a fight. The pad legend and the test sheet's pad table also name no melee, no armour-plate and no air-strike button, while the keyboard has V, H (hold) and G. The "pad revamp later" was never scheduled and the first-test difference table does not list any of this.

**Why it matters:** player 2 is on the pad at the party, and "pad does nothing / buttons in the wrong place" is on his worry list (Q27, third place). A guest on the pad cannot heal as fast as the guest on the keyboard.

**Draft question:** "Player 2 can only heal by opening the wheel; player 1 taps one key. How should the pad heal?"
a) Tap D-down = heal right away, hold D-down = open the wheel (the pad then matches the keyboard).
b) Leave it: the wheel is the only heal for everyone (the keyboard's H would be switched off in the party demo).
c) Leave both as they are.

**Recommended: a.** It restores what you said yes to on 10/11 and keeps the wheel, with no new button.

### S3-06 | unclear | priority 1 | "Coordinate P1 and P2 better": which differences first
**His words:** afternoon orders #6 (10-18), quoted in S3-05. The lane-h table (notes/p1p2-consistency.md, 10-18) lists 10 differences; its own rule is "both windows look and behave the same except for which player they are (number, name, colour), unless how the game works needs it".

**What is unclear:** your order does not say which differences count. The helpers' table has these open: (1) the welcome-pack window shows under player 2's waiting screen; (2) "player 2 gets none" of the RUN OVER card; (3) names over heads show "Pillager" instead of Player 1 / Player 2; (5) a "You are hosting" line in player 1's pause menu; (6) each window plays on its own copy of settings. The pad-versus-keyboard gaps in S3-05 are not in the table.

**Why it matters:** the run-over card is the last thing a guest sees, and player 2 getting nothing is the loudest gap. Time before the 10/26 cutoff is limited.

**Draft question:** "If only some of the player 1 / player 2 differences can be fixed before Monday 10/26, which group goes first?"
a) What a guest sees at the end: player 2's run-over card, names, the stray welcome window.
b) What the hands can do: the pad's heal and other missing buttons.
c) Settings: player 2 copying player 1's text size and layout (see S3-07).

**Recommended: a, then b, then c.** The end-of-run card is the thing guests will notice and screenshot.

### S3-07 | undecided | priority 2 | A setting changed in one window: does the other follow
**His words**
- Round 1 Q30 (10-18): "All settings are reachable from the demo pause menu." Q21: "TV-size text is on by default in the demo."
- Helper note p1p2-consistency.md row 6 (OPEN): "each window plays on a copy of its OWN save ... CFG dials, HUD layout and collapsed panels, kid damage, so the two windows can differ".

**What is unclear:** a guest on player 1's keyboard turns the text size or HUD size down; player 2's TV does not change. Nobody has ruled whether that is wanted. Volume is the one setting that may truly be different per TV.

**Why it matters:** the two TVs would show differently sized screens, which is one of the "inconsistencies" you complained about.

**Draft question:** "When a guest changes a setting (text size, HUD size, sound) in one window, what should happen in the other?"
a) The other window copies it at once, everything.
b) Each window keeps its own settings.
c) The other window copies it, except sound volume (each TV may need its own).

**Recommended: c.** Looks must match; volume depends on the TV.

### S3-08 | unclear | priority 2 | "See each other in the undercroft": demo, career co-op, or both
**His words:** afternoon orders #7 (10-18): "players 1 and 2 should be able to see each other in the undercroft". Helper open question (tools/handoff/console/questions.md, 10-18): "In the 2 player arcade demo the Undercroft is only a blurred picture behind the party screen (nobody walks there; a press drops straight into a raid) ... In the 2 player co-op (same machine) mode they walk the Undercroft and now see each other (v30.64). Should the arcade demo also let the two walk the Undercroft before the drop, or keep the straight drop? I changed nothing there."

**What is unclear:** which mode he meant. The first real test was the party demo, where there is no walkable Undercroft at all.

**Why it matters:** a walk-the-Undercroft lobby before every demo run would change the 10-second walk-up flow (S3-01), and it is a big job.

**Draft question:** "Should the two party-demo players walk around the Undercroft together before each run, or drop straight into the raid?"
a) Drop straight in (your seeing-each-other order applies to career co-op only).
b) A short shared lobby before every run: walk to the lamp to start.
c) Shared lobby only for the first run of the night.

**Recommended: a.** Instant drop-in is the party, and the order is already met in career co-op.

### S3-09 | unclear | priority 2 | Which colour is player 1 and player 2
**His words:** afternoon orders #6 (coordinate P1/P2). Style guide line 75 (notes/ui/style-guide.md): "Two players: focus ring tinted per player (P1 lime, P2 --ally)." Survey q15 C (10-18 PM): "left 'Player 1' ... 3px lime top bar; right 'Player 2' (3px blue top bar)". Game code: SEATCOL = ['#ffb02e' (amber), '#38d6ff' (cyan), ...]. Round 1 Q46 (10-18): "Lime yellow accent".

**What conflicts:** in the world and HUD, player 1 is amber and player 2 cyan; in the new menus player 1 is lime and player 2 blue. Lime is also the colour of "selected" and "the one main action" (style guide), so a lime player 1 looks like a selected button. Lime on the grass map is also the weakest case (survey q03 text: green limes are "the weakest against grass").

**Why it matters:** with two TVs, "which raider is me?" is answered by colour; mixed colours between the raid and the menus read as a bug.

**Draft question:** "What colours say 'player 1' and 'player 2' everywhere (in the raid and in menus)?"
a) Player 1 amber, player 2 cyan, everywhere; lime stays only for "selected" and the main button.
b) Player 1 lime, player 2 blue, everywhere (the raid rings change).
c) Keep the split: amber/cyan in the raid, lime/blue in menus.

**Recommended: a.** Amber and cyan already read well on the map; lime keeps one meaning.

### S3-10 | unclear | priority 2 | Feedback tile in the party pause menu; the pad player cannot type
**His words**
- Round 1 Q61 (10-18): "Keep the feedback line, button and Send play data."
- Survey q29 C (10-18 PM): six pause tiles including 'Feedback', "the feedback line 22px under the tiles".
- 2-player test sheet (Desktop): feedback = "pause, click FEEDBACK, type a note, and press Ctrl + Enter"; files land in exports\ via a collector program, else in Downloads.
- pillagers-ten-answers-2026-10-15.md #5 (10-15): "i don't even know what this means and don't want to worry about it right now."

**What is unclear:** in the party demo the pause menu appears in both windows. Player 2 has only a pad and cannot type a note; player 1's keyboard is also the only keyboard. "Send play data" is not explained for guests.

**Why it matters:** a guest tapping Feedback on the pad gets a box they cannot fill, and a typed note on player 1's window pauses that player. Round 2 asks how the party is captured for the debrief, but not about this tile.

**Draft question:** "Guests will see a Feedback tile in the pause menu. How should it work at the party?"
a) Show it in both windows (a pad player just cannot type).
b) Show it only in player 1's window (the one with the keyboard); pad players tell you in person.
c) Hide it for the party and collect comments by talking.

**Recommended: b.** It keeps your Q61 ruling where it works and avoids a dead box on the pad.

### S3-11 | unclear | priority 3 | Controls tile vs F1 page vs Settings keys list
**His words:** survey q29 C adds "a sixth 'Controls' tile"; survey q31 D "Tabs and one list ... Keyboard and Controller tabs"; round 1 Q70 "The game must be completely self-explanatory"; round-2 Q9 mentions the how-to-play card on the waiting screen. The game also has an F1 key list and a how-to-play page. MEMORY.md: "ONE CONTROL PER JOB - never a 2nd row doing an existing control's job".

**What is unclear:** controls would now be listed in four places (waiting-screen how-to card, F1 page, pause "Controls" tile, Settings keys list).

**Why it matters:** your own one-control-per-job rule; four copies will drift apart and need four updates.

**Draft question:** "What should the 'Controls' tile in the pause menu open?"
a) The same quick-reference page as F1 and the waiting-screen how-to (one page, three doors); Settings keeps the list for changing keys.
b) The Settings keys list.
c) No Controls tile.

**Recommended: a.** A guest wants to look, not rebind.

### S3-12 | contradiction | priority 3 | What's New: corner card, pause tile, both, and not for guests
**His words:** pillagers-fourth-fifty-answers-2026-10-13.md #37 (10-13): "The What's New card moves to a button on the pause menu." Survey q27 D (10-18 PM): "No pop-up: a small card in the corner of the hub that fades away by itself." Survey q29 C adds a 'What's new' tile to the pause grid.

**What conflicts:** the picks give two places for one job. The note is also build-by-build change text (the "five things that changed" kind), which means nothing to a party guest. Helper note: the card's stamp has to be refreshed constantly or "the card STOPs ships once it is 0.16 stale" (pillagers-sunday-start-2026-10-18.md), a recurring ship blocker.

**Why it matters:** clutter on the guest pause menu, and a maintenance cost that blocked ships on 10-15 to 10-18.

**Draft question:** "Where should What's New live?"
a) Career only: the corner card when there is news, plus the pause tile; not in the party demo at all.
b) Everywhere: corner card plus pause tile.
c) Pause tile only, no corner card.
d) Remove it.

**Recommended: a.** Guests do not need build notes; you still get your news.

### S3-13 | follow-up | priority 1 | How did the first real 2-player test go on stutter, sound, crash
**His words:** Q27 (10-18): "Worst problems, in order: stutter or harsh sound; crash or freeze; P2 pad or window fails; guests can't tell how to start." Q35: "First real 2P test: TODAY, 10/18." Afternoon orders (10-18 around 12:00-12:30) list keys, pads, glyphs, lower case, inconsistencies and the undercroft.

**What is unclear:** the afternoon orders say nothing about stutter, harsh sound, crashes or freezes, the top two worries. Either none happened or they were not reported. The test sheet asks exactly these first.

**Why it matters:** Q18 sends 75% of overnight robot time to the real 2-player setup; whether a problem is already known decides what the robots hunt for.

**Draft question:** "In your first real 2-player test, did you notice any stutter, harsh sound, freeze or crash?"
a) No, it ran smooth and sounded fine.
b) Some stutter or slowdown (tell us which window, and when).
c) Some harsh or doubled sound.
d) A freeze or crash (tell us when).

**Recommended: ask it as is.** It is a fact only he has; the answer retargets the overnight robots.

---

## B. Score and rules

### S3-14 | contradiction | priority 1 | What a death costs in a 2-player run
**His words**
- pillagers-ten-answers-2026-10-15.md, 10-16 entry, quoting his orders: "EXTRACTING should be a 2x multiplier on score, KIA should be a 50% penalty".
- Round 1 Q60 (10-18): "Ending early halves the score, the same as dying."
- Q65 (10-18): "In 2P the run ends when both players are out."
- pillagers-arcade-demo-2026-10-11.md (10-11): "On death they spawn back onto the same map."

**What conflicts:** in the code (dark_raiders.html, arcadeDied) a 1-player arcade death ends the run (so KIA -50% applies), but in 2 players a death sets that player's score to 0 ("SCORE LOST"), plays a buzz, and respawns them with a fresh kit. The 2-player test sheet even says "Die once on purpose, to see the respawn and the score reset." So a 2-player death costs all, a 1-player death costs half, and your Q60 wording says dying halves. A respawning player is never "out", so Q65's "both out" can only happen when both extract (or End run / idle).

**Why it matters:** this is the biggest swing in the party scoreboard. Round 2 asks whose fate sets the extract/burn multiplier (Q22) and what End run does (Q23), but not what a death costs. (The code tag feat0f is cited for the respawn; I could not find the ruling text.)

**Draft question:** "In a 2-player run, when one player dies and respawns, what happens to their score so far?"
a) They lose half of it, then respawn (same as the KIA rule everywhere).
b) They lose all of it, then respawn (as it works now).
c) They keep it all but wait a few seconds to respawn.

**Recommended: a.** One rule for 1 and 2 players, and a guest who dies at 3,000 points does not drop to zero.

### S3-15 | contradiction | priority 2 | Forge price shows "$" but is paid in score
**His words:** pillagers-forge-2026-10-12.md (10-12): "It is paid with RAID SCORE, the same in DEMO and CAREER." Round 1 Q59 (10-18): "$ for money, SP for score." Afternoon orders #1 (10-18): lower case everywhere. Code: FORGE_COST=[2500,6000], text "NEED $2,500", taken from "RAID SCORE ... in the DEMO (ARCADE.mine)".

**What conflicts:** the forge reads in dollars, but in the demo score is points; Q59 says these must not be mixed. It also quietly lowers a guest's board score by 2,500 to upgrade a gun.

**Why it matters:** a guest sees "$" in the demo, where money does not exist (Q55 hides credits), and may not realise the upgrade costs them leaderboard points.

**Draft question:** "In the party demo the forge costs score points. How should that look and count?"
a) Show the price in points ("need 2,500 sp") and it comes off the score, as it does.
b) Show the price in points, but the board ranks what you earned (spending does not lower your board score).
c) No forge in the party demo.

**Recommended: a.** It is your approved forge design; only the label needs to follow your $/SP rule.

### S3-16 | contradiction | priority 2 | Board: 20 rows vs the top-ten picture vs big text
**His words:** pillagers-fourth-fifty-answers-2026-10-13.md #12 (10-13): "The high score board has 20 rows." Survey q26 A (10-18 PM): "A top ten table with gold, silver and bronze bars ... plus three big letter boxes beside it." Survey q02 C: couch-first text ("menus get big and fewer rows fit"). 2-player test sheet: "A top-10 run asks for initials." Code: the party board keeps 20 (ARCADE_BOARD top:20).

**What conflicts:** the picked picture has 10 rows; the ruling says 20; the picked text size makes 20 rows barely fit. If round-2 Q46 is answered "b" (two rows per run), 20 rows holds only 10 runs of the night.

**Why it matters:** under 10 guests over 3 hours means roughly 15 runs and 30 entries; a 10-row board drops most guests off the TV.

**Draft question:** "How should the 'tonight's best' board show scores?"
a) Ten rows, big (as in the picture); the other ten are kept but not shown.
b) Twenty rows in one smaller list.
c) Two columns of ten (1-10 and 11-20), big enough to read from the sofa.

**Recommended: c.** Everyone can find their name, and it stays readable at 6-10 feet.

### S3-17 | contradiction | priority 2 | "Every gun on its own key": ten guns, nine keys
**His words:** round 1 Q78 (10-18): "Every gun on its own key." Q69 context: "The game now has ten guns: Scav Pistol, Magnum, Compact SMG, Auto Rifle, Burst Carbine, Support MG, Riot Scattergun, Longshot, Meridian Lance and Rocket Launcher." Code comment (his order 2026-10-14): "1 pistol (Scav Pistol, Magnum) ..."; 10-18 order: "get rid of the marksman rifle, move everything past it down a number, and then add a rocket launcher as '0'" ... "Key 9 does nothing." Survey q19 A (10-18 PM): "All ten key slots in a row."

**What conflicts:** the Scav Pistol and the Magnum share key 1 (the better one keeps the key, the other goes to the backpack with no key), while key 9 sits unused, and your answer says every gun gets its own key.

**Why it matters:** a guest who picks up a Magnum while holding the Scav Pistol loses a gun to the backpack with no way to press it.

**Draft question:** "Should the Magnum get key 9 so all ten guns have their own key?"
a) Yes: Magnum on 9 (ten guns, ten keys).
b) No: pistols share key 1 and the better one wins.
c) Remove the Scav Pistol once a Magnum is found.

**Recommended: a.** It is literally your answer, and key 9 is idle.

---

## C. Raid screen (HUD)

### S3-18 | contradiction | priority 1 | Goals pill "hold Tab" collides with three existing controls
**His words:** survey q21 D, "A pill that opens" (10-18 PM): "the expanded list ... with the hint 'Hold Tab' (pad: D-pad up)." Game code: "ESC, TAB and P (the pause and back-out keys)" cannot be rebound (KEYS_FIXED includes Tab); "TAB closes the box first, as ESC does"; key list ['AltLeft','raid status (hold)']; pad legend: ['DPAD UP','ping (twice: danger); hold: map'] (his order v16.46: "PING ON D-PAD UP").

**What conflicts:** Tab already pauses/backs out, D-pad up already pings (tap) and opens the map (hold), and hold-Alt already shows raid status. The picture gives all three jobs to a new "hold" of the same buttons.

**Why it matters:** a guest holding the key to see goals could pause or ping; on the pad it would clash with a button you use to call danger.

**Draft question:** "Which button should show the full goals list?"
a) Hold the same button as the raid-status peek (Alt on the keyboard; the matching pad button), so goals and status open together.
b) Hold Tab and hold D-pad up, as in the picture.
c) No hold at all: the full list stays on screen.

**Recommended: a.** Reuses a key that already means "show me how I'm doing".

### S3-19 | contradiction | priority 2 | Goals pill hides how-to-score from walk-up guests
**His words:** survey q21 D (collapsed pill 420x56: '3 pillagers 1/3 ... 186 m'). Round 1 Q56 (10-18), the question text: "The goals panel on the right (for example '6 crates +200 SP') is what tells guests how to score."; his answer: "Also hide the item-value line and the backpack hint in the demo. Keep the run goals." Q70: "completely self-explanatory".

**What conflicts:** the pill shows only the nearest goal. The list that teaches what scores sits behind a hold, in the mode that has no tutorial.

**Why it matters:** a guest who never opens the list does not learn that vaults, elites and crates score, which is the party game.

**Draft question:** "In the party demo, how should the goals show?"
a) Always open (the full list, no pill); the pill is for career.
b) The pill everywhere; guests find the list by holding the button.
c) Open for the first minute of a run, then it folds into the pill.

**Recommended: c.** Teaches at the start, then clears the screen.

### S3-20 | contradiction | priority 2 | "Countdown clock needs to be bigger" vs the picked HUD
**His words:** pillagers-fourth-fifty-answers-2026-10-13.md #14 (10-13): "10-minute runs stay. 'the countdown clock needs to be bigger'". Survey q16 A (10-18 PM): "top-centre score 48px at y54 and timer 40px at y110".

**What conflicts:** the picked layout draws the clock smaller than the score (40 vs 48). I could not confirm the clock's current size; it may already be bigger than before, but the picture makes it the second number.

**Why it matters:** the 10-minute burn is the main pressure in the raid; guests read it from 6-10 feet.

**Draft question:** "Which should be the biggest number at the top of the raid screen?"
a) The clock (and it turns red in the last minute); score below it.
b) The score, as in the picture; the clock smaller below it.
c) Both the same size, side by side.

**Recommended: a.** Your 10/13 order; the clock ends the run.

### S3-21 | contradiction | priority 2 | Ammo pips plus a ring at the cursor
**His words:** survey q17 B (answers-2026-10-18.txt): "B : ALSO KEEP/ADD RING AT THE CURSOR". Spec of B: "a row of 15 pips ... 12 lit lime and 3 dark". Round 1 Q57: "Ammo must be prominent." pillagers-polish-answers-2026-10-15.md #9, #37 (10-15): the active-reload bar needs a clear red line, and the combo ring "didn't notice it at all, so make it noticeable". Memory: ONE CONTROL PER JOB.

**What conflicts:** the cursor already carries a combo ring, a bloom ring and an active-reload ring (my code search of the style/HUD cursor layer); an ammo ring makes a fourth. And 15 pips fit a pistol, not the Support MG (about 60 rounds) or the 2-round rocket.

**Why it matters:** the cursor is where eyes are during a fight, and you complained about messages in "six different places" (10-15).

**Draft question:** "What should the ring at the cursor show for ammo?"
a) Nothing until the magazine is nearly empty, then a thin ring drains (pips stay on the bottom-right plate).
b) A thin ring that always shows how full the magazine is.
c) No ring; only the pips and the number.

**Recommended: a.** It tells you what pips cannot (last rounds, while looking at the target) without a permanent fourth ring.

### S3-22 | undecided | priority 1 | Partner status and team score have no place in the picked 4-corner HUD
**His words:** survey q16 A, "Four corners" (10-18 PM; sample is one player: "HP 100 ... score '420 SP' ..."). pillagers-fourth-fifty-answers-2026-10-13.md #10 (10-13): "In 2-player DEMO, each window shows only its own belt." Round 1 Q65 (10-18): the run ends "when both players are out."

**What is unclear:** the picked picture shows one player. Nothing says where the partner's name, health and downed state sit, or how the team score and "my score" are shown. Round 2 asks whether to alert when a partner is down and which score numbers to show, but not where any of it goes.

**Why it matters:** this is a 2-player game; every guest has a partner on the other TV.

**Draft question:** "Where should your partner's status sit on your screen?"
a) A small block under your own health, bottom-left (name, health bar, 'down' state).
b) Top-left, under the goals box.
c) Only a name tag and an arrow in the world; no block.

**Recommended: a.** Health stays in one corner, and it matches how Halo 4 shows a squadmate.

### S3-23 | unclear | priority 3 | "Show all the loot": how, when the haul is huge
**His words:** survey q25 B (answers-2026-10-18.txt): "B : show all the loot -- copious amounts of loot from an a successful extraction is an important part of the game." Spec B: "a big grid of the loot on the left with rarity glows ... card 1240x700". Reviewer note on q25-B: "the grid is empty, so the option shows nothing."

**What is unclear:** there is no rule for a haul of 40+ items, and no time limit on the reveal. The picture never showed a full grid.

**Why it matters:** show-all is only good if it stays readable and does not make guests wait.

**Draft question:** "When an extraction brings back a lot of loot, how should the card show it?"
a) Shrink the tiles so everything fits on one screen (up to about 60), then scroll.
b) Reveal tile by tile with a count-up, skippable with any button, then scroll.
c) Show the best two dozen plus "and 23 more".

**Recommended: b.** Keeps "copious" feeling big, and the skip protects the queue.

### S3-24 | unclear | priority 3 | Career run card: where do the leaderboard and ledger go
**His words:** pillagers-ten-answers-2026-10-15.md (10-15 ~08:40): "career mode should still have a leaderboard that is shown after every match -- figure out triple AAA way to integrate thisinto existing UI". (10-15 ~09:40): "stats page should account for scoring system vs haul amt -- need to reconcile the two conepts somehow in a somoother AAA manner". Built: SUMMARY ledger, then HAUL, then LEADERBOARD. Survey q25 B (10-18 PM): one card, loot grid left, "the numbers and achievements" right.

**What is unclear:** the picked card has no leaderboard step and no ledger lines (raid score, credits banked 1:1, haul value). Either the three-step card stays and q25 B is just the loot step, or the board goes.

**Why it matters:** a rebuilt card that drops your 10/15 orders without a word would be a regression. Career is after the party, so this can wait.

**Draft question:** "After the loot-reveal card, should your career leaderboard and score/haul numbers still get their own step?"
a) Yes: loot-reveal card with the numbers, then a leaderboard step.
b) Merge: one card with a 'rank 3 of 18' line, and the board only from the hub.
c) Drop the leaderboard step.

**Recommended: a.** Both are your explicit orders.

---

## D. Look and feel

### S3-25 | contradiction | priority 2 | The lime: three different yellow-greens
**His words:** round 1 Q46 (10-18): "Lime yellow accent, whichever is most visible." Survey q03 C (10-18 PM): "Lime #c4f12e ... A clearly green-leaning lime. Fresh and modern, a little less bright, and closer to the grass colour." Option B was "Volt #e4ff2e ... The brightest of the four, so it pops on dark, orange and green grounds." Style guide: "--acc:#e6ff3d" (built). The survey's own sample palette in the q16 spec uses "lime #e4ff2e".

**What conflicts:** "most visible" points to the brightest (B); the later pick is the calmer green-leaning C; the game and style guide are on a third value (#e6ff3d, almost B). The raid HUD sits on grass.

**Why it matters:** the accent is on every button, ring and number; changing it later means re-checking every screen's contrast.

**Draft question:** "Which yellow-green do you want as the main colour?"
a) The calmer green-leaning one you picked (#c4f12e), checked against the grass map.
b) The brightest "volt" yellow-green (#e4ff2e).
c) Keep what the game uses now (#e6ff3d, nearly the bright one).

**Recommended: a.** It is your most specific, latest pick; helpers check contrast on grass with pictures first.

### S3-26 | contradiction | priority 2 | Bounce: "livelier" vs the picks
**His words:** round 1 Q47 (10-18): "Livelier motion, with bounce." Style guide (notes/ui/style-guide.md line 80): "position moves use ease-out-back, c1 = 1.5, which runs 8% of the travel past home ... (his band is 6 to 10%; never above 10%)". Survey picks (10-18 PM): q28 B "Light" (5.3% overshoot, about 2.5 px), q09 B "Pop" (2%), q10 B "Springy glide" (4.6%), q32 C "Lively without a bounce". Reviewer note on q10-B: "The overshoot is only about 2.5 px on a 56 px move. It is invisible and the option looks the same as A".

**What conflicts:** all three bounce picks are under the style guide's 6-10% band, and a reviewer says the pictures showed no visible bounce. Q47 says "livelier"; q28 option C "Lively" ("Feels like Fortnite and Halo 4") was available and not chosen.

**Why it matters:** the style guide is what helpers build to and the critic scores against.

**Draft question:** "How much bounce should menus and the score have?"
a) As picked: barely visible (2-5%).
b) The style guide's 8% on cards and score pops, a softer 4% when moving between list rows.
c) The 'Lively' option from the survey (clear overshoot and punchy pops).

**Recommended: b.** It matches "livelier, with bounce" while keeping list movement calm.

### S3-27 | contradiction | priority 1 | Couch-first text sizes stacked on the demo's 1.5x scaling
**His words:** survey q02 C, "Couch first" (10-18 PM): "Smallest text 24, normal 32, titles 48, big number 96. Easiest on a TV, but menus get big and fewer rows fit." Option B "Roomy" read: "In the demo's 1.5x the small text becomes 30, comfortable from 8 feet." Round 1 Q21 (10-18): TV-size text on by default in the demo. Game: ARCADE_SBX uiScale 1.5 + menuZoom 1.25. Style guide type scale: 56/32/20/16/14.

**What conflicts:** choosing couch-first as the base and also scaling the demo 1.5x gives smallest text 36 and a big number 144. Career and the Undercroft (a desk screen, "restyle only") would also get TV-size text.

**Why it matters:** fewer rows fit on every screen, including the board (S3-16) and the stash; the choice sets the size of every screen being built this week.

**Draft question:** "How big should text be?"
a) Couch-first sizes for party screens only; career and the Undercroft use desk sizes; no extra demo scaling.
b) Couch-first sizes everywhere; no extra demo scaling.
c) The "Roomy" sizes (smallest 20) everywhere, with the demo's extra 1.5x on top.

**Recommended: c.** Gives about 30 px smallest text in the demo (the survey itself calls that comfortable from 8 feet) and does not blow up career screens.

### S3-28 | undecided | priority 2 | Frosted glass and blurred backdrops on two TVs at once
**His words:** survey q04 B (10-18 PM): "Frosted glass: See-through blurred card ... a bit lower contrast." q07 B: "Blurred and dimmed ... blur 12px". Memory: GRAPHICS PROGRAM "60 fps at 4K"; FRAME COST is wall weathering. Round-2 Q24: the raid only stops when both players are paused.

**What is unclear:** in a 2-player run one player can have the pause card open while the world keeps moving behind it, so the blur must redraw every frame, in two windows, on one PC. Nobody has measured it. Reviewer note on q04-B: the picture was "barely see-through, so it reads as A with rounder corners", so the picked look was not actually seen.

**Why it matters:** "stutter" is your #1 worry (Q27); a pretty blur that costs frames on the TVs is the wrong trade.

**Draft question:** "If the blur costs frame rate on the two TVs, what gives?"
a) Keep the blur everywhere; helpers lower something else.
b) Use a plain dim, no blur, in the party demo.
c) Blur only when the world is frozen (both players paused); plain dim otherwise.

**Recommended: c.** Looks like your pick when it is free and avoids the cost mid-fight.

### S3-29 | reconfirm | priority 1 | 34 of 36 survey picks were made on pictures a reviewer flagged
**His words:** menu-survey/survey.json "rejected" list (132 reviewer notes); 34 of his 36 picks match a flagged picture. About 23 notes are only "rendered before the lowercase rule", but these show the pick did not show what its label said:
- q04 B: "reads as A with rounder corners and does not show what the label says".
- q05 C: "The bar is thin although the option is called thick."
- q06 B: "The key caps are not really 3D".
- q10 B: overshoot "invisible".
- q15 C: Start is "a muddy translucent block".
- q19 A: belt counts "too small to read at 6-10 ft".
- q21 D: expanded list "floats ... 300 px from the pill".
- q23 D: "The edge shade cannot be seen."
- q25 B: "the grid is empty, so the option shows nothing".
- q29 C: "Two items are lime, so it is unclear which one is selected."
- q36 A: the Buy button and a disabled "need $120 more" button "appear together".

**What is unclear:** whether he would still pick the same options if he saw them properly. Helpers are building from the written spec of each pick now.

**Why it matters:** about 11 picks drive the pause menu, HUD, run-over card and board; a wrong guess costs a rebuild after the cutoff.

**Draft question:** "Some of your survey pictures did not show what their option really does. How should we handle that?"
a) Re-draw the 11 weak ones and show you only those for a second look; the rest stand.
b) Trust all 36 picks and build from the written descriptions.
c) Re-draw all 34 flagged ones and re-pick.

**Recommended: a.** Cheap, and it fixes the picks that were made blind.

### S3-30 | reconfirm | priority 3 | "Real" combat behind the title is a staged fight
**His words:** round 1 Q52 (10-18): "Behind the title, scoreboard and how-to pages: the live map, dimmed, with real pillager-vs-robot combat in it." Q54: "No attract clip. Use the live map." Helper note 03-title-and-backdrop.md: v30.69 "scripted pillager-vs-robot fight ... Cheap: 2 pillagers + robots, no sim"; "Real combat needs ... a raid sim ... Big engineering task, not started"; "4K 60fps not measured."

**What is unclear:** whether the staged fight is acceptable. The helper decided it; it is not what the words say.

**Why it matters:** this fills the TVs most of the night (round 2 describes the idle loop as the first thing guests see).

**Draft question:** "The background behind the waiting screen is a staged fight, not a real simulated one. Is that fine?"
a) Fine, if it looks like real combat on a TV.
b) No: use a real simulated raid, even if it takes until after the party.
c) Use a calm dimmed map with no fight.

**Recommended: a.** The simulated version is a multi-day job with a frame-rate risk.

### S3-31 | unclear | priority 2 | Lower case vs the button pictures and key caps
**His words:** afternoon orders #1 (10-18): "change all text shown to player to lowercase only -- i don't like how you have random words capitalized". Memory note: "Acronyms and key names go lower case too (sp, hp, esc)." Survey q06 B: "Filled icons, 3D-looking key caps and the real Xbox button colours so guests instantly know which button to press." Survey q13 C/q15 C draw "LB and RB glyph chips" and a blue 'A' chip.

**What is unclear:** pad buttons are letters printed on the real pad (A, B, X, Y, LB, RB). Lowered, a green 'a' no longer matches the pad in the guest's hand.

**Why it matters:** your own order says guests must instantly know which button to press (q06) and the live-glyph order (#5) is about matching the real controller.

**Draft question:** "Should the letters on the pad button pictures also be lower case?"
a) Everything lower case, including the pad letters and key caps.
b) Pad button pictures keep the printed capitals (they are pictures of the real buttons); key caps and all words are lower case.
c) Pad pictures and key caps both keep their printed look.

**Recommended: b.** Matches the real pad, keeps your rule for every word.

### S3-32 | reconfirm | priority 3 | Lower case vs the logo
**His words:** afternoon orders #1 (10-18), as above. Survey q12 B: "'Pillagers' Barlow Condensed 800 at 144px in lime". Round 1 Q51: the title line "Ascend. Pillage. Extract."

**What is unclear:** is the logo "text shown to the player"? The tagline now reads "ascend. pillage. extract." in the lower-case door.

**Why it matters:** the logo is on the title, the waiting screen and the store image; it is the one word that could be a brand mark.

**Draft question:** "Should the Pillagers logo also be all lower case?"
a) Yes, "pillagers", like everything else.
b) No, the logo keeps its capital P as a brand mark.

**Recommended: a.** Your rule says all; one line flips it if the logo looks wrong.

---

## E. Plan, dates, the build that runs on the night

### S3-33 | reconfirm | priority 2 | "All-in Thu to Sat" for the allowance is stale
**His words:** round 1 Q2 (10-18), his answer d: "Even, then all-in Thu to Sat." The option text: "(steady until Wednesday, then spend whatever is left on party and launch)". The allowance "refills on Sunday 10/25 at 1 am". Later answers: Q16 "There is NO public launch on 10/31"; Q14 "Lock the party build on Thu 10/29 evening"; Q15 "He stops everything himself on 10/30."

**What conflicts:** the plan puts the biggest burst on Thu/Fri/Sat, but Thursday evening the build locks, Friday everything stops, and Saturday has no launch. The peak would sit where there is nothing to spend on; the days that matter (Sun to Wed) get the "steady" share.

**Why it matters:** the week before the cutoff holds the 2-player testing and fixing; the weekly budget is already tight (MEMORY: pace the week).

**Draft question:** "With no launch and the build locked Thursday evening, how should next week's allowance go?"
a) Even to Wednesday, then a small reserve for Thu/Fri fixes you approve.
b) Heavy early (Sun to Wed), a reserve held back for approved fixes after the lock.
c) Keep it as you answered (steady, then everything Thu to Sat).

**Recommended: b.** It was the original recommendation, and the first test sessions show the most bugs.

### S3-34 | contradiction | priority 2 | Is the 10-15 polish freeze still on for audio and HUD/meta picks
**His words:** pillagers-polish-before-more-2026-10-15.md (10-15): "FREEZE new-feature work until the polish pass is done. That covers the 100-pick batches B6 audio, B7 visuals, B8 heat/nemesis and B9 HUD/meta, plus #14 elemental combos." Round 1 Q5 (10-18): "Do a, b, c and d all this week", where d = "Extras you said yes to" (rise from underground, light shafts). Q17: "After the rehearsal, switch off janky raid features rather than polish them." 100 picks (10-14): audio picks 69-74 (for example space-aware gunfire, pitch-climbing kill chain, late-night audio mode) and 48 "share by drop" (goes in B9).

**What conflicts:** Q5 lifted the freeze for some B7 visuals; round 2 R1-R3 re-asks heat/nemesis, combos and the looks-only extras, but nobody has said whether the audio batch (B6) and the HUD/meta batch (B9) are still frozen. B9 touches the HUD being redesigned this week (Q57). I could not check which of these already shipped.

**Why it matters:** each late new thing can turn into the "more fun but janky" problem you called out on 10/15.

**Draft question:** "Are the audio batch and the HUD/meta batch (pings, share by drop, extra HUD pieces) still on hold until after the party?"
a) Yes, both on hold.
b) Audio may go in before Monday; HUD/meta stays on hold.
c) Both may go in before Monday, inside the HUD redesign.

**Recommended: a.** The HUD is being rebuilt, and a week is short; "harsh sound" is handled by a loudness pass, not new sounds.

### S3-35 | follow-up | priority 3 | Round-1 Q89 (itch page private?) was skipped with the launch section
**His words:** pillagers-answers-1-78-2026-10-18.md: "Questions 79-95 are skipped." Q89 text: "Every new version, even one with a half-finished screen, is uploaded to your itch page automatically. I opened the page the way a stranger would and it asks for a password ... Only you can confirm that is the setting you chose". Q38: "No secret link." Q37: "No new people before the party." tools/PUBLISH.md says: "Visibility: Restricted (secret URL)".

**What is unclear:** 79-95 were skipped because the launch moved, but Q89 is not about the launch date; it is the only thing between half-finished builds and strangers, and uploads continue every build.

**Why it matters:** "no new people before the party" is only true if the page is really private.

**Draft question:** "Is your itch page set to private, with a password or restricted link?"
a) Yes, private; uploads are fine.
b) It is public; stop the uploads.
c) Not sure; pause the uploads until you check.

**Recommended: a** if he confirms; otherwise c until he checks. (The helper saw a password box.)

### S3-36 | follow-up | priority 1 | Which address do the party windows load on the night
**His words:** round 1 Q12 (10-18): "Tag builds as stable or intermediate, and his play window always loads the latest stable." Q14: "Lock the party build on Thu 10/29 evening." pillagers-sunday-start-2026-10-18.md: "localhost:8802 serves the repo file live." MEMORY: "NEVER the play port ... :8802 is his". tools\party\party.cfg: URL_BASE=http://localhost:8802/dark_raiders.html. 2-player test sheet: "stable.html on the same address is steadier but older (currently 29.09)".

**What is unclear:** the party shortcut points at the live play address, which follows the newest build, not at a frozen copy. A lock that is only a tag will not stop a late helper ship from reaching a reloaded window (a reload happens automatically after any leave/crash, up to 4 per 30 seconds, per note 05-party-launch-mode).

**Why it matters:** the lock exists so nothing changes on party night; today a reload mid-party could pick up a new build. Round 2 Q81 asks what helpers may change after the lock; this is the mechanism it relies on.

**Draft question:** "On party night, should the two windows load a copy that cannot change?"
a) Yes: a frozen copy made Thursday evening, at its own address; helpers cannot change it by accident.
b) The normal play address, but only tagged stable builds are allowed to appear there after the lock.
c) Leave it as it is now (the live address).

**Recommended: a.** Cheapest guarantee that "locked" means locked.

---

## Round-2 premise problems (round 2 asks something already settled or now false)

- **Q7** ("How long into a run may player 2 still join?") presumes instant drop-in; his survey pick q15 C (Start when both are ready) conflicts. See S3-01.
- **Q9** (printed controls card) says "The game already shows a controls card for a few seconds as each raider drops in". cw-notutor (v30.50) removed it: arcadeCardOn() returns 0. The how-to page on the waiting screen and F1 still exist.
- **Q10** ("Who records the idle loop clip?") presumes a clip. His Q54 answer was "No attract clip. Use the live map." (the 10-13 #11 "The attract video stays" is reversed).
- **Q32 option b and Q34** ask for someone who has never seen the game; Q37 was "No new people before the party." Either the question should note it re-asks Q37 or it should drop those options.
- **R3** (rise from underground, light shafts, slow motion): Q5 d already asked for "extras you said yes to" this week, and the question itself says the git log shows the first two are in. Only slow motion is open.
- **Q46** (one row per pair) correctly cites his Q62; it is the shipped code that conflicts (note cw-iniplayer: "board shows 'ABC . XYZ'"). No error, but it affects S3-16.

## Dropped (near-duplicates or already settled)

- "Halloween dressing" (10-11 order): removed by his 10-12 answer 22, code comment v23.6x nohallow: "no halloween dressing, forget and remove this concept."
- 1/2-player title switch (q13 C) vs the P2 join slot: consistent once read as title-only (operator) vs window state (guest). Folded into S3-01.
- Random raider look vs P1/P2 identity: the code already builds a random look each run and keeps it through respawns (arcadeLook); seat colour is S3-09.
- Fair board vs vault-gun luck (Q67 vs Q68): he picked both knowingly.
- Cold-guest test: overlaps round-2 Q32/Q34 (see premise list).
- Heat dial / nemesis, combos, looks-only extras, Experimental settings, missions, "coming later" row, empty board: round-2 R1-R7. (Round-1 Q96-100 were exactly R1-R5.)
- Window crash, mouse leaving the window, pad on a cable, one-TV shortcut, sound split, hold of unpaused partner, who gets kill points, end-of-run wait screen: round 2.
- Stop list on 10/30 (Q15): exists (party-stop.ps1, party-day-stop-list.md); stable definition (Q12): exists (stable.sh).
- "Settings out of reach" vs Q30: already resolved by him (Q30 overrides Q28).
- Easy mode timing: round-2 "When should Easy mode be offered?"; code asks after the second death.
- Alert pills (q22 C) vs the helper HUD spec "one alert plate": spec is the helpers', not his; the feed placement is consistent with his "left middle or bottom".
- "Q18: how much raid code do 1P and 2P share": answered in the test sheet (about four fifths).
- "Lowercase his own edited lines": covered by Q8 (helpers may shorten or delete lines, with a logged reason); the display door does not change the stored keys.

## Helper-only notes (not for the owner)

- tools\party\party.cfg has URL_OPTIONS=0 while notes/05-party-launch-mode.md says the shortcut needs URL_OPTIONS=1; check the shortcut really opens both party URLs.
- Pair code is [a-z0-9]{4,16}, so the lower-case door is harmless there; check any mixed-case invite code shown to players (online invite) survives ncFix.
- Fuzz robots (tools\fuzz.ps1, fuzz-pad.js) still use a fake pad on slot 2; with cw-p2pads (first pad = player 2) it must be slot 0.
- Style guide (notes/ui/style-guide.md) tokens to update after answers: --acc, bounce c1, type scale, P1/P2 ring colours.
- Old checks that pin the title scrim at 95% and the mode-row arrow order are stale; the corpus will keep failing until retargeted.
- Test the two-window link with the network off (the undercroft body uses WebRTC; the link takes about 6 s with STUN, longer if slow).
- Memory note "an edited line is a key - never reword his edits" is now contradicted by his Q8 answer; update the note.
- Check melee, armour plate and air strike on the pad (not in LEGEND_PAD or the test sheet's pad table).
- The 2-player test sheet says stable.html is 29.09; refresh it before the rehearsal.
- Critic scores at v30.59-v30.69: screens 21 and 50 scored 2, title 3 (target 4 everywhere).
