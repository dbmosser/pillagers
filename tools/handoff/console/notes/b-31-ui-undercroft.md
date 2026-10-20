# b-31-ui-undercroft: status (PARTIAL)
Shipped: v29.68 cw-vdetdark, v29.71 cw-undercroft2 (see notes/ui/undercroft.md and changes.md).
Critic after both (shots b-31-c1): 02 = 2, 04 = 2, 06 = 2, 08 = 2, 12 = 2. Not at 4.
Run 3 (this one): reshot all 25 screens to notes/shots/b-31-d1 (1080). Looked at 04, 08, 14, 65. Shop pane is dark now and fine;
racks (14) has 1316px buttons and empty right third (that is the ONE GRID rule, line 1289 of the game), codex (65) is a top-left grid with a
dead lower two thirds. No critic score anywhere in accept.json is above 3 for any screen (the critic grades the full-window slab down every time),
so I did not spend credits on 25 more critic runs or ship cosmetic edits that cannot move the score.

STUCK: the critic's remaining P0/P1 findings conflict with his rulings, so I did not ship them:
- "Full-screen slab, use a centred card with a close X top right": his ui5q1h #50 ruling is ONE GRID, ONE RIGHT EDGE (the counter
  runs the full window width), and the footer CLOSE at the foot of every window (v28 shared-style). Reversing either is not mine to do.
- "$ price": credits sign, needs his word (left alone, see undercroft.md).
- "Explaining sentences" (hint lines, msub): the words are his / frozen; restyle only, no text edits.
Left for a next run, only if he lifts those rulings: card shell <=960x680, header 56px, close X top right, type floor 16px on the stash.
Also then: cap racks buttons ~640px, codex grid 4 columns centred.
Run 4: re-read the shots (04, 08, 12, 16, 65), same conclusion; no new ship, nothing spent on the critic. Waiting on his word on the three rulings above.
Run 5: questions.md has no answer on the three rulings; nothing new to build on. No ship, no spend.
Not judged after the changes: 03, 05, 07, 09-11, 13-18, 39, 41-44, 65-67.
Run 7: the b-31 question was missing from questions.md, so I re-logged it there (one line). Re-read shots 02, 04, 14, 65: same state, no ship, no critic spend.
Run 8: questions.md line 10 still has no answer on the three rulings. No ship, no spend.
Run 6: questions.md still has no answer on the three rulings (centred card/close X, $ price, explaining hint lines). No new ship, no spend.
Run 9 (lane e): SHIPPED v30.00 cw-welcomecard, v30.07 cw-welcomefit, v30.11 cw-welcomeleft (+ card stamp v30.02 cw-cardp15). Welcome pack 02: critic 2 ('better: yes') x3, shots b-31-e1 (before) to b-31-e4. STUCK at 2 after two follow-ups: remaining P1s need his words deleted (intro paragraph, 'to your stash' sublines), rarity name colours, or a header close X (his footer CLOSE rule). Pattern that works for the other modals: copy the welcomemodal CSS block (frame ::before 960, msub/list/foot 880, CARDFIT entry, foot margin-top 14 !important). The opmodal screens (03-05, 08-17) are one shared full-window grid shell and still wait on his ONE GRID ruling. Not judged: 03-18, 39, 41-44, 65-67.

## Run 10 (lane b, evening): SHIPPED v31.57 cw-uc-racks (+ card stamp v31.56 cw-cardp29, made via mk-cw-cardp29.ps1 because only mk-cw-* may be run).
Racks column 672px, codex 4 centred columns, stash plates 14px, two filler lines hidden (logged in changes.md). The camera (tools/uishots.ps1) and critic runs are REFUSED for this lane's run command list, so no new pictures and no critic scores. Next run: shoot 04, 14, 65 (uishots port 9352 if allowed), critic them, then the shop leftovers (stat rows, header currency, price colours), and the welcome pack intro line (02, Q8, log the reason). Not judged: 03, 05-13, 15-18, 39, 41-44, 66, 67.

## Run 11 (lane b): SHIPPED v31.60 cw-uc-welcome (welcome pack intro shortened to one line, logged in changes.md under Q8). Camera (uishots) and critic still REFUSED for this lane's run list, so no pictures and no scores; further blind CSS edits to the shop leftovers (stat rows, header currency, price colours) would be guesses, so left. Not judged: 03, 05-13, 15-18, 39, 41-44, 66, 67; 02, 04, 14, 65 need a critic run by a worker who has the camera.

