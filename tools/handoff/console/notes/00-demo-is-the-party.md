
--- codex run 2026-10-19 11:02 ---
2026-10-19, lane o, first run, base v31.82.

Prepared one ship: cw-cx-demoplain, listed in keys.txt. It removes the ?party=1 launch parser, flag, CSS, auto-boot, reload/navigation functions, stale-mark clearing and title overrides. EXIT DEMO uses ordinary arcadeLeave. The online party window, host/join flow, NET, pair and invite codes are unchanged. The existing hostup receiver is left in the online pair handler; only the retired launch-mode sender and timer are removed.

The normal demo now closes its opening sector map after MAPFIRST.auto (still 20 seconds). Career still waits for a press. F2 and F8 require Ctrl throughout the demo, including its attract and raid; career keeps the plain keys. The crouch undo stays intact. The existing editor tag, fixed-key labels and Settings hint follow the current demo state when rendered, rather than being fixed at page boot. No new controls, screens or player wording.

Local verification: the mk script printed written; all 19 anchors matched exactly once and applied in memory; the resulting game script, new check and preserved map check parsed with Node vm.Script; all retired launch names and CSS were absent. Output files checked as ASCII. The tracked game and fixture were not edited. No browser, network, play port or ship scripts were used.

The new draft check exercises the normal title demo row, automatic map start just before and just after MAPFIRST.auto, F2 and F8 on the attract and in the raid, Ctrl chords and crouch restoration, key labels, EXIT DEMO and return to career F8. On the old build the launch functions are present, demo maps wait, and plain demo F8 starts a snip, so the control must fail. Browser execution remains for the lane; syntax checks do not prove those runtime results.

Fixture work is ready for a Claude lane under its ship lock: fixture-retarget.json contains three exact edits. Delete the six v30.79 launch checks, which only test the retired mode. Delete v31.37 cw-partykeys, replaced by this ship check. Preserve the rest of v31.09 cw-mapfirst, remove its saved PARTY variable and retired flag arms, and keep the career press check. The new ship check owns demo auto-start. This preserved check remains valid on the old build, so its fixture-only commit can precede the ship. prepare-fixture.ps1 regenerates that manifest against this worktree; it writes only the task output folder.

Still required: apply/check/commit the fixture edits, preflight and ship cw-cx-demoplain, fresh-page comparison with ?party=1, pictures and critic for title and map, and a real two-window run from the plain title with one opening-map picture per player. shots.txt requests available catalog screens 01 and 22; screen 22 is a career-map staging and does not replace the required demo pair. questions-new.md records the lane work, with no owner decision requested.


--- codex run 2026-10-19 11:06 ---
2026-10-19, lane o, preflight follow-up, base still v31.82.

Confirmed the failure is the fixture prerequisite from the first run, not a failing new demo assertion. Preflight executes its new-check and control gates before recent checks; reaching REGRESS 31.09 means the new check passed twice on the draft and failed on the old build. The unchanged v31.09 check reads oParty=PARTY before its try block and later requires a demo with PARTY=false to keep waiting. Both are incompatible with the requested removal and plain-demo auto-start.

The automated lane only installs mk scripts and runs preflight/shipping. It harvests questions-new.md but does not apply fixture-retarget.json. Therefore another identical retry cannot resolve this failure. I did not restore PARTY or alter runtime tests to hide the regression.

Regenerated the fixture replacement manifest and repeated local anchor/syntax/ASCII checks. Added the fixture prerequisite to the mk script comment. Temporarily emptied keys.txt and retained cw-cx-demoplain in pending-keys.txt so the automated lane does not spend another gate attempt on the unchanged fixture. Restore that key after the Claude lane applies and commits the existing fixture handoff. No tracked files changed.

The controlling instruction is Codex addendum, How a change ships, step 5: if an older check must be retargeted, write it in questions-new.md and end TASK PARTIAL naming it; a Claude lane does it. Remaining work: that fixture update, retry preflight/ship, and the requested title/query comparison and two-window demo pictures/critic.


--- codex run 2026-10-19 11:06 ---
2026-10-19, lane o, resumed after fixture handoff. Confirmed the shared repository still has the unchanged v31.09 reference oParty=PARTY at tools/mkfixture.ps1:8790; master is still v31.82. The required Claude-lane fixture update has not landed. Local draft validation still passes (19 unique anchors, game/check syntax, ASCII). keys.txt remains empty, with cw-cx-demoplain retained in pending-keys.txt, to avoid another identical failed preflight. The existing questions.md handoff and fixture-retarget.json contain the required changes. No new question or duplicate gate attempt. Resume shipping after that fixture-only commit.

--- codex run 2026-10-19 11:07 ---
2026-10-19, lane o, resumed with no new gate result or fixture commit supplied.

The shared fixture still reads oSay=say, oParty=PARTY at tools/mkfixture.ps1:8790. The prepared fixture-retarget.json has not been applied, so the previously reported REGRESS 31.09 remains unresolved. No further code changes or repeated gate attempt are justified. keys.txt remains empty; pending-keys.txt retains cw-cx-demoplain. The existing questions.md handoff already specifies the exact fixture edits and required two-window/query checks, so no duplicate question was added.

Next action belongs to the Claude lane under its ship lock, as required by Codex addendum shipping step 5: apply and commit fixture-retarget.json, then restore pending-keys.txt into keys.txt and retry cw-cx-demoplain. The task must not be requeued to Codex before that prerequisite changes. After shipping, the title/query comparison, both demo-window map pictures, automatic start in both windows, and critic results remain required.


--- codex run 2026-10-19 11:07 ---
2026-10-19, lane o, continued after refresh to v31.82.

Checked both the refreshed workspace and shared tools/mkfixture.ps1: line 8790 still reads oParty=PARTY. The required fixture update has not landed. No new gate result was supplied. The pending game draft and fixture-retarget.json remain ready; keys.txt stays empty to avoid the same known preflight failure. No new code change, duplicate question, or gate attempt.

Required external action: a Claude lane applies and commits fixture-retarget.json under the ship lock (Codex addendum shipping step 5). Then restore cw-cx-demoplain to keys.txt, run preflight/ship, and complete the fresh-query title comparison and two-window demo map/run pictures with critic results. Codex can resume dependent work after that fixture update or a new lane result.

