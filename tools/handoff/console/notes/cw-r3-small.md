# cw-r3-small: round 3 small fixes (helper-fixes lines 28, 34, 35, 36, 37, 39, 41, 43) plus two coordinator additions

Written 2026-10-18 evening by the round 3 small-fix helper. Not committed (this folder is never committed).

## Shipped (each its own ship, each check failed on the build before and passed twice on the new one)

| Line | Key | Build | Commit | What |
|---|---|---|---|---|
| 35 (S2-15) | cw-ascendin | v31.20 | 3a8f7954 | the demo respawn count reads "ascending in n" (was "dropping in n"). Check draws the real HUD at hold 2.4, 1.2 and 0. |
| 28 (G5) | cw-endhalf | v31.27 | 96aa428e | END RUN from the demo pause menu (why "menu") halves both scores like a death or the burn (Q60). Player 2 is told (arcend carries hf) and builds its own card with "ended early -50%". Extraction still doubles. 'idle' is untouched (Q78 decides it). |
| p2 prompt (coordinator, his 10-18 afternoon item 5) | cw-p2prompt | v31.28 | 01a8f617 | player 2 attract prompt follows player 2's own last device: a key reads "player 2: press any key", its pad reads "player 2: press a" (padB, so a PlayStation pad reads its own name). Player 1 unchanged. The run over card sits on the same attract, so it follows too. |
| 37 (S2-stale) | cw-nobagfull | v31.29 | bec40570 | the BACKPACK FULL path is gone: pedBuy cap, weight and refusal, the gunClassSwapIn and beltGunFull overflow drops, bagDropHint, the updatePlayer cap local, the search refusal chain. Every removed name was grepped in the game and the fixture. |
| 36 (S2-stale) + coordinator (a) | cw-gearrules | v31.33 | b240a508 | GEARRULES says keys 1 to 8 and 0 bring up your guns, the old belt block now teaches the item wheel (hold q), the armour tip says use one from the item wheel. The Keys window no longer lists "H heal (tap), armour plate (hold)" (H does nothing: HHOLD.arm is never set). Locked gun keys read "1 - 8, 0"; the rebind refusal note says 1-8 and 0. The item hover card (beltInfoCard) names the item wheel instead of HEAL / THROW / PLATE on H and G. |

Fixture commits (retargets so older checks hold on the old AND the new build): 855dbb50 (23.35, 23.45, 27.51 accept dropping in / ascending in n; 22.59, 22.62, 23.49, 13.51 skip the refusal arms; 25.85 and 23.41 read the score the run ended on) and 475bedac (26.52: no H row wanted, KeyH exempt in the code scan, locked keys accept 1 - 8, bind-and-swap runs on C).

## Not a ship
- 34 (S3-15 + S2-03), Forge price label: already true. Every Forge price (the upgrade line, the NEED refusal) goes through arcadeCr, which prints "n sp" (lowered by the text door); dollars are arcadeMoney and are not used for the Forge. Probed live on a staged Forge. No change.
- 39 (fuzz fake pad on slot 0): done in tools/fuzz-pad.js and tools/fuzz.ps1 (index 0, getGamepads returns [pad,null,null,null]). The edit was swept into another helper's ship commit 9af54a75 (v31.10) because ships commit every modified tracked file; the content is in HEAD. The fuzz ran once in both pad modes (replay raid seeds 4242 and 4243): 0 problems, pages closed. Note: netPairOf wants a 4 to 16 character pair, so a tiny replay seed makes a 3 character pair and the two windows never link.

## 41: do mixed-case codes survive the lower-casing text door?
Yes for everything a player sees today. The online invite code, the reply code and the restore code are shown only as the `.value` of a textarea (partycode, exporttext). txDom lowers text nodes, title, placeholder and aria-label but never `.value`, and the textareas have text-transform none. Probed live: after txDom twice and after renderParty the invite code ("PTY1opAbCd...") and the restore code ("PIL1AbCd...") were byte for byte what was set, and the parser still read them. The pair code is a-z and 0-9 and is lower-case safe.
Two notes: (1) if a code were ever drawn on the canvas or as a text node it would be lowered and would no longer parse (netCodeParts and restoreRead are case sensitive and the body is base64 style; they returned null on the lowered code); nothing draws one today. (2) the textarea placeholder hints "it starts pty1o" in lower case while the real code starts "PTY1o"; harmless when pasted, wrong only if someone types the code by hand.

