# o-223 steady-hand-and-beast-mode : two new damage streak statuses
HIS WORDS 10-29 about 02:00 (in the Gameplay Edit Intaker chat), verbatim:
"i want to add another similar multiplier status effect -- give 1% damage boost for kills without changing guns and without taking damage -- stacks up to 15 times -- any damage or any change of guns immediately kills it -- give it some kind of clever name --steady hand"
"add another one called beast mode -- give 1% damage boost for enemies killed in immediate succession -- within 5 seconds of one another -- stacks up to 15 times -- not getting a kill within the 5 seconds kills it -- the 5 seconds resets each time a kill happens -- show the clock next to the status or something"

Model on HEAD: the active reload chain as a status (v36.17 cw-cx-reloadstatus, dark_raiders.html ~43932-44040: status entry, glyph, '+N% damage'); the damage multiplier is applied where a player round is made (~25549, the G.player.ar... factor). arSetHeldGun (~26247) is the one door for a held-gun change.

Build:
1. STEADY HAND: each kill by this player adds 1% damage, up to 15 (x1.15). Any damage taken (health or shield, any source including fire and blasts) or any change of the held gun (arSetHeldGun) ends it at once. Status entry next to the active reload one: "steady hand +N%".
2. BEAST MODE: each kill made within 5 s of this player's last kill adds 1%, up to 15 (x1.15); every kill resets the 5 s; 5 s with no kill ends it. The first kill starts the clock at 1 stack. Status entry "beast mode +N%" with a small countdown (a shrinking ring or the seconds) beside it.
3. All three bonuses (active reload, steady hand, beast mode) multiply onto the round's damage; say the top total in the DESIGN watch line. Kills by the air strike count as kills (they credit the player) unless that makes beast mode trivial: decide and say which.
4. Each pillager owns their own (both windows, P2 over the net like the reload chain). Live play only, G.sim never runs it, nothing draws from the seeded stream. Player text lower case.
Check (must FAIL on the current build): 3 kills same gun, no damage: steady hand 3, damage x1.03; take a hit: 0. Kills 2 s apart x4: beast mode 4; wait 5.1 s: 0. Gun swap ends steady hand, not beast mode.
Rules: seed 4242 fingerprint must hold; never touch the pickup stack, loot sounds or loot rows; status entries in the existing status row, same look. DESIGN.md watch line: "steady hand and beast mode, up to 15% each". Model: Opus high.
TASK DONE when it shipped and is ON HIS PC.
