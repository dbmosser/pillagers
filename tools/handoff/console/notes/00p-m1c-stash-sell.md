# 00p-m1c-stash-sell notes (lane b), key cw-m1sell

## What exists (v37.17)
- Stash sale sites: item menu Sell one / Sell all N (itemMenuRows ~58650), hover act Sell one (~59429), sellall button onclick (~61176). All paid ival(k) in $ and XP.
- The in-raid Peddler pays G.pedCarry at endRaid: that is m1b's (its job file names it), not mine.
- No "account card" exists yet: net worth goes on the stats page cards (renderStatCards, beside Net lifetime earnings). m1e adds lifetime earnings and rank to "the account card" too.

## Design (cw-m1sell)
- sellPriceOf(k) = ival(k) (one place for m1d). stashSell(k,n), stashBuyBack(i), stashWorth(), netWorth().
- P.sellDay {d local day, e $ sold today and not bought back, s [{k,n,p}]}. Today's sales bank into P.lifeEarn through lifeEarnAdd when the day closes (sellDayGet). lifeEarnNow() = P.lifeEarn + e: readers (m1e ranks) use it. P.lifeEarn never goes down; a buy back only takes its sale off e.
- Buy back strip #buyback under the sell button: chips, newest first, each buys back that whole sale at the price paid. Cap 12 entries.
- XP removed from all four sale sites; sellall label lost "+N XP".

## Result
- SHIPPED v37.18 (eb62f44a0), ON HIS PC v37.18. Check 37.18 PASS/PASS; fingerprint held.
- v24.28 retargeted (fixture b92cbf7ba); 24.28, 37.18, 22.01 PASS on runchk.
- Critic: 15-mainframe-stats 3 (P1 on mine: net worth sub-line repeats the header figures; left for m1e, which reworks that card), 67-career-stash-stocked 3 (all findings older layout). Finish line for these screens is 3.
- Buy back strip has no camera stage: asked the coordinator in alarms.md. Pictures: notes/shots/00p-m1c-before and -after (1080 and 4K).
- DESIGN.md (not writable for me) lacks the day-close banking note; it is in notes/progression/README.md and alarms.md.
