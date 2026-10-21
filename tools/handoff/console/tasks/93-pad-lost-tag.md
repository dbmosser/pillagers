93-pad-lost-tag : the teammate pad lost tag reads at a glance (critic on the o-07 two-window pictures, 2026-10-21)
Queue (coordinator 10-21 00:40): from coord-08; his 10-20 23:00 order: nothing waits for the party.
effort: low

Source: notes/ui/accept.json (pictures notes/shots/o-07-pad-lost-coordinator-check/j8-p2-sees-p1-lost-1080.jpg and j8-p1-sees-p2-lost-1080.jpg, v33.28):
- j8-p2-sees-p1-lost 2: P0 "p1 pad lost" tag, centre of screen at about (960,285): Make it one dark --ui-panel card with a 3px --warn left bar, 32px f-cond title "p1 pad lost" in tx-1, and a 16px --tx-2 line "reconnect pad" below. Centre it at y≈30% with a 90ms bounce-in. Keep the pad glyph at 24px in --warn.
- j8-p1-sees-p2-lost 2: P0 top-centre and centre banner stack (team score, extract, chill row, golden enemy, stronghold, p2 pad lost): Show each message once. Drop the centre 'golden enemy' and 'stronghold' pills, since the toasts already carry them. Make 'p2 pad lost' a single 20px f-cond 600 line in --warn on a --ui-panel pill, with a 3px --warn left bar, at about 30% screen height, and keep nothing else near it.
The tag text comes from netPadHud() ("p1 pad lost" / "p2 pad lost"); keep his words and lower case. Do not touch the pause card titles "pad lost"
and "press a" (his ruling, done/o-07-pad-lost.md).

1. Restyle only the teammate tag: one dark panel with a --warn left bar at the top centre band, at the style guide sizes, clear of the
   extract and team score block, so it is the first thing the eye finds. No new words, no explaining line.
2. Check (new, must fail on the build before): with the teammate pad lost in a linked raid, the tag draws inside the top band at its new
   size and does not overlap the extract callout.
3. Two-window pictures (his 2.86 a): copy notes/shots/62-share-drop/camera-recipes.json (real linked pair) and stage the loss as
   o-07 j8 does; critic finish line 4 (raid), at most 6 tries.
Party risk: low (one HUD tag in 2-player raids). Watch line: the tag is seen at once on the TV.

TASK DONE when shipped with its check and a picture from each window; TASK PARTIAL with what is left.
