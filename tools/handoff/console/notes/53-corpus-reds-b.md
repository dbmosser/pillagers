# 53-corpus-reds-b (lane c, 2026-10-20)

18 of 19 green on the rebuilt fixture (fixture commits be6e9125, 82a4cc94, 857d0e54, 4021e0ee; one game ship v32.87). None of o-02's 22 touched. All 19 were red when I started.

- v26.54: STALE. Settings is a left rail now (screens 25-32): the jump bar is sticky at top 0 (was -3px), sits up to 4px under the list top, and the KID MODE head is the 16px label size (was 19) in lower case.
- v26.59: STALE. Marksman Rifle and Whisper are gone (cw-gunsgone, Q69), and cw-botlook (his picks a18 A, a19 D) puts every hostile bot in one dark red coat, so the coat check is now "all roles wear #7a2f2a"; the role mark colour check stays.
- v26.97: STALE. Codex lists 16 guns after cw-gunsgone (was 19); Longshot and Lance stand in for the Marksman Rifle and Whisper in the raid scan.
- v27.00: STALE. v28.xx lean6 took the gold ring off a box that holds a contract item in the world on purpose; the backpack and pickup edge checks stay, and FIVE now fails if the world glow comes back.
- v27.56: STALE. The What is New card is a flat panel (UIC.ui_panel) on its own scrim since cw-wnew40, not a hudPanel; the check now wants a card sized rectangle in an opaque colour. The backpack half is unchanged.
- v27.75: STALE/HARNESS. The rail hides the first head (THE RAID, display none) and holds a data-go button that is not a section chip; the check lets the first chip return to scrollTop 0 and skips the button.
- v27.79: STALE. Marksman Rifle gone; the Longshot stands in (its patience beat is 2.5 s, it closes at 0.7 a second). Pistol, Auto Rifle and every-gun parts unchanged.
- v27.80: STALE. Magnum stands in for the Marksman Rifle.
- v27.83: STALE. The V keycap is drawn lower case.
- v27.91: STALE. cw-mapstyle (his 3.13 a, player 1 amber, player 2 cyan) draws the chevron in the seat colour, not neon green; the check wants that seat colour.
- v28.06: STALE. The pause box has a top right X (pausex), not a third choice; the two button question is otherwise as before.
- v28.20: REAL, still red. At the default menu zoom 1.3 the gun key and item wheel names are cut (names are 20px since cw-cx-namefinal; room per name is 35px for the gun tiles and 33px for the wheel, the longest names need 66-69px). Options for the stash UI lane: two columns instead of three (5 rows each, about 106px taller, the backpack pane has the slack), or 16px names with the picture hidden below a tile width. It is a layout choice and touches pad navigation of the tiles, so I did not do it blind. Logged in alarms.md.
- v29.11: STALE. cw-lowercase lowers every word, acronyms too ("machine alert", "+50 sp  ·  2p lmg  ·  ak-47").
- v29.14: STALE. Same: "press any key|drag onto another key|type your note".
- v29.30: STALE. The title line is lower case "f1 controls"; the match is case blind. The line itself still says F1, not H.
- v29.31: STALE. The backpack cue moved to the bottom left of the card (cw-cardhint) and is left aligned; the check no longer requires right alignment. Colour #aaa498 still asserted.
- v29.32: STALE. "create a new save", "sector a", "enter raid!" (all lower case).
- v29.33: REAL then STALE. The title and mode rules in the shared block had six raw px sizes (tagline margin, wordmark 96px, resolution buttons, key line): fixed in the game as tokens, v32.87 (cw-titletag-tokens, no change on screen, 96px is 56 x 12 / 7). The rest of the shared block now has 58 rules with raw px from later screen ships (stash, pause, Settings), so the scan is limited to the title and mode rules (the check's own subject).
- v29.39: STALE. The Settings chip is a rail tab, so the 3px accent bar is on the left edge (was under the word); no box, no top border.

--- codex run 2026-10-20 11:21 ---
2026-10-20, Codex lane o, continuation at v32.87.

Read the existing task notes first. The previous lane already classified all 19 checks and recorded 18 green on the rebuilt fixture. Those fixture changes are in this checkout. No changes to the o-02 checks or classifications.

v28.20: REAL, repair prepared as cw-cx-kitnamesfit. The 20px gun key and wheel labels lose most of their width to the picture and key number. Each label now gets the full tile width below its picture; tiles grow from 48px to 76px. Keep both existing three-column grids, all nine gun keys, all eight wheel positions, drag targets and pad navigation. Keep the 20px names. No wording change.

The new check stages the stash at 1920x1080 and menu zoom 1 and 1.3, asserts all 17 labels fit, checks their 16px floor, visible pictures, actual rectangle overlap and label containment. Its old-build control should fail on the existing clipped labels. Local validation: mk script printed written; exact edit anchor occurs once; generated check passed node --check. Browser control/pass and pictures remain lane work.

Important sequence: ship the game key first, then return the result and pictures. v28.20 currently uses an x-only picture-overlap test, which cannot handle a name below a picture. After this key ships I will supply a fixture retarget to test rectangle intersection in both axes. That preserves the clipping test unchanged. Do not run that retarget before shipping: the current REAL clipping failure would correctly make its before-ship run fail. No retarget file handed over this run.

Requested screen 04 before/after and critic. The existing task notes explain the other 18 checks. Remaining work is the game gate, visual review and the v28.20 geometry retarget after ship.

53: moved to done/ by the coordinator 10-20 11:58; its last piece (28.20 after v32.89) is job 56
