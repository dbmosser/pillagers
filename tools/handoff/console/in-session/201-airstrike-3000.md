# 201-airstrike-3000 : damage needed to unlock an airstrike 1500 -> 3000
His order 10-28 (verbatim, forwarded by the old intake chat): "make it 3000 damage to unlock an airstrike instead of 1500"
Tuning, allowed before 11/1. Model: claude-sonnet-5-5, effort high (rung 2: one number).
Do: in dark_raiders.html (via mk script, never by hand) `var AIR={need:1500,...}` (~line 65579) -> need:3000; fix the comment at ~65571 that says "AIR.need (1,500)". The hint text "damage charges an air strike" stays. Most fixture checks use AIR.need symbolically; grep tools/mkfixture.ps1 for hard-coded 1500 near air and retarget any under fixq. New check must FAIL on the build before (AIR.need === 3000). Seed 4242 fingerprint unchanged; no storage key change. Looting untouched.
Ship: preflight, shipq; done when ON HIS PC vNN.NN prints. Move this file to console/done/, add a SHIPPED line in open-orders.md.
Watch for: charging takes twice the damage; the charge percent on the strike meter fills half as fast.
