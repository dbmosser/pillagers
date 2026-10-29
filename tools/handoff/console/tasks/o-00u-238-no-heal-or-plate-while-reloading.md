# o-00u-238 no-heal-or-plate-while-reloading : a bandage or a plate and a reload never run at the same time
HIS WORDS 10-28 about 23:25 EDT (in the Gameplay Edit Intaker chat): "player should not be permitted to apply a bandage and reload at the same ttime; nor apply armor and reload at the same time"

What is on HEAD (v36.26), dark_raiders.html:
- The wheel path is already right: handTake (~24963) takes the item out and sets p.reloading=0, and R (~29982) and the empty-trigger auto reload (~29986) refuse while p.hand.
- The gap is the other doors: the belt INSTANT keys (beltEquip ~24805 / beltInstant, his v26.02 "leave the gun equipped and instantly use the item"), quick heal H (quickHeal ~24830, useBeltHeal ~24754), quick plate (quickPlate ~24843, useArmor ~28363), and the pad; they start a heal wind-up (p.healQ, tickHeal ~26379) or a plate while p.reloading runs, and R can start a reload during a heal wind-up or plate.
Build (one rule for every door: belt keys 5-9 and 0, H, the plate key, the wheel, the pad, player 2):
1. Starting a bandage or medkit wind-up, or slotting a plate, CANCELS a reload in progress (the reload clock is lost; the reload sound is cut like a swap, rlfxStop). It does not count as a missed active reload: the reload chain is kept.
2. While a bandage/medkit wind-up or a plate is in progress, R and the empty-trigger auto reload do nothing (the reload starts once it is done, if he presses again or holds the trigger).
3. Stims and grenades are not part of this order: leave them.
Check (must FAIL on the current build): reload the rifle, press the bandage belt key mid-reload: p.reloading becomes 0 and the heal starts; during the bandage wind-up press R: no reload starts; same two with a plate.
Rules: seed 4242 fingerprint must hold (the bot sim's own heals untouched); both windows; never touch the pickup stack, loot sounds or loot rows. DESIGN.md watch line: "no healing or plating while you reload". Model: Sonnet 5.5 high.
TASK DONE when it shipped and is ON HIS PC.
