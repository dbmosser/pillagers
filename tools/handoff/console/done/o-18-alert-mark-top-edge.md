o-18-alert-mark-top-edge : a pillager bot's ? or ! mark lands on its name near the top edge of the screen (planner draft 2026-10-20)
effort: medium

Source: tools/handoff/console/alarms.md (o-04, 10-19): "puts the bot name afk_in_the_bushes and its ? alert together against the top edge".
Not done (planner, 10-20): dark_raiders.html about 42887: hudText(mk[0],sm2.x,Math.max(sm2.y,...)) keeps the ? or ! on screen, but the
world nameplate under it is not moved with it, so near the top edge the mark is pushed down onto the name. The picture
tools/handoff/console/notes/shots/o-04-camera-closer-after/37-raid-extracting-countdown-1080.jpg shows "afk_in_th?_bushes". git log has
no later ship on the mark or the nameplates (the only edge ships are v30.83, the score label, and v28.59, the golden label).

1. Near the top edge the mark never overlaps the name: either the mark sits beside the name, or the name and the mark step down together.
   This keeps his 2026-10-09 order quoted in the comment near 42871 (the mark sits clear over the name).
2. Nothing else moves: away from the edge the mark and name draw exactly as today. (c-02 used its 6 tries on the raid HUD; this is a
   measured overlap, not a taste change.)
Check (control must FAIL on v32.90): a bot staged at the top edge of the view: the mark's box and the name's box do not intersect; a bot
in the middle of the view draws as before.
Pictures: camera-recipes.json with a bot at the top edge (screen 37 staging is the model), p1 at 1080.
Party risk: low (a small HUD placement; it shows in the demo too).

TASK DONE when shipped, the check passes and the picture shows the name whole; TASK PARTIAL with what is left.
