# 103-ui-raid-hud-hierarchy : the raid HUD gets one clear hero, lower case everywhere and couch-size type, so the raid screens at 3 reach 4 (coordinator 2026-10-24)
effort: high

Queue (coordinator 10-24 12:50): the second half of 102 (raid HUD calm), which shipped v34.24 to v34.26 (one panel fill, merged type
sizes, quiet corners) and lifted 21-raid-hud-calm and 19-raid-hud-drop-first-raid from 2 to 3. Raid screens need 4 (3.51 a).

What the critic still says (10-24 16:28, after v34.26):
- 21-raid-hud-calm 3: "still a pile of small dark boxes of equal weight, with wrong-case text, tiny type and a wrapping contract".
- 19-raid-hud-drop-first-raid 3: "still a stack of five or six equal dark boxes. The keys cheat sheet is big and always on, and the
  hero ammo number is the only strong focal point".
- 37-raid-extracting-countdown 3: "the extraction banner still lacks hero weight, the top-right stack is dense, and several fonts are
  too small to read from a couch".
- 61-raid-wheel-open 3: "the wheel's own labels and badges are crude, a capital letter slipped in, and the screen still has too many
  differently sized text blocks".

Do, in this order, each a small ship with a watch line in its DESIGN.md section (feel is his call):
1. Lower case: every player-facing HUD and wheel string is lower case (his 10-18 order, ALL lower case). This is a defect, not taste:
   find each capital the critic saw and any other in the raid HUD, and fix it at the source. Edited lines are lookup keys for his
   own edits: change case only, and log each in notes/ui/changes.md.
2. Couch-size type: no raid HUD text under the style guide's minimum for a TV at couch distance (read style-guide.md for the number).
   The contract line fits on one line (shorten with a Q8 reason, never wrap).
3. Hierarchy: one hero per state (the guide names it; ammo in a fight, the extraction banner while extracting) and the other boxes
   step down in weight. Keep the top-right column where his 10-18 notes put it.
The keys cheat sheet: his 10-18 orders want live key and pad prompts for walk-up players, so it stays; it may get smaller or quieter
(fewer lines, lower weight), never gone, and never hidden behind a setting he did not ask for.

Rules: rendering and HUD only (no change to the simulation, saves or the storage key); P1 amber and P2 cyan stay; check 1080p and 4K;
the HUD must not add draw calls a frame (measure DRS.workMs before and after on a busy raid). Read style-guide.md, shared-style.md
and hud.md first.

Checks (each must FAIL on the old build): no capital letter in any raid HUD string drawn in one raid frame; no HUD text under the
minimum size at 1080p; the contract line on one line.
Pictures: camera-recipes.json with 21, 19, 37 and 61 at 1080p, then the critic.
TASK DONE when 21-raid-hud-calm reaches 4 from the critic (never your own grade) or the three steps shipped and the critic scores
of all four are written with the best two versions noted; TASK PARTIAL with what is left.
