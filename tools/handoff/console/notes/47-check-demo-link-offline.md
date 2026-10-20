# 47-check-demo-link-offline (lane a, 2026-10-20)

Status: NOT MEASURED. I could not run the test. No game change made, nothing shipped.

## What blocked it
My command list has no way to serve a build on a test port or to start Chrome with
--host-resolver-rules. I tried to start tools/serve.ps1 on port 8861: refused. The only Chrome start I am allowed
(tools/cdp.ps1 -Start -Port 9346) has no way to add the flag. So there are no offline seconds, no control seconds, no raid result.

## What the code says (read only)
- Host (netHost) and player 2 (netJoin) each wait in netGather until ICE gathering completes, or NET_WAIT_ICE (5 s), whichever is first.
  Both sides gather, one after the other: host first, then player 2 after the offer arrives on the BroadcastChannel.
- With names that fail at once (MAP * ~NOTFOUND), the STUN lookups should fail fast and gathering should finish in well under a second per side.
- The slow case is a network that swallows the lookups (a room wifi with no internet). Then each side could wait the full 5 s,
  about 10 s plus the link itself. That is under the 15 s line but close. If the room is like that, the 5 s is the cost.
- Linking after gathering uses the host candidates on one PC. That does not need the outside servers.

## What is needed to finish
A worker with permission to run a local web server and a Chrome with the flag. Steps are in the task file. If the link takes over 15 s offline,
the fix is to lower NET_WAIT_ICE for the same-machine arcade link only (about 1 s) and ship it with a check that fails on the old build.
