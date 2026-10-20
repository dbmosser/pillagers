47-check-demo-link-offline : does the 2 player demo link with no internet (coordinator 2026-10-20, helper-fixes item 42)
effort: low

Why: at the party the room may have no internet. The 2 player arcade demo links its two windows over WebRTC on one PC
(netHost, netJoin, netAccept over the BroadcastChannel). NET_ICE lists two outside STUN servers and the host waits up to
NET_WAIT_ICE (5 s) for them. On one PC the host candidates should still link, but nobody has tried it with the outside
servers unreachable (tools/handoff/q-round3/verify-log.md row 34).

Do (test only, no firewall, no adapter changes, never port 8802):
1. Serve the current build on a free test port. Start Chrome with
   --host-resolver-rules="MAP * ~NOTFOUND , EXCLUDE localhost , EXCLUDE 127.0.0.1" so every outside name fails while
   localhost works. Click the 2 player arcade demo row; let player 2's window open.
2. Record how many seconds from the click until both windows stand in the Undercroft as a party of two. Do it 3 times.
3. Start a raid and let it run 3 minutes. Note any disconnect, freeze or warning text.
4. Repeat steps 1 to 3 with normal name lookup as the control.

Write a check only if a game change is needed. If the link fails or takes over 15 s offline, the fix is to make it link on
host candidates without waiting on the outside servers (keep the STUN list for later builds); ship it through the queue
with a check that FAILS on the old build. If it links fine, change nothing in the game.

Report in tools/handoff/console/notes/47-check-demo-link-offline.md: offline seconds (3 tries), control seconds, raid result.
TASK DONE with the numbers (and the ship, if one was needed); TASK PARTIAL with what is left.
