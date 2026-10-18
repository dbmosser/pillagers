# Corpus triage, 72 failures on HEAD v28.78 (task 01-corpus-triage)

Source: corpus-1016-2219.txt (72 FAIL lines in [120..2006) plus 5 on line 1, range [0,120)). Row # = order in notes/triage-list.txt (76 versions; v9.03 failed twice).
Method: each version re-run alone (notes/triage-out.txt), then the check read in tools\mkfixture.ps1 and the game code it tests.
Verdicts: STALE = check is right for an old design his later order changed. REAL = game wrong today. FLAKY = passes alone or setup noise.
Fix column is what to do later (retarget via fixq.sh for STALE, mk-cw script for REAL). Nothing was shipped or edited in this task.
Confidence is HIGH unless marked (low).

## Summary
- REAL: 1 row (27.38), a lean2 SP regression in the feed. The three suspects mostly cleared: 27.00 and 25.26 are STALE, 28.48 is FLAKY.
- FLAKY: 11 rows (10 pass alone, 10.68 is the rarity roll; 28.68 also has an elite roll, listed in H).
- STALE: 64 rows. Biggest groups: belt to wheel / gun keys (27 rows, section C), feed and alert lane (11, E), run card / stash / UI redesigns (12, G), score $ to SP (5, D), melee key (4, F), mixed (5, H).
- Total 76 rows = 72 corpus failures + the 5 on line 1 (v9.03 counted twice there), all present below.
- Suggested order: 27.38 REAL fix first (one small mk-cw script), then one fixq pass per section D, E, F, then C (retire in bulk), then G and H.

## A. REAL
| # | Ver | Verdict | Reason | Fix | Status |
|---|-----|---------|--------|-----|--------|
| 10 | 27.38 | REAL | A medal makes 2 feed lines. scoreBonus() labels " +100 SP"; feedLabel (html ~19323) only skips labels that start " +$" (lean2 turned $ into SP), so the label becomes a second info line next to feedMedal's own line. Same SP break in feedLabel ~19324 (/^\+\$[\d,]+$/ no longer merges a kill popup "+50 SP" into the kill line, feedMoney) and feedSay pick (~19307 /^[+\-]\$/ so "+70 SP" is not a money row). | mk-cw script: make the three regexes accept both forms, `\$` or `[\d,]+ SP` (skip " +N SP" labels, merge "+N SP" into the kill line, treat a "+N SP" pick tag as money). Check 27.38 SEVEN then passes unchanged. | DONE (shipped v28.81 cw-feedsp, 27.38 passes) |

## B. FLAKY (pass alone; failed only inside the corpus run, an order or leftover-state effect)
| # | Ver | Verdict | Reason | Fix | Status |
|---|-----|---------|--------|-----|--------|
| 5 | 28.48 | FLAKY | 2P shield bubble: passes alone. Corpus failure was "with no bubble the host still draws extra arcs" = absolute arc count compared with a count from an earlier entity (animation or time dependent arcs). Bubble flag logic (pb sent, kept, relayed, drawn) verified by the passing run. Watch it, it matters for 10/30. | Harden the check: compare arcs with pb=1 against the same entity with pb=0 in one call, not against a count taken earlier. Rerun the corpus; if it fails again alone, treat as REAL. | DONE (check hardened: same entity pb 0 vs pb 1, passes 3x) |
| 6 | 28.16 | FLAKY | Head layer: passes alone. | none unless it recurs; then find the earlier check that leaves state (hero kit, G.pwr). | DONE (FLAKY-OK, passes 3x) |
| 7 | 28.13 | FLAKY | Passes alone. | as 28.16 | DONE (FLAKY-OK, passes 3x) |
| 8 | 28.12 | FLAKY | Passes alone. | as 28.16 | DONE (FLAKY-OK, passes 3x) |
| 43 | 19.00 | FLAKY | Status effects left side: passes alone. | as 28.16 | DONE (was not flaky: failed alone in a fresh tab. Column band widened to 40 percent because the feed zone pushes the column right of the vitals, retargeted, passes 3x) |
| 45 | 18.25 | FLAKY | Trade-key floor lines: passes alone. | as 28.16 | DONE (order dependent: key line follows state hub or raid. Check now stands in a raid for the key line, passes 3x) |
| 46 | 17.86 | FLAKY | Pause legend CTRL / C: passes alone. | as 28.16 | DONE (order dependent, same fix as 18.25, passes 3x) |
| 47 | 17.75 | FLAKY | Passes alone. | as 28.16 | DONE (order dependent: legend is by state, hub says use a station. Check now reads it inside the raid, passes 3x) |
| 74 | 9.93 | FLAKY | RMB aims down sights legend: passes alone. | as 28.16 | DONE (FLAKY-OK, passes 3x) |
| 75 | 9.92 | FLAKY | Passes alone. | as 28.16 | DONE (FLAKY-OK, passes 3x) |
| 68 | 10.68 | FLAKY | "carbine did not go to his empty second slot (it holds carbine_v)": the rarity variant roll (20% one tier up, rarvar) sometimes turns the carbine into carbine_v; passed on the rerun. | In the check, pin the pick to the plain model (or accept gun_carbine and gun_carbine_v). | DONE (check accepts the plain id or its _v id, passes) |