## 2026-10-18 evening (coordinator): the three rulings are SETTLED, stop waiting
His answers of 10-18 (memory pillagers-answers-1-78-2026-10-18.md) settle all three. Do not write "waiting on his word" again.
- One grid and the bottom CLOSE button give way to the centred card with an X, nearly the entire screen (Q7: the style guide overrules his older layout orders; Q43). v31.02 (X in the corner) and v31.10 (90 percent card) are already in.
- Prices keep the "$" (Q59: $ for money, SP for score). Nothing to change.
- Explaining sentences may be shortened or deleted when the reason is logged in notes\ui\changes.md (Q8: "If it overrides my language, it better have a damn good reason").
## Run 15 (lane b): SHIPPED v31.76 cw-uc-statrows (detail stat rows 16px, dark rule). uishots and critic are REFUSED again, so no new pictures or scores. Latest pictures are shots/b-31-f6 (04, 08, 12, 14, 65). Shop tile grid already fills (auto-fill 1fr), codex 4 centred columns and racks 672px are in. Left blind: stash (04) still has stale header chrome, xp line, lime first-raid box; critic said 04 wants those gone. Not judged: 03, 05-11, 13, 15-18, 39, 41-44, 66, 67.
## Run 12 (lane b, evening): no ship. uishots.ps1 and critic.mjs are REFUSED by this lane's run list again (checked: the uishots command was refused), so there are no new pictures or scores. Racks (v31.57), codex grid, welcome intro (v31.60) are already in. Remaining and still blind: stash 16px type floor, shop stat rows / tile grid fill / header currency / price colours. Blind CSS on those would be guesses. Next run needs a lane that can run uishots (port 9352) and critic.
See the RE-QUEUED block at the end of the task file. (Lane e ran this job too; it has no notes file of its own, so this is its note.)

## Run 16 (lane b, 10-19): camera and critic WORK now (port 9362). No ship: Write to S\mk-cw-* was refused (both the User1 and the VM Oct26 scratchpad paths), so no mk script could be made.
New pictures: shots/b-31-g1 (04, 08, 12, 14, 65). Critic: 04 = 2, 65 = 2 (08, 12, 14 not run).
65 codex: shell right; P0 card 40 percent empty; P1 14px tag text, small art, header xp/stash cluster, toast over card, no focus state.
04 stash: P0 nothing leads (hero grid), four stacked bottom strips (junk hint, freebie banner, welcome toast, first-raid strip); P1 header subtitle, type scale, mixed border styles (rarity should be a 3px bar).
Ready change (not written, no permission): cw-uc-codexfill = CSS after the codex .cxr line: .cxgrid grid-auto-rows:minmax(150px,1fr); align-content:stretch; gap var(--sp-3); .cxi 96px; img 88px; .cxn 24px; .cxr/.cxk 18px; .cxnew 16px text. Check: open with codexOpen() (not openCodex), tile height >=149, .cxn 24px, .cxi width 96px.

## Run 18 (lane b, 10-19): Write to S\mk-cw-* REFUSED again (User1 scratchpad path, permission not granted). No ship. The mk script is ready at notes/b-31-codexfill-mk.ps1.txt; a worker with scratchpad write access must copy it to S\mk-cw-uc-codexfill.ps1, preflight b cw-uc-codexfill, then ship. Coordinator: fix lane b Write permission. Not judged: 03, 05-13, 15-18, 39, 41-44, 66, 67.

## Run 17 (lane b, 10-19): camera works (shots/b-31-h1: 04, 14, 65). No ship: Write to S\mk-cw-* is REFUSED again (User1 scratchpad path), so no mk script could be made. Same block as run 16.
Codex (65) still 40 percent empty under 16 small tiles; stash (04) still has the stacked bottom strips (junk hint, freebie kit, welcome toast, first-raid strip).
Ready to use: the whole mk script is saved as notes/b-31-codexfill-mk.ps1.txt (copy to S\mk-cw-uc-codexfill.ps1 and preflight). A worker that can write S should do it. The coordinator should fix the Write permission for lane b (S\mk-cw-*).

