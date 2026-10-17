# 2P drafts (shared by 3 tasks; lanes claim rows by writing CLAIMED lane-x)
# KEY INSIGHT (lane b): the chain2 "parse check" STOPs were an apostrophe in the draft "now" line (breaks the DEVNOW string).
# Fix = mk-cw-KEY.ps1 that reads draft-SRC.json, strips apostrophes from now, writes draft-cw-KEY.json (copy S\mk-cw-ovshake.ps1, change $src and $key), then shipq.sh cw-KEY.
# Check each draft's anchors still match HEAD first. Two drafts touching the same line (blast-past-shield, hit-stop-rule) must ship in turn, the later rebuilt.
key | status | reason
late-body-boss-range | DROPPED (lane-b) | superseded: v28.60 p2boss (boss mark) + v28.61 p2reach (sr reach in new word) already shipped; anchors gone
overseer-phase-shake | DONE (lane-b) | v28.87 via cw-ovshake
p2-blast-past-shield | CLAIMED lane-b | cw-blastshield
p2-hit-stop-rule | CLAIMED lane-b | rebuild after blast-past-shield (same lines)
p2-mimic-seen | CLAIMED lane-b |
p2-near-miss-pins | CLAIMED lane-b |
p2-screen-clear | |
ricochet-seen | |
teammate-hears-windup | |
feel lane-target | |
muzzle-net | |
p2-blow-not-round | |
padcap-nextgun | |
role-twin | |
raid bountyfire | |
evsh | |
shforge | |
shrespawn | |
