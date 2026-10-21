81a-ads-breaks-sprint : aiming stops a sprint at once, even with Shift still held (his order 2026-10-20 evening)
Queue (coordinator 10-20 22:10): 81a, after the size jobs and before the minimap and corner jobs.
effort: low

Source (his words, 10-20 about 22:00, verbatim): "ADS should immediately break sprint, even if shift is still held down"
Where: dark_raiders.html about line 28217, v16.81 "A SPRINT TAKES YOU OUT OF FOCUS AIM": with Shift held and moving, aim is dropped every frame
(and a pad aim toggle let go). About line 28226: if(p.ads) sprint=false. This newer order reverses v16.81: aim wins over sprint.

What to do:
1. Pressing aim (right mouse in either Settings AIM mode, or the pad's LT) ends a sprint the same frame, and aim holds while Shift is still down:
   no sprint speed, no stamina spent, no sprint scent (28226 already does this once p.ads holds).
2. Remove the v16.81 drop of aim while Shift is held. The crouch line under it keeps its !p.ads test.
3. Aim let go with Shift still held: the normal sprint rule applies again (Shift, moving, breath), so the sprint comes back.
   A pad sprint toggle (stick click) is let go when aim starts, so it does not restart by itself.
4. Player 2 on a pad follows the same rule.
Check (new, must fail on the build before): in a live raid, moving with Shift held and full breath, aim on: after one frame p.ads is still true and
G.sprinting is false; aim off with Shift still held: sprinting again after a frame. If an old check asserts the v16.81 drop, retarget it in the same ship.
Pictures: none needed (no screen change); say so in the DONE note.
Cut-off: FEATURES. Ship before Mon 10/26. Party risk: medium (controls feel): tell the coordinator what he should watch for on his next play.

TASK DONE when shipped with its check; TASK PARTIAL with what is left.
