81b-no-loot-gun-card : looting a gun no longer pops up its stat card (his order 2026-10-20 evening)
Queue (coordinator 10-20 22:10): 81b, after 81a.
effort: low

Source (his words, 10-20 about 22:00, verbatim): "get rid ofd weapon card opopups when weapons are looted -- they are invasive and not helpful"
Where: the loot path raises the card about dark_raiders.html line 25786 (G.gunCard={gk:itm.gk,w:found,...}); gunCardHud (about line 21971) draws it
for GUNCARD_T=4 s (about line 21944). It came from his #17 answer 34 ("on pickup and in the backpack"); this newer order removes the pickup part.

What to do:
1. Looting a gun (a search, the floor, a body) no longer raises the card in a raid. The pickup stack row on the right edge (icon, name, where it
   went) stays.
2. The card stays where he looks on purpose: the backpack, the belt hover card, and the forge upgrade card in the Undercroft (about line 14078,
   not looting).
3. If the pickup stack still leaves room above for a card that no longer comes, close the gap only if that is a one-line change; else leave it.
Check (new, must fail on the build before): in a live raid, a gun picked up through the normal loot path leaves G.gunCard null and draws no card,
and the belt hover card still draws. If an old check asserts the pickup card (feat2b), retarget it in the same ship.
Pictures: a raid at 1080 right after a gun pickup, before and after.
Cut-off: FEATURES. Ship before Mon 10/26. Party risk: low.

TASK DONE when shipped with its check and pictures; TASK PARTIAL with what is left.
