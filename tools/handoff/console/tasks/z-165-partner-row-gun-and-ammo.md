# 165-partner-row-gun-and-ammo : the teammate row shows his gun and his rounds under the bars
Queue (coordinator 10-25 16:30): his 10-25 answer g-64, "Add ammo and gun" (notes/answers-100-1025.md; line numbers read on v34.83, check them on HEAD). He went against the suggestion here. Party fix (Fri 10/30 first): two players on one couch see what the other holds.
Since v34.81 the SMOOTH look is the default: test and take pictures in the smooth look.
effort: medium

Do: today netTeamHud (61186) draws per row the name, DOWN with seconds, a health bar and an armour bar (61203-61213) in a box 36 high (61206) on a 44 step (61203, _trh 61196). The st word (60417) carries the gun id (w, for example 'carbine') but no ammo, and the row never shows the gun. Build: the st word adds am (p.ammo, rounds in the magazine) and rs (rsvShow(p) 25478, the reserve as his own HUD shows it); the host relays both (58987) and the take stores them (58980). netTeamHud: a third line under the bars, the gun name (forgeName(g.w,g.fk), lowered by the text door) on the left and 'am / rs' on the right in TYPE.micro; nothing when he holds no gun (w empty or 'fists') or g.hd. Row box from 36 to 48 high, row step from 44 to 56 (the y step, _ty, _trh and NETTEAMBOX). If job 171 (endless spawn pistol) has shipped, rs is its infinity sign, already through rsvShow. Job 138 (hud size row) may scale this box: keep the new sizes inside its scale. Pictures at 1080p and 4K, both windows, smooth look: a row with a rifle, a row down, a row with fists. Check (fails today): feed a teammate word with w 'carbine', am 18, rs 90; draw netTeamHud with fillText captured: 'burst carbine' (any case) and '18 / 90' are drawn. Today neither is drawn. Watch line for DESIGN.md: the left column may crowd at 4K; the row must stay readable from the couch.

Rules: the seed 4242 fingerprint (ents 85/374, containers 165/593) must hold unless this brief says otherwise; the check must FAIL on the build before; both windows; player text all lower case. Say in DESIGN.md what he should watch for in a playtest.
TASK DONE when it shipped; TASK PARTIAL with what is left.

HIS PRIORITY 10-27 (priorities page): MEDIUM
