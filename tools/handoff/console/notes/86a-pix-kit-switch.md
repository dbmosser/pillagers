# 86a-pix-kit-switch (lane a, 10-21)

Shipped (all through the gate, each with a check that failed before):
- v33.50 cw-pixzoom: ZDEFAULT 1.05 to exactly 1.0. The two 33.23 camera checks now read ZDEFAULT (fixture a29fe711) so they hold at 1.0 and at 1.05. Watch: the camera is a touch further out.
- v33.51 cw-pixkit: row xfPix (extras group, scope l, default on), pixOn, PIX_ACT/PIX_ENV, pixBlit, PIXSTORE (24 MB actors, 16 MB scene, 2 builds or 2 ms a frame, nearest pose), the kit (pixRamp, pixBandRamp, pixTones, pixHarden, pixSilhouette, pixRing, pixSwap), PIXRAMPS (4 districts day and night, plants, machine palette, 3 skins), pix row in G.tel.gfx, ?pixbench. Fixture pins xfPix 0 at load, in __resetCfg and __pinDefaults (19bfefd0); the experimental page checks 33.21, 33.28, 33.33 count the new row (90feedd2).
- v33.52 cw-pixlook: pixLook(lk) and pixOwned(id), read side, no profile write. Check walks all rack ids, 21 fixed looks, profile unchanged after resolve and save, a profile with only The Machine owns the trooper.
- v33.53 cw-pixsmoke: pixFaults() and the smoke check (career, demo, floor, title at 1080p and 4K with xfPix on). Later jobs extend it.

Gaps, said plainly:
- "A staged raid frame hashes the same as on the build before" cannot be a stored hash: two page loads of the same seed gave different world canvas hashes (measured). The check compares xfPix 0 against a frame with every pixel path stubbed off, in the same page. It is weak until 86b makes the pixel frame differ.
- The smoke check does not run a linked 2-window pair (no easy staging in the fixture). Pixel state is per window and keyed by look, so there is nothing shared to break; the party robots with pixel on cover it.
- No pictures: the camera cannot show Settings, experimental or ?pixbench (no such screen, no -Url). Asked in questions.md.
- A throwaway draft tools/handoff/drafts/draft-cw-pixhash.json (discovery only, never shipped) is left in the drafts folder; delete it.
- The pixel-look count: 145 rack ids (COSMETICS plus the 5 old sets) are walked by the check; it asserts at least 145.

Style sheet: notes/pixel-style.md.
