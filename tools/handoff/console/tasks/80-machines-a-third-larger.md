80-machines-a-third-larger : the machines draw 33% larger (his order 2026-10-20 evening)
Queue (coordinator 10-20 21:40): renumbered from 73 so the pick order follows the plan (his 10-20 evening play notes go first, camera first, then the sizes, the minimap before the corner block).
effort: medium

Source (his words, 10-20 about 21:40, verbatim): "enemies need to be like 33% larger"
My reading (logged question, take this and do not wait): "enemies" = the machines (sentry, crawler, warden, choir, listener, bulwark, howler,
crier). Pillager bots stay the size of a pillager (they share the pillager painter; a bot bigger than you would read as a different kind of thing).
The peddler and the stray survivor are not enemies and stay as they are.

Where: the world draw sends every machine through one dispatcher, dark_raiders.html about line 39890 (if(e2.kind==='choir') drawChoirS(e2);
else if warden ... sentry ... crawler ... snitch ... listener ... howler ... bulwark). The map preview draw has its own sentry call about line 47996.

What to change:
1. Draw each machine kind 1.33x around its foot point (wc.save, translate to e2.x,e2.y, scale, translate back, restore), in the world draw only,
   with one constant (for example FIG_MACH=1.33) so he can ask for another size later. The shadow, elite ring, affix mark, windup glow, hit flash
   and the health bar position follow the bigger body (nothing floats inside it, nothing is cut off).
2. Shots must hit what he sees: the bullet hit test against a machine uses its radius times FIG_MACH. Movement and wall collision (doors, the nav
   grid) stay as they are, so no machine gets stuck in a doorway; say so in the DONE note, and say if any kind now overlaps walls in a picture.
3. Never touch the layer split: simulation and AI keep their flat coordinates; this is the render size plus the bullet hit radius only.
Check (new, must fail on the build before): draw one of each machine kind to a test canvas and assert each one's drawn bounds are 1.33x (within
2%) of the old bounds, and that a shot passing at 1.2x the old radius now hits; the seed 4242 fingerprint holds (ents 85/374, containers 165/593).
Pictures: the lineup scene (tools/handoff/art-survey/recipes-x.json, lineup) and a raid fight picture at 1080, before and after.
Cut-off: FEATURES. Ship before Mon 10/26.
Party risk: medium (bigger hit area makes machines easier to hit; feel is his call). Tell the coordinator to ask him to watch whether fights got
easier and whether the bigger machines block his view in tight rooms.

TASK DONE when shipped with its check and pictures; TASK PARTIAL with what is left.
