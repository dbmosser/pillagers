# 192-one-word-hotbar : the number-key row has one name everywhere, "hotbar"
Queue (coordinator 10-27 21:50): found by the stable triage. Polish, MEDIUM (party week: wording he and the party guests read).
effort: high (Sonnet is enough)

The row of number keys is now named three ways: "hotbar" on the stash row (v35.12, check 35.12 requires it), "belt" on the pre-raid
screen, and "tactical belt" in older surfaces (his 09-03 ruling, checks v10.26 and v9.89, now on tools/handoff/stable-known-red.txt).
His own word in every 10-27 order is "hotbar" ("items on the hotbar", "hotbar swap", "hotbar items work like the wheel"), so his newer
word wins: call it "hotbar" on every surface a player reads (lower case, his text rules). Grep the game for belt / tactical belt in
player text only (not code names), change the labels, and retarget v10.26 and v9.89 through fixq.sh so they guard the one word "hotbar";
then delete their two lines from tools/handoff/stable-known-red.txt.
Check (must FAIL on the current build): every player-visible label for the number-key row says "hotbar" and none says "belt".
Pictures of the stash, the pre-raid screen and the raid hud at 1080p.
TASK DONE when it shipped with pictures; TASK PARTIAL with what is left.
