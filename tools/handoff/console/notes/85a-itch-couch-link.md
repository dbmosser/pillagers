# 85a-itch-couch-link (lane a, 2026-10-21)

Shipped (all gates PASS, seed 4242 fingerprint unchanged):
- v33.57 cw-p2nolink: netSameWatch(now), 15 s after the pick with nobody in: status "player 2 not linked", title note with RETRY, one hub feed line. Ticked from netMateTick (Undercroft frame), top level too.
- v33.59 cw-p2bridge: netSameChan seam. Embedded host (reportEmbedded) and a player 2 window with emb=1 talk over window.opener.postMessage, words wrapped {pg:'pillagers',m}. netBridgeIn takes a word only from this origin, with the tag, from the pair's own window, with the pair code. netP2Url adds emb=1 and keeps the frame's own query (itch ?v=). Player 2 with emb=1 and no opener shows "no link: pick 2 player in the player 1 window" and posts nothing.
- v33.61 cw-p2marks: player 2 beat every 2 s (raid 0/1, pair free), host memory NET.mateBeat read by p2RaidNow/p2LiveNow (max with storage), host adopts the beat window as NET.p2win; shared keys NET_WHO_KEY, NET_SPLIT_KEY, KID_SHARE_KEY compared once a second (netBridgeTick, from netMateTick), only those three accepted, host posts all three on ready.

Not done (needs the coordinator, see alarms.md): real cross-site frame run (notes/85a/frame2p.mjs written, not run), PUBLISH.md SharedArrayBuffer line, real itch draft test (his item).

Watch line for him: if the party line ever says player 2 not linked while both windows are open and playing, tell me. On itch, never turn on SharedArrayBuffer support.

## Run 2 (lane a, 10-21 ~08:00)
- FOUND why coord-06's rerun on 33.60 (raw-T4-framed-3360probe.json) did not link: the rig host page carried ?netslot=A, netP2Url (embedded path) copied it to player 2, and ?netslot beats ?p2 at boot (NETP2=!NETSLOT&&..), so that window was never player 2 (p2 probe same:"" pair:""). Real itch has no netslot, so this is a rig artifact, but the fix is free: cw-p2noslot (netP2Keep drops netslot on the embedded address). Rerun the framed T4 after it ships.
- The stale-card STOP (REGRESS 33.46) came from the 0.15 stamp rule: shipped cw-card45 (stamp only; the three short notes stay).

## Run 3 (lane a, 10-21)
- Nothing left for this lane. The cross-site frame run was done by coord-06 on 33.59 (links in 1.8 s in Chrome and Edge with itch's own query). PUBLISH.md already carries the SharedArrayBuffer line (line 59). The netslot fix moved to its own task 85b-emb-p2-drops-netslot. The real itch restricted-draft test (Chrome, Edge, Firefox, saves check) is his item, not a lane item.
