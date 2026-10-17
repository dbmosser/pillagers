# c-01-art notes (art build)

Run 1 (10-17 ~09:30):
- No earlier art.md existed; nothing from the brief was shipped before this.
- Step 1 = Heavy helmet neon bar. Draft: S\mk-cw-helmbar.ps1 (key cw-helmbar). The crest becomes a low steel ridge, the scheme
  accent only a small brow lens (ink housing + white glint). Check measures pixels: on schtoxic the accent (#8dff2e, tol 24) in the head
  rows is no taller than 4.5 px in any column and there are at least 20 accent pixels (the lens).
- Older check 28.16 (mkfixture ~8600) needs >=6 accent pixels at full strength on heavyhelm and a change on schfrost, so the accent must stay
  full-strength somewhere. A half-alpha stripe (the cw-heavycrest draft by someone else) FAILED that check. Do not use half alpha.
- Ship STOPs "game or fixture has uncommitted changes": a failed cw-fewerguns ship (fingerprint moved) left VER 28.79 and its LOOT edits
  in dark_raiders.html. I cannot revert that (git is read only for me). Retry later.

Next steps after the helmet bar (brief order): 1px ink outline + four-step hue ramps on the player body, pouches/bandolier, goggle glint,
soft cast shadow + gun shadow, then Heavy/Raider set plates (chipped paint, panel stripes). Bake-to-sprite last (biggest, riskiest).
