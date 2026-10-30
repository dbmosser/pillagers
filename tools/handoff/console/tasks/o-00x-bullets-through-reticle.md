# o-00x bullets-through-reticle : a shot's streak passes visibly through the reticle centre
WAITS FOR THE PARTY FREEZE (do not build before Sun 11/1 01:00).
HIS WORDS 10-29 ~22:40 (to the CEO chat). I told him: "Bullets also fly at gun height in the 3/4 view, so they can look slightly above the line you aimed." He answered: "i think this is the problem". Before that he asked: "ideally bullets should go through the center of the reticule, right?"

What is on HEAD (v36.55): fireWeapon (~25528) aims from the shooter's centre (sh.x, sh.y) at the cursor point (tx, ty): base=atan2(ty-sh.y, tx-sh.x), plus spread (bloom, moving, lmg heat; steady 0.4x). So the sim line runs through the reticle. The bullet and its tracer are DRAWN lifted to gun height in the 3/4 pass (and the muzzle flash sits at the gun), so on screen the streak runs parallel to and above the aim line. It looks like the bullets miss high of the reticle.
Build (render layer only, never the sim; hit tests, line of sight and seed 4242 stay exactly as they are):
1. A player's round is drawn so its streak passes through the reticle centre. Start the drawn lift at gun height at the muzzle and blend it to 0 (ground level, where the sim point is) by the aim point, or across the first ~N px. Pick whichever reads cleanest in pictures, and keep the muzzle flash at the gun.
2. Same for the partner's rounds in both windows (netFxShot) and the pillagers' rounds, so all tracers read the same way.
3. Impacts, puffs and hit sparks stay where the sim hit is.
Check (must FAIL on v36.55): fire a still, zero-spread shot at a cursor 300 px away; the drawn streak's screen point at the cursor distance lies within 3 px of the reticle centre. Same in the P2 window.
Pictures: uishots at 4K, still shot and moving shot, both windows. Look at them.
Rules: render only; seed 4242 fingerprint must hold; both windows; never touch the pickup stack, loot sounds or loot rows. DESIGN.md watch line: "bullets now run through the middle of your reticle". Model: Opus 5.5 high (rendering; a feel change he will judge).
TASK DONE when it shipped and is ON HIS PC.
