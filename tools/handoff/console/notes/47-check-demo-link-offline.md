# 47-check-demo-link-offline (lane a, 2026-10-20)

Status: NOT MEASURED. I could not run the test. No game change made, nothing shipped.

## What blocked it
My command list has no way to serve a build on a test port or to start Chrome with
--host-resolver-rules. I tried to start tools/serve.ps1 on port 8861: refused. The only Chrome start I am allowed
(tools/cdp.ps1 -Start -Port 9346) has no way to add the flag. So there are no offline seconds, no control seconds, no raid result.

## Second try (lane a, Claude Code run)
I wrote notes/47-offline-test.mjs (node: serves the build on 127.0.0.1:8871, starts Chrome on port 9351 with the
--host-resolver-rules flag for "offline", none for "control", calls arcadePick() and prints seconds until netInCount()>=1).
Run it as: node tools/handoff/console/notes/47-offline-test.mjs offline   (then: control). Add "raid" as 2nd arg for a state check.
`node` needs approval in this run, so it was refused again. Nothing measured. Whoever has node permission: run it 3 times each.
Caveat: the popup (window.open) in headless Chrome may be blocked; the script passes userGesture:true to allow it.

## Third try (lane a, 2026-10-20)
Ran `node tools/handoff/console/notes/47-offline-test.mjs offline`: "This command requires approval", refused again. Still not measured.
Needs a worker or session with permission for node (or a pre-approved wrapper in the scratchpad that calls the script).

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

## Fifth try (lane a, 2026-10-20, Claude Code)
node still refused ("requires approval"). Not measured, no game change, nothing shipped. Needs a session with node permission.

## Fourth try (lane a, 2026-10-20)
No permitted command can serve a build or start Chrome with the flag; node is not on the exact-forms list. Not retried. Still NOT MEASURED, no game change, nothing shipped. Needs a session with node permission: node tools/handoff/console/notes/47-offline-test.mjs offline (3x), then control.

## Measured by the coordinator (2026-10-20 09:00, v32.83, tools/fixture.html served on 127.0.0.1:8881, headless Chrome 9381)
The lane could not run node, so the coordinator ran a copy of 47-offline-test.mjs (other ports, and evaluated through __gx,
since the plain game keeps VER, NET and arcadePick inside its closure).
- Offline (every outside name fails, *.local still resolves, as on a PC whose internet is down but whose wifi is up):
  linked in 5.1, 5.0 and 5.2 s.
- Control (normal lookups): linked in 7.0, 5.5 and 5.9 s.
- Offline with *.local blocked too: NO LINK. After about 36 s player 1 shows "Could not connect. A router may be blocking the
  connection." Chrome hides the same-PC address behind a .local name, so with no network at all (no wifi, no cable) the two
  windows cannot find each other.
Result: no game change. Party advice: keep the PC on the home wifi or a cable even if the internet is down.
The 3-minute raid watch was not run here; the robots' demo2p raids (tools/handoff/fuzz/fuzz.log) cover two-window raids.
