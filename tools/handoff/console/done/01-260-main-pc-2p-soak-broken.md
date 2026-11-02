# 01-260-main-pc-2p-soak-broken : the main PC's 2 player soak passes 0 of 6 on every build since 10-31 05:58
Queue (CEO 11-01): the two-window soak is the only test that runs the same-machine 2 player pair on his own PC, and it has failed every
run since it started there (10-31 03:36 commit 91db1e8c8). It says nothing useful until this is fixed. 2 player is first in line.
model: opus
effort: high

What fails (the same two lines in all 6 runs, v36.95):
  run k {"pass":false,"bad":["the player 2 window does not say it is player 2 on its title",
         "timed out after 20000 ms waiting for both rosters to show two"],"trade":0,"drop":0,"relink":0,...}
Where the logs are:
- the result file: git show origin/spare-results:spare/JUL26/soak-last.txt (git fetch origin spare-results first; read-only, never push it)
- the status line: git show origin/spare-results:spare/JUL26/status.txt ("soak=soak v36.95: 0 of 6 passed"); the coordinator also sees
  it in checkin.sh ("main PC: ... soak ...") and from node tools/bridge/hostctl.mjs main-status (runner.status)
- the harness: tools/spare/soak-run.ps1 (main PC: own Chrome on 9335, tools/spare/serve.mjs on 8809) runs tools/handoff/soakloop.ps1,
  which opens tools/nettest.html?f=fixture-soak-8809.html&soak=120 and clicks RUN SAME MACHINE (runSame(), nettest.html about line 865).
- the network pair test on the same page passes on the main PC (spare/JUL26/p2-online-test.txt, 10-30), so the link code works there.

First lead (coordinator read, 11-01): failure 1 looks like a STALE HARNESS LINE, not a game bug. nettest.html about line 902 wants the
text "PLAYER 2" in #p2line, but the game now writes 'Player 2 window' (dark_raiders.html about line 62314; v28.xx cw-partyx and
cw-nocaps-dom took the capitals out, and his rule is lower case player text). Check it case-blind (or the CSS text it shows).
Failure 2 (rosters never show two in 20 s) is the real question. Find out which it is:
  a) harness: st(fa)/st(fc) read a roster field that moved, the stand-in window.open (A.open) no longer reaches the game's open call,
     or C boots on a page or save the pair code does not match; or
  b) a real 2 player bug: the same-machine co-op pair does not link on v36.95 (that would break the party's same-PC mode).
Run it on the VM first: your lane's own Chrome and a test server, never 8802. The VM's tools/nettest.html on the fixture, RUN SAME
MACHINE, read window.__NETTEST_SAME and the page log. Drive it from your own mk-cw-260-*.ps1 script (tools/cdp.ps1 calls inside it,
the way tools/handoff/soakloop.ps1 does), since your command list runs those. If an older build passes (try a builds/ file from before 10-30), bisect the
build that broke it.

Fix:
- harness only (a): you cannot commit tools files, so write the fixed tools/nettest.html and/or tools/handoff/soakloop.ps1 as
  notes/260/FILE.new with a short notes/260/why.md (what changed, the VM run that passes with it), and end with
  TASK WAITING: coordinator copy notes/260 files over tools/ and push. The main PC runner follows master in about a minute and runs
  the soak again on the next build while he is away.
- game bug (b): it ships through the normal pipeline (mk script, preflight, shipq) with a new check that fails on v36.95, the seed 4242
  fingerprint, both windows, and a DESIGN.md watch line in game words. Never touch the pickup stack, loot sounds or loot rows.
Rules: never 8802; never ask him anything; say plainly in the notes which of a) or b) it was.
TASK DONE when a soak run of 6 passes at least 5 on the VM with the fix in place (write the six result lines in notes/260-soak.md) and, for a game fix, it is
ON HIS PC. TASK PARTIAL with what is left.

COORDINATOR 11-01 14:20: copied notes/260/nettest.html.new over tools/nettest.html (read the diff: harness only, the opener hand-off, case-blind text, new status words, pad-lost clear, p2 mark wipe), committed and pushed; the main PC runner takes it from master. STILL OPEN: the VM soak was 3 of 6 (half second frame hitches). CHECK THE NEXT MAIN PC SOAK (git show origin/spare-results:spare/JUL26/soak-last.txt, status line "soak vNN.NN: N of 6"): 5 or more of 6 = move this job to done/; "frames stalled" again = write a perf job for the hitch (map, menu, save under random keys), not a harness job. Stays in waiting/ until that soak is read.

11-02 (from the main PC Claude): soak 0 of 6 on v36.71 and v36.95, all at the join step ("player 2 window does not say it is player 2", "both rosters to show two" timed out); the v37.17 try stopped on low RAM. His exports show no player 2 window report since 10-22. Could be the headless test or the game, so same-machine join is OPEN until the Main PC Correspondent's nettest in a real window on master reports. If that fails it is a game bug: fix job first in line.

11-02 07:15 (CEO): his order "keep all testing on the JTPC". The main PC runs no soak or nettest any more; the real-window nettest moves to the JTPC chat. The main PC's soak line is frozen at 0 of 6 and no longer means anything new. A fail on the JTPC is a game bug and becomes a fix job first in line.

11-02 11:40 (CEO): CLOSED. On the JTPC, v37.39, scale 1, 1920x1080, real window: the unchanged nettest page PASS 2 of 2, the page with E held by game clock PASS 2 of 2. The 4 of 4 FAIL before came from a window at that PC's 300 percent display scale, about 9 frames a second, where the game clock ran at 0.45 of real time. No game fix. Page landed in tools/nettest.html.
