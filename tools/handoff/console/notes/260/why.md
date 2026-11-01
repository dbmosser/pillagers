# job 260: why the main PC 2 player soak failed 0 of 6, and the fix

Answer: (a), HARNESS ONLY. The game's same machine pair links fine on the current build. tools/nettest.html had four stale parts.
No game change. Nothing in tools/ was edited; the fixed page is nettest.html.new in this folder.

## For the coordinator
Copy notes/260/nettest.html.new over tools/nettest.html, commit and push. tools/handoff/soakloop.ps1 and tools/spare/soak-run.ps1
need no change. The file is rebuilt from the current tools/nettest.html by
S/mk-cw-260-patch.ps1 (17 exact edits, each anchor found once), so if nettest.html moves first, run that again.

## What was wrong (all in tools/nettest.html, untouched since 10-11)
1. THE REAL BLOCKER: player 2 never linked. The test page runs player 1 (copy A) in an iframe, so the game counts it as embedded and
   since v33.58 (cw-p2bridge, 10-21, built for itch) gives the player 2 address emb=1. A player 2 window with emb=1 talks through
   window.opener. The test page stands in for the popup with another iframe (copy C), and an iframe has no opener, so C stopped at
   boot ("noopener", chan false) and the rosters never showed two. A real popup always has its opener.
   Fix: armC() hands C its opener (A) on every tick while C loads, and reloads C (up to 3 times) if it still booted without one.
   Armed by the stand-in window.open and by the reload step. The boot wait now also needs C's link channel open.
2. Upper case text checks: "PLAYER 2" on the title line, "CO-OP" and "SAME MACHINE" in the PARTY mode line, "PARTY" and
   "ABANDONED" on the run cards. The game shows them lower case now (his 10-18 order). Checked case-blind.
3. Old status words: the host-out line has said "NAME is out (how) . extract to finish" since v16.74, and a spectating host reads
   "party back . raid over". Both regexes accept these now.
4. The pad loot step pulled its stand-in pad out mid-raid. Since the pad-lost pause, player 2's raid then pauses for "reconnect"
   and reopens the pause box every frame until that pad comes back, so the mouse shots fired 0 rounds and the ping was refused.
   The step now waits for that pause (it should happen; the log says it did, about 100 ms), then puts C back on mouse and keys
   through the fixture's __gx hook. Also clearFloor() hid every open modal, the pause box included, before checking whether the
   pause box was open, so it never pressed resume; it presses resume first now (and on the game's own pauseOpen word).
5. The wipe button now also clears the player 2 live and raid marks (salvagerun:p2live, salvagerun:p2raid). A Chrome ended while
   player 2 was up top never runs its pagehide, the raid mark stays, and for 75 s the co-op row refuses to open a window over
   "a player 2 still in a raid" (right in real play). It cost one VM run; the main PC kills its soak Chrome the same way.
Also added: the shots and ping failure lines now say what C's raid held (paused, pause box, gun, focus...), for next time.

## VM runs (lane c Chrome 9353, test server 8817 serving a staging copy of fixture.html; never 8802)
- before, old page: run 1 FAIL, the same two lines as the main PC ("does not say it is player 2", "both rosters to show two").
- with fixes 1-3: linked in 5 s; then shots 0 rounds, ping refused (C paused).
- with all fixes: run 1 PASS (linked 4525 ms, trade 630 ms, drop-in 492 ms, relink 502 ms).
- 6 runs with the 120 s soak: 3 of 6 with the final page, every failure a half second frame hitch (A and C both drew 2 frames in
  one second; they usually draw 26 to 30). All other steps pass. Details and the four batches: notes/260-soak.md.
- S/mk-cw-260-patch.ps1 now makes 17 edits (the run of it that went with batch 2).

## One thing worth a look in real play (not proven, not changed)
The pad lost pause keys on the pad the player 2 window sees, and with the pair on one PC player 2 sees a pad the player 1 window
forwards only while player 1 is in front. If neither game window is in front (a click on the taskbar), the forward stops, and
after 0.6 s player 2's raid may pause on "reconnect" until A is pressed on the pad. Seen here only with the test page's fake pad.
