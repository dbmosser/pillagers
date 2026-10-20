# 62-share-drop-ping (lane b, 2026-10-20)

Shipped v32.97 (cw-droppings, 3172e3e5). A dropped item pings the teammate in a linked raid.
- netPileShare(seat,key,x,y): host sends the ordinary ping word (t:'png') marked pl:1 with the item name to every window except the dropper; keeps the ping itself when a guest dropped. Solo and the dropper get none.
- Hooks: dropItem (host's own drop, after the pile is pushed) and netPileTake (guest drop made by the host).
- netPilePrune (called first in netPingDraw): a pl ping ends when no unopened dropped pile lies within 8 px (after 1.5 s), else the normal 10 s ping time.
- Map, minimap and world already draw NET.pings, so no new marker (named pings are orange diamonds, as before).
- Check 32.97 covers solo (none), host drop (one ping to the teammate, none for the dropper), guest drop (host keeps it, nothing sent back), taking the pile clears it.
- Known limit: two piles dropped within 8 px of each other keep each other's pings until both are taken.

Left: a picture from EACH window (his 2.86 a). The camera cannot stage player 2 of a real pair yet (coord-08 still in staging-1020).
