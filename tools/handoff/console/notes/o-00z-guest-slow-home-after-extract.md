
--- codex run 2026-10-30 08:43 ---
2026-10-30 - o-00z-guest-slow-home-after-extract - v36.57

NORMAL RESULT CARD; THE TEST ADDS THE MINUTE

The guest is not held for the host or a missed-packet timeout. The run-over card waits for the player to return, as in solo play. The reported minute is a wait in tools/p2online/p2.mjs before the test presses that control. Ship nothing.

Evidence:
- The two-PC result on origin/spare-results, spare/JUL26/p2-online-test.txt, run 202610301231-JUL26, passed all 10 steps. Its guest note says still up top a minute after extracting, then in the Undercroft. The host returned at 12:33:41 and collected the guest result at 12:34:49. These timestamps do not measure the actual extract-to-home duration.
- dark_raiders.html:35066-35069 sets G.over and calls netSpecStart/netUpEnd. netSpecStart at 64319 only keeps a raid for a HOST with an active teammate; a guest returns false immediately.
- netUpEnd at 62602 clears NET.upSeed and broadcasts the reliable up/out packet immediately. Extracted guests also set lateBan for that seed, preserving the no-rejoin rule. No network acknowledgment or timeout is awaited to close the result card.
- netUpView at 62781 reports on whenever G exists and state is raid, even with G.over set. It exposes over separately. A result card therefore still has up().on === true.
- The result card opens at 35917. Its return handler at 72371 commits the run, closes the card, clears G and calls showScreen(hub) without a host or network condition.
- p2.mjs:226-228 extracts the guest, waits up to 60000 ms for up().on to clear, and only THEN calls __p2.home() after another 3000 ms. home() is the function that clicks the return button. The wait cannot succeed while the untouched result card is open. The diagnostic where() also tests up().on before checking the card, so it calls this state raid.
- The host path at p2.mjs:191-193 instead calls __p2.home() as soon as its initial 3000 ms sleep ends. The two paths are asymmetric.

Verification:
Ran node .codex-work/o-00z-guest-slow-home-after-extract/diagnose.cjs against the unchanged game functions netUpEnd, netUpView, the result return handler, and the unchanged harness LIB. Solo, host and guest all passed: the result flag stays on after extract, and the first scripted return click reaches hub immediately. For linked roles, the network seed is cleared and up/out is sent before the click; the guest retains its no-rejoin seed. This is an offline check with stubbed DOM/network helpers, not a new linked browser test. No browser or network was started. The existing real two-PC run is the linked evidence.

No game or fixture edits, no keys, no visual change, no new shipping or ON HIS PC claim. Seed 4242, team damage, pickup stack, loot rows and sounds are untouched.

LOCAL: no linked review. This finding concerns the test driver waiting on its own window flag; no packet or shared game state changes.

Optional test-driver correction for its maintainer: remove the guest 60000 ms up().on wait and call __p2.home() after the same 3000 ms delay used by the host. Capture Date.now() immediately before each __endRaid(extract), store elapsed milliseconds when home() returns hub, include the guest value in its mailbox result, and print both values in the host result lines. Those times include the deliberate result-card delay. Do not describe the existing timeout as still up top; print __p2.diag() on a real home failure. No driver change is needed to establish this finding, and none is shipped with this normal-result investigation.

Requested notes/o-00y-findings.md entry: the guest delay in 202610301231-JUL26 is normal result-card behavior plus an artificial 60-second harness wait before pressing return. It is not a minute-long game transition. The actual extract-to-home time was not recorded in that run.
