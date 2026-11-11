# 264-belt-key-1-vacant-18-34 : check 18.34 fails, the first belt key is not painted in a fresh raid (full runs corpus-1101-1520 v37.17 and corpus-1102-0048)
Codex: never change tools/mkfixture.ps1. If the answer turns out to be a check change, put the finding and the exact change in your notes and stop; the HTML CEO chat makes it.
Queue (known-red triage 11-02). Treat as a possible REAL BUG until proved otherwise.
effort: low to medium (grep "18.34" in tools/mkfixture.ps1, about line 78088; the belt tile draw is in dark_raiders.html at "v18.34, THE STYLING PASS IN THE RAID", about line 44765)

What fails: "control: the belt key is not painted inside (alpha 0)" and "the belt key corner is square (corner 0, inside 0)". The check deploys with kit [] on seed 4242 map 0, draws two frames and reads the HUD canvas inside the first belt cell (g.hotCells[0]). Alpha 0 means nothing is painted on key 1.
History: green through corpus-1101-1057 (v37.02), red at corpus-1101-1520 (v37.17) and corpus-1102-0048. The belt code paints a raid tile only when the slot is owned or selected (vacant slots have no slab since the quiet belt, cw-cx-hudtvread, v35.64), so key 1 is now vacant or unselected in a fresh raid. The question is why a kit of nothing used to leave a gun (the scav pistol loaner) on key 1 and no longer does.
Suspects in v37.03 to v37.17: v37.14 the account and the pillager (acctEnsure, a pillager record), v37.16 and v37.17 worn gear (the fixture's __cleanProfile now resets P.pil and P.hall and calls acctEnsure), and the dead code batches 37.04 to 37.09 (no removed function still has a game caller; cycleHeal, unkeyedHeals, countHeals and beltInstant went). Also look at whether the scav loaner is still handed out onto key 1 and whether it is selected (on).
Do: run 18.34 alone on v37.02 and v37.17 (main PC or spare, not the VM) and log hotbarSlots() and hotSel() right after __deploy to see what key 1 holds. If the game lost the loaner or the selection, that is a real bug: fix it. If the loaner is gone on purpose, say which build and re-aim the check to stage a gun (a kit with a gun) and keep the corner assertion.
Rules: through shipq for a game change, fixq for tests only; seed 4242 fingerprint holds; never touch the pickup stack, loot sounds or loot rows.
TASK DONE when 18.34 passes on the current build in a full run.

REQUEUED 11-07 09:45 by Codex Correspondent (owner order: Codex carries HTML development). First read the notes and log from the failed tries; current build is v37.48. If the same blocker stands, end with TASK PARTIAL naming it.

Lane note 2026-11-11 16:25: NEEDS COORDINATOR, parked by lane p. Codex's last words:
Fixture correction is applied in `0fe2908e5`. No game change is justified. Recorded the remaining validation handoff.

LOCAL: no linked review.

TASK PARTIAL: coordinator must verify 18.34 in a current full run; JT PC runner is off pending the owner’s decision.

Coordinator note 2026-11-11 17:05 (HTML CEO): the full run corpus-1111-0904 ran at 842c0b628, before the 18.34 fix 0fe2908e5, and failed 18.34 as expected. The JT PC starts a full run only when the game file changes, so this closes on the first full run after the next ship: if 18.34 is not in its fail list, move this job to done/. No Codex run needed.
