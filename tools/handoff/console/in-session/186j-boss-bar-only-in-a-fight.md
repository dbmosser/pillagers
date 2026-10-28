# 186j-boss-bar-only-in-a-fight : the Overseer bar shows only while you are fighting him
Queue: HIS ORDER 10-28, in the HUD Improver chat, with a picture (notes/186h/boss-bar-his-picture.webp: "the overseer" bar across the top while he walks among crawlers). Built by the HUD Improver (lane h). HUD polish.
effort: high (Opus)
Key: cw-bossbarfight

His words, verbatim:
"the overseer's health bar should go away unless i'm actively fighting him eg dealt damage in last few secs"

Build: drawBossBar shows the bar only for BOSSBAR_HOLD (4) seconds after a hit you or your partner landed on him (pHitT, set by every round, charge, blade and strike); a joined window, which does not hold the hit marks, counts a drop in his health. The seen-him-first rule (v18.74) stays.
Check (must FAIL on the build before): seen and near but not hit, no bar; a hit, the bar; 5 s later with no hit, no bar.
Watch-for line for him: whether 4 s is long enough between bursts, or the bar blinks during a fight.
TASK DONE when shipq prints ON HIS PC.
