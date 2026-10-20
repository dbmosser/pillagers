# 17-party-easy-mode notes

Found in the code (v32.06): easy mode already exists in the demo (v30.32 cw-easymode). A card asks y/n after a player's second death with no extraction, per window. Yes cuts damage taken by 30 percent (EASY_MUL 0.7). Functions: easyAskMaybe, easyAnswer, easyHud, easyKey, easyPad near line 63960. A Forgiving setting (eDmg 0.7) is in the Terms list.

Done:
- 3.16 b free medkit: shipped v32.07 (cw-easymed). Yes puts one medkit in the bag; no gives nothing.
- 2.28 c choice at run start: shipped v32.15 (cw-easystart). arcadeDeploy calls easyStartAsk, which resets ARCADE.easy to 0 and puts the same y/n card up in that window. The after-second-death offer stays for anyone who said no. Not yet seen in two windows with pictures (2.86 a): still to do.

Left:
1. 2.90 b: Career offer of Forgiving after a few deaths, plus a Settings switch. easyAskMaybe returns early unless ARCADE.on. Career deaths end the raid, so the offer needs a card on the menu or outcome screen and a profile counter (storage key must not change without a migration). That is a new card design, so it needs 2 or 3 mockups (his 53). Not started.
2. 2.47 c: board tag and 30 percent points cut belong to task 15, which has not read the flag yet. The flag is ARCADE.easy (1 = easy, reset to 0 at each new demo run, per window). Task 15 should read that.
3. Two-window pictures of the start card (uishots, ports 9361 for lane a).

Run 2026-10-20 (lane a):
- 2.90 b shipped v32.23 (cw-easycareer). Career counts deaths in a row (P.dieRun, extraction clears it, additive field, storage key unchanged). On the third, the next career raid shows the SAME y/n card (no new design, so no mockups). Yes: G.easyC = 30 percent less damage plus free medkit for that raid. Asked once per streak, not when Forgiving is already on in Settings. The Settings switch for career is the existing Forgiving step in "how hard they hit".
- Flags for task 15 (2.47 c): demo = ARCADE.easy (per run), career raid = G.easyC. Board is demo only, so ARCADE.easy is the one to read.
- Not done: two-window pictures of the start card and career card (the camera has no stage for them). Needs a shots json entry; ask coordinator.

Run 2026-10-20 b (lane a): nothing new built. Task 15 (board tag, 30 percent points cut) has no notes or tasks file yet, so there is nothing to make agree; it should read ARCADE.easy (demo only). Two-window pictures still need a uishots stage for the start card and career card.
