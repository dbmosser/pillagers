o-93-fps-counter-screen-rate : when the screen gives fewer frames than his cap, the fps counter says so (coordinator 2026-10-27)
effort: medium

Source: his question 10-27 (verbatim): "ipput the game on 144 fps and my screen is set to 144 fps, but it still says 60 fps on the fps
tracker -- why?". The browser hands the game one frame per screen refresh, so a 60 Hz VM or remote window, a 60 Hz monitor, energy
saver or dynamic refresh caps him at 60 whatever the Frame cap row says. Not a game bug, but nothing on screen tells him that.
Not done (coordinator, 10-27): the game already measures the screen rate (VSYNC, vsyncNote, cw-drscap, near the frame cap code;
VSYNC.ms is the refresh time). The fps counter and the Frame cap row never show it.

1. When CFG.fpsCap is above the measured screen rate by more than 5 (and the measure has settled), the fps counter adds a short callout
   with the screen rate, for example "screen 60". All lower case, no explaining sentence (CLAUDE.md rule 9). Nothing shows when the cap
   is off, at or below the screen rate, or before the measure settles.
2. Words only: the cap, DRS and the frame pacing do not change.
Checks (must FAIL on v35.14): with VSYNC staged at a 16.7 ms refresh and CFG.fpsCap=144, the counter text holds "screen 60"; control
with CFG.fpsCap=60 has no screen callout. Restore VSYNC and CFG in finally.
Party risk: none (words only, counter on).

TASK DONE when shipped and the checks pass; TASK PARTIAL with what is left.
