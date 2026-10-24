# 98 initials and bare hands reds

Both reds were the check going blind (case b). No game change, so no ship and no picture.
Fixture commit bc57562fb. Re-run on the rebuilt fixture: v23.45 PASS, v9.55 PASS.

- v23.45 (arcade initials card): the game still opens the card and draws it. The text door lowers everything drawn (his 10-18 all lower case order), so the card draws "enter initials" and the letters q, w, b. The check looked for upper case. It now compares without case. The claim is kept: the heading and the three letters must be drawn.
- v9.55 (bare hands): the pixel art pass makes drawItemIcon add rarity pips under a gun, so a pistol drawn as an item and as a gun differed in 451 pixels. The control now compares only the rows above the pips. The claim (fists must not be the gun painter) is untouched.
