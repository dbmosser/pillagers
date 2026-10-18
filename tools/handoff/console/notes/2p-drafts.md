# 2P drafts (shared by 3 tasks; lanes claim rows by writing CLAIMED lane-x)
# KEY INSIGHT (lane b): the chain2 "parse check" STOPs were an apostrophe in the draft "now" line (breaks the DEVNOW string).
# Fix = mk-cw-KEY.ps1 that reads draft-SRC.json, strips apostrophes from now, writes draft-cw-KEY.json (copy S\mk-cw-ovshake.ps1, change $src and $key), then shipq.sh cw-KEY.
# Check each draft's anchors still match HEAD first. Two drafts touching the same line (blast-past-shield, hit-stop-rule) must ship in turn, the later rebuilt.
key | status | reason
late-body-boss-range | DROPPED (lane-b) | superseded: v28.60 p2boss (boss mark) + v28.61 p2reach (sr reach in new word) already shipped; anchors gone
overseer-phase-shake | DONE (lane-b) | v28.87 via cw-ovshake
p2-blast-past-shield | DONE (lane-b) | v28.88 via cw-blastshield
p2-hit-stop-rule | DONE (lane-b) | v28.92 via cw-hitstoprule
p2-mimic-seen | DONE (lane-b) | v28.93 via cw-mimicseen
p2-near-miss-pins | DONE (lane-b) | v28.95 via cw-nearmiss (anchor 3 retargeted to the hitstoprule line)
p2-screen-clear | DROPPED (lane-b) | superseded: v27.86 partyp4 already sends a pulse word (nc,1500) and pays the medal in a linked window
ricochet-seen | DONE (lane-b) | v28.97 via cw-ricoseen
teammate-hears-windup | DONE (lane-b) | v28.99 via cw-windup (rebuilt: whirr via spkPlay lmgSpinUp since v27.95; one-line anchors)
feel lane-target | CLAIMED lane-b (b-15) |
muzzle-net | CLAIMED lane-b (b-15) |
p2-blow-not-round | CLAIMED lane-b (b-15) |
padcap-nextgun | CLAIMED lane-b (b-15) |
role-twin | CLAIMED lane-b (b-15) |
raid bountyfire | CLAIMED lane-b (b-15) |
evsh | |
shforge | |
shrespawn | |
