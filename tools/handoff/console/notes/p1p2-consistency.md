# p1p2-consistency (lane h, task cw-p1p2), started 2026-10-18

HIS ORDERS (2026-10-18, verbatim, from his first look at the two-window game):
- A) "there seem to be a lot of inconsistencies between p1 and p2 games, please coordinate them better"
- B) "players 1 and 2 should be able to see each other in the undercroft"

THE RULE: both windows look and behave the same except for which player they are (number, name, colour), unless how the game
works needs it (the host window runs the world).

## How I looked (so a later run can repeat it)
- Real two-window harness (a lane-h tool, not in the repo): scratchpad\h\h-lib.mjs, h-aud.mjs, h-arc.mjs, h-two.mjs. It starts
  headless Chrome on port 9368, serves a copy of tools\fixture.html with one extra hook (window.__xx = eval inside the game
  closure) on 127.0.0.1:8869, opens TWO windows (host + ?p2=1&mode=coop&pair=CODE&arc=1), links them as a real same-machine
  pair (netSamePick without window.open, then the real WebRTC handshake, it links in about 6 s), then drives the arcade and
  takes a picture of each window. Run: `HMODE=arcade node h-aud.mjs` (or coop). Pictures: notes\shots\p1p2-aud, p1p2-two-arc,
  p1p2-two-coop.
- Staged single-window pictures with tools\uishots.ps1 -Port 9368 (notes\shots\p1p2-before).
- FINDING THAT SHAPES JOB B: the Undercroft ALREADY draws the other player over the WebRTC link (v15.75, netHubTick,
  netDrawPeers, netDrawPeer, netDrawTags); in the real two-window harness both windows list the mate as shown. It was not
  enough: (1) both windows arrive at the same spot (140,390), so the mate stands exactly under your own raider and is invisible
  until someone walks; (2) it needs the WebRTC link (about 6 s after the pick, longer if the STUN servers are slow), while the
  pair channel is up at once; (3) in the arcade demo the Undercroft is only the blurred backdrop of the attract page.

## Differences found (most visible first). status: DONE vN / OPEN / BY DESIGN
| # | where | what differs | fix | status |
|---|-------|--------------|-----|--------|
| 1 | arcade attract, player 2 window | on a fresh player 2 save the WELCOME PACK window opens under the party attract and is what shows through the blur (player 1 window shows the Undercroft). arcadeEnter clears open windows BEFORE NET.start() opens the pack (ARCADE.on is still 0 then, so firstRunNext lets it open) | clear the windows after the sandbox is in, and make NET.start in arcadeEnter run first | OPEN |
| 2 | run over, player 2 window | player 1 gets the RUN OVER card (team score, kills, extractions, deaths); player 2 gets none (arcadeEndTake only tears the raid down), only the initials card when one is mirrored | build ARCADE.over on player 2 from its own score words when arcend arrives | OPEN |
| 3 | names over heads, HUD teammate bar, feed | the roster holds each save name (made at link time, before the arcade sandbox sets PLAYER 1 / PLAYER 2), so a mate shows as "Pillager" or his save name | in the arcade a seat is Player 1 / Player 2 in netSeatName | OPEN |
| 4 | Undercroft (co-op same machine) | both arrive at 140,390: the mate hides under you. Needs the WebRTC link; the pair channel is not used | job B: pair channel word hubmate + a spawn beside | OPEN |
| 5 | pause box, player 1 window | extra small yellow line "You are hosting. Closing this window or ending the party ends the raid for your whole party." (netHostHolds); player 2 has none | hide it in the arcade (a guest TV, nobody closes the window) | OPEN |
| 6 | settings that live in each save | each window plays on a copy of its OWN save (arcadeSandboxIn): CFG dials (P.cfg), HUD layout and collapsed panels (P.hud), kid damage (P.kidDmg), so the two windows can differ in anything his save changed and the fresh player 2 save did not | player 2 takes player 1 dials for the session | OPEN (see below) |
| 7 | attract, player 2, live run | the strip "Join your team - Team score" is drawn behind the how to play card (faint text across the card) | position | OPEN |
| 8 | titles | player 1 title is the mode menu; player 2 title is Enter the undercroft + saves list showing $ (e.g. "$900") | by design (different job); the $ in the save row is a separate text rule | BY DESIGN / note |
| 9 | feed at the drop | player 1 "Player 2 joined"; player 2 "You joined the raid in progress" (it joined at the drop, not late) | wording | OPEN (low) |
| 10 | HUD, pause box, sounds, text size | same code both ways: HUD 1.5 scale, same menu zoom, same sounds (split left/right), same pause card | none | SAME |

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

## Ships (order of work)
1 cw-p1p2mate   the Undercroft body over the pair channel (job B)
2 cw-p1p2spawn  player 2 arrives beside the lamp, not on player 1
3 cw-p1p2names  party arcade: Player 1 and Player 2 in both windows (netSeatName)
4 cw-p1p2over   player 2 gets the RUN OVER card
5 cw-p1p2pause  the hosting line is left off the arcade pause box
Open after that: 1 (welcome pack under the player 2 attract: cw-partyclear by another lane may already cover it; re-measure),
6 (player 2 adopting the host dials), 7 (team strip behind the how to card).
