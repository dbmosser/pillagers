# 00p-m3f-shop-sources notes (lane c, run 11-08)
Key cw-m3shop. mk: S\mk-cw-m3shop.ps1, check S\mk-cw-m3shop.check.js. Waits clear: m3a (v37.44) and m3b (v37.48) shipped.
Design:
- One door wornGift(p,k,r,seed) -> {pc,key}: kind (random when none), rarity, power from wornDropPw on wornRand, into P.gear. Never in the demo (trDemo).
- Seller: P.gearShop {d mktDay, s [{k,r,pw,sd}] rolled on wornRand from the day, b [bought index]}. 4 pieces, odds scrap 55 sound 33 rare 12. Price wornShopPrice = 2x wornPrice x lootMult, rounded to 10. Gear rows go after the SHOP rows (SHOP indexes keep their place); grid cells get class wg; shopListNow() = SHOP + today's gear for grid and detail.
- Wirt: GAMBLE_POOL gets 4 token rows wg_ring_R_1_1 (weights 4,4,3,1 = 12 of 112, about 1 roll in 9); the token is a valid piece key so dispR puts it in its rarity odds row; the roll makes a fresh random piece of that rarity into P.gear; the log keeps the real piece key.
- Contracts: c.wg {k,r} from wornConRoll at genContract (std 30%, hard 45%, elite 60%), Math.random seeded wornRand, no rr. Claim adds the piece. Board line "gear: rare gloves".
- Ranks: gear rows at 10 13 16 19 22 25 28 ({k:'gear',g,r}). rankPay pays via wornGift.
- Kit: priv items ['medkit'], wg {k:'armor',r:1}; birthBorn gives it when the kit is paid (c>0), seed from the generation; worn on armor if empty else P.gear.
SHIPPED v37.60 cw-m3shop (e3891c4eb), ON HIS PC 58 s after. First preflight failed lint: a // comment in the middle of the one-line rankRwTxt hid its closing brace; /* */ fixed it. Fixture retarget commit 4cfc10259.
Pictures: notes/shots/00p-m3f-after via notes/00p-m3f-shop-recipes.json (made by S\mk-cw-m3shopshots.ps1).
Critic 3 on s1, s2, s3, s5 (finish line 3 for these screens). Its P0 and P1 were outside this job: the welcome pack toast from staging, the Mainframe's explaining lines, Wirt's two button styles. The P2 (empty space on the shop panel) is shared by every shop item. Lint: 2 low contrast on the seller and 2 on the kit at 4K, 1 small at 4K on the contract board, all existing text.
Fixture retargets (done): v37.21 m1ranks ONE (every reward cash or kit) accepts gear; shop FOUR (cells === SHOP.length) counts .vcell:not(.wg).
