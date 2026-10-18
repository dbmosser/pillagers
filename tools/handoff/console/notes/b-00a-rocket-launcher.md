# b-00a-rocket-launcher
- Step 1 SHIPPED: v29.15. Step 2 SHIPPED: v29.18.
- Step 3 (remove dmr + whisper): run 5. Plan: ONE key cw-gunsgone. Hits (line nums as of run 5, grep '^(?!\s*//)[^\r\n]{0,160}(dmr|whisper)'):
  WEAPONS 2929/2949, WTIER 2970, ITEMS gun_dmr/gun_whisper 3249-50, LOOT 3366/3374/3376/3377, CGEAR 4603, sfx 7762/7768,
  12925 pool, 13560 PED_GUNS, 13634, 15245, RECOIL 21147/21151, reload foley 21866-70/21896, 22090 role, 23180, 23198,
  27713, 30129/47/54 (SP unlock ladder), 32890/32903 draw D., 33893/94, 42096-98, 42156/42261 (suppressor can), 47644/46/93, 48445, 56238, 56385.
- Need: saved dmr/whisper item -> credits/ammo in applyLoadedProfile (read ~4126).
