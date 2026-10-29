# o-00r-236 no-roll-in-water : you cannot roll in water
HIS WORDS 10-28 about 23:10 EDT (in the Gameplay Edit Intaker chat): "roll shouldn't work in water"

What is on HEAD (v36.26): tryRoll, dark_raiders.html ~21271, refuses a roll when downed, already rolling, on cooldown, low stamina (TOO TIRED TO ROLL) or in the arcade drop-in hold; nothing checks water. Water tests: inWater(x,y) ~14725 and inWaterDeep ~14734; wading slows you (CFG.wadeSpd 0.34) and the status reads WADING / STANDING IN WATER.
Build:
1. A roll cannot START while the pillager stands in water (inWater at his position, wading or deep). The press does nothing visible except the same dull refusal sound the game already uses (blip 'clank'), no text line (he wants fewer messages), so the key does not feel broken.
2. A roll that carries him INTO water ends at the water's edge: he drops to wading speed there instead of sliding through the water at roll speed.
3. Same for player 2, the pad (A sends the same key), and the arcade. Pillager bots: only if they roll and only if the seed 4242 fingerprint still holds; otherwise leave the bot sim untouched.
4. Stamina is not spent on a refused roll.
Check (must FAIL on the current build): pillager in water, press roll: p.roll stays 0 and stamina unchanged; roll toward water from 60 px away: the roll ends within a few px of the edge and he is wading.
Rules: seed 4242 fingerprint (ents 85/374, containers 165/593) must hold; both windows; never touch the pickup stack, loot sounds or loot rows. DESIGN.md watch line: "no rolling in water". Model: Sonnet 5.5 high.
TASK DONE when it shipped and is ON HIS PC.
