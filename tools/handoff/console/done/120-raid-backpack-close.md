# 120-raid-backpack-close : the raid backpack gets a close button (his Q1 rule)
Queue (coordinator 10-25 09:25): after 117 to 119. From job 115's notes: the critic's top point left on screen 23 is a missing close button.
effort: medium

His rule (09-03, Q1): "Every menu screen gets a CLOSE button and ESC closes it". ESC and Tab already close the raid backpack (dark_raiders.html about line 18122); a close button does not exist yet.
Do: one close button on the raid backpack card, in the same place and look as the close button on the hub windows (style-guide.md, shared-style.md), drawn in both player windows. Clicking it does exactly what ESC does there (same sound, drops a held drag the same way). On a pad, B already closes it; the button shows the pad glyph when the last input was a pad, as the key caps do. No other new readouts or controls.
Screens: 23-raid-backpack-open (critic 3 now, target 4); keep 41-hub-backpack and 41-hub-backpack-pad-p1 at 3.
Checks (each must FAIL on the old build): a close button is drawn inside the raid backpack card at 1080p; a click on it closes the backpack as ESC does.
Pictures: camera-recipes.json with 23 at 1080p, then the critic.
TASK DONE when the button shipped and the critic score is written (stop rule 2.83 b applies); TASK PARTIAL with what is left.
