# 44-ui-score-hits : punchy hits on confirm and on the score count (coordinator 2026-10-20, helper-fixes item 30, gap G8)
effort: low

His answer Q48: menus get "soft ticks, punchy hits on confirm and score". The soft focus tick is in (cw-uimotion, SND_UI.move).
Two parts are still missing:
1. A heavier confirm. SND_UI.ok is a light 520 to 780 Hz triangle blip. Give it weight: a short low body under the click
   (a thump, under about 120 ms) so a press feels like it landed. back, deny, open and close stay as they are.
2. The score hits. The run-over card's score rolls up over 1.4 s (arcadeOverCount, ARCADE_OVER_CU) in silence, and so does the
   career end card's count-up (lbCountEnd and the data-to figures near "A count-up on one figure"). While a figure is moving,
   play one short hit per step (at most one every 60 to 80 ms, pitch climbing a little as it goes), then one heavier landing hit
   when it reaches the final figure. A press that skips to the final score (his answer 2.50 b) plays only the landing hit.
   A score of 0 plays nothing.

Rules:
- All of it goes through the UI bus (sndBus('ui')) and stays under the hard cap on loud sound (v32.32). Nothing seeded, no game
  state touched: sound only. G.sim and the player 2 spectator tick (NET.specTick) stay silent, as sndUi already does.
- A card rebuilt mid count (an initials letter) must not restart the hits or play them twice: tie them to ARCADE.over.at the way
  the count itself is tied.
- Change nothing you can see on either card.

Checks (each must FAIL on the old build), using uiSndPick and SND_UI_LOG so no audio is needed: the ok sound has a low body
(its spec carries the second layer); a run-over card with a team score over 0 logs between 8 and 25 score hits and exactly one
landing hit within 2 s; a skip logs only the landing hit; a score of 0 logs none; a career end card count logs hits too.

No pictures needed (sound only). In your notes, say plainly what he should listen for at the next playtest (feel is his call).
TASK DONE when shipped and the checks pass; TASK PARTIAL with what is left.
