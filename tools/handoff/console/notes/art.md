# art.md (see also c-01-art.md)

Nothing from the char-art brief is shipped yet as of 10-17 09:45 (run 2).
Step 1 drafted, NOT shipped: S\mk-cw-helmbar.ps1 (Heavy helmet neon bar -> steel ridge + small accent lens with glint; pixel check on schtoxic:
accent column run <= 4.5 px and >= 20 accent pixels). Run 2 re-ran the mk script ('written', anchor still matches once on the current file) and
shipq.sh cw-helmbar STOPped twice: "the game or fixture has uncommitted changes".
CAUSE: dark_raiders.html is dirty (VER 28.79 + unsplit gun-weight halving from a STOPped cw-fewerguns ship; git diff shows only that). I cannot
revert it (git is read only). Already in questions.md (asked by b-11). Nothing else blocks step 1.
Compatibility checked: mkfixture 28.16 now (commit dce29b79, cw-heavycrest) checks the Heavy helmet by pixel DIFFERENCE between schemes, so a
full-strength accent lens passes it. Do NOT use a half-alpha accent for the lens anyway (my own 28.16 reading before that commit).
RETRY: once `git status --porcelain dark_raiders.html` is empty, just run: bash shipq.sh cw-helmbar (re-run the mk-cw-helmbar.ps1 first only if the
anchor stops matching; the line is wc.fillStyle=INK; rrF(hx2-2.2,ty-50.2,4.4,10.2,1.6) near game line 33204).
Next after that: ink outline + hue ramps on the player body, pouches/bandolier, goggle glint, cast shadow + gun shadow, Heavy/Raider set plates, then bake.
