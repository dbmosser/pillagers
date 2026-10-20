# 44-ui-score-hits (lane b, 2026-10-20)

Shipped v32.73 (cw-scorehits). A stale What's New stamp came first: shipped v32.72 (cw-cardp38, polish pass 38).

What changed (sound only, UI bus, nothing drawn differently):
- SND_UI.ok has a second layer: a 140 to 68 Hz sine thump, 0.11 s, under the click. back, deny, open, close unchanged.
- New SND_UI kinds: hit (short 760 Hz triangle tick) and land (300 to 150 Hz click plus a 110 to 52 Hz body, 0.18 s).
- sndScoreHit(st,k,v,to): one hit per changed step, at most one every 70 ms, pitch 1.0 to 1.5 over the count; one landing at the end;
  a skip plays only the landing; a score of 0 plays nothing. Several figures landing together make one landing (120 ms guard).
- Run over card: state kept on ARCADE.over (o.shSt), so a rebuilt card (initials letter) never restarts or repeats it.
- Career ledger figures (lbCountStart / lbCountEnd): own state on each figure; skip (lbCountEnd) plays the landing only.
- hit and land are logged to SND_UI_LOG even with no audio, so the checks run headless. Check cw-scorehits covers all five claims.

Not done / notes: the run over card has no skip press of its own in this build; a card first seen after the count is over plays only the landing.

Listen for at the next playtest (feel is his call):
- A press: should feel like a soft thump under the click. If it is too boomy, lower body.v (0.07) in SND_UI.ok.
- Run over card: about 20 quick ticks climbing in pitch over 1.4 s, then one heavier thud on the final score. Too busy: widen the 70 ms gap.
- Career end card: same on the ledger figures; a press that skips gives just the thud.
