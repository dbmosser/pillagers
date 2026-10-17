# 02-corpus-fix notes
Rows this run (first 8 OPEN): 10 (27.38), 5 (28.48), 6 (28.16), 7 (28.13), 8 (28.12), 43 (19.00), 45 (18.25), 46 (17.86). ALL DONE in corpus-triage.md.
- 27.38: shipped v28.81 (cw-feedsp, S/mk-cw-feedsp.ps1): feedLabel skip, feedLabel merge and feedSay pick regexes accept SP as well as $. Check 28.81 and old 27.38 pass.
  Lesson: an edit anchor that is a line prefix must not end in a // comment (it swallows the rest of the line, parse check times out).
- 28.48: fixture hardened (arcs with pb 0 vs pb 1 on the same entity). Passes 3x.
- 28.16, 28.13, 28.12: pass 3x (FLAKY-OK).
- 19.00, 18.25, 17.86 were NOT flaky: they failed alone in a fresh tab. 18.25 and 17.86 read keysLegendHtml which follows state (hub vs raid vs DEMO), so they now set state='raid' and G.arcade=0 around the call. 19.00: the status column sits right of the vitals when the feed zone fills the left edge, so its left band is 40 percent wide.
- A fixq commit takes the whole fixture file, so a half-made check from another worker's draft can ride along. Watch for that.
- Next run: next OPEN rows start at row 68 (10.68) in section B, then the STALE section C onward.
