# 50-corpus-old-a (lane b, 2026-10-20)

All 16 checks green on HEAD (run in one tab, order of the list). No game change was needed: every red was STALE or HARNESS. All edits are in tools/mkfixture.ps1 (commits e89bd0a5, 2e2869fc, c6027caa, 0e13be59, f6a8db61).

- v8.66 STALE: the belt is nine gun keys (wheel4, his order: guns only on the bar). Retargeted: a bandage on a gun key is refused, a gun lands, a consumable on the hand gun key is refused, a gun moves with no copy, a drop on its own key changes nothing.
- v8.65 (gun swap) HARNESS: a deploy only brings the equipped guns, and the guns sit on whichever gun keys the settle gave them. Now sets equipped and second gun, and finds the keys by what they show.
- v8.65 (heal and plate) STALE: no heal or plate keys on the belt. Now takes the item from the wheel (handTake), pulls the trigger, checks heal, armour and the spent item. Renamed v8.65h so a run by version can reach it (both were v8.65 and only the first could be run alone).
- v8.58 FIXED SINCE: passes on HEAD.
- v8.91 STALE: v27.26 (feedleg) shrinks the compact legend on purpose (zoom down to 0.9, ends before 47 percent width). The legend now gets the same floor as the other two panels: never smaller than before v8.91 grew it.
- v8.96 STALE: items other than guns cannot go on the belt. The drag is now a gun to the last gun key and back; also sets its own equipped guns so earlier checks cannot change the result.
- v9.13 STALE: the backpack panel was redesigned; 1080p size is 830x477 now (was 1194x435). Scale, shape, clearance and fit tests unchanged.
- v9.14 STALE: the heading is the sector name in the card header (light text, cw-mapstyle), not amber text above the frame. Measures that text through mapProj, scaled by the canvas ratio. 1080p baseline 171x34, 4K ratio 2.0 (needs 1.7).
- v9.15 STALE: the frame is a neutral 1 px line (was blue, 4 px). Measured as line-colour coverage left of the map: 0.9 px at 1080p, 1.7 at 4K.
- v9.26 STALE: the Marksman (dmr) is gone (cw-gunsgone). Uses a pistol with a tight spread and long range, same exact near-miss geometry.
- v11.52 STALE: money shows as $ now (his words), not "credits". The readout must show the $ figure and xp.
- v13.26 STALE: v32.45 (cw-preraid-a, Q8 reason in changes.md) cut the test robot rate from the sector row. Kept: no first contact, containers or median haul, the real map facts show, and the line reads the same whether or not the player raided there.
- v11.29 STALE: same cause. A robot extract figure, if shown, must still be owned ("test robot") and match the code; the death card tests are untouched.
- v10.13 STALE: the warning is the short callout "no armour equipped" now (short callouts only). The Armour Plates sentence and the cap line are dropped.
- v10.05 STALE: the chosen day/night chip is a fill with a check (v32.45), so the look is border, fill and text colour together.
- v9.97 STALE: same chip change, and the night chip carries its "+20%" badge.

Open for the coordinator: none. Note that a version number used twice (8.65) cannot be run alone by runchk.sh, which takes the first match.
