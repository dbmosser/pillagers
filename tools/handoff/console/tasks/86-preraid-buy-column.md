86-preraid-buy-column : on the pre-raid page, a buy control to the right of each pack row (his order 2026-10-20 evening)
Queue (coordinator 10-20 21:40): renumbered from 71 so the pick order follows the plan (his 10-20 evening play notes go first, camera first, then the sizes, the minimap before the corner block).
effort: high

Source (his words, 10-20 about 21:30, verbatim): "on the rpre raid screen, next to the pack items, to the right, there should also be an
ability to purchase those items (skip some of the guns if they aren't purchaseable) -- do you understand?"
The page: #sectormodal (dark_raiders.html about line 2644), the "pack" list on the right (medkit /2, bandage /3, smoke canister /1, frag charge /2,
armour plate /2, burst carbine (field) /1, compact smg (field) /1, each with - 0 +). Picture: tools/handoff/console/notes/shots/51-before/05-sector-page-1080.jpg
(camera screen 05-sector-page). Page layout is his pick A (memory pillagers-orders-2026-10-19): do not restyle it away from A.

What to build:
1. To the right of each pack row's - 0 + stepper, a small buy control showing the price ($ and the figure, lower case, his Q59). One press buys ONE
   into the stash, so the /N count goes up by one and the row can then be packed with +.
2. Money comes from banked credits (P.credits), his 10-19 order "stash pays". Never bring back a take-cash control.
3. One price list: use the Undercroft counter's own list and buy path (var SHOP about line 4218, renderShop about 54369, shopStocked about 54367),
   so price, credits, stock and the sold tally stay one system. Do not write a second price table.
4. "skip some of the guns": a row whose item the counter does not sell gets no buy control (blue, purple and gold guns are never sold, his v8.74
   order; the scav pistol rule of v24.xx stands). My call: a row the counter does not stock today (shopStocked false) also gets no buy control,
   the same rule as the counter.
5. Cannot afford: the control stays visible but dim, price in the danger colour, and a press does nothing (no sentence on screen, a short callout
   at most). Keyboard, mouse and pad must all reach it (the pad focus order runs across the row: stepper, then buy).
Questions logged (take the best choice, do not wait): should items he owns none of (shop items not in the stash) get rows to buy from as well?
Best choice for now: no, only the rows the pack list already shows.

Check (new, must fail on the build before): on a staged profile with known credits, a sold item's row has a buy control, a press lowers
P.credits by exactly the counter price and raises the stash count by one; a gun the counter never sells has none; with too few credits the
press changes nothing; the seed 4242 fingerprint holds.
Pictures: tools/uishots.ps1 screen 05-sector-page at 1080 and 4K, before and after; run the critic on the after picture.
Cut-off: none (his 10-20 23:00 order: nothing waits for the party). Aim for Mon 10/26.
Party risk: low to medium (a money path on the pre-raid page). Tell the coordinator what he should try at the next play.

TASK DONE when shipped with its check and pictures; TASK PARTIAL with what is left.