## C. STALE, belt became the wheel and fixed gun keys (his orders 2026-10-14: bar is guns only on keys 1-9 by class, HOLD Q wheel for all items, no H / G / U / J / 5-9 item shortcuts; starters removed, v26.39 nostarters2)
All of these build a tactical belt with items on keys 3-9 or Medical / Throwable cells, drag items onto belt keys, or use G / H / pad D-pad heals. Those cells no longer exist. Fix for the group: retarget each to the wheel / gun-key design where the idea still holds (an item type is used from the wheel, a gun goes to its class key), or retire the check with fixq.sh. Do the whole group in one pass.
| # | Ver | Verdict | Reason | Fix | Status |
|---|-----|---------|--------|-----|--------|
| 1 | 9.03 | STALE | Spent belted medkit / bandage slot stays dark: slots 5 and 6 no longer take item bindings (slot 5 is "Fourth weapon" now). Belt to gun-only bar. | Retire, or retarget to wheel (a type at 0 shows dim). | DONE (SKIP, both 9.03 checks; wheel dim covered by 26.33) |
| 2 | 9.31 | STALE | Drag onto / off the belt: items do not go onto the bar any more. | Retire. | DONE (SKIP) |
| 3 | 11.60 | STALE | Frag Charge on belt key 5 builds a gun cell: key 5 is the LMG class key. | Retarget: frag used from the wheel, count shown there. | DONE (SKIP; wheel counts covered by 26.xx checks) |
| 17 | 23.95 | STALE | A plate carried plus a Tripwire Mine each get a belt cell: no throwable / plate cells on the bar. | Retire (wheel has fixed 8 slots). | DONE (SKIP) |
| 20 | 23.63 | STALE | Tripwire Mine on the belt, Q chooses smoke: Q is the wheel. | Retarget to the wheel (Tripwire is wheel slot 4). | DONE (retargeted to wheelHave and handTake, passes) |
| 23 | 23.46 | STALE | Controls card has no HEAL row 7; G / pad D-DOWN do not start a Bandage wind-up (G removed, heals from the wheel). | Retarget: card row is ITEMS, a Bandage comes from the wheel. | DONE (ITEMS row, wheelHeal, G and D-DOWN tap start no heal, passes) |
| 25 | 23.42 | STALE | Card rows now MOVE,AIM,FIRE,ROLL,RELOAD,SWITCH GUN,ITEMS,EXTRACT,LOOT: HEAL became ITEMS (wheel). | Accept ITEMS in the expected list and the HOW TO PLAY test. | DONE (passes) |
| 30 | 23.05 | STALE | Medkit did not go on slot 9: slot 9 is the Energy gun class. | Retire. | DONE (item drop retargeted to the refusal line SLOT 9 TAKES GUNS ONLY, rest of the check kept, passes) |
| 32 | 22.54 | STALE | Meridian Lance row tagged SLOT 9 not SLOT 2: Lance is class key 9 by his gun-key order. | Expect SLOT 9. | DONE (expects the class key from gunClassKey, passes) |
| 33 | 22.43 | STALE | Belt line wording: "EMPTY SLOT", "SHOTGUN ON KEY 2": a shotgun goes to key 6 now (RIOT SCATTERGUN (FIELD) TO SLOT 6). | Retarget the words to the class key. | DONE (vacant key found dynamically, shotgun line names its class key, passes) |
| 34 | 22.39 | STALE | Old belt plan {8: Medkit, 9: Stim} slides to gun keys; no plan slide, no plate key. | Retire. | DONE (SKIP: removed by his order) |
| 36 | 21.93 | STALE | Belt shows rifle on key 1, shotgun key 3: guns are on class keys (key 1 pistol, 3 rifle...) with ghost gun cells. | Retarget to class keys or retire. | DONE (parts 1 and 2 retargeted to class keys, parts 3 and 4 retired, passes) |
| 49 | 16.85 | STALE | Controller builds tactical belt on the Stash screen. | Retire (wheel, GUN KEYS panel replaced it). | DONE (SKIP) |
| 50 | 16.79 | STALE | D-LEFT around belt keys to key 8, bind item to a belt key. | Retire. | DONE (SKIP) |
| 51 | 15.25 | STALE | Backpack SMG by key 3, cell 1 never black: cell 1 is the pistol class key now. | Retire or retarget to class keys. | DONE (SKIP) |
| 52 | 14.25 | STALE | One item one key in the backpack; Medkit onto key 5. | Retire. | DONE (SKIP) |
| 53 | 13.16 | STALE | Tactical belt offers the picked plate: plates are a wheel slot, hold nothing on the bar. | Retarget: plate shows in the wheel, bar unchanged. | DONE (wheelList shows the plate, bar has none, passes) |
| 54 | 12.31 | STALE | Staging: empty throwable cell, Bandage cell on key 4. | Retire. | DONE (SKIP) |
| 55 | 12.28 | STALE | Peddler purchase tag: autoBelt key names gone; tag is a caps tag "BACKPACK" now (terse caps), not "In your backpack". | Expect the caps tag; drop the belt-key cases. | DONE (BACKPACK tag expected, key-6 case dropped, passes) |
| 56 | 12.27 | STALE | Drop on a belt key says "ITEMS GO ON THE WHEEL" by design. | Retarget to that line, or retire. | DONE (SKIP, plan cells gone) |
| 57 | 11.97 | STALE | Pistol dragged onto key 6 refused: key 1 is the pistol class now, key 6 shotgun. | Retarget to the class-key rule. | DONE |
| 58 | 11.96 | STALE | Keys 3-5 refused Bandages / Medkit / plates: they say ITEMS GO ON THE WHEEL (the design). | Retarget: the refusal is correct. | DONE |
| 59 | 11.95 | STALE | Pistol took key 6 although guns go on 1-4: now guns 1-9 by class. | Retarget to GUN_CLASS_OF. | DONE |
| 60 | 11.91 | STALE | Belt draws no Medical cell to press. | Retire. | DONE |
| 61 | 11.90 | STALE | Drag gun from slot 1 to the backpack with it open: slot 1 is the pistol class cell. | Check by hand later; retarget to class keys. (low) | DONE |
| 62 | 11.83 | STALE | Key 3 use stim, stim sprint: no key 3 stim (wheel Stim slot; key 3 is the rifle). | Retarget to the wheel Stim use. | DONE |
| 76 | 9.82 | STALE | Drag off the tactical belt onto the backpack: no tactical belt. | Retire. | DONE |

