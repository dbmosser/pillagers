# o-00k-229 run-goals-pay-cash-not-sp : run goals pay $ or items at the Undercroft, never SP
HIS WORDS 10-28 about 22:20 EDT (in the Gameplay Edit Intaker chat), verbatim: "'run goals' on the right hand side shouldnt give sp if they change -- they should only give $$$ or item rewards at the undercroft -- because sp is like a high score counter so its not really fair for the run goals to do that unless they are always the same and progress -- ya know?"

What is on HEAD (v36.23): dark_raiders.html ~66430-66450. Three goals a raid drawn from a pool of eight (GOAL_IDS) on the side stream GOAL_TAG of the seed; a met goal pays its CHIP (200 to 500) into the run score (SP) at once, in DEMO (team score) and CAREER alike, with GOAL DONE in the alert lane and "+N sp" on the panel rows (his screenshot: "air strike +300 sp", "10 kills 9/10 +200 sp").

Build (his rule: SP is a fair high score, so goals that change raid to raid must not feed it):
1. A met goal adds NOTHING to SP, in career and in the arcade demo. The goal panel rows show the reward instead of "+N sp".
2. CAREER: each met goal banks a reward that is paid AT THE UNDERCROFT when you extract: $ (scale the chip to the raid economy, about $5 per chip point, so 200 -> $1,000 and 500 -> $2,500; tune to the $ values players carry, say the numbers) or, for the harder goals (vault, 3 pillagers, elite, warden), an item roll from the cache table instead. It shows on the extracted card as its own line ("run goals $2,500" / the item) and lands in the stash/wallet. Die or abandon and it is lost, like everything else you carry (his rule: coming back empty).
3. ARCADE DEMO (no Undercroft): a met goal gives the team a power-up drop at the player's feet instead of SP (the existing kill power-up pool), so goals still matter at the party without touching the leaderboard.
4. Update the panel text ("$1,000", "item", "power-up"), the GOAL DONE callout, What's New/help text that says goals pay a chip or score, and the score multiplier pause line if it counts goals. Player text lower case, $ for money.
Check (must FAIL on the current build): meet the 10 kills goal: run SP unchanged; career extract: the wallet rises by the goal's $ and the extracted card lists it; die instead: nothing paid; arcade: a power-up drops, team score unchanged.
Rules: seed 4242 fingerprint must hold (goal draws stay on their side stream); both windows (the party seed shares goals; each player's career banks their own); never touch the pickup stack, loot sounds or loot rows; never change salvagerun:profile. DESIGN.md watch line: "run goals pay $ or items at the undercroft, never sp". Model: Opus high.
TASK DONE when it shipped and is ON HIS PC.

VERIFIED by the CEO 10-29 01:55: real linked host + p2 review on v36.33 PASS, career and arcade, both seats (career +$2,500 and the goal item per seat, +0 sp; arcade 3 local power-ups per seat, team sp unchanged). Pictures: notes/shots/o-00k-229-linked-review/. No more camera rounds needed.
