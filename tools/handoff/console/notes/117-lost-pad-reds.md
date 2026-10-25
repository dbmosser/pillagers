# 117-lost-pad-reds (lane a, 10-25)
- v29.33 (raw colours in the lost pad title): the game. Fixed in v34.70 (cw-padtagcol, 3db8a6ce6): the css rules for .pl.p1 and .pl.p2 are gone, padLostTitle sets the tag colour (P1 UIC.warn amber, P2 #5fd7e8 cyan). Same colours on screen, no picture needed. New check 34.70 passes and failed on v34.69.
- v31.90 J8 (pause in two polls): the check went blind, not the game. v34.67 put a p1 or p2 tag before the title words, so the heading read "p1 pad lost", not "pad lost". Re-aimed in mkfixture (rode in the v34.70 commit): the words are read after the tag, and the tag must name this window (host p1, p2 p2). The pause itself was never broken.
- Single runs of 31.90 and 29.33 on the new fixture: see the end of this file (lock was busy).