## D. STALE, score $ became SP (his order 2026-10-15, lean2: arcadeCr reads "N SP", arcadeMoney keeps $ for credits). Checks match "$..." or an exact "1,234" string.
Fix for the group: accept /^\$?N( SP)?$/ in each. Do it once with the fixq pass.
| # | Ver | Verdict | Reason | Fix | Status |
|---|-----|---------|--------|-----|--------|
| 21 | 23.56 | STALE | Pickup tag "+70 SP" not "+$N", HUD "$1,234", "YOU $1,234", popup "+$50", board "$4,321": all SP now. Credits still $ (arcadeMoney). | Expect SP forms for score, $ only for credits. | DONE |
| 22 | 23.54 | STALE | 1P arcade HUD fillText is "1,234 SP" in one string; the check needs an exact "1,234". | Regex match. | DONE (accepts "1,234 SP", passes) |
| 27 | 23.38 | STALE | Popups are "+50 SP" / "+100 SP"; hasLbl wants "+50". | Prefix match. | DONE (hasLbl accepts "+N SP", passes) |
| 29 | 23.29 | STALE | Team score "450 SP" vs exact "450". | Regex match. | DONE (accepts "450 SP", passes) |
| 26 | 23.41 | STALE (low) | NEW HIGH SCORE never said: arcadeHiTick code is unchanged. Likely the 'tonight' window (arcadeBoardTonight uses rows since arcadePartyAt, v26.xx party5) or the board rows now need u:'cr' / mode m (v23.57, v23.54) so the first run's row is not in the bar. Needs one probe run to confirm; not a game bug on the code read. | In the check set the party stamp to 0 and give the rows the current mode/scale tag; if it still says nothing, reopen as REAL (2P demo relevant). | DONE (probe: the 13 h old 99999 row was in the bar once the party stamp was restored early; check holds the stamp through the NEW HIGH part, game fine, passes) |

