53-corpus-reds-b : 19 old checks (v26.54 to v29.39) red at v32.83 and already red at v32.16 (coordinator 2026-10-20, from tools/handoff/corpus-fails-v32.83.txt)
effort: medium

These have been red since 10-19 or earlier (they are in tools/handoff/corpus-fails-v32.16.txt too), so most are likely STALE after the 10-18
UI redesign, the lower case text, the HUD rework or the party screens. Codex (o-02) worked older checks in rounds 1 and 2: look in
tools/handoff/console/notes/o-02-corpus-green.md for any of these it already decided, and never touch its 22 (o-02 task, "Your first 22").

For each check: find it in tools/mkfixture.ps1 ({v:'NN.NN'), run it on the current fixture (runchk.sh; a check that passes on HEAD is FIXED SINCE), then decide:
- REAL: the game broke something no ship meant to change. Fix the game through the ship queue, with a new check whose control FAILS on the old build.
- STALE: a later ship changed it on his order or on purpose with its own check. Retarget the old check so it keeps its intent under the new rule
  (bash S/lock.sh, edit, runchk.sh, HELD=1 bash S/fixq.sh "MESSAGE", bash S/unlock.sh; short holds, a few checks at a time). Delete only if its feature was removed.
- HARNESS: flaky staging (window size, timing). Fix the staging.
Never weaken a check to make it pass. Write one line per check in tools/handoff/console/notes/53-corpus-reds-b.md: version, REAL / STALE / HARNESS / FIXED SINCE, one-line reason.

The checks (version what it checks -> what it saw at v32.83):
v26.54 settingsfix, his #50 (menus look AAA), from the 1080p shots of the new Settings: the jump bar sticks flush to the top of the list with no row text showing over it, the chip of the section in view lights, KID MODE is a head like the o
v26.59 his yes (suggestion 21): a pillager has a role from his gun and rig (rush, flank, supp, mark, shield), wears a coat tinted by it with one silhouette mark of its own, a rusher closes in nearer than a marksman holds, and crews mix role
v26.97 career2, his yes to the armory codex (30): a gun is filed once it has been held, the page lists every gun with its rarity and NOT FOUND for the unseen, the raid scan files a gun in the backpack, an old save loads, and the page closes
v27.00 career3, his yes to the needed-item glow (31): what an unfinished contract still needs is worked out (the lift kit does not count, a finished card needs nothing, the arcade has none), a shut box that holds it glows in the world and s
v27.56 his 2026-10-14 note (UI cleanup uic8): the What is New card and the Undercroft backpack are solid plates (the station signs of the floor read through both at 94 and 96 percent) -> the What is New card is a flat rectangle, not the HUD
v27.75 cloud-menus-settings-jump-zoom: under the menu zoom a big screen gets, each Settings section chip puts its section at the top of the list and lights its own chip -> THE RAID: the head sat -230 px from the top of the list; null: no se
v27.79 feel2a, his yes to the Halo Reach bloom: every gun blooms its own way. Spamming the Marksman Rifle or the pistol opens the spread to over twice the first round, a beat of patience gives the pinpoint round back, a held Auto Rifle fill
v27.80 feel2b, his yes to the Halo Reach bloom, the pacing half: the moment the bloom a round opened has fully closed, the ring on the cursor flashes once (a contracting ring and four ticks, p.rstT), not while a spam keeps it open, never fo
v27.83 feel2e, his words: a downed pillager in finisher reach shows the standard world prompt, HOLD [V] FINISH, over him (the key as a keycap, stacked under the REVIVE prompt when both are up) and nothing for a standing pillager or when you
v27.91 the big map draws the player as a neon green chevron (his order: easier to see) -> the player marker on the big map is not neon green (26 fills, none #39ff14)
v28.06 his 2026-10-14 note (UI cleanup uic1): the abandon confirm is a two button question: armed, the pause box shows YES, ABANDON and NO, KEEP PLAYING and nothing else, and every button stays inside the box frame (it ran about 110 px out 
v28.20 cloud-menus-kit-tile-names-fit: at the default menu size (zoom 1.3, the 2560x1440 layout) every GUN KEYS and ITEM WHEEL tile name on the stash shows whole, and no picture overlaps its name -> names cut on the plates at the default me
v29.11 no all-caps text: canvas text, menu text and the tab title come out in sentence case (his hard rule 2026-10-18) -> MACHINE ALERT is drawn as machine alert
v29.14 no all-caps text outside the menus either: the whole page is watched, tooltips and placeholders are fixed, the Taken stamp is not capitals (his hard rule 2026-10-18) -> outside #root the text, tooltip and placeholder read: press any 
v29.30 the title key line names F1 for the controls list, not H (H heals since keyswap) -> the title key line does not say F1 controls
v29.31 the HUD has one hero: the corner credits are 24 px cream, not 32 px amber, and the backpack cue is a quiet grey, not amber (style guide) -> the backpack cue was not drawn
v29.32 the title button reads Create a new save, not Create A new save (the article A lowers with its line) -> CREATE A NEW SAVE reads "create a new save"
v29.33 the title and mode menu run on the shared look: tokens in the CSS equal UIT, the ui-shared block has no raw color or font-size literals, the mode rows are 20px with a 4px radius, Panel P draws (his order 2026-10-18, one shared UI) ->
v29.39 the pause box and Settings (screens 18, 25-32, 42, 49, 68-75) run on the shared look: the pause title is 32px in light text, the key legend 16px, a Settings row name is 20px with its sentence moved to the detail pane, the stepper is 

TASK DONE when every check above is green on HEAD or explained in the notes; TASK PARTIAL with the ones left.
