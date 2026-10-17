# 06-corpus-fix notes
Rows this run: 57 (11.97), 58 (11.96), 59 (11.95), 60 (11.91), 61 (11.90), 62 (11.83), 76 (9.82), 21 (23.56).
Design facts: GUNKEYS=9, BELT_CLASS all 'gun' so guns drag/plan to ANY of keys 1-9 (not refused); items refused with 'ITEMS GO ON THE WHEEL' by planPut.
Plan: 11.97/11.95 pistol on key 6 is now ACCEPTED (retarget); 11.96 items refused, single gun packs one; 11.91 drop part TWO; 11.90 find hand cell via hotbarSlots k gunA;
11.83 use wheelHeal('stim'); 9.82 SKIP; 23.56 SP forms via arcadeCr/arcadeN.
List file: notes/chk-06.txt. Flow: lock.sh, edit mkfixture, HELD=1 fixq.sh, runchk.sh, unlock.
