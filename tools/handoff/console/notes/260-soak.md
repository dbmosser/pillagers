# job 260: VM soak runs (lane c Chrome 9353, test server 8817, fixture of v37.01, 6 runs x 120 s soak each)

Result: the fixed page passes 3 of 6, short of the 5 of 6 the task asked for. Every failure is the soak's frame-stall rule
(a second with under 3 frames); every other step (link, floor, pad, sound, saves, raid, enemies, loot, shots, ping, host out,
drop-in, trade, reload, party end) passed in all 24 runs below except batch 1 run 1 (stale p2raid mark, fixed after it).
Before the fix: 0 of 6 on the main PC, and the same two failures on the VM (run-a).

## Final page (notes/260/nettest.html.new as it stands; batch 2, run-soak6b.txt)
run 1 {"pass":false,"bad":["soak: frames stalled: A drew 2 frames in second 43; C drew 2 frames in second 43; A drew 2 frames in second 71"],"trade":743,"drop":504,"relink":501,"errors":0,"saved":0,"drops":0,"fps":{"A":2,"C":2},"soakSec":120}
run 2 {"pass":true,"bad":[],"trade":600,"drop":502,"relink":511,"errors":0,"saved":0,"drops":0,"fps":{"A":3,"C":3},"soakSec":120}
run 3 {"pass":true,"bad":[],"trade":628,"drop":494,"relink":561,"errors":0,"saved":0,"drops":0,"fps":{"A":3,"C":3},"soakSec":120}
run 4 {"pass":true,"bad":[],"trade":721,"drop":525,"relink":577,"errors":0,"saved":0,"drops":0,"fps":{"A":3,"C":3},"soakSec":120}
run 5 {"pass":false,"bad":["soak: frames stalled: A drew 2 frames in second 71; C drew 2 frames in second 71"],"trade":624,"drop":513,"relink":502,"errors":0,"saved":0,"drops":0,"fps":{"A":2,"C":2},"soakSec":120}
run 6 {"pass":false,"bad":["soak: frames stalled: A drew 2 frames in second 53; C drew 2 frames in second 53"],"trade":739,"drop":489,"relink":585,"errors":0,"saved":0,"drops":0,"fps":{"A":2,"C":2},"soakSec":120}

## Other batches
- batch 1 (run-soak6.txt, before the wipe fix): 4 of 6. Run 1 never opened player 2: the p2raid mark from my previous VM run
  (Chrome ended mid raid, no pagehide) made the co-op row refuse for 75 s. Run 2: frame stall.
- batch 3 (run-soak6c.txt, copy B hidden during the run): 1 of 6, all frame stalls; the VM was busier (every timing slower).
- batch 4 (run-soak6d.txt, stall judged against each window's own median): 3 of 6. It showed the windows usually draw 26 to 30
  frames a second, so a 2 frame second is a real hitch of about half a second, in A and C at once. Both of these trial edits
  are taken back out: neither helped, and the stall rule should stay as it was.

## What is open: the half second hitches
In 12 of 24 runs A and C each lost about half a second at least once during the random input soak, at random seconds, always both
windows in the same second (one renderer thread: the test page runs both games as same-origin frames). Not known yet: whether it is
the VM being shared with the other lanes' Chromes, or a game hitch the random keys hit (a map, menu or backpack opened the first
time, a save). The main PC is much faster; its soak with this page will say. If it also stalls, it is worth a perf job.
