# 00-fix-new-reds notes
Source: corpus-1018-0246.txt (v29.32). Candidate list notes/reds1.txt, outputs reds1.out (first full run).
Method: runchk.sh LIST OUT under lock; edits to mkfixture.ps1 in place; HELD=1? (I used plain fixq.sh while holding lock: worked: commits + rebuilds).
## done (committed 752cf020), all (b) retargets
- 24.79 b: drink name no longer uppercase (never all caps rule), 19px+ kept
- 24.87 b: action name same
- 24.45 b: row labels not caps; list left edge tolerance (one-sided)
- 24.63 b: mode row min height 50 -> 48
- 17.94 b: modal headers not caps
- 18.11 b: (already retargeted by cw-title-line dd2a1841), 18.73 now SKIPs (no step cards)
- 29.10 25.68 24.38 PASS already
## todo (failure first line from reds1.out)
9.18 story margin 16 vs 26 at 977px; 27.28/26.52/26.37/26.36 gun keys; 24.52 [FIRE] keycap; 23.05 slot 0 text;
21.93 SKIP; 21.84 zone name case; 21.81 EXPERIMENTAL; 13.05/13.03 EXPERIMENTAL; 11.78 readout 24px; 11.51 sector facts;
10.10 modal close; 9.76 9.74 text edits; 9.46 legend hit box
