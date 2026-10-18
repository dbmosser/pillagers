UI STEP 2b: SMOOTH (his words 2026-10-18 about Halo Reach, Halo 4, Diablo IV, ARC Raiders, Fortnite and Destiny 2 menus: "I cant
exactly tell you why they are so good, they are just reallly compelling and smooth"). Smooth is mostly motion and sound, which a
still picture cannot show. Read tools\handoff\console\notes\ui\references.md (Motion, Sound, Navigation and focus, How to check it)
and notes\ui\style-guide.md first. Notes: notes\ui\motion.md.
Build ONE shared UI motion layer on the shared look from task 11 (time-based, never frame-counted): open and close, focus ring
that eases to its target, tab change, card stagger, confirm pulse and deny shake, a press during a transition retargets and is
never ignored; one UI sound per event kind (focus tick with small pitch variation and a rate cap, confirm, back, deny), played on
the input frame through the game's existing sound code. Use the target numbers in references.md. Apply it to the screens task 11
moved (title/mode menu and the party demo board) first, then any screen already on the shared look.
Checks must measure time, not pictures: stage a menu open, step the clock and read the animated values at the moments listed in
"How to check it" (e.g. 50/100/200 ms), check a press mid-transition is handled within one frame, and that a focus change logs
exactly one tick. The fixture replaces sfx(), so put the which-sound decision in its own function and test that.
Never change game-feel values of the raid (shake, hitstop, speeds); this is menus only. Frame time must stay under 16.7 ms at 4K.
TASK DONE when the motion layer is shipped on those screens with its checks, or TASK PARTIAL with what remains.
