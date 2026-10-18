# 12-ui-party-screens notes

Shipped: cw-party-op (v29.45ish, screens 62/63 operator menu), cw-party-over (v29.47, run over card 52/55 onto shared panel), cw-party-over2 (v29.49, wider card, wordmark hides).
Critic on 55 after v29.49: 2 of 5, better than before. Wants: centred 720px card with centred content, dimmed world backdrop (attract has no video in the test shot, black void), stats as 4 cells (value over label), a Continue button instead of the floating PRESS ANY KEY.
Draft cw-party-over3 (centre text, 720px) FAILED preflight: it conflicts with older checks 29.47 (card left aligned), 29.49 (840px wide), and 29.33 (no raw px literals; use tokens, menu-w times 1.29). To do it: edit those three checks in tools/mkfixture.ps1 under the lock (fixq), then ship over3 with token widths.
Not yet done: screens 46, 47, 48, 49, 54, 56, 58, 63, 64 (before pictures in notes/shots/12-before2/). Screen 49 pause box and 58 P2 window title were critic-scored once (see accept.json).
Gotchas: attract overlay shows on pure black in test shots; critic penalises that every time. Consider a world frame scrim behind #attract (bigger task).
