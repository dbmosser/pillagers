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
