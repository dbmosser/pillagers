# o-00c2 reload-chain-breaks-on-switch : switching guns ends the active reload chain
HIS WORDS 10-28 about 21:25, right after v36.17 (the chain as a status): "Active reload chain should also break if player switches guns". Next in line: he is waiting for it.

What is on HEAD: dark_raiders.html v35.xx cw-reloadstack (about lines 26202-26269) and v36.17 cw-cx-reloadstatus (status entry, about line 43935). A switch away from p.arGun drops p.arBonus (line ~26212) but keeps p.arStk, so the status reads "chain ready" and the next active reload on any gun carries on the count.

Build: any change of the held gun (next gun, number keys, wheel, pad, pick-up swap, melee and back if that changes p.wep) sets p.arStk=0, p.arBonus=0 and clears p.arGun at once, the same as a missed active reload, so the status entry goes off that tick and the next active reload starts at x1. Find the one place the held gun changes (or each door that sets p.wep) and reset there. A reload that is cancelled by the switch also ends the chain. Both windows: each player's own chain only (a partner's switch does not touch yours).
Check (must FAIL on the current build): chain x2 on gun A, switch to gun B: arStk 0 and the status entry gone; switch back to A: still 0; next active reload reads x1.
Rules: the seed 4242 fingerprint (ents 85/374, containers 165/593) must hold; both windows; never touch the pickup stack, loot sounds or loot rows. DESIGN.md watch line: "switching guns ends the active reload chain".
TASK DONE when it shipped and is ON HIS PC.
