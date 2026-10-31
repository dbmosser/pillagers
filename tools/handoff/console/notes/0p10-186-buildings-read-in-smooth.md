# 0p10-186 buildings read in the smooth look

- HEAD before: not done. bakeGround used bldKindFloor and pixKindDetail only when `_px` (pixel look); smooth look kept bldFloor.
- Shipped v36.86 (cw-bldsmooth, 089a844e6): both looks floor by kind and bake the flat details. Two one-line edits in bakeGround. ON HIS PC v36.86.
- Check 36.86: bakes the 4242 map in the smooth look with and without kinds; each kind on the map must differ by 120 px or more, and the seeded stream must be equal. It failed on the build before (first preflight run).
- Fingerprint held: ents 85/374, containers 165/593.
- Pictures: notes/shots/0p10-186-after/21-raid-hud-calm-1080.jpg and -4k.jpg (open floor with stains, tiled office, racking, blue tiled shop visible).
- Frame cost: the change is in the one-time ground bake only; the per frame blit is unchanged. I did NOT run a 4K before/after timing.
- Watch on next play: smooth look floors now differ per building kind; houses show rugs, offices tile with papers, warehouses racking or dock with pallets and oil. Floors are subtle at night.
