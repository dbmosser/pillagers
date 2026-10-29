# o-00c active-reload-status : the active reload chain shows as a status icon
HIS WORDS 10-28 about 20:06: "active reload bonus stacks should be shown as a status". Second in line, after o-00b.

What is on HEAD: the active reload chain (dark_raiders.html, v35.xx cw-reloadstack, about lines 26202-26269: p.arStk, AR_STK_MAX, p.arMul, p.arBonus) shows only as a floating "ACTIVE RELOAD xN" label at the moment of the reload. Nothing on the HUD says the chain and its bonus are live.

Build: a status entry in the existing status column (drawStatusIcons and its list STATUSL / statusLive, about line 44088; same look and size as the other status icons, his v19.00 order puts statuses down the left) that is on while the chain is live (p.arStk >= 1) and shows the stack count, e.g. "active reload x3", plus the bonus it gives if the other statuses show a value. It goes off the same tick the chain resets (a miss, or a reload left to run out). Use an icon in the same family as the others; colour from the style guide (tools/handoff/console/notes/ui/style-guide.md), the green the chain label already uses is fine. Both windows: each player sees only their own chain. Player words lower case.
Check (must FAIL on the current build): after two active reloads in a row the status list has an active reload entry reading x2; after a miss it is gone.
Rules: the seed 4242 fingerprint must hold; both windows; never touch the pickup stack, loot sounds or loot rows. DESIGN.md watch line: "the active reload chain shows as a status with its count".
Pictures at 1080 and 4K with a x1 and a x3 chain.
TASK DONE when it shipped and is ON HIS PC.
