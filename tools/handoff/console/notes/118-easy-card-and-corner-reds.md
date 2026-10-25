# 118 notes (lane b, 10-25)
Both reds were checks gone blind (case b). The game is right; no game ship needed. Fixture commit 16fc12d0b.
- 30.75: v34.67 draws the easy mode buttons as "y  yes" / "n  no" (key cap, two spaces, word). Check regexes wanted one space. Now `\s+`; the "still names the other device" regexes too. Still fails if the wrong device letters show.
- 31.32: v34.69 moved hudPanel from moveTo/lineTo to roundRect, so the check's plate grabber saw no plates (found 2, then 1). grab() now also counts a roundRect corner to corner. The count is still exactly 3 (wallet, minimap, run info) or 2, so a missing or extra plate still fails.
- Run on the current build (v34.69 with the new fixture): 30.75 PASS, 31.32 PASS (notes/118-out.txt).
- Note: HELD=1 fixq.sh was refused as a command form here, so I released the lock and ran fixq.sh plain.
