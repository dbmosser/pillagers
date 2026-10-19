# 14-party-2p-flow notes (lane a; runs 10-18 21:18 and a second small-budget run)

## Shipped
- v31.79 cw-matedown (2.72 a): partner down plays a clear two-note alert (sndMateAlert) and the red edge arrow pulses (mateArrowPulse). Check fails on old build. No picture from both windows yet (2.86 a owed).
- v31.81 cw-kbmark (3.5 c): with two windows paired, the window in front wears a small "keyboard" chip at top left (kbMarkWant/kbMarkSet/kbMarkTick, 500 ms timer). Check fails on old build. No picture from both windows yet (2.86 a owed). Position (top left, x10 y6) not yet looked at against the arcade HUD.

## Read in code, not yet checked or changed (next run starts here)
- 2.25 b NOT done, biggest open item: arcadeExtractEnd (about line 59209) benches the extracting host (G.player.specOut=1); the benched host sees the attract overlay (arcadeAttShow, JOIN YOUR TEAM strip) not the partner's live view. Idea: hide the attract overlay while benched and mate live, point the render2D camera anchor (G.anchX/anchY, line ~37344, follows p) at the mate body (netPlayersList / netUpBody), add a small "waiting for player 2" strip. Risk: fog and lights are keyed to p, so the view may be dark around the mate. Needs a real look with both windows. Player 2 extracted (client) side: not read.
- 3.4 a: player 2 joins with A: arcadeJoinAsk / netLateAsk exist; no check yet that a mid-run join works (2.7).
- Not looked at yet: 2.1/3.9 window death and auto reload, 2.60 pass-through, 3.19 repeat pick-ups, 3.12/3.14/3.15 party settings, 3.6 side by side on the waiting screen, 2.24 pause, 2.29 same enemy count.
