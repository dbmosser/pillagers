# Check pages on the processor cost 43 minutes of every full run

All 2,880 checks took **53 minutes** with check pages on the graphics card, against **96 minutes** on the processor. Failing checks: 63 against 62. Table: `times.txt`.

This is about `a673cf90` (job 241) doing what it was meant to do, so it's a separate matter from `../p2-card/`. Nothing here is changed yet, and it's your call.

## The test

A private hidden browser on port 9345, on the frozen v37.48 copy. The only difference from the 96-minute run is that the patch's `if(location.search)` became `if(false)` in a private copy, since deleted. The live robot was held at 30 fps in both runs. One run each.

| | Uncapped robot, processor | Robot at 30, processor | Robot at 30, card |
|---|---|---|---|
| All 2,880 checks | 114 min | 96 min | 53 min |
| Failing checks | 63 | 62 | 63 |
| Slice 0 | 1130 s | 915 s | 407 s |
| Slice 2640 | 730 s | 688 s | 343 s |
| Slice 2760 | 1051 s | 752 s | 401 s |

Every slice was as fast or faster on the card, and most were clearly faster. The robot had 0 problems in 7 two-window raids meanwhile.

## What moved

| Check | Fails on the processor | Fails on the card |
|---|---|---|
| v34.90 cw-thirdsize (named in job 241) | | yes |
| v33.51 cw-pixkit, frozen frame not steady (named in job 241) | | yes |
| v27.00 career3: "an opened box glowed (1 pixels)" | | yes |
| v10.54 outfit rack: "an unowned suit repainted 1 pixels" | | yes |
| v9.27 standing behind a container roof | yes | |
| v18.34 belt keys are rounded tiles | yes | |

- v8.85, v8.89 and v9.07 are also named in job 241, and none of them failed on the card in this one run. They may flip only sometimes: v9.07 failed in one of the two processor runs.
- v10.10 failed in one processor run only.
- The other 57 or so fails were the same in all three runs.

So the patch does stop some pixel flips, and it also adds two fails that a card doesn't show.

## What I'd do

**Run the full set on the card, then re-run only the failing checks on a processor page, and call a check failed only if it fails there too.** `?kzN=1` pages already get the processor through this same patch.

That keeps job 241's protection against pixel flips for about 60 re-runs instead of 2,880. A check that fails only on the processor, like v9.27 and v18.34, would stop being counted, so you'd want to look at those two first.

I can build this and test it as a diff if you want it. I haven't started, because how `tools/stable.mjs` and the runner should read a re-run is your design.

## Not proven

- One run each way. A flip can hide in one run, so the "What moved" table may be missing some.
- The 53 minutes is private, with no gate job in it and the robot at 30 fps.
- JUL26 draws on another card and should gain too, but I haven't measured it.

## Also seen: the 25 s wait

`tools/corpus-slices.sh` waits 25 s after opening each slice's page. That's 10 minutes of every run. On this PC the page had its checks and read `complete` in 1 to 2 s, in 3 tries with the robot running. I'm testing a full pass with a wait that ends when the page is ready, and I'll send a diff only if the results hold.
