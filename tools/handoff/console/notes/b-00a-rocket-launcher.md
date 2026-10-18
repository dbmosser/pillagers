# b-00a-rocket-launcher
- Step 1 SHIPPED earlier: v29.15 (gun keys renumbered, rocket class on 0).
- Step 2 SHIPPED earlier: v29.18 (rocket launcher on key 0).
- Step 3 (remove Marksman + Whisper entirely): run 5. No mk-cw-remove script exists yet; plan = ONE mk script cw-gunsgone.
  Sites (line numbers of build at run 5; grep ^(?!\s*//).{0,250}(dmr|whisper) ): WEAPONS 2922 dmr, 2942 whisper; WTIER 2963; ITEMS 3242/3243;
  loot tables 3359,3367,3369,3370 (swap for other gun, SAME weight so fingerprint holds); 4596 {kind:'wep',k:'dmr'}; sfx 7755/7761;
  12918 pool; 13553 PED_GUNS; 13627; 15238; 21140/21144 recoil; 21859-21889 reload foley; 22083 raiderRole; 23173 GEAR_LIGHT; 23191 DRAWT;
  27706; 30122/30140/30147 rank rewards; 32883/32896 gun draw D.whisper D.dmr; 33886/33887; 42089/42091 fam map, 42149/42254 can; 47637/47639/47686 trades; 48438; 56231 ARCADE_GUNS2; 56378 vault guns; 50851 text; 2511 what's new line (old news, leave? 'marksman' key 7).
  Save migration: applyLoadedProfile at ~4119, gunKeysMigrate at 23370.
