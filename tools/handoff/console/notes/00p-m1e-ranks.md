# 00p-m1e-ranks notes (lane c)

## Result
- cw-m1ranks SHIPPED v37.21 (23c8a546b), ON HIS PC v37.21. First ship STOPped: the market (v37.20, cw-m1mkt) moves the price after a sale, so the
  check now reads what stashSell returned, not sellPriceOf after the sale.
- cw-m1rankui SHIPPED v37.23 (b92794f8f), ON HIS PC v37.23: critic P1 on the strip (13px labels, lime three times).

## What it does
- RANKS table (n, need, rw {k cash|kit|start, v, l}) after netWorth(). rankIxOf(le), rankLe(p), rankNow() (max of earnings rank and highest paid,
  so a buy back never drops it), rankRwTxt, rankPay, rankCheck() (pays unpaid reached ranks once into P.rankPaid; needs P.mig1r===1; not in ARCADE),
  rankNoteShow() (hubToast only when state==='hub'; else at next hub arrival, after szNoteShow), rankMig(p) (old save: marks reached ranks paid,
  pays nothing; also run on a restore code), renderRank() (#rankstrip in #opmodal, from openOps).
- rankCheck runs from lifeEarnAdd and stashSell. Rank rewards are NOT lifetime earnings (the ladder would feed itself).
- P literal: credits 1000, rankPaid:[0], mig1r:1.
- Account card = the "lifetime earnings" card on your stats (sub "rank <name>"), beside net worth.

## Curve (also in DESIGN v37.21)
His flight recorder 11-01 (last 60 runs): 15 extracts, hauls avg ~$41,500, median ~$38,500; ~1 run in 3 out => ~$12,500/raid.
Early starter kit hauls $5k-15k. First rank up $20,000; step x1.061 each; warlord v $1,500,000 (~120 raids, 6 weeks at ~20/week).
Rewards: cash 2,500..25,000 (121,000 in all) alternating with kits of existing items.

## Pictures and critic
before notes/shots/00p-m1e-before (12, 15 at 1080); after notes/shots/00p-m1e-after (v37.21) and after2 (v37.23), 1080 + 4k.
Critic 12: 3 (v37.21), 3 (v37.23); 15: 3. Finish line for these screens is 3. Skipped: "drop lifetime earnings from the strip/card" (the job orders both).
Rank up line picture: no uishots screen stages a rank up (asked in questions.md); the check proves the line in #hubtoast.

## Watch on his next play
The strip pushes the contracts list down about 90px. Whether the first rank comes fast enough ($20,000). His own save starts high (lifetime earnings from his log).
