# 186c-fewer-raid-messages : far fewer messages reach the player in a raid
Queue: his complaint 10-27 ~21:25 (verbatim): "I am worried your quiet hud shit isn't actually addressing my complaint, which is that there are too many messages coming in to the player". Shown the plan below, he answered (verbatim): "Ok? I don't know. You need to figure out what works". So this is the decided design; build it, measure it, ship it. Polish, allowed before 11/1.
effort: high
Worked in: the quiet hud part A session (it knows say, feedSay, the alert lane and the 35.30/31/33 changes). Lanes skip in-session/.

What is true: 338 say() call sites (78 info, 40 warn, 26 obj, 22 ally, 20 sys, 18 ext, 13 pick, 12 crit, 12 chat, 27 with no kind). In tonight's pictures 9 lines showed and only 2 mattered ("the pillbox has seen you", "spotted by the overseer"); the rest were location revealed, running slowly, codex entry, fog, stronghold 1 on the map, golden enemy.

The rule (decided):
1. A line reaches the screen only if it is one of five kinds:
   a. danger to you now (seen, shot at, siege, low health, a lock-on), the alert lane;
   b. extraction (available, called, inbound, missed, ring closing);
   c. your teammate (down, revived, extracted, left);
   d. money or a contract or goal done (not progress lines);
   e. the answer to something you just tried that did not work (health full, bandages stop at 85, backpack full, no x left): a key that silently does nothing reads as broken (memory dark-raiders-broken-often-means-silent), so these stay, one short line.
   Everything else stops showing (codex, location revealed, weather and fog, running slowly and wading, golden enemy, stronghold, discoveries, lore, chatter, system lines, progress counts). It still goes into G.msgLog. Classify every one of the 338 call sites; write the list with keep or cut per line into tools/handoff/console/notes/raid-messages.md so he can read it later.
2. DROPPED 10-27 ~21:35, his words (verbatim): "I feel like you are just fucking it up worse. I really like how looting feels and looks". Looting stays exactly as it is: the right-side pickup stack and its rows, loot sounds, money and SP rows, item labels, container open, their timing. The cut and the rate cap never touch any of it. A control check: a search of several items still draws one row per item, on both builds.
3. Rate cap: outside the alert lane, at most one new line about every 2.5 s; a line that waited more than 4 s is dropped unless it is money. Danger always goes through at once.
4. Real numbers, not guesses: count the lines actually drawn per minute in a staged real raid (not G.sim; a scripted 3 minute run through the fixture with a fight, looting, wading and an extraction) on v35.35 and on the draft. Put both counts in the DESIGN section and in the report to him. Aim for most of the reduction to show; if the count barely moves, the rule is wrong, fix it before shipping.
Checks (must FAIL on the build before): a codex entry, location revealed and running slowly draw nothing; a danger line still draws at once; a container search of several items draws one pickup row; two info lines in one second draw one. Old checks that expect the cut lines on screen: re-aim through fixq to prove the new rule; never loosen one just to pass.
Pictures: uishots 21, 33, 34, 50 at 1080; look at them; send him the 33 picture with the before and after counts in one line.
Ship: preflight on lane g (check no other preflight on g first), then shipq; wait for its ON HIS PC vNN.NN line. Rules: player text lower case; no storage key change; seed fingerprint unchanged.
TASK DONE when shipq printed ON HIS PC for the build. Then move this file to console/done/ and report two lines: build, on his PC, lines per minute before and after, and what he should watch for.

## RESEARCH RULE (10-27 ~22:10, replaces rules 1, 3 and 4 where they differ; looting rule 2 stands)
Source: reports/Player alerts and HUD messaging.md (sections "The drafted five-kinds rule holds" and "PILLAGERS raid HUD, region by region"). Read those two sections first. Ship as TWO builds so either can be reverted alone.

Build 1 (cw-msgroute): route and reshape the left feed (report jobs 1 and 2).
- Ladder: P0 danger to you now or teammate down; P1 extraction change; P2 other teammate news; P3 goal or contract done; P4 one-line answer to something you tried that did not work. Everything else (the 27 lines with no kind, the 78 info lines unless one is truly one of the five, codex, location revealed, running slowly, fog, weather, stronghold, golden enemy, discoveries, lore, chatter, progress counts) goes to G.msgLog only. Sort each of the 40 warn lines into P0 or the log. Write the keep or cut list per call site into notes/raid-messages.md as planned.
- The run log can be read on the pause screen so nothing is lost (a plain list of the last lines; it is the existing log, not a new screen).
- Left feed: at most 3 lines; each lives 5 s, fades in about 0.2 s and fades fully out about 0.4 s (today: 10 lines, 6 s bright then held at 60%). At most one new line per 2.5 s in this slot, counted after repeats merge into one counted line ("x2") that resets its time. A line that waited more than 4 s is re-checked and dropped if no longer true. P3 goal-done lines wait until no shot fired or taken for about 4 s, then show as one merged line. Teammate lines in the teammate colour (P1 amber, P2 cyan).
- KILL LINES STAY in the feed (his 10-25 answer g-86 asked for kill feed icons, job tasks/166): do not cut them; they follow the merge and the 3-line limit like any feed line. The report's "kill lines leave the feed" is overruled by his answer.
- "contract item nearby": leave it exactly as it is (close to looting; his call).
- No money exception is needed: money rows are in the pickup stack, which this job never touches.

Build 2 (cw-dangerslot): the danger slot (report job 3), after build 1 is ON HIS PC.
- Move the danger banner from about 16% of screen height to about 27% (y about 290 at 1080p), centred, one line about 30 px on a plate, scale in about 200 ms, life 3 s (4 s for "down" or as long as the state holds). One danger at a time; P0 replaces P1 at once and the P1 goes back to wait; same source and words not again for about 10 s; a danger that could not show within 1.5 s is dropped, never sent to the feed (today it moves to the feed after 2.5 s). Teammate down is P0 in the other window, teammate colour. Keep the "!" world mark over the enemy that saw you.
- Downed card: today about 480 by 200 px at screen centre. Check first whether the camera centres the player (arcade picture says yes, career pictures look off centre). If it covers the player, shrink it into the danger slot (timer, bar, "[f] self-revive" line). If it does not cover the player, leave it and say so.

Numbers for the report to him: lines drawn per minute in the staged 3 minute raid on the build before and after build 1. Checks must FAIL on the build before. Old checks expecting cut lines: re-aim through fixq, never loosen. Pictures: uishots 21, 33, 34, 50 at 1080 after each build; look at them. Watch-for line for him: whether he misses anything that now lives only in the log, and whether the lower danger slot covers enemies coming from above the character.
Model note (Development efficiency 10-27): this session continues as is; no new session for this job.

## HIS ORDER 10-27 ~22:35 (verbatim): "the game is telling me about extraction b when it is happening far across the map from me." Add to build 1 (cw-msgroute).
Lines found: "extraction X closing" and "extraction X closed" (sayWhenFree, kind ext, about lines 28744 and 28749) fire for every exit on the map with no distance check. Look for any other line that names an exit letter the same way (opening, siege, someone extracting).
Rule: an extraction line about a specific exit shows only if that exit is the one you are heading to (G.active, or one you or your teammate called) or is within about 60 m of you. Every other exit stays silent in text: the map and the top-centre pill already show its state (the pill job is 186e). Lines already gated by chatNear (survivor extracted, pillager bot called extraction) stay as they are. When the exit you are heading to closes, keep the closing and closed lines and the nearest-open-exit detail. Check (must FAIL on the build before): an exit more than 200 m away closing draws no line; the exit you are heading to closing still draws one.
