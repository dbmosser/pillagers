# 00p-m3g-coop notes (lane a)
Key cw-m3coop. mk: S\mk-cw-m3coop.ps1, check S\mk-cw-m3coop.check.js.
Both WAIT ON jobs (m3c, m3d) are in done/ (checked 11-08).

## What the code already did (v37.64)
- Damage, grit, speed, stamina, reload, aim, noise, heal, revive all run in the partner's OWN window on his own wornM (the host sends a raw {t:'hit'} and netHitTake runs his damagePlayer). So tough already worked for a partner; cutting on the host too would cut twice. Only two host-run sites needed the partner's numbers: sight (updateEnts `_wmh`, was 1 for every proxy) and the host running his search (netSrchTick `dt/r.slow`, no search gear). His own bar prediction (netSrchHold) also lacked search gear: fixed to match.
- Drops in co-op were already right: netSrchTake calls wornBoxRoll with the host seed and host wornDropPw; the key rides the loot word; netLootTake runs wornItemEnsure; each window banks its own bag. Only a comment added.
- A raid gift system exists (v17.44 netGiftKey/netGiftTake: offer, yes by the taker's T, give). Old T offer is unadvertised (veto). Gear hand-off reuses the gift words with wg:1, auto-yes on the partner's window, plus a got ack and a 1 s resend of the hand-over (12 s), dedupe by id (G.wgGot). Host relay now passes wg.

## Result
SHIPPED v37.65 (commit 700d404fe), preflight passed first try, check 37.65 PASS/PASS, fingerprint ents 85/374 containers 165/593 held, ON HIS PC 34 s after the ship.
Fixture camera helper window.__netKitShots added (commit 2876759f4, fixq; HELD=1 form is refused by permissions, so unlock then fixq). Recipes: notes/shots/m3coop-recipes.json (S\mk-cw-m3coopshots.ps1), out notes/shots/00p-m3g-after.

Pictures (1080 and 4K, lint 0): m3g-row (partner row "ring armor boots gloves +1" in rarity colours), m3g-give (footer "t give to vosk ii", tip beside), m3g-lines ("sound gloves given to vosk ii", "rare boots from vosk ii"). First give/lines shots showed raw keys: staging bug (fresh page, key never registered); recipes now bring each piece in through the real give door first.
Critic on row+give: 2. All findings are on older raid screen parts (backpack card not near full screen, controls panel expanded on a fresh page, run info teal, too many bold elements, unlabeled status icons); none names the new list, hint or rows. Left to the screen polish jobs; nothing to fix here.
TASK DONE 11-08.

## Design
- Word: netWornPut adds wm (p.wm, 4 decimals) and wg (['boots.2',...] from P.worn) to the raid state word on change or every 10th. netOnState keeps g.wm=netWmClean, g.wg=netWgClean only when the word has wm; relay passes it on. wornMof(p,s): own body wornM, proxy netSeatWm(p.seat,s).
- Give: T in the backpack (netGiftKey bag branch) or pad Y in the bag (falls back to drop when nobody in reach). Reach = netAidTarget(p,true) (NET_REV_R 64, not downed, not gone). Hint "t give to <name>" in the raid bag footer.
- Row: netTeamHud fourth line at y+44, kind names in rarity colour, rarest first, +n; rows step 70 when any shown partner has a list.
