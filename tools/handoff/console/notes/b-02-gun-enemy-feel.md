# b-02-gun-enemy-feel
Findings:
- Camera shake: G.shake set by fireWeapon (line ~21706 area) via gunShake(wep) + GUN_SHAKE table (new). gfxTrauma: trauma += rise/14 only when shake RISES, size A=18px*tr^2*hudRes. Decay 1.4 trauma/s; G.shake decays 26/s.
  So single 2.2 = 0.16 trauma = 0.44px (invisible). Held SMG (88 ms) rise .157 > decay .123 per shot: creeps up (to probe).
- Starting guns: pistol, smg, rifle, shotgun (SIM_START). Hit-stop: HITSTOP_DMG 40 only (pistol/smg/rifle never stop a body).
SHIPPED:
- cw-kickshotgun v30.35: shotgun shake 2.2 -> 6.5 (0.4 -> 3.9 px).
TODO order: smg (probe creep), pistol 3.6, rifle, lmg; then enemies (3 most common: check hit reaction hitT .16, death punch).
