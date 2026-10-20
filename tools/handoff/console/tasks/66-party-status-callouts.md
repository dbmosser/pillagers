66-party-status-callouts : the 2-player status lines become short callouts, not sentences (planner draft 2026-10-20)
effort: medium

Source: tools/handoff/console/RULES.md line 41: "Never an explaining sentence on screen."; q-process/answers.md 27: "a) Yes" (reword on-screen text).
Not done (planner, 10-20): dark_raiders.html 55397 NET.status=peer.name+' joined your party.'; 58456 reads "Your party is still in the
raid. Waiting for them to finish."; the hub picture notes/shots/o-08-pad-owner-recipes-4/j7-hub-p1-pad-owner-1080.jpg shows "pillager
joined your party."; none of these lines are in TXSHIP (his own rewordings) and notes/ui/changes.md has no entry for them.

In scope (lines that reach the screen in the same-machine 2-player flow and the career hub; line numbers drift, grep the text):
the netSay toasts at about 55397, 55415/55417 and 55459; the raid status lines at about 55356, 56608, 58456, 58565, 59153 and 59788; the
wait line at 55865/55889 where the party window shows it.
Out of scope: the online party window's invite and reply code lines (about 55244-55301 and 64983): there is no online co-op now. Lines he
kept on purpose (the Q61 pause feedback line) are not touched.
1. Make each a short lower-case callout with no full stop and the same meaning, for example "pillager joined", "waiting for player 2",
   "party ascended", "teammate still in the raid".
2. Log each change with its Q8 reason in notes/ui/changes.md (his answer 27 lets you reword; his Q8 wants the reason).
3. Retarget old checks that pin the old wording, through fixq.
Check (control must FAIL on v32.90): none of the in-scope lines contains a full stop or a second sentence.
Picture: the hub with a linked teammate (the p1 side stages; see the o-08 recipes-4 j7-hub-p1 recipe).
Party risk: medium-low (words on the 2-player screens). Ship before the Thu 10/29 lock with the hub picture, or leave it until after 10/30.

TASK DONE when shipped, logged and photographed; TASK PARTIAL with what is left.
