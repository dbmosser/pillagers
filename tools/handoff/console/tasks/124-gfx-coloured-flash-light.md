# 124-gfx-coloured-flash-light : blasts, shots, hunting machines and the beacon light the ground in their own colour (I2)
Queue (coordinator 10-25 10:05): his question "What else can you do to improve graphics?" (Sun 10-25). This is the unfinished part of his
10-12 graphics list, which he ordered in full ("add ALL of this stuff", memory note pillagers-graphics-program-2026-10-12). Sorts after
the party fixes 117 to 121. Not held for the party (his 10-20 order); ship with a DESIGN.md line on what he should watch for.
effort: small

Idea I2 (the unfinished half of plan gfx9). The lamp light map is coloured, but every dynamic light (flashes, rings, machine eyes, the
extraction beacon, the teammate lamp) is stamped in white. Use the colour each source already stores. Do not change REDUCED FLASHING
(on by default, his answer 2.61): fewer, shorter flashes stay as they are.

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

Coordinator 10-25 11:19: the stale index is fixed (shipone.sh now refreshes it), but shipq.sh cw-flashlight then STOPPED at 11:15: "verifySafe did not pass" on top of v34.76 (job 127 glow pools also works in the light pass). Rebuild the draft on HEAD, run preflight until PASS, then ship.
