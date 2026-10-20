# 55 retarget repairs (lane a, 2026-10-20)

Checks run on the current game (v32.90) with runchk.sh; output in 55-out1.txt and 55-out2.txt. Fixture commits ff42cd2d, b98bac38, 832f205e and the 10.13 follow-up.
"Fails on the bug" below is by the audit's worked example and by reading the code path; I did not build a broken game to prove each one.

- 24.21: REAL (game fix v32.90 cw-closeplace). Measured against each drawn frame the X sat 11, 11, 22, 11, 8 px down (shop, Mainframe, Settings, fashion, stash). Game fix: Settings and Keys X now 12 below the frame (top:calc(var(--py) - var(--sp-3) + 12px)), stash X top 12px. Check back to 2 px tolerance, stash in the group, right bound 48, top bound 56 (header row). Passes now. Pictures: notes/shots/55-closeplace-before and 55-closeplace-after (settings X now about 36 px under the screen edge, frame at 25).
- 25.01: FIXED. The wiring test is back (slow oscillator to depth gain to tone pitch). A build without v.lfo.connect(v.dep) now fails. PASS on current.
- 31.71: FIXED. List held at 1008 menu px when the wrap has room, pane must take the whole rest (within 2). The v31.70 flex layout (list grows, pane 480) fails both. PASS on current. Owner note (not a test change): the detail pane is about 311 menu px wide at 1080p with the default zoom 1.3.
- 15.86: FIXED. The SKIP now needs FZ (the second sector really frozen on his order). When the freeze is lifted for real, the assertions run and fail on boxless design A cards. Today FZ is 1, so it still SKIPs: that is correct, nothing to trip yet. Comment says v32.46.
- 24.37: FIXED. Probe back at 9.6 times FIG_HEAD (11.52): Curved must have no ink there, Lean must reach it; the edge comparison margin is 1.8 (was 0.6). Comment now says the caps sit inside the v32.64 head scale, not the vest. PASS on current. Owner note: v32.64 also scales every body shoulder caps by 1.2 (looks like a side effect of where the head scale restore sits); not touched.
- 20.89: FIXED. In the shop the line is tested against every visible .vcell and button in the panel, Fashion stays strict. PASS.
- 26.38: FIXED. Only the data-go button is skipped; a chip with no data-sec fails; only section chips count toward 5; a missing AUDIO chip fails. PASS.
- 19.64: FIXED. MAPBOX restored in the finally block. PASS.
- 9.14: FIXED. Band back to 13 px wide and 4 px tall around 171x34. PASS on current, so the 1080p heading really is that exact.
- 10.13: NOT A PROBLEM for the assertion (audit said the "equip plates" advice is still on the page: it is not, only "no armour equipped" is drawn; I tried the assertion and it failed on the current game, so I took it out again). Comment corrected: v32.46 callout, v32.22 cut the sentence.
- 27.20: FIXED. The text door (txDom) runs on the kit row and the raw text is read back; capital letters now fail. PASS.
- Version labels: FIXED in comments for 15.86, 16.13 (v32.46), 18.69 (v32.46, 960 map v32.52), 31.48 (v32.30 cw-cx-mapspace-o03), 18.48 (v32.75), 29.55 (cw-pset15 v31.71 and cw-pausegap v32.66), 10.13 / 11.29 / 13.26 / 10.05 / 9.97 (v32.46; 13.26 d: string no longer promises the test robot rate). One other v32.45 mention (the 18.69 terms and bar windows line) is a different change and stay.
- Not in the notes files of jobs 50 and 54: I did not edit those notes (not my files); the fixture comments carry the right labels.
