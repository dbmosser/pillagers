# Questions for him

## URGENT (b-02, 10-18 15:10): every ship STOPs "gen-draft failed" since v30.69
- tools/handoff/p3069.ps1, f3069.ps1, a3069.txt, d3069.txt, cm3069.txt, ppfa/fpfa/ppfe/fpfe.ps1 and tools/fxprobe68.html are tracked in git but DELETED in the working tree (a race: STOP 3069 cleanups at 15:00-15:07 ran while the v30.69 ship committed). gen-draft.ps1 line 10 reads p3069.ps1 as the header for the next number, so cw-kicksniper, cw-glyphs2, cw-hudstar, cw-title-fight and cw-p1p2mate all STOP. Workers cannot git checkout. Owner: git checkout -- tools/handoff/p3069.ps1 tools/handoff/f3069.ps1 (and the rest of the D list), or copy any p30xx.ps1 to p3069.ps1. (The v30.64 index.lock problem below is cleared: HEAD moved on to v30.69.)

## URGENT (b-02-gun-enemy-feel, 10-18): THE SHIP QUEUE IS BLOCKED
- .git/index.lock is left over from the ship.sh "Segmentation fault: git add -A" at v30.64 (cw-kicklmg, 13:32). Last commit is v30.63 at 12:08. dark_raiders.html (v30.64 lmg:2.0, VER 30.64) and tools/mkfixture.ps1 (+25 lines, not mine) stay uncommitted, so every ship STOPs "uncommitted changes". Workers cannot delete index.lock. Owner: delete .git/index.lock (check no git runs), then commit "v30.64: the support mg no longer builds into a heavy shake" and the mkfixture lines. Then draft cw-kicksniper (preflight ok except old check 30.35 pins the Longshot kick at 4.5; retarget it to 4.5 or 7).

## Open (asked in chat 10-18)
- The title's mode list has two "coming later" online rows in the middle of the rows that work. Move them to the bottom, or hide them? (c-30-ui-menu-map)
- The empty scoreboard (before anyone has played) shows five faint placeholder rows. Keep them, or show one line such as "No scores yet"? (12-ui-party-screens)
- In the 2 player arcade demo the Undercroft is only a blurred picture behind the party screen (nobody walks there; a press drops straight into a raid), so the two players cannot see each other in it. In the 2 player co-op (same machine) mode they walk the Undercroft and now see each other (v30.84). Should the arcade demo also let the two walk the Undercroft before the drop, or keep the straight drop? I changed nothing there. (cw-p1p2)
- In the 2 player arcade demo each window plays on a copy of its OWN save, and the sandbox keeps the HUD layout and the kid damage setting of that save (your 10-11 order). If your save has a custom HUD layout or kid mode on, the two TVs differ from each other (player 2 is a fresh save). Should the demo put BOTH windows on the default HUD layout and normal damage, so the two TVs always match? I changed nothing. (cw-p1p2)
- The player 2 attract and run over card say "Player 2: press A" while player 1 says "Press any key" (or button). Lane g set that on purpose (player 2 is the pad window), but player 2 now has its own keys since v30.68. Should player 2 read the device it last used like player 1 does? I changed nothing. (cw-p1p2, for the glyphs lane)

## Resolved by his answers of 10-18 (memory pillagers-answers-1-78-2026-10-18.md); helpers act on these
- HUD (b-30): ammo becomes prominent and the whole raid HUD is redesigned (Q57); the career top-right becomes ONE row with nothing removed (Q58 a); $ for money, including the bag line, haul values, prices and the pillagers board; SP only for score (Q59 a); Run info shows the 3 closest contracts, and ALL contracts go on the map screen (Q1). The work is now task 02-raid-hud-redesign.
- Pause box line "Please provide feedback anything that went or felt wrong.": KEEP it, along with the button and Send play data (Q61 b).
- Undercroft (b-31): windows become a centred card with an X that takes up NEARLY THE WHOLE screen (Q43 a; not a 960x680 cap). The style guide overrules his older layout orders (Q7). Helpers may shorten or delete his explaining lines, but only with a good reason logged in notes/ui/changes.md (Q8 a).
- Title on screen 58 and the rest: the title redesign is task 03 (Q50-Q54).
- The 10-17 note about a dirty game file is stale; ships have run cleanly since.
