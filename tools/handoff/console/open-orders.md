# open-orders: every feature he asked for that is not in the game yet

One list, kept outside the chat (his feedback 10-27: orders were dropped in a summarized chat). Update it when he gives an order and when one ships.
His priorities: https://claude.ai/artifact/8mXPSJ5fqq5DiV1Mxsy8Xr (db "answers"; ids and text in notes/priorities-page.html). All 100 items answered Tue 10-27 by about 20:08. Everything he marked NEVERMIND (44 asks) is listed in memory pillagers-nevermind-list-2026-10-27 and its job files are in console/cut. Do not bring those back.
No HIGH items left except 177 hardcore save (parked until 11/1, goes first then).

## His 10-27 orders (all MEDIUM; the VM PC - Pillagers Dev chat is archived 10-27 22:20, the CEO chat follows these up)
- Date and time (US Eastern) next to the version (cw-verat). SHIPPED v35.24.
- Active reload stacks, sweet spot shrinks each stack. SHIPPED v35.27.
- Extracted screen shows guns first. SHIPPED v35.29.
- White bars gone everywhere (v35.12 did shop, craft, wirt only). Dropped twice; found by the CEO chat 10-27 22:20, SHIPPED v35.40 (in-session job 199, now in done/); the pickup stack and loot pop labels keep theirs on purpose.
- More ammo boxes when out of ammo. SHIPPED v35.26.
- Drag items from the wheel onto the hotbar; a belt item works like a wheel pick (in-session/185). SHIPPED v35.25 + v35.28, on his PC 20:26.

## His 10-27 evening orders in "Gameplay Edit Intaker" (was "Game feature requests and edits"; job files in console/in-session/; ids there are chat ids, not the tasks/ numbers)
- "recovering to 85" icon lies in Superhot (184). SHIPPED v35.22, on his PC 20:01.
- Quiet hud, all 5 changes. 186a text lanes (no double lines, concealed icon, extraction word up top) SHIPPED v35.30/31/33, on his PC 21:18 (as 35.34). 186b panels (one money number, hide at rest, gun name once) SHIPPED v35.36, on his PC by 21:35 (he reports 35.37).
- Plain title backdrop, no robots in the Undercroft (187). SHIPPED v35.34, on his PC 21:15. The robots were the title fight from his 10-18 Q52/Q54 answers; his 10-27 order reverses them.
- Superhot off at every start (188). SHIPPED v35.32, on his PC 21:10.
- Extraction: no pop back up before the extracted card (189-extract-no-pop-up). SHIPPED v35.37, on his PC 21:35.
- His complaint 10-27 ~21:25 (verbatim): "I am worried your quiet hud shit isn't actually addressing my complaint, which is that there are too many messages coming in to the player". He is right: the quiet hud cut copies, not the number of messages. The game has 338 say() call sites. Proposal sent: only 4 kinds reach the screen (danger to you now, extraction, your teammate, money or a contract done), one pickup row per search instead of per item, a rate cap; everything else stops showing. His answer (verbatim): "Ok? I don't know. You need to figure out what works". Decided and building as in-session/186c-fewer-raid-messages.md (5 kinds: the 4 plus refusals of his own input), in the quiet hud part A session, 21:30. 21:35 his words: "I feel like you are just fucking it up worse. I really like how looting feels and looks": the one-row-per-search pickup change is DROPPED; looting is never touched by this job.
- His ask 10-27 ~21:40 (verbatim): "Can you do some real research on best practices in player alerts and messaging in terms of screen location etc and try to apply that to our game?" Research running in his orders thread; 186c is HELD before shipping (it finishes the message list and the before count) until the research sets the rule. Then (verbatim): "Everything about this game needs to be AAA and right now all the messaging on the hud is a clusterfuck". Research: 5 tracks (attention science, accessibility and sound, AAA shooter case studies, top-down games, notification systems), notes in research_notes/Player alerts and HUD messaging/, report to reports/. Report done 22:05, sent to his phone (reports/Player alerts and HUD messaging.md). Turned into jobs: 186c unheld with the research rule, 2 builds (cw-msgroute: five kinds, feed 3 lines 5 s, rate cap; then cw-dangerslot: danger banner to about 27% of screen height, one at a time, downed card check); kill lines stay (his g-86), looting untouched. 186e (in-session/, starts when cw-msgroute is on his PC, Sonnet): states as icons, extraction on the top pill, a small answer line under the character, text at readable size. Sounds per kind and message settings parked as after-nov1/198. The move-left question (a or b, picture on his phone) stays with lane d; the research says either is safe once urgent lines leave the left.
- Left side: his note "nope, i was trying to say that all this shit moves to the left": the whole cluster moves left, not only the F1 list. Passed to the VM PC chat to show him a picture first; he picked option a, SHIPPED v35.35 (f1 list and feed lines on the left).

- His note 10-27 ~22:25 with a belt picture (verbatim): "the higher white bars need to be removed as they are not helpful". These are the cream rarity pips (same bars as "White bars gone everywhere"); SHIPPED v35.40 with job 199 (belt included); the lower thin bar on each belt slot stays.

