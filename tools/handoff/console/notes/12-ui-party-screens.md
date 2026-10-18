# 12-ui-party-screens notes
Before shots: notes/shots/12-before (all 13 screens, 1080). party-screens.md did not exist (this file is it).
Findings (before):
- 52/55 Run over: "Pillagers" title plain; huge void; "ext" abbreviation; Press any button far below (y=890).
- 56/46/64 attract: card left-aligned at x=681..1239 only 560 wide, void below; title y=140.
- 62/63 Operator menu overlaps Tonight's best card (menu top y=400, card bottom 395), background dimmed only partly.
- 58 coop P2 title: orange paragraph 4 lines = explaining text, violates short-callout rule.
- 49 pause: box sparse, sentence "Please provide feedback - tell us anything..." ; F1 controls panel shows through behind scrim.
- 47: F1 controls card OK.
PLAN (ship order): S1 operator menu 62/63 (code arcadeOpOpen/Draw/Style ~60085-60138; labels all caps 'NEW PARTY','EXIT DEMO','BACK','OPERATOR';
 old check mkfixture ~16271-16272 tests /NEW PARTY/ /EXIT DEMO/ -> retarget to /new party/i when labels go sentence case (lock, fixq)).
 S2 run over 52/55 (~60440-60520). S3 pause 49. S4 coop P2 title 58 (orange paragraph). S5 attract 46/56/64. Tokens: --fs-title 32 --fs-body 20 --fs-label 16 --sp-1..5 8/16/24/32/48 --btn-h 56 --menu-w 560 --ui-panel --ui-line-hi --acc --ui-scrim .82.
 Pattern file for edits: S/mk-cw-uishared-board2.ps1 (L helper, $chk with run:function, ordered draft).
DONE: S1 cw-party-op SHIPPED v29.44 (62/63). Fixture 26.90 retargeted (commit 9d762309). Tolerance lesson: computed px under zoom are 639.987, use abs()<1.
 Run over strings (RUN OVER, EXTRACTED x2, KIA -50%) are asserted by old checks (8248, 20647, 26832, 22421...) so restyle only, never reword/case.
Attract overlay code: dark_raiders.html ~line 45650 (d.id='attract'). Arcade pause/over code ~59915-60700.
