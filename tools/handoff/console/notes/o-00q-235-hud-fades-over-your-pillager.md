
--- codex run 2026-10-29 05:55 ---
2026-10-29: Prepared cw-cx-hudfade against v36.40. Nothing is shipped yet.

The draft adds a render-only panel fade. It projects the drawn pillager box with the current world camera, zoom and figure build. Entry margin is 24 times hudRes; exit is 32 times hudRes. Fade and recovery take 0.15 seconds. Each window uses G.player. The helper also counts additional local players if a shared viewport supplies G.players; network peers in other windows do not trigger this window's fade.

Canvas panels are grouped and composited once at the requested opacity. This keeps text, icons and plate together, even where existing drawing code resets globalAlpha. An unobscured panel uses its existing canvas with no offscreen copy. One reusable canvas is allocated only when a panel actually fades. DOM HUD panels use the same player boxes, margins and fade clock; original inline opacity is restored outside the raid and over menus. DOM discovery preserves fade state across rescans.

Covered: separate clock and score plates, minimap, run info/goals, value at risk board, message feed, alert/location lane, gun/ammo card, belt, vitals/status, each partner row, air-strike meter, timed power-up chips, medal strip, held-item/use panel, notes, boss bar, fixed extraction/downed/banner panels and raid status. The player's world labels, reticle, reload bar, ground auras, strike targeting, partner direction arrows and pickup stack stay on their existing draw paths. No pickup code, loot rows, sounds, seed generation or gameplay values changed.

Validation completed locally: 46 edit anchors match once; generated draft reads back and applies to the same candidate; all candidate JavaScript parses. The project's exact lint rules report zero errors on both baseline and candidate. Local rendering smoke checks pass for fade and recovery in 0.192 seconds, the actual group composite alpha, the unobscured fast path, shared local viewport bodies, map bypass and balanced canvas state. No tracked game or fixture edits were made.

The browser gate check fails on the old build when the fade helper is absent. On the candidate it stages the real score plate, moves the real player screen box underneath, observes main-canvas drawImage compositing at 0.35 within 0.192 seconds, verifies a distant gun panel stays at 1, tests a real DOM panel, moves the player 100 scaled pixels clear, and checks scaled hysteresis and menu cleanup.

Handed over six camera recipes: pillager under clock/score, minimap and gun card, each for host and player-2 render paths. Run ALL SIX at BOTH 1080p and 4K. Player 2 uses the larger HUD and its gun view uses ADS. Recipes use the existing fixture role-staging helper and project the real rendered pillager under the panel by pinning the camera. These are independent window-role render checks, not a linked network play test. Their expect predicates require 0.35 opacity and the correct player seat. Review the returned pictures from both views. Faded text being only a hint is explicitly intended by his task; do not undo the requested 35 percent opacity for a contrast complaint.

DESIGN.md watch line is the draft's exact now text: hud panels go see-through over your pillager. Watch on the next play: panels should fade independently near your own pillager, recover without edge flicker, and remain smooth at 4K. Browser preflight, seed 4242 fingerprint, ship, ON HIS PC confirmation, camera/critic results and visual inspection are still the lane's next steps. No fixture retarget is currently needed.

