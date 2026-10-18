# HUD in play: audit (b-30-ui-hud, 2026-10-18) + his picture survey layout (q16-q23), rev 2026-10-18 evening (tasks 25a, 25b, 26a, 26b, 33a, 33b, 33c)
Pictures: notes/shots/b-30-before (21, 33, 36 viewed). Critic before scores: 21 = 2, 33 = 2 (no after yet, nothing shipped). His chosen pictures: menu-survey\img\q16-a, q17-b, q18-a, q19-a, q20-a, q21-d, q22-c, q23-d (.jpg). The layout below is BINDING (it answers the lock on the HUD layout: the fixtures retarget to it, tasks 25a, 25b, 26a and 26b).

## The layout (1920x1080, scale by H/1080; margins 96 left/right, 54 top/bottom; no two rectangles overlap)
- Top-centre cluster, centred on x960: score "420 sp" 48 (y54-102), timer "8:51" 40 (y110-150), extract chip "extract 152 m" 26 teal, 36 high (y160-196), alert pills from y200 (56 high, 8 gap, max 3).
- Top-right: minimap x1524 y54 300x300 (q20; frame 3px #9aa3a9 as in his picture, a 38px compass needle icon top-left inside), zone name 24 muted under it at y364, goals pill x1404 y404 420x56 (q21; his picture had y380, which would touch the zone name), its list at y468.
- Top-left: free. Career money row "$900  0 xp" 24 at x96 y54 (career only); the pillagers board only if kept, in this corner.
- Bottom-left: feed plates above y924 (pitch 46, 10 lines, q08); vitals x96, 460 wide: health 40 high y938, armour 28 high y984, stamina 8 high y1018 (q18).
- Bottom-centre: the gun strip, 72 px cells, gap 8, centred on x960, y954-1026 (q19; the picture drew ten cells = x564-1356, the game has nine gun cells = x604-1316); gun name above the selected slot; three 56x56 item chips (icon + count, a read-out of the wheel items) above its right end, y890-946.
- Bottom-right: ammo plate x1364 y836 460x190 (q17): 15 bullet pips, magazine number 88, reserve 44, gun silhouette 140. Magazine ring, reload ring and draw ring at the cursor STAY (recoloured lime; low ammo = danger red pulsing 2 Hz).
- Low health (q23 D): red heartbeat glow radius 140, 1.5 Hz, vignette 25 percent; shake 2 px per beat is a feel change, its own ship (task 33c). Downed: red tint 30 percent, countdown ring around the raider.

## Findings from the audit, and what his picks do with them
1. Same line three times (33, 36): centre info/obj rows AND the feed. Resolved by q08 + q22: an event shows once, alerts and goal-done go to the pills, the feed never repeats them. Still needs its own fixture sweep (hundreds of drawn-text checks).
2. Controls legend (40345-40411, G.legendOn 0/1/2, F1 cycles): a 12-row table over the play space. Still: hide except F1 and the first 30 s. It must never sit in the middle clear zone.
3. Run info (39197): 7 contracts at 14 px. Resolved by q21 D: a 420x56 pill, hold tab (pad: d-pad up) opens the 3 goals closest to done. All contracts stay on the map screen (Q1).
4. Pillagers board (41395-41510): "$" is loot VALUE, not score. Stays as is, but 'CURRENT PILLAGERS' micro 10 goes to 24 (type floor) and the board moves to the free top-left.
5. Hierarchy: resolved by q17 (ammo is the one hero, 88) and q16 (score 48, timer 40, credits 24).
6. World name label sits under the minimap: resolved by q20 (zone name under the frame at y364, never over the map).
7. Stamina label floats; slot 1 amber and slot 4 blue both read as selected: resolved by q18 (no label) and q19 (one selection colour, lime ring).
8. Extraction chip hugs Run info and the screen edge: resolved by q16 (chip in the top-centre cluster, pills under it).

## Code anchors and rules
HUDC (about line 11325) and TYPE (about 11280) hold the HUD colours and sizes: change the values there, do not add a second table. The HUD uses the exact px of its picture (never under 24, no menu snap). Lime on the HUD only on a dark plate. Plates are solid rgba(20,23,26,.88), 1px #2e3337, radius 4 (no glass on the HUD).
Fixture safety: HUDBOX overlap and text-drawn checks lock the old layout: take them through fixq.sh to the rectangles above, one cw- key per piece (tasks 25a, 25b, 26a, 26b).
