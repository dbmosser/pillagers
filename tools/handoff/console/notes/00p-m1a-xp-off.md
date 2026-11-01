# 00p-m1a-xp-off notes (lane a)

Key cw-m1xpoff, mk S\mk-cw-m1xpoff.ps1 + mk-cw-m1xpoff.check.js (29 edits). Preflight PASS 11-01 as v37.18.

## What it does
- xpOffMig(p) (once, P.mig1x, born set in the P literal), run on load right after seasonZeroMig: ladderPayout again, $ to lifeEarnAdd,
  hub line added to an unshown P.szNote (else a new one). P.xp untouched.
- No XP earned: addXp returns 0, addProgress no longer calls it (netEarn kept), xpForRun returns 0, walking out takes no XP (G.abandonFee 0).
  Sale lines (m1c) still do P.xp+= and syncXpLevel: left alone as ordered.
- Mainframe: no REWARDS tab (openOps('rew') opens contracts), no KeyR on the station, seasonReady() returns 0 (no badge, no sign "rewards
  waiting", no claim), renderSeason empties the pane, its msub text gone.
- No XP/level text: raid end card XP + next reward lines, abandon fee line and confirm "costs N XP", corner readout, stash header reptop
  (kept hidden, still written), stampBalance, YOUR STATS Experience card, title save slots, RAID XP conditions row, bar_now, peddler panel
  "carried home", sell all label, restoreSay, repline, salvage blurb.
- cosOwned: level:N and board:N looks are open (no level, no board any more).
- Kept: restore code x and l, syncXpLevel on load (P.xpLevel number nobody reads), his baked text map entries, bar_line (shows his
  "things are about to get real"), hidden sellhint, shop rep gates (every SHOP rep is 0, never shown), run report export line (60246).

## Lessons
- parsecheck.html balance() reads `return /re/.test(x)` as division then a regex: unbalanced braces, parse FAIL with no detail.
  Never put a regex literal right after `return` in a check. (Probe key cw-pftest proved the pipeline fine; its draft json stays in drafts/.)

## Old checks this breaks (not in the newest 80, so the gate does not run them): 11.52 (corner shows XP), 35.79/35.8x (xpBaseFor XP),
  the Experience card check near fixture line 111005, addProgress checks near 107074, 111732, 112083, bar_now checks near 98627. Logged in alarms.md.
