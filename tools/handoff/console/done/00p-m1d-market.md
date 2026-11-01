# 00p-m1d-market : season zero m1, build 4 of 5: sell prices move with a market, three wanted items a day
model: opus
WAIT ON 00p-m1c-stash-sell (it adds sellPriceOf): if 00p-m1c-stash-sell is in tasks/, waiting/, blocked/ or a lane holds it, end your run with exactly TASK WAITING: 00p-m1c-stash-sell and nothing else.
His note (answer 38): "i feel like prices should move around based on....something". Plan (open question 1, default taken): the market. Read tools/handoff/console/notes/progression/README.md first.
Do (all inside sellPriceOf and one small market record P.mkt, born set for a new profile):
1. Each item's sell price drifts day to day, seeded from the local calendar day (not the raid stream): within about 80% to 120% of today's base price.
2. What he sold a lot of this week sells for less (down to about 70% after heavy selling of one item); what nobody sold creeps back up toward base. Keep a per-item sold count for the last 7 days.
3. Three wanted items a day pay 50% more, picked from items that actually drop, shown as a short "wanted" strip on the stash screen and at the Peddler ("wanted: +50%" style, lower case).
4. The seller's prices never rise with lifetime earnings (his answer 42); buy back stays at the exact price paid.
Check (must FAIL on the current build): the same day gives the same prices; a different day moves at least one price; selling one item ten times lowers its next price below what an unsold item of the same base gets; a wanted item pays 1.5x the price it would have; buy back returns the price paid even after the market moved; an old save without P.mkt loads with nothing lost (README rule).
Rules: no player text beyond the wanted strip; lower case, $.
Pictures: stash screen and Peddler with the wanted strip, 1080p and 4K.
TASK DONE when it shipped and is ON HIS PC, with one line in notes/progression/log.md.