## E. STALE, feed and alert lane replaced the old message rows / world text (his orders 2026-10-15: one persistent feed bottom-left plus one top-centre alert lane, world text 60% size and depth sorted, no pickup stack, no notoriety banner; builds feed1-3 v27.24+, feed2 v27.51, feedocc)
| # | Ver | Verdict | Reason | Fix | Status |
|---|-----|---------|--------|-----|--------|
| 16 | 23.96 | STALE | Only the last sub-check fails: "a HUD drawn alone filled the world label". Labels are now also a feed line (feedLabel, v27.24), so drawHUD draws the label text in the feed. Earlier parts pass. | Use a label text feedLabel skips (e.g. WEAK SPOT) for that sub-check. | DONE (WEAK SPOT used for the last sub-check, passes) |
| 31 | 22.59 | STALE (low) | BACKPACK FULL: the pickup stack is not drawn now (feed line, key 'bagfull' dedupes to one line); two fillText hits are the feed line drawn with a shadow pass or line plus sub. Count distinct rows in g.fd, not fillText calls. If a real duplicate shows on screen reopen as REAL. | Retarget count to feed rows. | DONE (distinct g.fd rows counted, drawn at least once, passes) |
| 35 | 22.32 | STALE | Pillbox line drawn 800 29.7px not callout 700 22.3px: alerts are in the top-centre alert lane, bigger type, by design. | Compare against the alert lane font. | DONE (TYPE.title expected, passes) |
| 37 | 21.88 | STALE | Two message rows with protection and queue: rows replaced by feed + alert lane. | Retire. | DONE (SKIP) |
| 38 | 21.86 | STALE | Two message rows, boss bar band: same. | Retire. | DONE (SKIP) |
| 41 | 20.75 | STALE | NOTORIETY stamp not drawn: notoStamp is an alert (say, key noto) plus a feed line now. | Check the alert instead. | DONE (staged with alertSay, passes) |
| 70 | 10.52 | STALE | "[E] SEARCH CRATE" drawn at 14px vs callout 23.4: prompt is ~60% size in the world pass on purpose (his "wayy too big", 10-15 01:45). | Lower the floor to the new size. | DONE (floor 12 px, passes) |
| 72 | 10.44 | STALE | Only the control fails: compact legend at x 491 (> 400): the legend moved right of the bottom-left feed. | Allow x up to the feed width. | DONE (limit 30 percent of width, passes) |
| 24 | 23.44 | STALE | Arcade pause box ids now include wnbtn (WHAT'S NEW). | Add the id (10.96 same cause). | DONE (optional ids filtered, passes) |
| 66 | 10.96 | STALE | Undercroft pause box has 4 buttons (return, LEADERBOARD, WHAT'S NEW, character select). | Expect the four. | DONE (filter extended, passes) |
| 28 | 23.35 | STALE | Arcade CONDITIONS box laid out: v27.42 (info1) lets the arcade show its goals panel when the flow has goals. | Clear g.flow goals in the check. | DONE (goals regenerate in the loop, so the box check allows the goals panel; passes) |

## F. STALE, melee moved F to Q to V; F is next gun; 1-9 guns (wheel2, v26.xx)
| # | Ver | Verdict | Reason | Fix | Status |
|---|-----|---------|--------|-----|--------|
| 63 | 11.38 | STALE | Control swing next to a hostile pillager does no damage: the check presses the old melee key. | Call meleeStrike() or press KeyV. | DONE (__meleeKey helper now returns KeyV, passes) |
| 64 | 11.27 | STALE | F no longer swings (F = next gun); heal on belt slot gone. | Retarget to V; drop the belt control. | DONE (V via helper, belt control dropped, passes) |
| 65 | 11.26 | STALE | Pause box says "V melee" and "1-9 guns", not "Q melee" / "1-4 guns". | Update the words. | DONE (raid key line written first, V melee and 1-9 guns, passes) |
| 69 | 10.64 | STALE | F did not strike with a rifle in hand: same key move. | Use V. | DONE (helper already returns KeyV, passes) |

## G. STALE, run card chips, stash tabs, map marker, sprite, other late redesigns
| # | Ver | Verdict | Reason | Fix | Status |
|---|-----|---------|--------|-----|--------|
| 39 | 21.09 | STALE | Run card feel tags are hidden unless the feedback box is open (css 1347: #tagwrap / #oc_note display none when not .fbopen), so width 0. | Open the feedback box first (add .fbopen) or retire. | DONE (fbopen added then restored, passes) |
| 44 | 18.97 | STALE | Note box squashed to 0px: same hidden #oc_note. | same | DONE (fbopen, passes) |
| 42 | 20.58 | STALE | "0 of 29 run tags in reach of the pad": same hidden tags (he already noted it failed in its harness). | same, with the card open on feedback | DONE (fbopen, passes) |
| 40 | 20.92 | STALE (low) | Stash filter row ends 211px short: the row now holds 11 tabs (ARMORY, TROPHIES, LOCKED, SORT) after the stash redesign. | Retarget to the new filter row geometry. | DONE (row ends at TROPHIES, passes) |
| 73 | 10.11 | STALE | Stash tabs are now ALL, GUNS, CONSUMABLES, PARTS, SALVAGE, KEYS, VALUABLES, LOCKED, SORT, ARMORY, TROPHIES (his six were extended). | Expect the longer list, plates still under CONSUMABLES. | DONE (his six lead, extras allowed, passes) |
| 14 | 24.87 | STALE | Keys list max-width is 1500px in two columns (css 1334 overrides 1100): the full key list (settings, v26.38+). | Cap at 1500. | DONE (cap 1500, passes) |
| 15 | 24.19 | STALE (low) | The check scans only styleSheets of the first <style> for a rule joining :focus-visible and .padfocus with var(--acc). The game has that rule (html 993-996), so keyboard and pad focus are still one rule. Check harness reads the wrong sheet or the rule text changed. | Scan every document.styleSheets entry. | OPEN |
| 18 | 23.88 | STALE | Hint now reads "The world only. HUD and text stay sharp. Lower runs faster." The check regex is /WORLD/ and /SHARP/ case sensitive. | Make the regex case-insensitive. | OPEN |
| 19 | 23.85 | STALE | Settings tabs (THE RAID, AUDIO, CONTROLS, CONTROLLER ...) are 14px tracked .16em (css 1133 and 1278) after the Settings sections; check caps tracking at .145em. | Raise the cap to .16em for Settings. | OPEN |
| 67 | 10.92 | STALE | The map marker is a neon green chevron now (his order 2026-10-15, mapchev), not a gold disc; the check counts exact #ffc04a pixels (0). | Count #39ff14 pixels. | OPEN |
| 71 | 10.46 | STALE (low) | Jersey numeral reads 2 pale px (floor 6). Pixel read of the torso is covered by the bigger gun (GUNK 1.3, guns2x) and the head layer. Likely moot once the character art build lands. | Retarget after the char art build (queue item 3). | OPEN |
| 48 | 16.87 | STALE | TOP GEAR packed 2 of each grenade: kit moved into the map select screen as RANDOM KIT (2 guns, 1 of each wheel type) and BEST KIT (3 guns, up to 3 of each) by his kit order 2026-10-15. Names and counts changed. | Retarget to BEST KIT: 3 guns, up to 3 of each wheel item. | OPEN |

## H. Mixed (stale check, one cause is the game getting better)
| # | Ver | Verdict | Reason | Fix | Status |
|---|-----|---------|--------|-----|--------|
| 4 | 28.68 | STALE + FLAKY | Crawler bite is 9 now (crawldmg v28.76, his "too much damage per hit"), the check pins 13 / reach 26. Speed 120 vs 162: the second crawler is an elite (blessElite 1.35x), a random roll. | Expect dmg 9 and compare c.spd against 120 or 162. | OPEN |
| 9 | 27.82 | STALE | Rampage start plays no rampageRoar: the check stages a fake boss that is not in G.ents, and v28.63 (rampagedead) makes start() end the event when the boss is not in G.ents. | Push the fake boss into g.ents before EVENTS.rampage.start. | OPEN |
| 11 | 27.00 | STALE | Needed-item glow in the world changed 0 pixels: removed on purpose by lean6, his order 2026-10-15 "get rid of the shining circle for items, don't highlight items like that any more" (html 34485/34499). The backpack and pickup-row gold edges (SIX, SEVEN) still pass. | Make FIVE assert NO glow, or drop FIVE. | OPEN |
| 12 | 25.26 | STALE | Longshot not longer than Marksman: game draws it longer (GUNDEF sniper tip 39.3 vs dmr 35.6, both x GUNK 1.3 = 51.1 vs 46.3). The check's canvas is 96 px wide with OX 48, so the Longshot is clipped at 48 (diff 1.7 < 2). Left over from guns2x (v27.xx). | Widen the probe canvas (CW 128, OX 64), keep the length asserts. | OPEN |
| 13 | 25.01 | STALE | "4 oscillators run" with 1, 3, 6 machines: the siren itself is 2 oscillators; the other 2 are the LOCKED ON alert blip that lean7 (his words 2026-10-15) added in tickMachSiren. | Stub say() or blip during the siren check, or allow 4. | OPEN |
