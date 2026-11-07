# o-00y 2p-online-party-critical : make the 2 player online party solid for Saturday (two PCs, both on mouse and keyboard)
HIS ORDER 10-30 (to the Gameplay Edit Intaker, verbatim): "Over the next 30 hours, Make any edits you see as critical for two player play, and test them. Use Claude sparingly so as to leave me at least 5% of usage, try to blow Codex instead".
HIS PARTY PLAN 10-29 ~23:00 (CEO chat): "I want every player to have the option of mkb. The game is made for mkb". His main PC hosts on http://localhost:8802/ (v36.55). The spare PC joins from the itch link (the same build; itch follows each ship within about a minute). Each player is on their own mouse and keyboard. The steps he was given: at the lift press F (party window), HOST A PARTY, COPY CODE, send it to the other PC, paste it, JOIN A PARTY, send the reply code back (PTY1a), LET THEM IN, ascend together. The backup is the couch setup on one PC with a pad.

SCOPE: only what BREAKS or BADLY HURTS 2 player play. Every other job waits (Codex's other jobs are in console/hold-2p/; Claude lanes are off). No features, no restyles, nothing his veto list bans, never the pickup stack, loot sounds or loot rows.

Audit the real online path (WebRTC: sdpPack/sdpUnpack ~60720, netNewPc, NET_ICE STUN ~60577, LET THEM IN ~60841, JOIN ~60857, openParty ~71006, KeyF at the lift ~51728), NOT only the same-PC BroadcastChannel pair the gate usually runs. Risks to check first:
1. The guest runs inside itch's iframe. Does COPY CODE (netCopy) work there? Clipboard write can be blocked in a cross-origin iframe. If it fails silently, the code must be selected or shown so it can be copied by hand, and the button must say so in a short lower case word.
2. Does RTCPeerConnection connect between two separate browsers (different profiles, no shared BroadcastChannel)? Use tools/nettest.html with two ?netslot copies, or two pages in separate browser contexts, through host, invite, reply, let them in, then a raid start.
3. A version or proto mismatch between host and guest (itch catching up a minute after a ship) must say so plainly. It must not hang.
4. In a raid: both seats on keyboard and mouse (partypadbtn "no controller"). Movement, aim, fire, reload, heal, pickup, extract, downed and revive work for the guest, and the guest sees the host's shots and pings (his 09-27 ruling: you always see the other player and their shots). No team damage.
5. End of raid: extract, death, abandon. Both return to the undercroft, the guest keeps their own save (fresh itch save gets the welcome pack), and a second raid can start without new codes, or the re-host flow is clear.
6. A dropped link mid-raid: the remaining player keeps playing (a teammate who left is never waited for).
For each real break: a fix through the full gate (parse, the new check twice, ~80 older checks, seed 4242 fingerprint) and the 2-window checks, one ship per cause, DESIGN.md watch line in game words. A risk found sound: write one line per item in the ship note or in notes/o-00y-findings.md (no ship needed).
Candidates from hold-2p you may pull back ONLY if one breaks 2 player play: o-09j-players-pass-through, o-12-194-unlimited-partner-pickups, o-10-195-shared-last-5s-points.
Model: Codex high. The camera critic may run, but keep pictures to the 2 player screens (party window, both raid windows).
TASK DONE when every fix is ON HIS PC and the findings file lists all six items.

Lane note 2026-10-30 07:14: shipped cw-cx-onlinecopy and parked: only lane-side steps are left. Codex's last words:
The copy fix is ON HIS PC v36.56. All four test runs passed combat controls, healing, pickup, both revives, no team damage, and guest keyboard extraction.

Corrected the harness’s run-card return flow. No additional game bug was confirmed.

TASK PARTIAL: coordinator must run the corrected repeat-raid and host-disconnect tests; the lane’s two camera rounds are exhausted.
