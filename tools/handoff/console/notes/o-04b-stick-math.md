
--- codex run 2026-10-19 13:42 ---
2026-10-19: Prepared cw-cx-stickmath for J2. Read the J2 research and the actual menu, raid, forge, wheel and fixture paths. No prior task notes were present.

The change replaces separate axis deadzones with padStick(x,y): the current inner deadzone, a 0.06 outer deadzone, sensitivity applied to the length before clamping, and the original direction preserved. Move and aim use the pair, the item wheel receives the same aim vector, menu stepping uses the physical left stick pair, and forge stepping uses the movement pair. padAxis remains a one-axis wrapper around the same function for existing fixture callers. No settings rows, setting values, player text or control bindings change.

Local checks: all five edit anchors match once; the patched game script and fixture check parse. At lengths 0.30, 0.60 and 0.95, the new function has zero angular error to six decimal places across 360 angles. The old calculation has worst errors of 42, 21.188439 and 13.197841 degrees respectively, with 20 completely lost directions at length 0.30. Full diagonal output rises from 0.882977 to 1 at the default deadzone and from 0.723606 to 1 at HUGE. All 48 local wheel cases pass with the new function; 24 fail with the old one. Every tested vector below each of the four deadzones gives exact zero. verify-stickmath.js reproduces these local checks without a browser.

The shipped check also drives stub pads through pollPad for move angle, aim angle and actual cursor reach; walks straight and diagonally for 120 steps of 1/60 second at default and HUGE deadzones using the real updatePlayer with walls and water removed from the test raid; opens the real eight-slot wheel and checks its eight centres plus both sides of each segment boundary; checks circular deadzone activation; checks sensitivity; and confirms the left stick still steps the controller settings list. No live game file was edited. Browser tests remain for the lane.

fixture-retarget.json updates only the maths section of check 26.51 so that it accepts the former formula before shipping and the new radial formula afterward. Its exact anchor is unique. Both versions of that maths section passed locally with the corresponding extracted game functions. The two-window checks can still call padAxis for their single-axis expectations.

No camera request: this is input arithmetic and movement verification, with no changed screen layout, art or player text. Pending lane work: apply the fixture retarget under the lock, preflight cw-cx-stickmath, run its browser regression and ship it. A later run must review the lane result before calling this task done.

