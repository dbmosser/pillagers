# o-01a-245 undercroft-crowd-draw-order : in the Undercroft, whoever stands lower on screen is drawn in front
HIS WORDS 10-31 (in the Gameplay Edit Intaker chat), with a screenshot of his pillager overlapping a bot pillager who stands lower on screen, drawn over the bot: "if the player is standing above a another pillager in the undercroft, then the player should effectively be begind them. see image -- this is wrong, collision order is backwatd. player should be standing behind bot -- research best practices for this in 2.5d games if needed"
PARKED for the party freeze (his 10-29 order); build after Sun 11/1 01:00.

Cause (v36.55): drawHubWorld (dark_raiders.html ~52449) y-sorts walls, posts, the operator, the party and the dropped crates in DR (~52509, sort by k), but THE CROWD (v6.54, ~52548 "Behind him in the draw order") is drawn in its own pass before him, so a bot pillager standing in front of (below) him is still painted under him.
Best practice in 2.5D/3-4 view games: one painter's list sorted by each body's ground contact point (feet y; ties by x then a stable id), so the body lower on screen is drawn later and covers the one behind it. The raid already does this (the y-sorted 3/4 pass).
Build: put every crowd pillager into DR with its feet y as the key, the same way the party bodies are, and drop the separate behind-him pass; name tags/speech still draw on top of all bodies. Check the hub "nobody stands on anybody" spacing (v7.53) still holds and the gift/drop crates and walls still sort right.
Check (must FAIL on v36.55): a crowd pillager 20 px lower on screen overlapping him is drawn after him; one 20 px higher is drawn before him.
Rules: render layer only; seed 4242 fingerprint must hold; take pictures (uishots: Undercroft with him above and below a crowd pillager). DESIGN.md watch line: "in the undercroft whoever stands in front is drawn in front". Model: Sonnet 5.5 high (or Codex).
TASK DONE when it shipped and is ON HIS PC.
