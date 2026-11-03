# 267 notes (lane h, 11-02 night)
Suspect (from the code and the run files, before any Chrome):
- v35.74 cw-meleez (10-28 09:21, his order): melee sits on the Z key, drop on the V key. keyRemap('KeyV') is 'KeyZ' on the defaults.
- fixture helper __meleeKey() still returns 'KeyV', all 7 uses are in 10.64, 11.27, 11.38. So these press the DROP key. Check 35.74 THREE says "V swung the crowbar" is wrong.
- All three red in EVERY stored run from corpus-1028-0934 (v35.76, first run after v35.74) on; corpus-1028-0755 (v35.66) has them green. corpus-1101-1520 (v37.17) has all three RED too (job text says green: wrong).
- 25.67 has the same fault (line about 53901 presses KeyV by hand).

Probe cw-d267 answered (spare PC, base 739a1dac, drafted 37.41, clean page, no slice before it):
km{} v3 V>KeyZ Z>KeyV of=KeyZ po0 mf0 gp0 se0 ro0 ck0 md[] bare(smg,30) V:m0d0 Z:m1d0 fn=trued0 rifle V:m0d0 Z:m1d0 a25 / NOW 10.64:with a rifle in hand, F 11.27:F did not swing 11.38:control: a melee swing FOLLOWMAP 10.64:ok 11.27:ok 11.38:ok
Read: no leak (no pause, map hold, modal, roll, search). V never swings, Z swings. The three fail ALONE with the old helper and pass with a helper that follows the key map.
OPEN: my probe's Z swing shows d0 (swing, no damage). Suspect my staging: arm() does not reset p.face, and the first __loop turns him to the mouse. kit:[] is also not bare hands (it reads smg,30). Must be proved with a corrected probe, not assumed.

Retarget committed 8a954a526 (22:22, fixq, lock held under a minute): __meleeKey and __meleeKeyName read keysOf('KeyV'); 25.67 mkM uses __meleeKey(). Probe cw-p267 next: player path with re-facing, real fists, the d0 question, and the real check objects.

Probe cw-p267 answered (spare PC, base 8a954a526, drafted 37.42, clean page; result=FAIL only because the probe always answers with text):
dealt(smg) V:m0d0/0 Z:m1d43/43 fists(mag0) V:m0d0/0 Z:m1d43/43 rifle V:m0d0/0 Z:m1d43/43 a25 fn=trued43 face=-1.57 stale d0 aimed d43 / helper KeyZ,z km{} 10.64:ok 11.27:ok 11.38:ok 25.67:ok 35.74:ok
Read: Z swings and hurts a pillager in reach, with a gun, bare hands and a rifle, no round spent. V never swings. d0 in the first probe WAS my staging: one frame turns him to the mouse, a swing not faced at the target misses. No player fault.
Next: slice probe cw-s267. Full run corpus-1102-2152 is on v37.40 with a frozen copy, so it cannot show the retarget. The next full run can.

Probe cw-s267 answered (spare PC, base has 8a954a526, drafted 37.42, one page; always answers with text):
A i38=2691 i64=2760 ran 2640-2691 n51 14s km{} md[] 11.38:ok 11.27:ok 10.64:ok red 11.96,11.86,11.67,11.63 / B i38=2691 i64=2760 ran 2666-2707 n41 81s km{} md[] 11.38:ok 11.27:ok 10.64:ok* red 11.67,11.63,11.29
Read: no leak up to 11.38. * = 10.64 ran after the time cap, not in its place. Probe cw-t267 covers 11.27 through 10.64.

Probe cw-t267 answered: ran 2701-2711 of 2701-2760 n11 155s km{} md[] 11.27:ok 10.64:not reached. Those checks are slow; a probe has 180 s. Stopped probing: the next full run shows it.
State at the end: no game change, no ship. Retarget 8a954a526 is on master. Full run corpus-1102-2152 started 21:52, before the retarget, on a frozen copy: the three WILL read red in it, which says nothing about the fix.
Remaining: read 10.64, 11.27, 11.38 (and 25.67) in the first full run whose test copy holds 8a954a526. Then take the v25.67 line out of tools/handoff/stable-known-red.txt (its header says remove once a full run passes).
Job text is wrong on one point: corpus-1101-1520 has all three red. Last green stored: corpus-1028-0755 (v35.66). First red: corpus-1028-0934 (v35.76), the first run after v35.74.

FINAL REPORT (00:05 11-03; written here too because SubagentHandback was refused once: "Only the auto-mode classifier can allow SubagentHandback: the session is not in auto mode")
Cause: tests press the wrong key. Since v35.74 melee is on Z and V is drop (his 10-28 order); __meleeKey() still sent KeyV. Game is fine, no player can hit it.
Changed: fixture only, 8a954a526, on origin/master (__meleeKey, __meleeKeyName follow the key map; 25.67 uses __meleeKey). No ship. Master v37.41.
Seen pass, all on a drafted v37.42 with the retarget: 11.38 and 11.27 in a clean page, after 51 earlier slice checks, and in their own place. 10.64 in a clean page and after 51 and 41 earlier checks, NOT in its own place. None seen in a full run.
corpus-1102-2152 predates the retarget: the three will read red in it, which says nothing about the fix. Read the first full run whose test copy holds 8a954a526; then take v25.67 out of stable-known-red.txt.
Flipscan: CLEAN: 6 commits, 20 changed line pairs, 2 digit-only changes passed
TASK PARTIAL: 10.64, 11.27 and 11.38 passed on the spare PC but have not been seen in a full run; read them in the first full run whose test copy holds 8a954a526, not corpus-1102-2152.
