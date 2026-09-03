# HUD measurement, 2026-09-03, on the v9.98 fixture (his note: "menus and hud in the raid are still wonky")

Method: __hudBox() rects and __textTrace() after real frames at 1920x1080, 2560x1440, 3840x2160; DPR pinned 1; map 0, seed 4242, kit medkit/frag/plate.

Panels reported (x,y wxh):
- 1080p: body 14,881 532x193; gear 1577,864 335x222; cond 1633,49 270x195; legend 9,673 467x197; raiders 7,150 384x202
- 1440p: body 19,1175 709x258; gear 2103,1152 446x296; cond 2178,66 360x260; legend 12,901 622x262; raiders 9,199 512x270
- 4K:    body 28,1762 1064x386; gear 3155,1728 669x443; cond 3267,99 540x391; legend 18,1357 933x393; raiders 14,299 768x405

Findings:
1. No panel overlaps another at any size.
2. The gear panel leaves the viewport at every size: bottom edge at 1086 of 1080, 1448 of 1440, 2171 of 2160 (6, 8 and 11 px off the bottom).
3. Text drawn with no panel box around it (23 to 25 strings): the clock and EXTRACT line at top centre, the message line ("Grid is down..."), and the hotbar strip digits centre-bottom (x 577..986 at 1080p, y 976 and 1052). These are not boxed panels, so they cannot be dragged or measured by the panel tools; the hotbar strip in particular has no HUDBOX entry.
4. World-space zone labels ("THE SEAL 0%", "ELITE CACHE") appear off-screen in the trace; they are world labels, not HUD.

Next: fix 2 by name (v10.01), then consider boxing the hotbar strip so it is a panel like the rest.
