# cw-pausesp and cw-xpbreak (menus master, cloud, 2026-10-28)

## cw-pausesp: the pause box shows what the raid pays in sp
His order 10-28 with a picture of the raid pause box: "this isn't really helpful -- this is where all the modifiers/settings that impact sp should be shown, so the player knows exactly what they are playing".
- In a raid (career or demo), under the title and above the buttons: "score x1.34" (diffMul), then one row per setting that moves it: pillager bots, machines, how hard they hit, heat when you call for extraction, fog of war (as the raid was built, G.dmrows beside G.dmul, so a linked window shows the host rows it is paid by) and superhot mode (live). Each row: setting, choice, factor; x1.00 muted. The rows multiply to the headline. Then extract x2 and killed in action -50%.
- The run log list (cw-msgroute) leaves the box; the run log stays in the run report.
- Closing Settings mid raid redraws the panel (superhot is live).
- Retarget in the same ship: 35.44 SEVEN tested the run log list on the box. retarget-cw-pausesp.patch keeps SEVEN as "a log-only line stays in the run log".
- Pictures: 25-pause-before-1080.png, 25-pause-after-1080.png, 25-pause-after-1080-zoom13.png (his 1.3 menu zoom on a 1080 screen: fits, frame to the screen edge).
- Watch line: with a controller the key list shows too; on a 1080 screen at menu zoom 1.3 that may run the box past the screen.

## cw-xpbreak: the xp line keeps its own line
His picture 10-28: "+2,386 xpthe seal on cold storage is broken...". My cw-spmoney (v35.45) ended the career xp line on a hidden span, and the .ocsr + br rule ate the line break after it. One line fix.

## Cloud gates (base v35.70 with the 35.44 retarget and the card stamp moved to 35.70, both for gating only)
- cw-pausesp: PASS (parse, new x2, fails on v35.70, newest 80: 0 new failures, fingerprint 85/374 165/593).
- cw-xpbreak: PASS (same gates).
- Without the stamp move both STOP on 35.55 (card stamp 35.55, 0.16 behind): ship cw-cardstamp first, as RULES.md step 5 says.
