
--- codex run 2026-10-28 23:05 ---
Prepared cw-cx-damagestreaks against v36.26. Ten anchored edits add steady hand and beast mode, each at 1% per credited enemy kill and capped at 15 stacks. Steady hand resets on a landed health or armour hit, a shield-bubble hit, or an actual held-gun change through arSetHeldGun. A no-op selection keeps it. Beast mode starts at one, resets its five seconds on each kill, expires at five seconds, and survives a gun change. Its seconds and shrinking ring share the existing status panel next to active reload. The timer uses raid time, so solo pause and Superhot treat it like the other combat timers.

Both windows own their own fields. Host death credit and the addressed netKillTake path raise only the owner. Air strike kills count because they already credit that owner; the same 15-stack ceiling applies. Neutral survivor and peddler deaths do not build the enemy streak. No new network message, seeded draw, pickup change, loot row or loot sound. The sim does not update or apply either streak.

DESIGN watch text is in the draft why field: steady hand and beast mode, up to 15% each. With active reload at 15%, the three bonuses multiply to x1.520875 (+52.0875% damage). Watch the five-second ring and immediate steady hand reset on hits and gun changes in both windows.

The new regression check uses actual host death handling, addressed player 2 kill credit, airBlast, damagePlayer, arSetHeldGun, real fireWeapon round damage and drawn status words. It covers three steady kills and x1.03, health/armour/shield resets, four beast kills two seconds apart and x1.04, ring progress, 5.1-second expiry, a kill exactly at expiry, gun-swap independence, 15-stack caps, all three multipliers, other-player isolation and the sim guard in career and arcade staging.

Local validation passed: mk printed written; all ten anchors match once; the prospective game script, regression check and four camera recipes parse; mk is ASCII. The free lint command skipped because this worktree has no ESLint installation. Lane preflight must run the real lint, browser check and seed 4242 fingerprint. No game file or fixture was edited here.

Four camera recipes reuse the proven real linked-window setup: player 1 at 3% and 15%, player 2 at 4% and 15%, with different partner counts. Streaks come from actual host deaths and addressed net kill words. Before photographing, the recipes verify a player 2 gun change and a player 1 fire hit reset only the correct steady hand. The beast clock is held at three seconds only for the photograph; the regression check tests expiry. Each photograph includes the other live pillager and the active reload status at +15%.

Remaining lane work: preflight and ship cw-cx-damagestreaks; report ON HIS PC; photograph all four scenes and obtain critic reviews. This run does not claim the change has shipped or reached the owner.

