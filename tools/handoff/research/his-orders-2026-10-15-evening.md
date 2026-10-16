# His orders, 2026-10-15 evening and 10-16 (BINDING; queued: weekly at 100%, reset Sun 10-18 01:00)

## Setup
- Yes: install Node.js LTS (+ Playwright), Python 3 and PowerShell 7 via winget. Then move the test gate to Node/Playwright and split the game file into modules with a one-file build step.

## Score and economy
- EXTRACTING = a 2x multiplier on score; KIA = a 50% score penalty.
- "its still really confusing how score is in dollars but it doesn't match loot value etc -- maybe score just needs to be like sp (score points)?" So score shows as SP, never $.
- Stash value and bag value are always shown in the top right corner, everywhere, with credits and XP.
- Hard enemies drop better loot.
- Too many guns in the loot: getting a gun should be rarer.
- Guns cost more to craft.

## Pre-raid screen (the map select screen, renamed PRE-RAID)
- On the pre-raid screen, quickly pick how much cash and how many of each wheel item to take, plus keys and guns.
- Also how much ammo to take.
- Slot a data core there too.

## Raid
- Player reload bar and the other bars above the head draw on top of buildings and are never blocked by buildings or other raid elements.
- Red barrels: after the first explosion, also leave fire that deals damage over time.
- MIMIC crawler from a looting box:
  - pops out AWAY from the player, so he can kill it without taking damage;
  - has a different name, so he knows where it came from;
  - the box gets a unique disappear-into-the-void swirl animation.
- Hold-to-breach door: he did not have to hold, then got slaughtered by crawlers. Breach must really need the hold, and the enemies in breach houses should not leave the house.
- Crawlers are too fast now.
- Remove the shining circle highlight on items, so the player loots every box and enemy.
- A siren noise he hears sometimes means nothing to him: kill it or add text.
- All text shown to the player on screen also goes into the player feed.
- Killed a deer and it became a dead human: fix that; improve sprites and animations.
- One shot of liquor is too intense on the effects: turn it down.

## Wheel and guns
- The wheel is accessible in the Undercroft, even though nothing can be used there.
- The mouse cursor shows over the wheel while it is open, so the player never loses the cursor when the wheel closes.
- Consolidate the Scav Pistol and SMG slots, and add a ROCKET LAUNCHER as the last slot (0).

## Crafting
- Hold to craft does not work correctly: it needs a clear 1-second bar.
- A way to craft multiples quickly (for example craft 10).

## Settings
- Frame cap options above 60: 75, 90, 120, 144, 165, 240.
- Consider what else would be good in the tuning console.
