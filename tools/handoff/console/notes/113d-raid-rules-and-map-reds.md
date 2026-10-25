# 113d raid rules and map reds (lane a, 10-25)

All seven were check problems, fixed in tools/mkfixture.ps1 (commit 5a5f8a6c1), no game change. All seven PASS on the rebuilt fixture (113d-out2.txt); before they all failed (113d-out.txt).

- 30.26: staged sentry left in patrol, v4.45 weld gave it +2 hp. Now state 'chase' like a landed round.
- 22.12: v34.46 shortened the contract done line (Q8). Check now matches the line ending in the place name.
- 20.38: Crier sees host since v21.23 and re-marks him. Check faces it away from the host.
- 15.80: a real pillager bot round (dmg 46) was still in flight. Check clears G.bullets before the staged round.
- 13.81: since v26.26 one find in five is the rarity twin (carbine_v, mag by quality). Check matches by gunBase and half of the held gun's mag.
- 10.81: v34.50 solid pieces (furn) counted as interior walls. Check counts partitions only.
- 9.81: v34.50 raised the wall counts 2191/545 to 2268/558. Counts re-aimed.

Optional game hardening (weld test hp>0 guard) not shipped: not needed, no player-visible bug.
Gate not run (no game change); the fixture commit is what ships these.
