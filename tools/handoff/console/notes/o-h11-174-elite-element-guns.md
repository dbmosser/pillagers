
--- codex run 2026-11-07 17:18 ---
2026-11-07, first run at v37.55.
Prepared cw-cx-eliteelements (14 exact anchors) and keys.txt. No game or fixture file was edited.
Elite selection uses roll/rate under 0.25 and four equal element bands, with forgeApply at fk 2. Damage follows the forged gun. No random draw was added. Enemy rounds keep no element and warning red, already present from cw-redtracers.
The death body records only its held unpaid gun with gk/fk/el. Loot consumes its forge once for the matching exact key. A body gun still consumes the old quality roll, but keeps the model and field baseline that the enemy actually held. Other guns keep their existing rolls.
Party container words validate/carry forge metadata. Loot words carry the current ownership of the one forged copy and reserve it on the host; left words preserve use state for takeover. Held-entity words carry forge tier/element so the remote gun has the same finish.
Local validation: mk prints written; all 14 anchors unique; patched game script and regression check parse. Isolated real blessElite/forgeApply functions with weapon fixtures, seeds 1-200, gave 252 forged / 984 elites (25.6 percent), exactly two draws per blessing. This is a local logic check, not a browser/preflight pass.
Regression check stages a real raid, samples elite blessing across seeds 1-200, checks two draws, damage/tint, plain red enemy rounds, kills a real mkRaider, verifies death-body metadata, round-trips body and entity packets, grants body loot locally and from the remote body copy, and proves one matching forged copy plus host reservation. It fails the old build at the zero-forged share before touching new helpers.
Two custom camera recipes request a naturally blessed elite fighting and the recovered gun comparison in the backpack, smooth look at 1080p. They use actual blessing/death/grant paths; the gun card stays in the backpack and no pickup popup is restored. Pictures and critic result are pending the lane. These recipes are solo staging, not evidence of a real two-window link.
Watch line is in draft why for DESIGN.md: element finds may make forge MK III feel less special; forged elites hit harder; watch find frequency.
LINKED REVIEW NEEDED: synced. Fields: cont.fw, loot.fw, ent.fk/fe. Need a real host/peer fight and body search in both windows, including partial body search/takeover and confirming the forged copy cannot go to both seats. Ship, ON HIS PC, camera critic and linked review remain with the lane/coordinator.
No known older check requires retargeting. tools/mkfixture.ps1 untouched.
