# 79a-player-size-back (lane c, 10-20)

- SHIPPED v33.22 (cw-figback, a3ae3ce4): FIG_SCALE 1.25 back to 1 (the size before v32.64). Head 1.2, pack, vest and build heights kept. FIG_UP (plates over the head) 19 to 12. drawAimMark now keeps the build height at scale 1 (it dropped it when FIG_SCALE was 1).
- Check: new v33.22 check (standing figure drawn no taller than its build height, FIG_SCALE no bigger than 1) fails on the 1.25 build, passes now. Old v32.64 check retargeted to compare against FIG_SCALE instead of 1.25. v20.01 and v20.11 both PASS on the new build (no retarget needed).
- Numbers (1080 raid, shots/79a-before and 79a-after, 21-raid-hud-calm): standing pillager about 70 px tall before, about 58 px after (a drop of 17 percent, 1.25 to 1 plus the build height). Next to the bush and crates beside him he now reads as one person among props, not a giant. I did not go below 1: the 79 camera (1.05) shrinks everything and his skeleton share was 6.2 to 6.4 percent of screen height; the pillager is now about 5.4 percent. Dial is FIG_SCALE if he wants it even smaller.
- No body, tree or deer was in the staged shot; not measured against them. Character select and Undercroft wardrobe previews use their own canvas, so they were not touched.
- Tell coordinator: ask him about this together with 79 and 80 (machines a third larger) after his next play.
- Watch next play: plates and health bars over the heads (FIG_UP 12 was set from the old numbers, not a picture of a bot); name plates in the 2-player window.
