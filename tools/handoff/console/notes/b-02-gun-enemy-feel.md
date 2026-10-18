# b-02-gun-enemy-feel
- Shipped: cw-kickshotgun (v30.35, shotgun camera kick 6.5), cw-cardP18 (card), cw-kicksmg (SMG kick 2.2 to 1.9: worst held-mag shake 4.65 px to 1.41 px).
- cw-kickprobe: preflight only, measuring probe (not shipped).
- cw-kickpistol: PREFLIGHT PASS as v30.42, but ship STOPs 3044 (another worker holds uncommitted tools/mkfixture.ps1 edits, 70 lines). Retry later.
- Ship retried 7+ times: the dirty fixture is worker 00-fix-new-reds (hudhero, ncFix, qtymodal edits), not mine. Next run: re-run preflight b cw-kickpistol, then ship.
- Fixture note: scattergun kick check now uses sniper (4.5) as the control instead of smg.
- TODO enemy pass: animHitShift (dark_raiders.html ~34501) pushes 5 px over 0.16 s; deathAnimAdd; crawler/sentry/raider. Each its own cw- key.
- TODO guns: rifle, magnum kicks. Not yet done.
