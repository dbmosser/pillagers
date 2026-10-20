# 17-party-easy-mode notes

Found in the code (v32.06): easy mode already exists in the demo (v30.32 cw-easymode). A card asks y/n after a player's second death with no extraction, per window. Yes cuts damage taken by 30 percent (EASY_MUL 0.7). Functions: easyAskMaybe, easyAnswer, easyHud, easyKey, easyPad near line 63960. A Forgiving setting (eDmg 0.7) is in the Terms list.

Done:
- 3.16 b free medkit: shipped v32.07 (cw-easymed). Yes puts one medkit in the bag; no gives nothing.
- 2.28 c choice at run start: shipped v32.15 (cw-easystart). arcadeDeploy calls easyStartAsk, which resets ARCADE.easy to 0 and puts the same y/n card up in that window. The after-second-death offer stays for anyone who said no. Not yet seen in two windows with pictures (2.86 a): still to do.

Left:
1. 2.90 b: Career offer of Forgiving after a few deaths, plus a Settings switch. easyAskMaybe returns early unless ARCADE.on. Career deaths end the raid, so the offer needs a card on the menu or outcome screen and a profile counter (storage key must not change without a migration). That is a new card design, so it needs 2 or 3 mockups (his 53). Not started.
2. 2.47 c: board tag and 30 percent points cut belong to task 15, which has not read the flag yet. The flag is ARCADE.easy (1 = easy, reset to 0 at each new demo run, per window). Task 15 should read that.
3. Two-window pictures of the start card (uishots, ports 9361 for lane a).
