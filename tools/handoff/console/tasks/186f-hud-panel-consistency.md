# 186f-hud-panel-consistency : one panel style, even margins, a clear timer (raid HUD polish)
Queue: the Codex camera critic on o-120d (v35.51 to v35.53, pictures tools/handoff/console/notes/shots/o-120d-pad-trigger-not-aim-recipes-3/, the four 120d-*-smooth-1080.jpg) scored the raid HUD 3, 3, 3, 2 and stayed stuck there over two rounds; its findings are about the existing HUD, not that task. The CEO chat filed them here 10-28 for the HUD lane. His standing words: "UI weakest part" (memory pillagers-ui-program-2026-10-18), and 10-27 night "this has to be AAA top to bottom". Polish, allowed before 11/1.
effort: high (Opus; picture work, take and look at pictures before and after)
Key: cw-hudpanels

The critic's P1 findings (its words, shortened):
1. Panels differ: "the roster has a lighter border, the weapon card is near-black with no clear border, and the minimap card is another variant"; the contracts bar has "a different fill and a 14px chevron". One panel style (fill, 1 px border, 4 px radius) for the bots list, contracts bar, minimap frame, ammo card and weapon bar.
2. Ragged edge margins: "the roster starts at x=10, the bars at x=24, the minimap sits about 18px from the right edge, and the weapon card runs almost flush to the right and bottom edges". One inset for every corner panel.
3. Timer hierarchy: "the timer, sun icon, extract chip and teal arrow are four separate floating pieces with no shared container"; "the extract timer is the number the player needs under pressure" and is "light on a busy backdrop". One centred card holding the clock and the extract row. Coordinate with 186e (the extract pill states): whichever ships second rebases on the other.
4. Roster density: "eight rows of 14-15px text set at equal weight form a dense block that competes with the minimap". Give "you" and the money column more weight than the bot rows, or fewer rows while folded.
5. Minimap: "a 300px block with a large empty black lower half", "no frame". Smaller (the critic says about 240 x 240) and framed in the shared panel style, when it is on (it is off by default since v33.35, his 10-20 order).
6. Player tags and vitals styling in the party windows (p2 window scored 2): the p1 and p2 tags stay amber and cyan (his r3-13); check they read over light ground.

Do not change (his rulings): "contract item nearby" stays exactly as it is (his call 10-27, close to looting), even though the critic asked to shorten it; the pickup stack, its rows, loot sounds and item labels (looting is never touched); the medal row; player text stays lower case. Read tools/handoff/console/RULES.md (the veto list) before starting.

Check (must FAIL on the build before): the corner panels share one inset (within 2 px at 1080p) and one fill and border; the clock and extract row draw inside one card.
Pictures: uishots 21, 33, 34, 50 at 1080, plus the party windows; look at them before and after, and run the critic on the after set; the target is 4 or better.
Watch-for line for him: whether the HUD reads calmer and the clock is easier to find in a fight.
TASK DONE when shipq prints ON HIS PC.
