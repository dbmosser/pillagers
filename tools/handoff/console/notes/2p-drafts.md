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
feel lane-target | DONE (lane-b) | v29.05 via cw-lanetarget
muzzle-net | DONE (lane-b) | v29.08 via cw-muzzlenet (rebuilt: rico field now 8th, new fields 9-11)
p2-blow-not-round | DONE (lane-b) | v29.07 via cw-blowround (rebuilt: only the roll was left; stop/pin fixed by hitstoprule/nearmiss; roll now needs sk)
padcap-nextgun | DONE (lane-b) | v29.04 via cw-padcap
role-twin | DONE (lane-b) | v29.02 via cw-roletwin
raid bountyfire | DROPPED (lane-b) | already fixed in HEAD: bounty pays only on byPlayer===true or bySeat>0
# NOTE: preflight.sh is runnable (bash tools/handoff/preflight.sh b cw-KEY). A card-stamp STOP was fixed with mk-cw-cardP9 (P9 used, next is P10).
evsh | DROPPED (lane-b) | already in HEAD: convoy ok() and the bounty pick both carry shAt(x,y,80)
shforge | CLAIMED lane-b | strongholds are now real buildings (shCands), no fence/compound circle; rebuilding as cw-shforge: shCands skips a building holding the Forge
shrespawn | DROPPED (lane-b) | obsolete: strongholds are now map buildings with walls, no fence and no p.shS side memory in HEAD
