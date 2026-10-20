# p1p2-consistency (lane h, task cw-p1p2), started 2026-10-18, closed the same evening (builds v30.84 to v31.15)

HIS ORDERS (2026-10-18, verbatim, from his first look at the two-window game):
- A) "there seem to be a lot of inconsistencies between p1 and p2 games, please coordinate them better"
- B) "players 1 and 2 should be able to see each other in the undercroft"

THE RULE: both windows look and behave the same except for which player they are (number, name, colour), unless how the game
works needs it (the host window runs the world).

## How I looked (so a later run can repeat it)
- Real two-window harness (a lane-h tool, not in the repo): scratchpad\h\h-lib.mjs, h-aud.mjs, h-arc.mjs, h-two.mjs, h-strip.mjs,
  h-cfg.mjs, mkfix.sh. It starts headless Chrome on port 9368, serves a copy of tools\fixture.html with one extra hook
  (window.__xx = eval inside the game closure) on 127.0.0.1:8869, opens TWO windows (host + ?p2=1&mode=coop&pair=CODE&arc=1),
  links them as a real same-machine pair (netSamePick without window.open, then the real WebRTC handshake, it links in about 6 s),
  then drives the arcade and takes a picture of each window. Run: `bash mkfix.sh` (rebuilds the copy), then
  `HMODE=arcade node h-aud.mjs OUTDIR` (or `node h-two.mjs coop OUTDIR`, `HMODE=arcade node h-strip.mjs OUTDIR`).
- Pictures: notes\shots\p1p2-before (single window), p1p2-two-coop, p1p2-two-arc (first look), p1p2-after (v31.01),
  p1p2-strip, p1p2-final (v31.15, the last look).
- FINDING THAT SHAPES JOB B: the Undercroft ALREADY drew the other player over the WebRTC link (v15.75, netHubTick,
  netDrawPeers, netDrawPeer, netDrawTags); in the real two-window harness both windows listed the mate as shown. It was not
  enough: (1) both windows arrived at the same spot (140,390), so the mate stood exactly under your own raider and was invisible
  until someone walked; (2) it needed the WebRTC link (about 6 s after the pick, longer if the STUN servers are slow), while the
  pair channel is up at once; (3) in the arcade demo the Undercroft is only the blurred backdrop of the attract page.

## Differences found (most visible first). status: DONE vN / OPEN / BY DESIGN
| # | where | what differed | fix | status |
|---|-------|---------------|-----|--------|
| 1 | arcade attract, player 2 window | on a fresh player 2 save the WELCOME PACK window opened under the party attract and was what showed through the blur (player 1 showed the Undercroft). The window clear at the top of arcadeEnter ran BEFORE NET.start() opened the pack (ARCADE.on was still 0 then, so firstRunNext let it open); cw-partyclear (v29.9x) and cw-partystats did not cover that order | clear the windows once more after arcadeSandboxIn for player 2 | DONE v31.11 (cw-p1p2clear) |
| 2 | run over, player 2 window | player 1 got the RUN OVER card (team score, kills, extractions, deaths); player 2 got none (arcadeEndTake only tore the raid down) | arcadeOverMirror builds ARCADE.over on player 2 from its own score and the host score when arcend arrives (x2 for an extraction, half for a death, player 1 on top) | DONE v30.98 (cw-p1p2over) |
| 3 | names over heads, HUD teammate bar, feed | the roster held each save name (made at link time, before the arcade sandbox set PLAYER 1 / PLAYER 2), so a mate showed as "Pillager" or his save name | in the arcade a seat is Player 1 / Player 2 in netSeatName | DONE v30.88 (cw-p1p2names) |
| 4 | Undercroft (co-op same machine) | both arrived at 140,390: the mate hid under you. The body needed the WebRTC link; the pair channel was not used | job B: pair channel words hubmate / hubgone (v30.84) and player 2 arrives beside the lamp (v30.86) | DONE v30.84 (cw-p1p2mate), v30.86 (cw-p1p2spawn) |
| 5 | pause box, player 1 window | extra small yellow line "You are hosting. Closing this window or ending the party ends the raid for your whole party." (netHostHolds); player 2 had none | hidden in the arcade (a guest TV, nobody closes the window); the co-op pause box keeps it | DONE v31.01 (cw-p1p2pause) |
| 6 | settings that live in each save | each window plays on a copy of its OWN save (arcadeSandboxIn): CFG dials (P.cfg), HUD layout and collapsed panels (P.hud), kid damage (P.kidDmg). The sandbox forces text size, menu zoom, keys, autoloot, one rifle and the ARCADE_CFG dials in BOTH windows; the rest comes from each save. Measured on two fresh saves: 235 dials, 0 differ. They differ only when HIS save has changed dials or a HUD layout and the fresh player 2 save has not | none shipped: his 10-11 order keeps the HUD layout and kid settings of each save on purpose, and his 10-12 answer says the demo plays like career, so neither "both defaults" nor "player 2 copies player 1" is mine to pick | OPEN, asked in questions.md (two choices) |
| 7 | attract, player 2 (and a benched player 1), live run | the strip "Join your team - Team score" was drawn at 28.5 percent from the bottom, behind the how to play card (it now reaches 84 percent), and read faintly through the card rows | with a page or the run over card up the strip sits on the bottom margin under the card, no band | DONE v31.15 (cw-p1p2strip) |
| 8 | titles | player 1 title is the mode menu; player 2 title is Enter the undercroft + saves list showing $ (e.g. "$900") | by design (different job); the $ in the save row is a separate text rule | BY DESIGN |
| 9 | feed at the drop | player 1 reads "Player 2 joined"; player 2 reads "You joined the raid in progress" (the late-join path: it really joins a raid the host already started) | the two lines say different true things (who came / what you did); the counter "Dropping in n" after a respawn was reworded by another helper to "ascending in n" (v31.20, 3a8f7954) | BY DESIGN for the two feed lines; the respawn counter is DONE v31.20 |
| 10 | HUD, pause box, sounds, text size | same code both ways: HUD 1.5 scale, same menu zoom, same sounds (split left/right), same pause card | none | SAME |
| 11 | attract and run over prompt | player 1 reads "Press any key" (or button, by last device, cw-glyphs2); player 2 reads "Player 2: press A" (pad window) although it has played its own keys since v30.68 | left to the glyphs lane | OPEN, asked in questions.md |

