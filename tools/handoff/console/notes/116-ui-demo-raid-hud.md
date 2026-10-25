# 116-ui-demo-raid-hud (lane b, 10-25)
Fresh critic on HEAD (v34.68): 47 = 2, 48 = 2, 51 = 2. No overlap in 47, 48 or 51 (report.json lint 0; pictures checked), so step 1 needs no fix. 48's start prompt is not buried (controls folded).
Shipped v34.69 cw-hudpanel1: one corner panel look (HUDPS: fill, 1px line, 4px radius) for hudPlate and hudPanel. Check fails on v34.68 (no HUDPS).
Critic after (before and after pair): 47 = 2 same, 48 = 2 same, 51 = 2 same. 50, 20, 21 not worse (picture of 21 checked, panel change only).
Left (all layout rebuilds, not a one-line fix): vitals stack (three bar heights, armour and stamina blues alike), score block hangs from the top edge with the extract line in a separate pill, ammo and run info panels flush to the screen edge (no 5 percent inset), hotbar empty slots as bright as filled ones, run info rows not right aligned. 51: the critic keeps counting the top pill plus log row twice (his ruling rs-2 a, keep both) and wants a max 3 log rows.
48's critic P0 "no move to start prompt" is the demo's own state (no new readouts allowed in this job).

10-25 later run (lane b): re-read pictures, no new ship. All remaining critic points are layout rebuilds (vitals stack, score block, edge inset, hotbar dimming) that the task forbids as moved panels or new readouts. Scores stay 47=2, 48=2, 51=2; 50, 20, 21 not lower. Needs the coordinator or him to allow a hud layout rebuild job.

10-25 fourth run (lane a): no new work. v34.69 is the shipped fix; scores 47=2, 48=2, 51=2 with the reasons above; 50, 20, 21 not lower. The rest needs a hud layout rebuild job.

10-25 third run (lane b): no new work. Note: screen 47 (arcade drop controls card) is a removed screen (v30.50 cw-notutor, RULES veto), so its score of 2 should not be chased; the coordinator may drop it from this job. 48 and 51 stay at 2 until a hud layout rebuild job is allowed.

10-25 fifth run (lane c): no new work. v34.69 stays the shipped fix. 47=2 (removed screen, veto), 48=2, 51=2; 50, 20, 21 not lower. Rest needs a hud layout rebuild job.
