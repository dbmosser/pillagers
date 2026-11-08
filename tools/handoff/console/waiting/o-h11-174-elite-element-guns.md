# 174-elite-element-guns : a quarter of elite pillager bots carry a forged element gun you can take from the body
Queued 11-07 by Codex Correspondent on OVERLORD order: the owner answered these (his-review, 10-28); build it. Read the job body for his words. Build at HEAD (line numbers may be old).
Codex: never change tools/mkfixture.ps1; if a check must change, put the finding and exact change in your notes and stop. Owner quotes below are binding as written.
Queue (coordinator 10-25 16:30): his 10-25 answer g-36, "Yes, a rare element gun" (notes/answers-100-1025.md; line numbers read on v34.83, check them on HEAD). Not needed for the party: release work for Thanksgiving.
Since v34.81 the SMOOTH look is the default: test and take pictures in the smooth look.
effort: medium

Do: today an elite pillager bot (CFG.eliteRate 0.08, blessElite 15094) gets a better plain gun from a weighted pool; no bot gun is forged. Elements exist only on MK III guns made by forgeApply (4490, which also sets the tint to the element colour). Only player rounds carry an element (the fireWeapon el line about 24748). A forged gun comes out forged only from a dropped pile (the loot path at 26354 requires ct.dropped; the pile records c.fw at 24928 and 24983, with no gun key). Build: in blessElite, for an elite pillager bot, with no new draw: frac=roll/rate (where the elite roll fell, 0 to 1). When frac<0.25 (a quarter of elites, about 2 percent of bots), e.wep=forgeApply(WEAPONS[_gk],2,ELEM_ORDER[Math.floor(frac/0.25*4)]) and e.dmg=e.wep.dmg (check that forgeApply draws no rnd; the build counts must not move). His rounds stay plain, and his gun art draws in the element colour (forgeApply sets the tint). His tracers are warning red if job 140 (red enemy tracers, g-88) has shipped, which beats the element tint for enemy rounds; if 140 has not shipped yet, leave the tracer to it. On death, the body container (31270) records ct.fw={gk:'gun_'+e.wep.id,fk:2,el}. The loot path at 26354 also applies fw on a body, once and only to that gun key: (ct.dropped||ct.fw.gk===key) and mark it used. Co-op: the cont word (netContNewWord 63147, read in netContMake 63296) carries the fw fields so a party search gets the forged gun. Pictures at 1080p: an element elite in a fight and the gun card from his body. Check (fails today): over seeds 1 to 200, elite pillager bots with wep.fk===2 and an element exist and make up 15 to 35 percent of elite bots; in a staged raid, kill one and search the body: the gun comes out with fk 2 and that element. Today no bot gun ever has fk or el. Watch line for DESIGN.md: element guns from bots may make the forge's MK III feel less special, and a MK III elite hits harder; watch how often he finds one.

Rules: the seed 4242 fingerprint (ents 85/374, containers 165/593) must hold unless this brief says otherwise; the check must FAIL on the build before; both windows; player text all lower case. Say in DESIGN.md what he should watch for in a playtest.
TASK DONE when it shipped; TASK PARTIAL with what is left.

HIS PRIORITY 10-27 (priorities page): LOW

Lane note 2026-11-07 17:53: shipped cw-cx-eliteelements and parked: only lane-side steps are left. Codex's last words:
v37.56 is shipped and confirmed on his PC. Pictures show the forged elite and recovered shock MK III.

Critic scores remain 2. Its requested exit-arrow removal conflicts with check 35.50; documented for the coordinator without editing the fixture.

TASK PARTIAL: coordinator must resolve the HUD/check conflict and complete real linked-window verification.