Coordinator's list of 8 (sweep-4-reality G9): welcome pack (1, v31.11), run over card (2, v30.98), names (3, v30.88), hosting line
(5, v31.01), settings (6, open, asked), join strip (7, v31.15), wording at the respawn (9, DONE v31.20: the respawn counter reads
"ascending in n"), and the Undercroft overlap (4, v30.84 and v30.86).

Still open as of 2026-10-18 evening (checked against this table and git log; no queued task lists any of them): #6 (settings that live in each save) and #11 (the player 2 "press A" wording). Both are questions to him in questions.md, not tasks. Whether #11 shipped since: unverified.

## Job B notes: what was chosen
- The pair channel (netSamePost / netSameOnMsg, every word carries the pair code) now also carries the Undercroft body. Two new words:
  `hubmate` {x, y, f (facing), m (walking), r (roll time), nm (name), lk (look, first word and every fifth word)} about 8 times a second
  while this window stands on the floor (not on the title, not in a raid), and `hubgone` once when it leaves the floor.
- The receiver keeps ONE body (NETMATE.g), eases it toward the last spot (same ease as the WebRTC floor), drops it after 2.5 s of
  silence, and draws it with netDrawPeer (the same operator drawing the party uses: his fit and racks, walking, standing, rolling)
  sorted with the player, with a name plate over the head like the party names. A nameless mate reads Player 2 in the host window
  and Player 1 in the other.
- When a linked party (the WebRTC floor list) already shows him, the pair body is not drawn a second time.
- Solo play: NET.same is empty, so nothing is posted and nothing is drawn.
- The check stubs netSamePost: a hubmate word given to netSameOnMsg makes the floor draw him, a hubgone word removes him, a word
  with another pair code is ignored, a floor update posts the word, and a raid start posts hubgone.
- The player 2 window arrives one body to the right of the lamp (182,400) so the two bodies do not stand on each other.
- Seen on v31.01 and v31.15: both windows show the other raider beside their own at the lamp (notes\shots\p1p2-after\A-hub.jpg and
  B-hub.jpg), and in the arcade the player 1 window shows the player 2 body (and the other way round) behind the party pages
  (p1p2-final\1-B-attract.jpg). In the arcade the Undercroft is only a blurred backdrop (nobody walks there), see questions.md.

## Ships (order of work)
1 cw-p1p2mate   v30.84 the Undercroft body over the pair channel (job B)
2 cw-p1p2spawn  v30.86 player 2 arrives beside the lamp, not on player 1
3 cw-p1p2names  v30.88 party arcade: Player 1 and Player 2 in both windows (netSeatName)
4 cw-p1p2over   v30.98 player 2 gets the RUN OVER card
5 cw-p1p2pause  v31.01 the hosting line is left off the arcade pause box
6 cw-p1p2clear  v31.11 the welcome pack no longer stays open under the player 2 attract
7 cw-p1p2strip  v31.15 the team strip is not drawn behind the how to play card

## Lessons for a later run
- A STOP "REGRESS ...: the card is stamped ... behind" is the stale What's New card: another worker's card ship (cardP25, card-autoP26)
  fixes it for everyone. Wait for it in shipq.log, do not ship your own card at the same time.
- shipchain.sh (scratchpad\h) retries uncommitted-change STOPs and lock theft; it must run with run_in_background, a
  `( ... &)` subshell from a tool call dies with the call. NEVER kill a lock.sh waiter (the orphan takes the lock later and leaks it).
- Check shipq.log lines by time, not by the key alone: an old STOP line for the same key matches a plain grep.
- Preflight can fail with "parse check ERROR" or "regex matched 0 times: var VER" when another ship is committing at the same moment;
  rerun when git status of dark_raiders.html is clean.

- 10-20 (coordinator): check in his next real two-window play, not checkable in the headless camera: each player's stash pays for a forge buy in a raid on its own (o-01, v32.40 to v32.43), and the closer camera (o-04) in both windows.
