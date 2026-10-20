# 17-party-easy-mode notes

Found in the code (v32.06): easy mode already exists in the demo (v30.32 cw-easymode). A card asks y/n after a player's second death with no extraction, per window. Yes cuts damage taken by 30 percent (EASY_MUL 0.7). Functions: easyAskMaybe, easyAnswer, easyHud, easyKey, easyPad near line 63942. A Forgiving setting (eDmg 0.7) is in the Terms list.

Done:
- 3.16 b free medkit: shipped v32.07 (cw-easymed). Yes puts one medkit in the bag; no gives nothing.

Left (in this order):
1. 2.28 c: choice before the run starts, per player, demo only. Needs a spot in the demo start flow (find where each window leaves the waiting screen). Today the card only appears after the second death.
2. 2.90 b: same offer in Career after a few deaths. easyAskMaybe returns early unless ARCADE.on, so Career needs its own path (and a Settings switch, 2.28 note). Not started.
3. 2.47 c: board tag and 30 percent points cut. This belongs to task 15; make the two agree. Not started. Check that ARCADE.easy is the flag task 15 reads.
