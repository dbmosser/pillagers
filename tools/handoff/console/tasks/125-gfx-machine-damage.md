# 125-gfx-machine-damage : machines smoke at half health and spark near death (I4)
Queue (coordinator 10-25 10:05): his question "What else can you do to improve graphics?" (Sun 10-25). This is the unfinished part of his
10-12 graphics list, which he ordered in full ("add ALL of this stuff", memory note pillagers-graphics-program-2026-10-12). Sorts after
the party fixes 117 to 121. Not held for the party (his 10-20 order); ship with a DESIGN.md line on what he should watch for.
effort: medium

Idea I4 (item 4 of his list, never started). A live machine trails dark smoke under half health and spits sparks with a stuttering
eye near death, so players see which one to finish, in both windows. Never use G.smokes (they block sight, about line 28067): use
clock-driven puffs like the wreck smoke, sparks from the fx stream. The hooks gfxBodyFx (about line 52914) and gfxOnDeath (about 53199)
are empty stubs meant for this.

Read first: notes/graphics-next-1025.md (where the 10-12 list stands, the 4K frame budget, his look rulings and vetoes; your
idea is the I-number named above, with its line numbers and cautions).
Rules for every graphics job:
- Render layer only. Any randomness from the cosmetic fx stream (fxr/fxn), never rr, rnd or pick: the seed 4242 fingerprint (ents 85/374,
  containers 165/593) must hold. No change to the simulation, sight, saves or the storage key salvagerun:profile.
- 2.5D canvas only: no WebGL, no shaders, no outside art or libraries. Both looks (pixel, the default, and vector) keep working; in the
  pixel look draw on whole art pixels.
- Frame cost: the 4K budget is tight in busy frames (1-in-20 frame about 16 ms at 4K with two windows on v34.18). Hang the new drawing on
  the quality ladder (GFXQ, gfxqCan) so a busy frame sheds it first, scale it by EFFECT INTENSITY where it is an effect, and measure its
  cost at 4K with both windows before and after (the game frame telemetry, or tools/fuzz.ps1 -Size 3840x2160 on a scratch port, never
  8802). Write the numbers in the ship's DESIGN.md section.
- Pictures: take before and after pictures at 4K and 1080p (tools/uishots.ps1 or tools/handoff/shots.ps1) and look at them; both
  player windows.
- Checks (each must FAIL on the old build): the new drawing happens when it should, does not happen when it should not (the quality
  step, the setting off), and costs under the budget you measured.
TASK DONE when it shipped with pictures and frame numbers; TASK PARTIAL with what is left.

Coordinator 10-25 11:19: shipped by the coordinator as v34.74 (0dfa49fbd) after the stale index was refreshed. Do only what is left: 1080p and 4K pictures (both windows) and the 4K frame numbers; add the numbers to notes and, if they belong in DESIGN.md, ship them with the next change. No second ship of cw-machdmg.

Coordinator 10-25 11:52: his photo of v34.78 (notes/his-photo-notes-1025/bulwark-and-wallet-v3478-1080.jpg, recipe recipes-bc.json screen gfx-b-machine-damage, one bulwark at 40% and one at 10% health) shows NO smoke on either machine and one orange pixel spark on the 10% one. The effect does not read at 1080p zoom 3: find why (drawn under the name plates, too faint, too small, or not firing in that state) and make it read in that picture. Job 120a makes the bulwark bigger; put the smoke on the new body.

Coordinator 10-25 16:30: his 10-25 answer g-83, "Smoke and sparks only, as now" (notes/answers-100-1025.md; line numbers read on v34.83, check them on HEAD), folded into this job: his pick names this job's smoke and sparks as the only damage cue on a machine, so the two ship together. The question left one thing out: every machine is named (mkName at 15124, 15142, 15283, 15386, 15442, 15459, 15483, 15490) and the nameplate loop in _wtA draws a 3 px health pip under any visible named body once it is hurt (41270-41275, if(ne.hp<ne.maxhp){ ... fillRect(ne.x-tw/2-4,ne.y-lift+5,(tw+8)*fw,3) }), so today a hurt machine also shows a small bar.
Add (g-83), only after the smoke reads in the 1080p picture, so a nearly dead machine never goes unreadable: at 41271 change if(ne.hp<ne.maxhp){ (it occurs once in the file) to if(ne.hp<ne.maxhp&&!GFXDMG_KINDS[ne.kind]){. Pillager bots, the hire, strays and the peddler keep their pip; machine nameplates, smoke and sparks stay; the Overseer (kind warden, boss) keeps its top boss bar (drawBossBar 42925). Render only. Code comment: v34.xx (cw-nomachpip), his pick 'smoke and sparks only'. Job 120a (its line 16) mentions the machine health pip above the bulwark: after this ship machines have none, so its check looks at the name plate and the alert mark only.
Check (fails today): live raid fixture: a sentry in view at 50 percent health and a hostile pillager bot at 50 percent, both in VIS; render2D with a wc.fillRect spy: no 3 px high fill at the sentry's pip row (ne.y-lift+5) while the pillager bot's pip is drawn. Today the sentry's pip is drawn.
Watch line for DESIGN.md: the question did not tell him about the pip, so watch that he really wants it gone; until the smoke reads at 1080p a nearly dead machine is hard to spot.
