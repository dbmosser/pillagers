# 0p13-189-p2-window-dies-recovers

Shipped v36.90 (cw-p2reopen), commit 50746d0cb. ON HIS PC v36.90.

HEAD before: host already played on alone when the link dropped (netDrop, ~61545) and a p2 window that boots finds the pair itself (ready/offer/arcon, ~62203/62222). If the host window dies, p2 takes over the raid (v17.69, ~66218). Missing: nothing opened a closed p2 window again.

Now: arcadeMateWatch (1 s timer, before arcadeSoloPick): after p2 was linked and the link is gone 3 s, host reopens the p2 window at the same pair address; open-but-dead window reloaded after 10 s unless p2RaidNow; blocked open retried every 2.5 s (next key press gets through).

Not covered: player 1 window dying. The game cannot reopen its own opener; the launcher (tools/party/party.ps1, which I may not edit) would have to. Left for the coordinator if he wants it.

Watch: close the p2 window mid run, feed says "player 2 window reopening", window returns, p2 presses A to rejoin.
