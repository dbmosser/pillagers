# UI motion layer (task 11b-ui-motion), rev 2026-10-18 evening: his picture survey q09, q10, q28, q32 replace the numbers (tasks 24a: pop and bounce, 24b: spring and tab rows)
Shipped v29.60, v29.62, v29.82. Code: `UIM` (after the titleFit IIFE, about line 62306) and `uiSndPick(kind,t,lastAt,n)` (pure, tested). Full numbers and reasons: style-guide.md section 5 and section 9 (q09, q10, q28, q32). The pictures: menu-survey\img\q09-b.html, q10-b.html, q28-b.html, q32-c.html in snip\ (motion has no jpg; the html is the picture).

## New numbers (time-based, never frame-counted)
- Window or dialog open 280 ms (q09 B pop): opacity 0 to 1 over the first 120 ms; scale .92 at 0, 1.02 at 55 percent (ease-out cubic .215,.61,.355,1), 1.00 at 100 percent (ease-in-out .645,.045,.355,1). Scrim to 55 percent in 200 ms. No rise, no stagger on open.
- Close 140 ms (.4,0,1,1): scale 1.00 to .96, opacity to 0, scrim to 0. (was 140 ms ease-in: same length, new scale)
- Highlight glide (q10 B): spring, omega 30, damping .70 (4.6 percent overshoot at 147 ms, within 2 percent at 200 ms). Replaces x += (target-x)(1-exp(-dt/.04)). Cap the overshoot at 8 px; over 170 px steps use damping .85. Retarget from current position and speed. Combat belt does NOT spring (snap with a 90 ms scale).
- Cards, count-ups, button press (q28 B): ease-out-back c1 1.2 = f(t) = 1 + 2.2(t-1)^3 + 1.2(t-1)^2, peak 1.053, cubic-bezier(.34,1.4,.64,1). Card 240 ms (rise 48 px, scale .92 to 1.00); count-up 900 ms then a pop 1 to 1.06 to 1 in 160 ms; button press 1 to .96 to 1.00 in 140 ms. Replaces the "overshoot 6 to 10 percent / c1 1.5 / 24 px rise / 1.08 pulse" reading, which v30.85 shipped (task 24a).
- Tab switch (q32 C): outgoing rows out in 80 ms; incoming rows rise from +12 px, 160 ms each, cubic-bezier(.2,.8,.2,1), 25 ms apart; underline glide x += (target-x)(1-exp(-dt/.035)) with no overshoot. Replaces "200 ms cross-fade + 24 px slide" and "stagger 35 ms per card, max 8".
- Feed plates slide in 160 ms; alert pills drop 12 px in 160 ms; loot tiles pop 40 ms apart.
- Kept from before: a press mid-transition retargets from the current value; deny shake 6 px over 100 ms; sounds (focus tick rate cap 40 ms, pitch variants, confirm, back, deny, open/close sweep).
- Never over 6 percent overshoot (spring 4.6, cards 5.3, menu pop 2).

## Screens on it (unchanged)
title, party window + arcade attract board tab, pause, end card (no open/close sound), settings, keys (now the controls window, q31), 15 hub windows.
Not on it (deliberate): fbmodal, askmodal, devmodal, cheatmodal, tunemodal, simmodal, sharemodal. The new corner card (q27), pills (q22) and feed (q08) have their own entrances above.

## Checks to retarget (fixq.sh, per key; they measure with the steppable clock UIM.manual)
open 0/50/100/200 ms becomes 0/60/154/280 ms (opacity .5 at 60, scale peak 1.02 at 154); stagger gaps become the tab-switch 25 ms; close under 150 ms stays (140); pulse peak 1.08 becomes press .96 and card peak 1.053; tab slide 24 px becomes 12 px rise; ring 33/81/95 percent becomes the spring (110 ms reaches target, 147 ms peak 1.046, 200 ms within 2 percent); one tick per focus change stays; the sound picker stays.
Note: v30.85 (cw-bounce) is ALREADY IN the game with c1 1.5 (8 percent), a 24 px rise and a 1.08 pulse. His picture is the lighter c1 1.2: task 24a retunes the shipped bounce (change its constants, add no second easing). v30.89 (cw-cardwide) is in too: it only sizes Settings and Keys (task 22a sets the exact card).

Not done: 4K frame-time measure (needs a 4K stepping harness), hover ring, backdrop drift, cursor parallax, glimmer sweep.
