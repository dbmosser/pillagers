o-04b-stick-math : sticks keep their angle and full diagonal speed (pad research J2, coordinator 2026-10-19)
effort: medium

Found by the pad research and checked by the coordinator: padAxis (about line 18202) applies the deadzone to each axis on its
own, though its comment says radial. That snaps aim and walking toward the four straight directions (about 12.7 degrees at the
default deadzone, more at light tilt), and diagonal walking and aim reach lose about 12% (28% at the HUGE deadzone).
Build and test exactly as section "J2" of tools/handoff/pad-research/best-practices.md: one scaled radial deadzone function for a 2D stick, used for move and aim
(pollPad about lines 18269 and 18274), the lx/ly read at about 18112, and the item wheel pick. Keep the DEADZONE and SENSITIVITY rows and
their values, apply sensitivity to the length, and keep menu stick stepping working.
Checks (each control must FAIL on the old build): the angle sweep at raw lengths 0.30, 0.60 and 0.95 stays within 0.5 degree; raw
(0.707,0.707) gives length >= 0.99; below the deadzone gives exactly 0; a stubbed pad walking diagonally for 2 s covers the same distance
as walking straight, within 1%; the 8-slot wheel picks the right slot at 8 angles. Twin-stick only, no new control, no new text.
TASK DONE when shipped and the checks pass; TASK PARTIAL with what is left.
