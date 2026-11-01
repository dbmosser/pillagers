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

## After ship
- Retarget fixture check v24.28 line ~57722 (Sell all paid XP) to "no XP".
