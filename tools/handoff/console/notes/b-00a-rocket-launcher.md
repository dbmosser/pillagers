# b-00a notes
PLAN: keep GUNKEYS=9/HOTBAR_N=9 cells. GUN_CLASSES (line ~23147) becomes 8 classes + 'rocket' on cell index 8 labelled "0" (key Digit0). Key 9 unused.
Files facts (line numbers of build 29.11):
- WEAPONS table ~2774 (dmr 2774, whisper 2794, lance 2795); WTIER 2812; ITEMS gun_dmr 3091/gun_whisper 3092; loot tables 3207-3218
- GUN_CLASS_OF 23148, GUN_CLASSES 23147, GHOST_OF 37194, GUN_CLASS_ICON 48533, GUN_FAMILY 41488 (art in gunArt 41507/gunIcon 41610 by fam)
- sfx gun table 7588-7595; recoil table 20941-20946; DRAWT 22973; bullet spawn ~21058 fn near 21087; 21865 aim class
- other refs: PED_GUNS 13355, 13429, 12720 pool, 27478, 29927 (lance sp), 46981-47031 kits/recipes, 47783, 55692 ARCADE_VAULT_GUNS
- belt label: String(q+1) at ~37345; 'to slot '+(at+1) ~23225
Status: nothing shipped yet.
