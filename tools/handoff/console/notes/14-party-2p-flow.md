# 14-party-2p-flow notes (lane a, run 10-18 21:18, budget was only about $2)

## Shipped
- v31.79 cw-matedown (2.72 a): partner down now plays a clear two-note alert (same loudness at any distance, sndMateAlert) and the red edge arrow pulses (mateArrowPulse, 1 to 1.5, twice a second). The old sound was a thud placed where he fell, silent past 1400. Check fails on the old build. No picture from both windows yet (2.86 a still owed).

## Read in code, not yet checked or changed (next run starts here)
- 2.23 a / 2.25 b: arcadeExtractEnd (about line 59179) already benches the extracting player and lets the run go on until both are out (cw-bothout, Q65). The benched host sees the attract with a JOIN YOUR TEAM strip and team score (arcadeAttStrip), NOT the partner's live view with a waiting line. 2.25 b is NOT done: needs the partner's view shown live plus a small "waiting" line. Biggest open item.
- 3.4 a: player 2 joins with A: arcadeJoinAsk / netLateAsk exist; no check yet that a mid-run join works (2.7).
- Not looked at yet: 2.1/3.9 window death and auto reload, 2.60 pass-through, 3.19 repeat pick-ups, 3.12/3.14/3.15 party settings, 3.5 keyboard marker, 3.6 side by side on the waiting screen, 2.24 pause.