- His order 10-27 ~22:35 (verbatim): "the game is telling me about extraction b when it is happening far across the map from me." The "extraction X closing / closed" lines fire for every exit on the map. Added to 186c build 1 (cw-msgroute): exit lines only for the exit you are heading to or one within about 60 m; the rest stay on the map and pill.
- His order 10-27 ~22:40 (verbatim): "mousing over different items in the stash is a complete clusterfuck because it changes the size of one of the sub menus". Job in-session/200-stash-hover-no-resize.md, session stash-hover (Sonnet high) started 22:45. SHIPPED v35.42 (daf166dce, ON HIS PC): the item line under the stash grids is one fixed 160px box, hover or not, so the backpack, hotbar, gun keys and grids no longer jump; job moved to console/done/.

- 10-27 ~23:10: a fresh successor order chat "Gameplay Edit Intaker 2" (Sonnet high) was proposed to him as a card (the cost seat asked; this chat is long). Until he starts it, "Gameplay Edit Intaker" keeps taking his edits. Open here: 186c (HUD Improver session, build 1 then build 2) and 186e (start after cw-msgroute is ON HIS PC).

- 10-27 ~23:20: the Auditor cloud session sent two ready bug fixes on branch claude/audit-2026-10-28 (df251088): draft-cloud-ach-born-scan (a new save counts every kill twice the first time its stats page opens) and draft-cloud-p2-easy-card (player 2 never gets the easy mode card). Plus tool changes to merge. Not shipped yet: it came from another session, not from him; asked him in game words for a yes.

## Queued now in tasks/ (fix, polish or tuning; priority line in each file)
- MEDIUM: 139 solo pings; 140 red enemy tracers; 145 pad sprint toggle default; 151 damage numbers merge, yours red; 152 alarms volume row, low mag tick; 163 last minute ash and red glow; 165 partner row gun and ammo; 166 kill feed icons; 186 buildings read as house, office, warehouse in the smooth look; 03 title screen redesign, 94 60 fps on a 5 year old laptop, 95 2 player smooth on both TVs (re-queued from failed/, stop if the old blocker stands).
- LOW: 146 overseer ignores decoys; 131 sound cap; 187 impact puffs by material; 188 outline order; 189 a dead window recovers; 190 players pass through each other; 191 first demo fight at 15 to 20 s.

## Parked until Sun 11/1 (after-nov1/; release order in its README)
- HIGH: 177 hardcore save.
- MEDIUM: 120d2, 141, 142, 147, 149, 153, 154, 161, 172, 175.
- LOW: 144, 148, 150, 155, 156, 157, 158, 162, 169, 171, 174, 178, 182, 192, 193, 194, 195, 196, 197.
10-28 extracted card: "this extracted screen is an absolute mess -- money versus raid score/sp should never be intermingled" -> cw-spmoney (Menus master draft), shipping 10-27 night

- 10-28 00:0x: 186c build 1 (cw-msgroute) ON HIS PC v35.44 (his 8802 serves 35.45): lines in a staged 3 minute raid, 43.3 before, 30 after. Build 2 (186d danger slot) is now a lane job, tasks/186d-danger-slot.md. 186e started as its own helper on Opus high (job file updated); order chat "Gameplay Edit Intaker 2" took over from the old intaker at 23:1x.
- 10-28 186e build 1 (cw-hudstates): SHIPPED v35.49, ON HIS PC 23:56 (10-27). Revealed, hidden and in cover are small icons beside the stance chip; low health pulses the hp bar; low ammo pulses the count red; an empty gun shows the reload key on the gun card.
- 10-28 186e build 2 (cw-extpill): SHIPPED v35.50, ON HIS PC 00:03. The extract pill turns amber with a last minute countdown when its exit is closing (red when shut, one pulse per change); an exit just off screen is an edge arrow "c 152m"; the sky is a small icon beside the clock.
- 10-28 186e build 3 (cw-answerline): SHIPPED v35.52, ON HIS PC 00:12. A try that did not work (health full, throw blocked, too tired to roll) answers in one small line under the character for 2 s, once per press; backpack full stays in the pickup stack.
- 10-28 186e build 4 (cw-hudsize): SHIPPED v35.53, ON HIS PC 00:23. Feed and answer line at least 20 px, the opened controls list 18 px, danger headline 30 px; red words on a plate are a lighter red for contrast. Job file in console/done/.

- His order 10-28 (verbatim, via the old intake chat): "make it 3000 damage to unlock an airstrike instead of 1500". Job in-session/201-airstrike-3000.md, helper (Sonnet high) started by the order chat.
SHIPPED 10-28 v35.66: 201 air strike needs 3000 damage (was 1500). On his PC 168s after the ship.

- His order 10-28 (verbatim): "Ok here's the edit. When the player makes the game harder in any way in the settings (eg number of enemies, number of pillagers, damage taken, etc, that should give a score multiplier (maybe an additional 5% for each tier/level) and that should be indicated to the player. Super hot off should be considered harder and should also give the multiplier. All these multipliers should stack. Eg if player wants to play a really hard game, that should give more points." A new feature, so PARKED until Sun 11/1: console/after-nov1/202-difficulty-score-multiplier.md (Opus high, goes to tasks/ on 11/1, first in line). Told him.
- 10-28 his answer on the multiplier (verbatim): "No I want it now". Hold lifted by him: job 202 moved from after-nov1 to in-session/, helper (Opus high) started now.
- His standing order 10-28 ~08:10 (verbatim, via the CEO chat): "I don't want any development paused or delayed because of the party or any other anticipated date. Just keep developing". Ends the Nov 1 freeze; the order chat files every order straight into tasks/ or in-session/, never after-nov1.
