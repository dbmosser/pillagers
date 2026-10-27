o-92-fog-live-action-rest : with fog of war on, no live action draws out of sight: thrown grenades, smoke, death falls, body flames, machine damage fx (coordinator 2026-10-27)
effort: medium

Source: his words 10-27 (memory pillagers-fog-of-war-2026-10-27.md): "once I've seen it and walk away, it shows what's there but its
darkened and I can't see live action there unless I look at it". v35.14 (cw-fow) added fowLive(x,y) and gated tracers, sparks, smoke
puffs and blasts with it. Enemies and muzzle flashes were already sight gated.
Not done (coordinator, 10-27): these draw passes still draw out of sight with fog of war on (grep by name, line numbers move):
the G.throws loop in the air pass (grenades in flight), the G.smokes loop right after it, drawDeathAnims (a body falling), drawElemFx
(flames, arcs, frost, acid on bodies), gfxBodyFx / gfxDamageFx (machine damage smoke and sparks), and anything else in the air pass of
render2D that shows a moment happening rather than the ground.

1. In each of those passes, skip an item when !fowLive(x,y) at its world spot. fowLive returns true whenever CFG.fogWar!==1, so with
   fog of war off nothing changes. Do not gate the noise ring ("A NOISE YOU CANNOT SEE"): it shows a sound on purpose.
2. Smoke clouds that sit on the ground for many seconds: gate them too (he sees "what's there", not what is happening).
3. Nothing in the simulation changes: drawing only (CLAUDE.md rule 6).
Checks (each must FAIL on v35.14): with CFG.fogWar=1, stage one item of each kind at a spot behind the player and out of his sight
(the cw-fow check in tools/mkfixture.ps1, version 35.14, shows how to find such a spot and spy on wc calls over __frame(0)); nothing is
drawn there. Control: the same staging with CFG.fogWar=0 draws it. Delete own-property stubs on wc in finally.
Party risk: low (fog of war is off by default; drawing only).

TASK DONE when shipped and the checks pass; TASK PARTIAL with what is left.