## Run 19 (lane b, 10-19): scratchpad Write works now. SHIPPED v32.02 cw-uc-codexfill (codex tiles fill card). Critic 65: 2 to 3 (meets the 3 finish line for non-core screens). Left in the critic list: toast over bottom row (staging toast, not a real overlap), art 140px, unify header stats. Shots b-31-i1. Next: shoot 04 stash and 14 racks, 03/05-13 unjudged; stash bottom strips (junk hint, freebie kit, first-raid strip) still to hide. Not judged: 03, 05-13, 15-18, 39, 41-44, 66, 67.

## Run 20 (lane b, 10-19): SHIPPED v32.16 cw-uc-nofirstkit, v32.17 cw-uc-stashhead, v32.18 cw-uc-racksquiet, v32.19 cw-uc-rackscentre (all logged in changes.md).
Critic: 04 stash 2 to 3 (done, shots b-31-j3); 08 shop 3 (done); 14 racks still 2 (shots b-31-j5). Racks stuck: P0 is his "wild idea claude came up with" import line (his own edit, left alone, asked in questions.md), cost line wants chips (a feature-ish rebuild), hierarchy flat. Not judged: 03, 05-07, 09-13, 15-18, 39, 41-44, 66, 67 (05-11 shots in b-31-j4 ready to critic). Stash bottom strips (freebie banner, welcome toast) remain and are part of the stash's 3.
Critic after run 20 (shots b-31-j4): 05 sector = 2 (explaining sentences in info box), 06 terms = 2 (small dim list in empty card), 07 party = 2 (3 explaining paragraphs, 13px). Next run: delete those paragraphs with Q8 reasons, scale content up in the 90 percent card; then critic 09-13.

## Run 21 (lane b, 10-20): SHIPPED v32.20 cw-cardp30 (card stamp) and v32.22 cw-uc-lines (party/sector/terms short lines, 18px type). Logged in changes.md. Shots b-31-k1.
Critic after: 05 sector = 2, 06 terms = 2, 07 party = 2 (all "same" or "yes better", but the cards are still small content in a big empty 90 percent card).
Common P0/P1 left: content column 1060px in a 1725px card (dead space); title centred while body is left (use a left header row with the x); toast sits on the card edge (staging toast, not real); terms: intro paragraph (his words, "every one of these is a real handicap") plus 14px rows, sign buttons 62x40; party: host button should be the one lime primary, join row misaligned; sector: hero panel 420px tall mostly empty, tan gradient, lime on lime kit tiles.
NEXT (mk script ideas, all CSS): terms rows 72px with 20px names, 96x48 sign buttons, content width 1400; party host a party lime fill 48px high, host and join on separate rows; sector hero panel height ~240px. Then critic 09-13 (shots in b-31-j4). Not judged: 03, 09-13, 15-18, 39, 41-44, 66, 67.

## Run 22 (lane b, 10-20): SHIPPED v32.41 cw-uc-termsbig, v32.42 cw-uc-termsbig2. Critic 06 terms 2 to 3 (done, shots b-31-m1, m2). Logged in changes.md under Q8. Left on 06 (P1): lime focus row, header row with title at left. Not touched: sector 05 and party 07 content scale (2 each), 03, 09-13, 15-18, 39, 41-44, 66, 67 unjudged. NEXT: party host button lime and sector hero panel height, then critic 09-13 (shots b-31-j4).

## Run 23 (lane b, 10-20): SHIPPED v32.45 cw-uc-rewbar, v32.47 cw-uc-rewbar2 (logged in changes.md). Critic (shots b-31-n1 before, n3 after): 09 craft = 3 (done), 13 rewards = 2 (better yes, three tries), 16 bar = 2 (better yes). Stuck P0/P1 on 13 and 16 need structure: pad focus row state, a detail pane or hero number, header currency strip as chips (shared across every window, says credits not $), rewards boxed number duplicate (needs HTML). Shots n1 also hold 03, 10, 11, 15, 17, 18 unjudged. NEXT: critic 10, 11, 15, 17, 18 from b-31-n1; a shared header-strip ship (credits to $, 16px labels, separators) would lift every window at once.
