# 00p-m3c-death-pips notes (run 11-08)
Key cw-m3death. mk: S\mk-cw-m3death.ps1, check S\mk-cw-m3death.check.js. 00p-m3a-drops is in done/, so no wait.
Design: helpers wornOwnRaid / wornOwnList / wornLostV / wornLostLine / wornPipGain beside pilRaidEnd. pilRaidEnd sets P.worn={} after pilEnd copies it (dead or quit only; the free walk-back returns earlier in endRaid). KIA card: one row per worn piece (icon key wg_k_r_1_0 draws the kind icon, np), count "and n worn pieces", $ gone and hall end.lost add Math.round(wornPrice*lootMult). Quit card lists them too. Safe pockets: the nSafe pick skips wg_ keys. Extract: wornPipGain after the extraction bonus line.
Old check retargeted: 37.29 (cw-m2death) lines on end.lost and end.worn, commit 222ab0348 (holds on old and new build).
