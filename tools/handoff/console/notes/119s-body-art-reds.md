# 119s-body-art-reds (lane a, 10-27)
Ran all four alone on the current build (runchk, fixture rebuilt):
- 33.84 cw-pixrole: PASS alone, dropped (already fixed or order dependent in the VM run).
- 26.06 crowbar swing: PASS alone, dropped.
- 11.06 jersey 23: PASS alone, dropped.
- 33.58 cw-pixbody: failed on "fists was drawn in pixels but is still the vector body". Cause b: the game changed on purpose (v28.xx cw-pixmelee, dark_raiders.html pixDrawOp line ~52888: a plain look keeps its pixel body in a punch). Check re-aimed in commit 33e55f979 to assert fists ARE pixels; the downed and set cases are unchanged. Now PASS.
No game change, so no ship and no pictures needed.
