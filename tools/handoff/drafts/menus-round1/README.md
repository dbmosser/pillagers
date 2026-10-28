# Menus round 1 (menus master, cloud, 2026-10-28)

His ask 10-28: "can you continue to refine menus?" Survey of 16 menu screens at v35.85 (survey-sheet0..3.jpg, cloud camera cshots.mjs runs the uishots recipes headless).

## cw-pausecond (his pause order, completing it)
cw-pausesp listed the settings but not the raid conditions that pay sp since cw-cx-condition-sp (night, hard weather, signed terms, x1.05 each). They are rows now; a clear day shows one muted "conditions none" row; the headline is settings times conditions.
Retarget in the same ship: 35.75 (my cw-pausesp check) compared the headline with the settings alone. retarget-cw-pausecond.patch makes it settings times conditions.

## cw-menupolish1
- Mainframe contract card paid "320 c"; now "$320" (his rule: $ for money).
- Achievements list: the word "LOCKED" was glued to each locked name ("locked first out"); now a lock icon, locked names muted, an earned name in the emblem gold.

## Left alone on purpose
The hire banner "***experimental feature may glitch***", "buy a friend.", "stuff for you to do.", "no history between you." and the crafting and notoriety descriptions are his own words (TXSHIP values).

## Gates (base v35.85 with the card stamp moved and the 35.75 retarget, for gating only)
cw-pausecond PASS, cw-menupolish1 PASS (parse, new x2, fail on v35.85, newest 80 with 0 new failures, fingerprint 85/374 165/593).
Ship order: 35.75 retarget, cw-pausecond, cw-menupolish1. The card stamp is 35.71 on v35.85; ship cw-cardstamp first if a gate says it is stale.
