50-corpus-old-a : 16 old checks (v8 to v13) red at v32.83 (coordinator 2026-10-20, from tools/handoff/corpus-fails-v32.83.txt)
effort: medium

Oldest checks first. Many of these were probably red before too: the v32.16 list lost its first slice to a logging bug (fixed 10-20 in tools/corpus-slices.sh).

For each check: find it in tools/mkfixture.ps1 ({v:'NN.NN'), run it on the current fixture (runchk.sh; a check that passes on HEAD is FIXED SINCE), then decide:
- REAL: the game broke something no ship meant to change. Fix the game through the ship queue, with a new check whose control FAILS on the old build.
- STALE: a later ship changed it on his order or on purpose with its own check. Retarget the old check so it keeps its intent under the new rule
  (bash S/lock.sh, edit, runchk.sh, HELD=1 bash S/fixq.sh "MESSAGE", bash S/unlock.sh; short holds, a few checks at a time). Delete only if its feature was removed.
- HARNESS: flaky staging (window size, timing). Fix the staging.
Never weaken a check to make it pass. Write one line per check in tools/handoff/console/notes/50-corpus-old-a.md: version, REAL / STALE / HARNESS / FIXED SINCE, one-line reason.

The checks (version what it checks -> what it saw at v32.83):
v8.66 dragging onto the belt assigns, refuses and moves correctly -> the bar is not the shape this check assumes (a gun in hand, a Medical key, an empty key and one more ordinary key), so it is testing nothing
v8.65 the two gun slots swap weapons and never fire one -> picking the stowed gun did not bring it up
v8.65 the heal and plate slots spend the right item -> no heal or armour slot on the belt, so this check is testing nothing
v8.58 the sector board reads in metres, not a tenfold hectare -> no metre dimension on the board at all
v8.91 the three in-raid panels are twice the size, at every resolution, and never touch -> legend at 1920x1080 is 411 wide, under 1.4x its old share of the screen; legend at 2560x1440 is 549 wide, under 1.4x its old share of the screen; leg
v8.96 the Undercroft backpack has a belt and you can drag items onto it and off it -> threw: TypeError: Cannot read properties of undefined (reading 'x')     at drag (http://localhost:8806/fxcorpus.html?slice0=1:71641:25)     at Object.run 
v9.13 the backpack follows the monitor instead of staying its 1080p size -> control: the 1080p panel changed to 830x477, it was 1194x435
v9.14 the writing on the sector map follows the monitor, like the map itself does -> no map heading was found at 1080p, so there is nothing to compare
v9.15 the sector map markers and frame scale with the monitor, like its writing does -> the map frame was not found at 1080p, so there is nothing to compare
v9.26 a round that goes past a pillager counts as shooting at him -> threw: TypeError: Cannot read properties of undefined (reading 'dmg')     at Object.rollFieldGun [as roll] (http://localhost:8806/fxcorpus.html?slice0=1:3915:26)     at mi
v11.52 credits and XP are shown at all times in the upper right corner, in the Undercroft and in a raid, above the screens and clear of the CONDITIONS box, and the readout follows the profile when a figure changes -> in the Undercroft: the 
v13.26 the map screen shows every player the sector line he rewrote: the test robot extract rate in that map, without first contact, containers or median haul, whether or not that player has raided there (his baked edits matched only his ow
v11.29 the sector screen says whose figures it shows and shows the ones in the code, and a death card on a fresh profile gives the XP total without measuring it against the last reward of the season -> the sector screen shows figures withou
v10.13 the armour warning is on the sector page, under what you are going up with -> the sector page does not warn about armour: [gunCompact SMGNO ARMOUR EQUIPPED]; the sector page does not say to equip Armour Plates; the sector page does n
v10.05 every ascent starts at DAY, whatever the last raid was -> neither button is drawn as chosen
v9.97 day or night is chosen on the sector page, and the lift opens that page every time -> the buttons read [day] and [night+20%]; after NIGHT the two buttons look the same, so the choice is not shown

TASK DONE when every check above is green on HEAD or explained in the notes; TASK PARTIAL with the ones left.
