# o-01b-247 no-gun-card-after-upgrade : the weapon card shows only when you hover the gun on the hotbar
HIS WORDS 10-31 (in the Gameplay Edit Intaker chat): "after i upgrade a weapon, i don't need to see a weapon card. The only time a weapon card should show up is when mousing over the weapon in the hotbar"
PARKED for the party freeze; build after Sun 11/1 01:00.

What is on v36.55: a Forge upgrade sets G.gunCard (dark_raiders.html ~15116, cw-cx-forgeread: the new gun vs the old, "cost $N") and the card pops for GUNCARD_T seconds (~23248). The cw-cx-stashraid note (~15061) keeps the card, sparks, upgrade sound and the 700 ping.
Build: a Forge upgrade no longer pops the weapon card; keep the sparks, the upgrade sound and the cost line in the feed if one exists. Find any other place a weapon card pops on its own (a swap, a stall buy, a gamble win, a crate gun) and stop it too, EXCEPT anything in the loot pickup rows (his standing rule: never touch the pickup stack, loot sounds or loot rows). The card stays on hover over a gun on the hotbar (in raid and in the Undercroft), and wherever a menu shows it on purpose when you point at a gun (stash, stall).
Check (must FAIL on v36.55): Forge an upgrade: G.gunCard stays null and no card draws; hover the gun on the hotbar: the card shows.
Rules: seed 4242 fingerprint must hold; both windows; never touch the pickup stack, loot sounds or loot rows. DESIGN.md watch line: "no weapon card after an upgrade; hover the hotbar to see it". Model: Sonnet 5.5 high (or Codex).
TASK DONE when it shipped and is ON HIS PC.
