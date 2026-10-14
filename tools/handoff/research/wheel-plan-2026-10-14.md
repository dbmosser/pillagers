# THE ITEM WHEEL, 2026-10-14 (his design; this replaces the class belt of v25.87-v26.03 for grenades and heals)

His order, verbatim: "for grenades and heals, get rid of the cycle concept.  Lets ONLY show guns at the bottom of the screen, only 9 of them.  Then lets add a wheel for heals and grenades.  You go to the wheel, you select one.  Then you pull the trigger, and that lets you use the item.  Then your gun comes back (have to come off trigger and then click it again to start  firing).  To get another one time use item, you have to go back to the wheel.  That way players cant just spam grenades etc, takes a moment to pull them out.  Also different guns should have different 'pull out'/'ready to fire' times."

His answers (AskUserQuestion, binding):
- The wheel opens on HOLD Q. Move the mouse toward an item and release Q to pick it. Melee therefore moves off Q: crowbar melee goes to V (V is free since the emotes left; CoD uses V for melee). Rebindable.
- Time runs in REAL TIME while the wheel is open.
- EVERYTHING goes through the wheel: grenades, smokes, decoys, tripwires, bandages, medkits, stims AND armour plates. Removed: tap-H heal, hold-H plate, the instant 5-9 keys, U and J cycling, G quick throw, and the G/U/H/J/HOLD H keycaps and gold item rings.
- The bar holds 9 GUN slots (keys 1-9, guns only). A 10th gun replaces the weakest gun not in hand, which goes to the backpack. This is the v25.87 rule with 9 instead of 4. Extra guns may sit in the backpack.

## Behaviour
1. BAR: 9 gun cells only, keys 1-9 select and draw. The magazine bar and reserve number stay; so do the F and R caps on gun cells (F next gun, R reload) and the gold ring on the gun in hand. F cycles through the 9. The groups THROW / MEDICAL / ARMOUR and their labels go.
2. WHEEL (hold Q):
   - A radial menu centred on the player or the screen centre, in the game's UI style (graphite, amber, Barlow Condensed caps, chamfered).
   - It shows one segment per item TYPE carried: name, icon and count. Empty types are hidden.
   - The segment under the mouse direction is highlighted. Releasing Q picks it; releasing in the centre dead zone cancels.
   - The game keeps running; the player can still move, but cannot fire while it is open.
   - Pad: pick a free hold button (his 2026-09-27 layout stays; LB/RB walk the guns) and select with the right stick. Report which button.
3. ITEM IN HAND:
   - Picking an item puts the gun away and takes the item out, with a short "pull out" time (grenade about 0.35 s, heal about 0.3 s). The HUD shows the item in hand.
   - The TRIGGER (LMB / RT) uses it:
     - a grenade or smoke cooks while held and throws on release, as now (startCook / releaseCook);
     - a tripwire places;
     - a bandage, medkit or stim starts its existing use (wind-up, heal ceilings: bandage to 85, medkit to 100);
     - a plate slots.
   - A use consumes ONE item. Then the gun comes back automatically with that gun's draw time.
   - The trigger must be RELEASED and pressed again before the gun fires.
   - Cancel: pressing a gun key, or opening the wheel again, puts the item away with no use.
4. DRAW TIMES per gun class, applied on every gun swap and when the gun returns after an item. The gun cannot fire until ready. Suggested:
   - pistol 0.25 s, SMG 0.4, rifle 0.55, shotgun 0.6, marksman 0.7, sniper 0.85, LMG 1.0, launcher 1.0.
   - Forge upgrades do not change them.
   - Show readiness subtly: the reticle or ammo ring fills while drawing.
5. Removals and migration:
   - Remove the class keys (5-9 for items), U, J, G quick throw, H heal and plate, the item keycaps and gold item rings, and the beltglyphs item parts.
   - Rebinding: Q = wheel (hold), V = melee. G, U, J and H become free.
   - Saved plans: item bindings on keys 5-9 are dropped once (a beltV step). Guns may now bind to 1-9.
   - The DEMO random kit: guns on 1-2, items carried for the wheel.
   - The stash loadout row shows 9 gun slots, and items in a separate WHEEL ITEMS strip.
   - The words (F1 list, legend, pause line, the What's New card) describe the wheel.
6. Same in DEMO and CAREER. Two-player: each window has its own wheel. Net: throws and heals go through the existing paths.

## Build order (small, each shippable)
- W1 draw times per gun class (works on the current belt). Check: the time to first shot after a swap per class.
- W2 the wheel UI (hold Q, real time, select, cancel) plus melee to V. It only selects for now, and puts the item in hand.
- W3 item-in-hand and trigger use, the auto gun return, the trigger-release rule, and cancel.
- W4 the bar goes guns-only with 9 slots: remove the class keys, U, J, G, H and the keycaps; migrate plans; the 9-gun swap rule.
- W5 pad support for the wheel.
- W6 visual polish and words, with 1080p and 4K shots of the wheel and the new bar.

## Added 2026-10-14 (his words): "there needs to be a corresponding menu option in the stash and the backpack where you can set up your wheel"
W7 WHEEL SETUP:
- A WHEEL panel in the Undercroft stash / loadout and in the raid backpack. Drag item types onto about 8 ring slots; drag off to clear, drag between slots to reorder; AUTO FILL fills every carried type.
- The layout is saved in the profile (CAREER); DEMO gets an auto layout.
- A slot whose type has 0 carried shows dim with a 0.
- Pad navigable.
