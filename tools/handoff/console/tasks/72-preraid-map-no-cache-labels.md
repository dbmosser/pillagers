72-preraid-map-no-cache-labels : the map on the second pre-raid screen shows no cache labels (his order 2026-10-20 evening)
effort: medium

Source (his words, 10-20 about 21:35, verbatim): "map on this second preraid screen should not have caches labelled, makes the whole thing look messy"
His picture: tools/handoff/console/notes/his-shots/2026-10-20-preraid-map-cache-labels.png (the sector map at raid start: about ten "cache" words with
long leader lines run off the left edge, and a cut-off "...ngbox" (strongbox) word, over extracts a, b, c, the encampments, vault a and b, the
foreman office and blast freezer, hot ground, seal 35% and the peddler).
Where: the sector map draw labels each cache with mapLabel(CQ.opened?'LOOTED':'CACHE', ...) about dark_raiders.html line 47351 and the strongbox
with mapLabel('STRONGBOX', ...) about line 47479 (both from cw-cx-sectorhold-o03). The "second pre-raid screen" is the map that opens when the
raid starts and holds the clock (MAPFIRST, see done/o-03-map-popups-wait.md); confirm it on a picture before changing anything.

What to change:
1. On that screen, no cache word, no looted word and no strongbox word, and none of their leader lines. Keep the small cache and strongbox icons
   (so a player can still see where they are) unless the icons alone still look cluttered on the picture.
2. Keep every other label: extracts, locked rooms, encampments, vaults, the peddler, hot ground, the seal, the player arrow.
3. My call: change only the raid-start map. If the in-raid map (the m key) draws the same mess, leave it alone and note it in DONE so the
   coordinator asks him (logged question: drop cache words on the m map too?).
Check (new, must fail on the build before): draw the raid-start map on seed 4242 and count the labels: 0 with cache, looted or strongbox text,
the extract labels still there; the seed 4242 fingerprint holds.
Pictures: the raid-start map at 1080 and 4K, before and after, with his picture next to the before; run the critic on the after picture.
Cut-off: FEATURES (a removal, low risk). Ship before Mon 10/26.

TASK DONE when shipped with its check and pictures; TASK PARTIAL with what is left.
