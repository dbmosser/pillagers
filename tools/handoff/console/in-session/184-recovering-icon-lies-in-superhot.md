# 184-recovering-icon-lies-in-superhot : the left status column says "recovering to 85" while health is not climbing
Queue: his note 10-27 ~20:00 in chat, on build 35.19 (export run-20261027-193000-982.txt): "status nofifications are still broken, it says i'm recovering to 85 when I'm not". Bug fix, allowed before 11/1.
effort: medium

What was tried: v21.65 (regen ran in the last 0.5 s) and v35.11 cw-hudfix (a point gained within regenSec+0.6 s, hp not below the last regen hp). Both measure on G.t, the game clock.

Likely cause (found 10-27, verify first): his config has superhot:1. In Superhot the raid update sets dt=0 whenever no input is live (dark_raiders.html near line 54195), so G.t stops. tickRegen still stamps regenLive=G.t with the frozen clock, and G.t-regenUpT never grows, so statusLive (near line 42874) keeps RECOVERING lit for as long as he stands still while health does not move at all. Any other clock hold (map first, death beat) does the same.

Fix direction: keep it in the HUD layer. statusLive notices when p.regenUpT changes and stamps a real-time clock (performance.now) for that point; RECOVERING shows only while the last point landed within regenUpW real seconds. Do not touch tickRegen's rule or any seeded draw. Consider whether HEALING should do the same (probably not: it is a countdown of a heal he started).

Check: Superhot on, regen running, then no input for 5 real seconds: RECOVERING must go dark; must FAIL on v35.20. Control: Superhot off, regen running: icon stays lit while points land.
Rules: player text lower case; HUD only; no storage key change.
TASK DONE when shipped and his main PC reports the build (spare/JUL26/status.txt party=VER).
