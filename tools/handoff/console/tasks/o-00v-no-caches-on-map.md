# o-00v no-caches-on-map : the sector map stops marking caches
HIS WORDS 10-29 ~11:40 EDT (to the CEO chat, with a screenshot of the Cold Storage M map showing about 20 "cache" words and their leader lines): "quit showing caches on the map, even if player burns a data slot.  It makes the map super messy."

What is on HEAD (v36.50), dark_raiders.html, drawMapOverlay (~50611):
- ~50774-50792: the "Meridian caches are marked" loop draws, for EVERY container with .cache (strongbox excluded only on the raid start map), a pulsing ring, a dot, mapIcon and, on the M map, mapLabel('CACHE' / 'LOOTED') with the label placer's leader lines. This is the mess in his picture.
- ~50941-50951: the Stray's told cache (.revealed) draws a ring, icon and the word CACHE.
- ~50831: G.intel (a burned Data Core) draws KEYCARD marks and elite triangles; it does not add caches, but his words say no caches with a Data Core either, so nothing in the intel block may mark a cache.
Build:
1. Delete the always-on cache marks: no ring, dot, icon, CACHE or LOOTED word for any .cache container on the M map or the raid start map, with or without intel. Keep the guaranteed caches in the world; only the map stops showing them.
2. KEEP: the strongbox (its own icon and STRONGBOX word, a named objective), locked rooms (foreman office, vaults, blast freezer: outline, keyhole, LOCKED/OPEN), KEYCARD intel marks, elite triangles, encampments, extracts, peddler, hot ground, waypoint, seal.
3. The Stray's told cache (his one reward for helping the Stray) keeps a single plain ring with NO word, so it stays findable without clutter.
4. If the minimap draws cache marks, remove them there too (same order).
5. The legend or any map key row that names caches: remove the row.
Check (must FAIL on the current build): open the M map in a fresh seeded raid: no 'CACHE' or 'LOOTED' text is drawn and no cache ring; set G.intel=1: still none; the strongbox and the locked-room words still draw.
Old checks: cw-nocachelbl, cw-cx-sectorhold-o03 and cw-cx-mapstart-clear checks that want the cache ring or word will go red: retarget them to the new rule (his order supersedes), list them in the ship note.
Rules: seed 4242 fingerprint must hold (draw only); both windows (P2's map too); never touch the pickup stack, loot sounds or loot rows. DESIGN.md watch line: "the map no longer marks caches". Take a uishots picture of the M map at 4K and look at it. Model: Sonnet 5.5 high.
TASK DONE when it shipped and is ON HIS PC.
