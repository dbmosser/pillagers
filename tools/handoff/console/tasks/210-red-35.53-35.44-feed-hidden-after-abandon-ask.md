# 210-red-35.53-35.44-feed-hidden-after-abandon-ask : press Abandon, then ESC, and the left feed stays hidden until the next pause
Queue (stable triage 10-28 05:45, run corpus-1028-0320 on v35.63, rerun on v35.65). Fix, small, MEDIUM (a real bug a player can hit; both checks have been red in every full run since v35.54).
effort: medium (Sonnet is enough)

Checks 35.53 ("control: the feed line did not draw") and 35.44 ("five feed lines up draw 0 lines, not 3") pass alone and in the ship gate, but fail in the corpus slice [0,120)
every time. One cause for both. Bisected on v35.65: the old check 9.37 (you cannot abandon while bleeding out) arms the Abandon confirm, then closes the pause box with
togglePauseBox(false). That leaves the class "asking" on #pausebox. feedWaits() (dark_raiders.html about line 23409, added with the end cards in v34.32) returns true while
#pausebox has "asking", so feedDraw returns before drawing, and every later check in the tab that draws the feed sees nothing. Clearing the class makes both checks pass.
The same thing happens to a player: open the pause box, press Abandon run (the YES or NO question shows), press ESC (or the close x). The box closes, "asking" stays, and the
whole left feed (pickups, kills, contract lines, the danger lines that wait behind it) stays hidden until he opens the pause box again, because only togglePauseBox(true)
calls disarmAbandon (line about 20897: "if(on) disarmAbandon();"). Probed: armed then ESC gives open=false, asking=true, feedWaits=true.
Suspect ship: v34.32 (feedWaits reads "asking"); exposed by v35.44 and v35.53 only because those checks draw the feed after 9.37 in the same tab.
Fix: close the question when the box closes: call disarmAbandon() in togglePauseBox for both on and off (or make feedWaits() also require pauseOpen); either way "asking" can never
outlive an open box. Say what he should watch: Abandon, then ESC, then loot something, the feed shows the pickup.
Check (must FAIL on the current build): open the pause box, press Abandon, close the box by ESC and by togglePauseBox(false), then feedWaits() is false and a feed line draws.
It is enough to prove 9.37 then 35.53 in one tab (index order of the corpus): run the 9.37 run function, then the 35.53 run function, expect PASS.
TASK DONE when checks 35.53 and 35.44 pass in a full slice [0,120) (or after 9.37 in one tab) and the gate passes.
