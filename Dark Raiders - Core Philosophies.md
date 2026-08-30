# DARK RAIDERS - Core Philosophies

Written 2026-08-26, at v3.56. This is the constitution the game has actually been
built under, distilled from the DESIGN.md record. Each one exists because
something went wrong without it.

## 1. Risk versus greed is the game

The one-sentence pitch: everything you are carrying can be taken from you, and
every decision should ask how much you are willing to walk out with. The
backpack is unlimited because you asked for that, and the pillar survives it:
weight costs speed and noise continuously instead of refusing pickups, the
Peddler pays 55 percent instantly against full price for surviving the trip, and
the windfall system pays you for time spent on the surface. When a measurement
showed greed was SAFER than caution (it was, at v1.58), that was treated as a
bug in the game, not a fact about it.

## 2. Death must cost, and the cost must be legible

Dying loses the bag and the worn rig, and both go onto a named body on the map,
recoverable next raid. The point is that loss creates the next raid's purpose
rather than just subtracting. The same idea drives armour permanence, notoriety
for killing neutrals, and the standing ledger raiders keep about you: prices are
paid in things you can see and get back or live with, not in abstract penalties.

## 3. The world does not exist for you

Raiders loot for themselves, fill their own bags, extract with the goods, feud
by crew, revive their own crewmates, and use medicine out of their own supplies.
Machines fight raiders as readily as they fight you. The board in the corner is
a cast list, not a spawn table. Whenever a system applies to you, the first
question is whether it should apply to them too, and the answer is usually yes:
downed states, status verbs, heal pacing, loot rules. A raider is you, run by
the machine.

## 4. Information the player owns must reach the player

A long line of your notes are one note: something true in the code that the
screen never said. The vest you bought that nothing showed. The status hidden
under the armour bar. Items with no statement of what they are. The extract
opening with no sound. The rule now: if the player owns a fact, the screen owes
it to them. Slots read EQUIPPED or EMPTY. Wind-ups draw bars. The board says
what each raider is doing in the same vocabulary your own status uses.

## 5. Commitment over convenience

Healing is one item at a time, slower than you want, with a visible wind-up
before it even starts, and the item is spent the moment you press. Grenades
cook in the hand. Reloads are interruptible but never free. The design keeps
moving decisions from "press when convenient" to "commit and live with it,"
because tension lives in the seconds you cannot take back.

## 6. Loud and quiet are a currency

Noise is the game's second economy. Every action has a noise price, listeners
convert noise into consequences, weight makes you louder, rain muffles, the
crowbar exists because zero-noise damage is worth a hotbar slot. The stealth
game is not a mode, it is just what happens when you choose to spend less.

## 7. Measure, do not argue

Every balance claim gets a paired A/B on seeded raids, 320 seeds, same raids in
both arms, McNemar on the discordant pairs, and single runs are never compared
because the sim swings 10 to 23 percent on 30-raid batches. Three separate
hypotheses about the map spread were refuted by measurement this way. When a
measurement cannot be run, the changelog says so in a "Not verified" line
instead of pretending. The flight recorder exists so your real runs are data,
and your notes in it outrank everything else.

## 8. The player's instruction stands, the system adapts around it

"Unlimited backpack" stayed even when it silently deleted a pillar; the fix
made weight cost rather than capping the bag. "Fewer dials, forms people
understand" became the settings presets. When you ask twice, the second ask is
a directive, not a discussion. The record keeps the why, so a future change
knows which decisions are yours.

## 9. One file, no excuses

The whole game is one HTML file. No build step, no libraries, no WebGL, no
raycaster. Anyone can save the page and own the game. Every system has to earn
its complexity inside that constraint, which is the main reason the code stays
readable and the main reason regressions get found: there is nowhere to hide.

## 10. Fixes name their causes

The changelog is long-form on purpose. Every entry says what was wrong, why it
was wrong, what shipped, and what was NOT verified. Recurring bug classes are
recorded as classes (stale strings, falsy-zero defaults, two systems that never
met, units mismatches) because the same mistake made twice is a process bug,
not a code bug. The game's history is part of the game.

---

## Where the philosophies currently strain against each other

These are live tensions, not failures. Flagged so they get decided rather than
drifted into.

- **2 versus playability:** healing weaker, downed longer, Warden stronger all
  shipped the same day on your direct calls. Their NET effect on survival is
  unmeasured, and 77 percent of your deaths already happen before the decision
  to leave exists. The looting phase is where the game is actually hard.
- **3 versus performance:** a living world is expensive. The earshot LOD keeps
  far bodies honest but cheaper; if raiders ever feel scarcer or dumber, that
  dial is the first suspect.
- **1 versus the data:** the recorder shows survival RISES with value carried
  right up to 12,000c. The risk-versus-greed curve the design wants is not yet
  the curve the game produces. This is the largest open design question on the
  books, and it is yours to call, not mine.
- **4 versus screen space:** the HUD now carries status, board, conditions,
  legend, wind-up bars. Your collapse-and-drag request is the right next move
  for this and is on the list.
