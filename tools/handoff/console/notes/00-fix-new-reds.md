# 00-fix-new-reds notes
Source: corpus-1018-0246.txt (v29.32). All fixture edits committed (752cf020, 823d06df, 7dd7ce2c, e4926979). All retargets (b), none a real game break.
Final verification run (reds4.out, runchk on build after v30.43): all PASS.

## one line per check
- 9.18 b: title no-scroll check: margin retarget to the new title (cw-title-line); PASS
- 29.10 b: quantity prompt (qtymodal) way out is Cancel/Esc, not a CLOSE button; PASS
- 27.28 26.52 26.37 26.36 b: gun key checks retargeted to gunkeys0/gunsgone wording; PASS
- 25.68 24.38 b/none: PASS already
- 24.79 24.87 24.45 17.94 b: never all caps (names/labels/headers sentence case), 24.45 left edge one-sided
- 24.63 b: mode row min height 50 -> 48
- 24.52 b: [FIRE] keycap retarget; PASS
- 23.05 21.93 21.84 21.81 b: ncFix (sentence case drawn) applied to his-wording comparisons; PASS
- 13.05 13.03 b: same ncFix retarget; PASS
- 11.78 b: credits readout 32 -> 24px (style guide, Q7), height 40 -> 36
- 11.51 b: sector line compared through ncFix
- 10.10 b: modal close word is "Close"; qtymodal exempt (Cancel)
- 9.76 9.74 9.46 b: probes in sentence case; legend filter ignores single-x words in lower panels
- 18.73 SKIP (no step cards), 18.11 PASS
