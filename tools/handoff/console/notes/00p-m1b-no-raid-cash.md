# 00p-m1b-no-raid-cash notes (lane a)

m1a done (v37.19), so no wait. Key cw-m1nocash, mk S\mk-cw-m1nocash.ps1 + mk-cw-m1nocash.check.js (34 edits). Preflight PASS first try as v37.20.

## What it does
- New at file scope after mfPayPer: PAY_POOL, payItemsFor(v) (salvage worth about v, greedy, no dice), RACK_MATS, rackMatsFor(v) (board, cell,
  wire, scrap in turn), keysWorth, keysLine, contractPayKeys(c), EXTRACT_BONUS 0.10, extractBonusFor(v).
- Extract: bonus = round(secured value x 0.10) (the "N items secured for $X" figure), P.credits + lifeEarnAdd, card line "extraction bonus +$N".
- Stall: pedSellAll pays P.credits + lifeEarnAdd at the sale (not in sim); G.pedCarry stays 0; pickup row tag CARRIED to BANKED; panel promise
  "N% of value, banked now"; card "stall sales $N banked" on every outcome; runEarnings counts pedSold on every outcome for rows with pedBank:1.
- Survivor: same ri(900,1500) roll, paid as salvage through the one grantLoot with his gift; no $ row, no +$ world label; card "survivor gift worth $N" on extract.
- Raid goals: cash goals add payItemsFor(chip x 5) to R.items (banked on extract like goal loot, lost on death); text "bonus salvage"; one card line.
  (Task said "into the raid bag"; the existing goal loot path banks at extract and dies with the run, same effect, no bag or pickup change.)
- Contracts: salvage worth the old reward to the stash + gear; an owned contract gun comes as a spare gun_ to the stash (payGear); board row
  and panel say "worth $N", panel shows the salvage icons.
- Racks/arrays: rack parts worth mfPayPer to the stash; card "mainframe parts: ..."; rack texts say parts worth $N.
- Hire cuts kept, now through lifeEarnAdd.

## Old checks this breaks (not in the newest 80): 9.40 now SKIPs (extract no longer banks pedCarry); checks near fixture 12128-12160,
12504, 89633-89669, 95192-95230, 100312-100339 (pedCarry), 96714/104301 ("survivor paid"), 91979/100877 (payGear $), 100742 (claim $),
9701-9772 (36.33/36.34 goal cash). Logged in alarms.md.
