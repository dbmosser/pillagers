68-head-scale-body : the 1.2 head scale also scales the shoulder caps, pauldrons and chest marks (planner draft 2026-10-20)
effort: medium

Source: tools/handoff/console/notes/55-retarget-repairs.md: "v32.64 also scales every body shoulder caps by 1.2"; done/40-art-player-look.md: "a05 B: ... the vest and pauldron plates 1.12".
Not done (planner, 10-20): dark_raiders.html 36150 opens wc.scale(FIG_HEAD,FIG_HEAD) ("the mascot head, hats and ...") and only 36658
closes it ("end of the scaled head"). Inside it are the suit paint marks (about 36499-36604), the gfxsil shoulder caps (about
36615-36631) and drawPads with its own FIG_VEST (about 36633), so pauldrons draw at 1.2 x 1.12 = 1.344. Job 55 left it untouched and
check 24.37 was retargeted to accept the scaled caps.

1. Close the head scale before the suit paint, the shoulder caps and drawPads (or draw those outside it), so only the head, hair, hat and
   face are scaled 1.2 (his a01 D pick) and the pads draw at 1.12 (his a05 B pick). The vest (about 36043) and patch (about 36132) are
   already outside and stay as they are.
2. Move the 24.37 probe back to body scale through fixq (keep its intent).
Check (control must FAIL on v32.90): the pauldron and shoulder cap draw at FIG_VEST and body scale, not 1.344. Fingerprint unchanged.
Pictures: figure close-ups (player in both seat colours, one pillager bot) before and after at 1080. This is his art pick: put the pair in
notes for him; the critic is only a second look.
Party risk: medium (every body on screen changes slightly). It is a fix to his written spec, not a feature: ship before the Thu 10/29 lock
only if the before and after pictures show nothing else moved; otherwise leave it until after 10/30 and say so.

TASK DONE when shipped with the check and the picture pair; TASK PARTIAL with what is left.
