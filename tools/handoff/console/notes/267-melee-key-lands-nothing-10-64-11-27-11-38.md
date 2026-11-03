# 267 notes (lane h, 11-02 night)
Suspect (from the code and the run files, before any Chrome):
- v35.74 cw-meleez (10-28 09:21, his order): melee sits on the Z key, drop on the V key. keyRemap('KeyV') is 'KeyZ' on the defaults.
- fixture helper __meleeKey() still returns 'KeyV', all 7 uses are in 10.64, 11.27, 11.38. So these press the DROP key. Check 35.74 THREE says "V swung the crowbar" is wrong.
- All three red in EVERY stored run from corpus-1028-0934 (v35.76, first run after v35.74) on; corpus-1028-0755 (v35.66) has them green. corpus-1101-1520 (v37.17) has all three RED too (job text says green: wrong).
- 25.67 has the same fault (line about 53901 presses KeyV by hand).
