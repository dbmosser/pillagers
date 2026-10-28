# 204-new-player-default-settings : the settings page he showed becomes the default for a brand new player
His order 10-28 (verbatim, forwarded by the old intake chat, with a picture of his settings page): "these should be the default settings for a new player"
Picture (checked by the order chat), top to bottom: difficulty = new player; edit the words = off; superhot mode = off; shared sight = on; fog of war = off; pillager bots = few; machines = few; damage = forgiving; raid length = long; how much is out there = rich; heat when you call for extraction = light.
Model: claude-opus-5-5, effort high (rung 3: defaults touch the party demo and the new score multiplier).
Do:
1. These values are the defaults of a fresh profile (a brand new player). An existing save keeps every choice it has, his included; never change the storage key `salvagerun:profile`; no migration that rewrites saved choices.
2. Find where defaults live (gameOpts defaults, the "new player" difficulty preset, any demo-start reset such as the Superhot-off start reset near line 64596) and make sure a fresh profile lands exactly on this list; where a value is already the default, change nothing.
3. Score multiplier (v35.68-70, cw-diffmul): few / forgiving / light should pay the base with no penalty; superhot off still pays its +1 step (x1.05 default is as he ordered). Say in the report what a fresh profile shows.
4. Party demo flow: a fresh 2 player party start gets the same list for player 2 (host settings rule the party). Raid length and loot amount: the demo/career raid uses a fixed 10 minute clock; only change what the dial really controls.
Rules: seed 4242 fingerprint unchanged unless a default feeds world generation (then say so and re-pin only if the gate requires); new check must FAIL on the build before; both windows; looting untouched; picture of the Settings page for a fresh profile at 1080.
Done when ON HIS PC vNN.NN; move this file to done/, SHIPPED line in open-orders.md.
Watch for: a brand new profile opens with exactly this settings page; his own save is unchanged.

ADDED 10-28 (his verbatim, via the old intake chat): "and for arcade mode"
The same list is also the default for arcade mode (the party demo walk-up raids, both players). Same rules: never overwrite saved choices; the demo start may set these each time only if the demo already resets settings (see the Superhot-off demo start reset near line 64596); otherwise it is the fresh-profile default only. Say in the report which.
