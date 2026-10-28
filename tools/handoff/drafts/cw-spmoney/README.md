# cw-spmoney: the extracted card splits score and money (menus master, cloud, 2026-10-28)

His order 10-28 (in the "Menus master" chat, with a picture of the extracted card): "this extracted screen is an absolute mess -- money versus raid score/sp should never be intermingled".

What ships (draft-cw-spmoney.json, base v35.42, 6 edits, display only):
- The career ledger becomes two panels side by side: RAID SCORE (sp only, gold) and MONEY ($ only, teal), each with its own total. The money total was drawn in the score gold; it is teal now. No RAID TOTAL row.
- The haul pictures sit under both panels; six medals fit on one line.
- On an extraction, DAMAGE TAKEN moves under the result (a KIA card still opens on what killed you).
- The xp line reads "+2,782 xp"; the season total and the "next: ... claim it at the mainframe" sentence are hidden text (that sentence was the line cut off behind the leaderboard button in his picture).
- Recovered guns and a finished contract are chips, as on every other card.
- Same figures and rules: 1 sp banks $1 on an extraction, KIA halves the score and banks nothing.

Cloud gate (tools/cloud/gate.sh cw-spmoney, base v35.42): PASS. Parse PASS, new check PASS x2, FAIL on v35.42, newest 80 checks 0 new failures, fingerprint ents 85/374 containers 165/593.

Old check to retarget in the same ship: 28.03 pins the one list (COMBAT/OBJECTIVES tags, a RAID TOTAL row). retarget-cw-spmoney.patch (one level up) changes those two asserts to the two panels; with it 28.03 passes x2 on the new build. 23.87, 27.08, 28.67, 28.71, 34.23 pass unchanged.

Pictures (1080p, cloud headless, heavy staged run): 38-extracted-before-1080.png, 38-extracted-after-1080.png, 35-kia-after-1080.png.
Watch for: on a run with many recovered guns the damage list at the foot of the card scrolls under the button (it is a footnote); the top of the card never moves.
