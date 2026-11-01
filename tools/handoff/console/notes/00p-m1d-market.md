# 00p-m1d-market notes (lane b), keys cw-m1mkt, cw-m1mkt2, cw-m1mkt3

## Design (cw-m1mkt, v37.20)
- All inside sellPriceOf (file scope after lifeEarnAdd): mktPriceAt(k, day, noWant) = ival x drift (0.8 to 1.2, FNV hash of item and local day number, never RNGS) x pressure (max 0.7, 1 - 0.03 x copies sold in the last 7 days, a sale a days old weighs (7-a)/7) x 1.5 when wanted.
- mktWanted(day): 3 distinct from mktPool() (every LOOT table item, no guns, no keys), hash per day, cached per day.
- P.mkt {s:{dayNumber:{item:n}}}, born set in the P literal, repaired lazily by mktGet (old save: nothing sold). mktNote(k, n): stashSell adds, stashBuyBack takes off, pedSellAll adds (not in G.sim).
- Demo (trDemo) and G.sim: sellPriceOf = ival. Lifetime earnings never read.
- Peddler: pedSellAll and drawTrade price at sellPriceOf x pedBuyRate; "carried home" at sellPriceOf. Panel grows LH(16) for a "wanted +50%" line (icons and names, icons only if names do not fit).

## Ships
- v37.20 cw-m1mkt (a46e78b7f), check 37.20 PASS/PASS, fingerprint held, ON HIS PC.
  First ship STOPped: my TEN part compared prices before and after an old save load, but the load changes CFG.lootMult; fixed by comparing to the same save with an empty market.
- Fixture c136db748: 37.18 and old sale checks read sellPriceOf. Fixture bb0e3f66b: 37.22 takes tx-1 prices.
- v37.22 cw-m1mkt2 (6ee7c9885): critic P0, the strip over the sell button took grid height and cut the last row. Moved into the stash header row. ON HIS PC.
- v37.24 cw-m1mkt3 (450802573): critic P1, strip 16px, 24px gaps, label warn, names tx-2, prices tx-1. ON HIS PC.

## Critic (67-career-stash-stocked, finish line 3)
- 2 (strip over sell button), 2 (in header), 2 (16px). Two follow-ups did not raise it: stopping per the rule.
- Its remaining asks on my strip: at most 2 items and no icons (job orders three; his note wants item pictures), or its own row (that was the P0). The rest: old stash layout (right pane, footer, header money, tabs).
- Best versions: notes/shots/00p-m1d-after3 (current) and 00p-m1d-after2. Lint on after3: no issue from the strip.
- Peddler panel: no camera stage; asked the coordinator in alarms.md.
