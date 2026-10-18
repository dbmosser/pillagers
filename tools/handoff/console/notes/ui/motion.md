# UI motion layer (task 11b-ui-motion)
Shipped v29.60, v29.62, v29.82. Code: `UIM` (after the titleFit IIFE) and `uiSndPick(kind,t,lastAt,n)` (pure, tested).

Numbers (from references.md, time-based, never frame-counted):
- Open 240 ms ease-out, 16 px rise. Close 140 ms ease-in.
- Stagger 35 ms per card, max 8. Tab change 200 ms cross-fade + 24 px slide.
- Focus ring: x += (target-x)*(1-exp(-dt/0.04)). Confirm pulse 1+0.06*sin(pi*t) over 120 ms. Deny shake 6 px over 100 ms.
- A press mid-transition retargets from the current value.
- Sounds: focus tick (rate cap 40 ms, pitch variants), confirm, back, deny, open/close sweep.

Screens on it: title, party window + arcade attract board tab, pause, end card (no open/close sound), settings, keys, 15 hub windows.
Not on it (deliberate): fbmodal, askmodal, devmodal, cheatmodal, tunemodal, simmodal, sharemodal.

Checks measure time with the steppable clock (UIM.manual): open 0/50/100/200 ms, stagger gaps, close under 150 ms, interrupt, pulse peak, shake, tab slide, ring 33/81/95 percent, one tick per focus change, sound picker.

Not done: 4K frame-time measure (needs a 4K stepping harness), hover ring, backdrop drift, cursor parallax, glimmer sweep.
