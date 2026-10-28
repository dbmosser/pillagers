# 218-red-35.81-preraid-names-and-ledger : v35.81 (condition reward readability) turned 4 older pre-raid and ledger checks red
Queue (JTPC Correspondent 10-28 15:30; runs corpus-1028-1222 on v35.83 and corpus-1028-1346 on v35.89 on the spare PC, red in both, green in corpus-1028-1057 on v35.80). Fix, MEDIUM: one of the four is a name he can see cut to dots on the pre-raid screen. These 4 block stable.
effort: medium (Opus high; a layout fix with pictures, not a one number change)

Suspect ship: v35.81 (c78ad122d, cw-cx-condition-ui, a critic round run while he was away, not his order). It added <style id="cx-condition-ui"> (sector modal, terms modal, the .lg ledger) and raised the pre-raid zone name size in sectorPreviewDraw from fs=20 to fs=24 (git log -S'fs=20,' between v35.80 and v35.89 finds only this ship).
Not bisected for 33.48 and 28.71: confirm each on v35.80 vs v35.81 first; if one turns red later (v35.82 renamed pillagers and machines, v35.83 final rush), say so and fix it there.

The four checks (fail text from the spare PC):
- 33.48 the pre-raid pack names are shown whole beside the buy slot (kit column 480 px at most), and a buy control is never lime -> "names cut to dots: BURST CARBINE (FIELD)". A player sees this. Fix the game: the kit row must show the whole name (the new 16 px .kitb .kd rule and the 24 px #srkitcol gap are the first suspects). mkfixture.ps1 about line 16638.
- 32.53 the pre-raid map draws its zone names at 20 px, shrinking to no less than 14, and exit and keyed room names at 18 -> "zone names do not start at 20 px; zone names can shrink below 14 px; exit names are not 18 px; keyed room names are not 18 px". mkfixture.ps1 about line 19936.
- 17.82 each sector row is tall enough to hold its map, zone names 20 px -> "the zone names are not 20 px" (it reads fs=20 in sectorPreviewDraw source). mkfixture.ps1 about line 72522.
- 28.71 (his order 10-15, score as SP) every score figure reads N SP in the CAREER ledger -> "the KILLS row reads , not 600 SP": the KILLS .lgr row is found but its value is not in a <b> any more, or the label changed. mkfixture.ps1 about line 32067. Fix the game if the row lost its value; retarget only if the value is there and the markup moved.

Zone names (32.53, 17.82): 20 px start was his pick (design A, 10-20, check 32.46 notes). The 24 px came from a critic, not from him. Take pictures of the pre-raid map at 1080p and 4K with 20 and with 24. If 24 fits every zone without spilling and reads better, keep it and retarget both checks to 24 (keep the shrink floor of 14 and the 18 px exit and keyed room names, and check whether those moved too); if any name spills or crowds, go back to 20. Say which in DESIGN.md with the pictures.
Check (must FAIL on v35.89): on the pre-raid screen at 1080p every pack name in the kit column is shown whole (scrollWidth <= clientWidth and no ellipsis), and the CAREER extraction ledger KILLS row reads 600 SP for g.cs.b.kill 600. Then run 33.48, 32.53, 17.82 and 28.71 alone: all pass.
Rules: menu styling only; the v35.81 readability gains (Terms header, larger rewards) stay unless they cause the cut; no storage key change; seed 4242 fingerprint unchanged; looting and pickup rows are never touched.
TASK DONE when the four checks pass, pictures are taken and looked at, and it is ON HIS PC.