## 43: melee, armour plate and air strike on a pad (layout not changed)
- Armour plate: yes. Hold D-PAD DOWN (the item wheel opens), push the RIGHT STICK toward the plate segment (the bottom of the wheel), let go of D-PAD DOWN. LEGEND_PAD lists "D-DOWN item wheel (hold)" but not the plate, and the test sheet pad table lists D-pad down item wheel without the plate.
- Air strike: yes, but not in LEGEND_PAD or the test sheet. Press LB and RB together (within 0.3 s) once the meter is full: that arms it (flowOn must be on); aim, then RT calls it; LB + RB again cancels. The LEGEND_PAD comment still says both bumpers only walk the belt, which is out of date.
- Melee (V, the crowbar): NO. meleeStrike is called from the V keydown only. Nothing on the pad reaches it. Y with a downed pillager in reach holds V, but that is only the finisher (it does not swing the crowbar); otherwise Y reloads, searches a ring or helps a teammate. So a player on a pad (player 2) cannot swing the crowbar. Question 13 decides the layout work.

## Test sheet (Desktop\dark raiders\2-player-test-today.md, not in git, so nothing to commit)
Fixed three stale lines: the shield bubble no longer comes with a controls card (removed by Q70, cw-notutor, arcadeCardOn returns 0); the keys now point at F1, the pause screen and the how to play page; the gun keys read "1 to 8 and 0, or F for the next gun" (it said 1-9). NOT changed (line 44 of helper-fixes, someone else's): the build number in the intro, "stable.html is 29.09", and the missing melee / plate / air strike rows in its pad table (see 43).

## Left alone on purpose, flag for the coordinator
- LEGEND and LEGEND_MINI still label the gun keys "1-9" and the pause box legend (keysLegendHtml) says 1-9 guns; the guns are 1 to 8 and 0. Checks 26.43, 25.75 and a few 27.xx assert the "1-9" label, so changing it needs a retarget first.
- Dead code now: autoCull, worstBagIndex, arcadeBagFree, the __bag hook, P.autoloot; and H: holdHTick, HHOLD, quickHeal, quickPlate (the fixture still names holdHTick and HHOLD).
- The static HTML of #pausekeys (in the game file, line 1934) still lists H and 1-4 guns, but keysLegendApply replaces it whenever the box opens, so it is never seen.
- Four older checks are red on the OLD build too (v31.05) and on v31.33 alike, in lane c and in the gate Chrome, so they are not from these ships: 23.40 (host attract reads press any key, expects press any button), 23.41, 23.45 and 25.85 (the initials card flow). They look stale since the live key / pad prompts (cw-glyphs) and want a retarget or a place on the known-red list.
- Pipeline: the What's New stamp check (31.08) went stale mid-queue at v31.24 and was fixed by another helper's card ship (cw-cardP27). The earlier drafts only needed to wait for it.

## Second pass (the coordinator's two follow-ups), all shipped
- Gun key label, cw-gunkeys19, v31.42 (d39a2483): LEGEND, LEGEND_MINI, the pause line, the demo controls card (SWITCH GUN) and the stash key row now say 1-8, 0 instead of 1-9. The refusal for a gun on the wrong key said guns go on keys 1 to 9 in three places; it now comes from beltClassWord (guns go on keys 1 to 8 and 0). The stash number-key bind had the same mix-up: with a gun under the cursor, key 9 bound the rocket launcher key (the ninth cell) and key 0 did nothing; now 0 binds it and 9 does nothing. Checks 26.43, 26.00, 25.75, 17.76, 11.26 and 25.89, 25.90, 22.52 were retargeted first (fixture 5f20404a) to take the old or the new words. There were no 27.xx checks that assert the label.
- The four red checks were stale, plus one real bug. Fixture dc490501 retargets them (and 23.24, 23.25, which were red for the same reason):
  - 23.40, 23.24, 23.25: the attract prompt follows the last device used (live key and pad prompts), so a keyboard reads PRESS ANY KEY, a pad PRESS ANY BUTTON. They expected BUTTON always.
  - 23.41, 23.45, 25.85: his Q62 (cw-iniplayer, v30.36) made a 2 player row take player 1's initials and then player 2's, so the first DONE keeps the card up for player 2; they expected one set. 23.41 also expected a live NEW HIGH SCORE mid-run, which his Q71 (cw-noliverank) took out (arcadeHiTick returns false); it now expects none. And a row with player 1's initials only counts as still wanting player 2's (arcadeBoardQual), so its staged row got both sets.
  - REAL BUG, cw-inihead, v31.45 (e2b1fcb1): since v30.36 the initials card had no heading. cw-iniplayer rewrote the heading line to say whose turn it is and left the c.appendChild(el); statement inside the line comment after it, so the card drew the three letters and the hint only (no player 1 / player 2, no top 10 tonight). Restored; its own check 31.45 fails on the old build. 23.41 now also asserts that the card says player 2 on the second turn.
- All of 23.40, 23.41, 23.45, 25.85, 23.24, 23.25 plus 26.43, 26.00, 25.75, 17.76, 11.26 pass on v31.45 in lane c and in the gate Chrome.
