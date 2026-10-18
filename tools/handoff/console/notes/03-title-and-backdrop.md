# 03-title-and-backdrop notes
- before shots: notes/shots/03-before (01,44,45,46,56,57 at 1080).
- Code map (dark_raiders.html): title div id="title" line ~2298 (button #titlestart ~2362); titleOn() 46239, titleSceneReady() 46240;
  attract overlay ATT 46315/46339 (idle 30s), arcadeAttShow 60783, arcadeAttTick 60796; loop() 47458 (hub branch draws drawHubWorld 45694 under title);
  render2D(dt) 36089 (raid world draw to wc, drawHUD at 38105); simStep 32146 (headless, G.sim); buildRaid(sim) ~15666; resize 32439.
- Plan: ship 1 = title text (Q51 one line, Q53 no raiders). ship 2 = live backdrop (hard; do only if budget).
