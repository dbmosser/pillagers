VERIFY LOG, round 3 (checker pass, Sun 10-18). For the coordinator only. NOT for the owner.

Files checked: questions-100-round3.md (Desktop) and q-round3/questions.json, kept in sync (ids r3-01 to r3-94).
Result: 100 questions written, 6 dropped, 94 kept and renumbered 1 to 94. The md says at the top that the count is 94, not 100.
Of the 94 kept: 12 unchanged (OK), 43 fixed for content (FIXED-C), 39 fixed for length or wording only (FIXED-L). Every question is now 120 words or fewer (full block, labels included); 70 of the originals were over 120.
Words = full block (number, labels, options, pick, because), old -> new.

PER QUESTION (old number -> new number)

1 -> 1 | FIXED | now asks about 'your first 2-player run' and says skip it if you have not run it yet (no record that a two-TV run happened; the noon notes cover buttons, pads, case and seeing each other); the sentence listing what the noon notes cover is gone | 125 -> 119 words
2 -> 2 | FIXED | same: conditional on the two-TV run; sound claim kept (two windows, one output) | 116 -> 118 words
3 -> 3 | FIXED | same: conditional on the two-TV run; round 2 question 1 bridge kept | 111 -> 117 words
4 -> 4 | FIXED | 'Start button greyed out' removed (the survey pick is two ready cards that start when both are ready); the round 2 question 7 bridge moved into correction 1 | 141 -> 118 words
5 -> 5 | FIXED | mechanism sentence simplified (a click that brings player 2's window forward leaves player 1 still); added 'skip if round 2 question 13 settled it' | 144 -> 120 words
6 -> DROPPED | already handled by the game: a window follows the pad it last played (PAD.ix / NET.padIx, v18.52) and an unplugged pad pauses the run with 'controller disconnected, reconnect to resume' (v17.73, v17.88), so options b and c already exist. Source: dark_raiders.html about lines 18164-18178 (real wireless re-numbering not testable here, see unverifiable)
7 -> 6 | FIXED (length/wording) | cut 'a helper asked which you meant and changed nothing' and the word 'code'; facts re-checked (v30.84/v30.86 co-op sees each other; party demo Undercroft is the blurred backdrop, p1p2-consistency.md) | 141 -> 119 words
8 -> 7 | FIXED (length/wording) | examples cut to the one label that exists in the game ('hold [v] finish'); the 'completely self-explanatory' clause cut for length | 137 -> 116 words
9 -> 8 | FIXED | 'power-ups' removed and the dates fixed: he said he never noticed the events on 10/15 and the combo ring on 10/14; option b reworded to match | 139 -> 118 words
10 -> 9 | FIXED (length/wording) | cut the 'player 2 may have nothing left to play' clause and the bracket (moved into the pick reason); orders 10/2 and 10/18 unchanged | 144 -> 119 words
11 -> DROPPED | premise false: there is no one-tap heal on the keyboard any more. HHOLD (the H tap/hold) is never armed and the wheel is the only way to a heal (his 10/14 wheel order, v26.27-v26.28, code comment 'the arcade quick heal is gone'). Two stale label lines remain (Settings key list 'H heal (tap)', a HUD hint) and go to a helper. Source: dark_raiders.html about lines 18127-18130, 21780-21801
12 -> 10 | FIXED | 'the game's own notes record a bug' removed (a later fix covers only the second press of a well-timed reload); now rests on his 9/27 layout and 10/15 'do what you think is best' | 144 -> 115 words
13 -> 11 | FIXED | REWRITTEN: 'the pad guide lists no button for melee, armour plate or air strike' was wrong for two of three (the plate is in the wheel; both bumpers arm the air strike, v27.25). The real gap is melee only (Y only held = finisher; meleeStrike only from the V key). Now asks how a pad player swings the crowbar; pick b -> a | 132 -> 118 words
14 -> DROPPED | already shipped: player 2's run-over card (v30.98), the stray welcome window (v31.11), the player 2 window following the last input device (v30.77), seats named player 1 and 2 (v30.88); the P1/P2 helper is still on the rest, and the leftovers are asked one by one (new 10, 11, 12). Source: git log 10-18 and console/notes/p1p2-consistency.md
15 -> 12 | FIXED (length/wording) | 3 words shorter | 111 -> 108 words
16 -> 13 | FIXED (length/wording) | cut the 'looks like a button' clause (kept 'lime is also the selected row and the main button') | 133 -> 120 words
17 -> 14 | FIXED (length/wording) | example rows cut to damage taken, auto-fire for player 2, superhot; 'raid stays the same' -> 'board must be fair' | 142 -> 119 words
18 -> 15 | FIXED | 'enemy numbers' -> 'how many pillagers and machines' (his vocabulary: never enemy); shortened | 131 -> 115 words
19 -> 16 | FIXED | removed the option where the gun fires by itself at the nearest enemy (breaks his no-aim-assist ruling) and 'no kid switch'; 'a third' -> 30 percent (EASY_MUL 0.7); the 'more ammo and heals' option became one free medkit | 137 -> 117 words
20 -> 17 | FIXED | key counts corrected: 9 gun classes sit on keys 1 to 8 and 0 and key 9 is inert (v29.15), so nine gun keys, not 'keys 1 to 9 and 0'; helper-read sentence cut | 134 -> 118 words
21 -> 18 | FIXED | dropped the claim that his orders 'only mention putting a new gun in the next open slot'; option a now matches his 10/11 order exactly (the better copy takes the key when the old one is put away) | 140 -> 119 words
22 -> 19 | FIXED (length/wording) | one word shorter | 121 -> 119 words
23 -> 20 | FIXED | contradiction removed: the old text said the tripwire 'hurts nobody' and option a said it 'hurts whoever sets it off'; verified in the code that tripwire and air strike do no player damage at all, so only grenade and barrel can hurt you; question text shortened | 132 -> 117 words
24 -> 21 | FIXED (length/wording) | option a shortened | 132 -> 120 words
25 -> 22 | OK | 120 -> 120 words
26 -> 23 | FIXED (length/wording) | shortened | 127 -> 118 words
27 -> DROPPED | premise false: the cursor already carries a magazine ring (and the combo ring and team ring), and his survey answer q17 'also keep/add ring at the cursor' is what shipped ('a magazine ring on the crosshair'); what the ring shows is a look matter. Source: dark_raiders.html about lines 40394, 49077, 61234
28 -> 24 | FIXED | 'nothing says where the team score shows' replaced by a fact: today a teammate row sits with the kill feed and the picture has no place for it | 130 -> 114 words
29 -> 25 | FIXED (length/wording) | option b shortened | 124 -> 118 words
30 -> 26 | OK | 110 -> 110 words
31 -> 27 | FIXED (length/wording) | shortened ('scripted' for 'staged'; '4K TV' cut) | 136 -> 119 words
32 -> 28 | FIXED (length/wording) | shortened | 125 -> 119 words
33 -> 29 | FIXED | status brought current: the shortcut was fixed this afternoon (first try at 15:36 opened nothing) and now opens both windows on the waiting screen; the old 'still opens the plain title screen' claim removed (party.cfg URL_OPTIONS=1) | 118 -> 109 words
34 -> 30 | FIXED | link claim made exact: while linking the game asks outside servers for addresses and waits up to 5 seconds (NET_WAIT_ICE=5000), about 6 seconds in all; on one PC it should link with no internet but untried in the room | 109 -> 119 words
35 -> 31 | FIXED | kick list completed to the five guns that kick more (original named only two); 'about 4 pixels at 1080p' cut | 113 -> 111 words
36 -> 32 | FIXED (length/wording) | 'your answer 70' -> 'your round 1 answer 70' (answer 70: no tutorial prompts) | 101 -> 103 words
37 -> 33 | FIXED | added 'skip this if you have not tried the pad seat yet' (no record of a pad-seat test) | 122 -> 118 words
38 -> 34 | FIXED | same: conditional, 'skip this if you played both windows yourself' | 117 -> 117 words
39 -> 35 | FIXED (length/wording) | shortened | 128 -> 115 words
40 -> 36 | FIXED (length/wording) | dropped the 'how big its entrance should be' clause | 112 -> 105 words
41 -> 37 | FIXED | dropped 'a day and a half before the lock' (not exact) and 'look work is the biggest thing still open' | 132 -> 115 words
42 -> 38 | OK | 106 -> 106 words
43 -> 39 | OK | 98 -> 98 words
44 -> 40 | FIXED | version facts fixed: newest stable is 29.09 (tools/handoff/stable-status.txt) and the game is past version 31 (was 'you are playing 30.73'); 'three things' count and the 'nobody is assigned to switch the shortcut' sentence cut | 130 -> 115 words
45 -> 41 | FIXED (length/wording) | shortened; option a 'nothing overwrites' | 129 -> 112 words
46 -> 42 | FIXED | 'your notes this afternoon name version 30.73' -> 'your notes today came from versions 30.57 and 30.73' (both feedback files exist) | 129 -> 116 words
47 -> 43 | FIXED (length/wording) | shortened ('a finished full test run' -> 'a full test run') | 135 -> 119 words
48 -> 44 | FIXED | 'while any test is red' -> 'newly red' (the baseline of 84 known-red tests exists; the list file does not); 'many days behind' cut | 140 -> 111 words
49 -> 45 | FIXED (length/wording) | shortened | 133 -> 117 words
50 -> 46 | FIXED | dropped the unverified date 'running out on 10/22'; the 'no paid extra usage was about your plan' note moved into option b | 144 -> 115 words
51 -> 47 | FIXED (length/wording) | shortened; first sentence and the parenthesis cut | 140 -> 120 words
52 -> 48 | FIXED | batch names made plain (audio picks, screen-and-meta picks) and 'two visuals picks are in' added in place of 'the raid screen is being redesigned now' | 130 -> 118 words
53 -> 49 | FIXED | screen numbers updated to the current accept.json (59 scored: 1 at 1, 38 at 2, 20 at 3, 0 at 4); the unverified 'other 50' removed; the six guest screens listed | 141 -> 120 words
54 -> 50 | FIXED (length/wording) | shortened; the waiting-screen parenthesis cut | 132 -> 120 words
55 -> 51 | FIXED (length/wording) | 'about 4 cents a call' cut; shortened | 134 -> 120 words
56 -> 52 | FIXED (length/wording) | cut the sentence about other restyled cards | 137 -> 119 words
57 -> 53 | FIXED (length/wording) | cut 'buttons are not covered by answer 8' | 123 -> 115 words
58 -> 54 | FIXED (length/wording) | shortened | 126 -> 115 words
59 -> 55 | OK | 114 -> 114 words
60 -> 56 | OK | 103 -> 103 words
61 -> 57 | FIXED (length/wording) | dropped 'the helpers' own key expires 11-16' (not part of the question) | 128 -> 120 words
62 -> 58 | FIXED | numbers brought current (19% used against a line of 8% at 17:21 on 10/18); the unverified 'so the plan helpers paused' and helper names (e and f) removed | 130 -> 119 words
63 -> 59 | OK | 118 -> 118 words
64 -> 60 | FIXED | 'local AI code review' -> 'code review' (vocabulary); shortened | 143 -> 117 words
65 -> 61 | FIXED (length/wording) | plain file names (party-stop, party-start) | 126 -> 119 words
66 -> 62 | FIXED (length/wording) | moved the jam sentence (13:32 to about 15:00) into the middle; 'nothing exists yet' cut | 134 -> 118 words
67 -> 63 | FIXED | 'a leftover lock file' -> 'an old busy marker file' (plain, and what the repair removes); shortened | 137 -> 112 words
68 -> 64 | FIXED | now says the notes from 15:42 to 15:47 were all acted on by 17:16 (only because I read them); the cross-reference points at new 47 | 132 -> 119 words
69 -> 65 | FIXED | 'a helper saw a password box' -> 'it asked me for a password' (round 1 question 89 text: 'I opened the page the way a stranger would and it asks for a password', sweep-3 line 590); pick c -> a | 126 -> 117 words
70 -> 66 | FIXED (length/wording) | cut 'the ship script says every ship pushes to GitHub and itch' | 128 -> 117 words
71 -> 67 | FIXED (length/wording) | shortened; the round 2 question 31 bridge kept | 130 -> 117 words
72 -> 68 | FIXED | dropped the version numbers '0.15 behind / stops at 0.16' (code words); says the version stamp must be kept near current by hand or publishing stops, and is close to the limit now | 129 -> 111 words
73 -> 69 | FIXED | counts brought current: git at 17:50 shows 205 versions on 10/18, 18 of them only 'polish pass' lines; now says '200-plus' and 'about 18' | 96 -> 98 words
74 -> 70 | FIXED (length/wording) | shortened | 131 -> 118 words
75 -> 71 | FIXED | 'a kill costs 50 percent' -> 'dying (KIA)' (his 10/15 wording); pick a -> b (his 10/12 order was made for exactly this case; the halving orders are about how a run ends) | 140 -> 120 words
76 -> 72 | FIXED | dropped the false claim that the screen shows the Forge price in dollars (it shows points); shortened | 141 -> 118 words
77 -> 73 | FIXED | 'text size makes 20 rows barely fit' replaced by what the game does today (two columns of ten); round 2 question 46 bridge dropped for length | 131 -> 117 words
78 -> 74 | FIXED | question made direct; 'a guest can bank a high score by ending' cut; round 2 question 23 bridge kept | 141 -> 120 words
79 -> 75 | FIXED (length/wording) | reworded as the other half of the round 1 question; no change of facts | 112 -> 110 words
80 -> DROPPED | already answered: his 10/18 answer 70 'No tutorial prompts. The game must be completely self-explanatory.' (given to a question that named this tip). Source: memory pillagers-answers-1-78-2026-10-18.md, answer 70
81 -> 76 | FIXED | 'AI crews' -> 'other crews' (his vocabulary); shortened | 132 -> 118 words
82 -> 77 | FIXED (length/wording) | 'ten-step' dropped; levels 2 to 4; shortened | 122 -> 116 words
83 -> 78 | OK | 103 -> 103 words
84 -> 79 | FIXED (length/wording) | shortened; options kept | 132 -> 117 words
85 -> DROPPED | already settled by the picture survey: his answer q13 C (title: a 1 or 2 player switch and three rows Career, Arcade demo, Saves). Source: tools/handoff/menu-survey/answers-2026-10-18.txt and survey.json q13; the leftover (which row is highlighted first) is new 80
86 -> 80 | FIXED | REWRITTEN to the real clash: survey q13 C highlights Career in the sample picture, his 10/12 ruling says the title highlights DEMO first; options rebuilt (Career / Demo / last played); pick b kept | 99 -> 117 words
87 -> 81 | OK | 113 -> 113 words
88 -> 82 | FIXED (length/wording) | shortened; printed-capitals reason kept | 137 -> 120 words
89 -> 83 | OK | 83 -> 83 words
90 -> 84 | FIXED (length/wording) | shortened; 'pillbox' example and the question's bracket cut | 132 -> 120 words
91 -> 85 | FIXED | 'your genre callout list' was my own list, not his; replaced by the plain fact 'squad appears nowhere' | 118 -> 110 words
92 -> 86 | OK | 89 -> 89 words
93 -> 87 | OK | 110 -> 110 words
94 -> 88 | FIXED (length/wording) | dropped the stale 'in-game gear rules still say keys 1 to 4' line (goes to a helper) | 128 -> 114 words
95 -> 89 | FIXED (length/wording) | wording only, no change of facts | 112 -> 105 words
96 -> 90 | FIXED | dropped 'the party-day stop list says the runner restarts itself, which is not true' (overstated; it says the runner restarts within 15 minutes once party-start has run); file names plain | 119 -> 101 words
97 -> 91 | FIXED (length/wording) | complaint quoted in his words; stops list shortened to 'seven separate stops' | 131 -> 120 words
98 -> 92 | FIXED (length/wording) | shortened | 123 -> 120 words
99 -> 93 | FIXED | dropped 'on 10/18 you ruled those wait until after the party' (he moved faster tests and file splitting after the party; removing the disabled maps was not mentioned) | 101 -> 102 words
100 -> 94 | FIXED | dropped 'four helper jobs failed ten times in a row' (they stalled waiting on his word over several open points); now says the helper is stuck waiting for his word | 125 -> 119 words

THE 8 CORRECTIONS (Before round 2: corrections)

C1 OK (verified): round 2 Q7 assumes instant start; his survey pick is two ready cards that start when both are ready (new 4 decides it).
C2 FIXED: round 2 Q9 premise verified (controls card removed in v30.50, arcadeCardOn returns 0); the word 'raider' in my own correction text changed to 'player' (round 2 used 'raider drops in').
C3 OK (verified): round 2 Q10 assumes a video clip; his 10/18 answer 54 is 'No attract clip. Use the live map.'
C4 OK (verified): round 2 Q32 option b and Q34 break his 10/18 answer 37 'No new people before the party.'
C5 OK (verified): round 2 Q80 puts performance fourth; his 10/18 answer 27 puts stutter or harsh sound first.
C6 OK (verified): round 2 Q81 calls the locked copy 'stable'; stable is v29.09 (tools/handoff/stable-status.txt) and the Thursday copy does not exist; refs updated to new 40 and 41.
C7 OK (verified): round 2 Q82 credit; about $50 of $198 by estimate; refs updated to new 46, 56 and 57.
C8 OK (verified): round 2 R3: the first two extras shipped in v30.34 (rise from underground, light shafts); only slow motion open.

OLD NUMBER -> NEW NUMBER

1=1, 2=2, 3=3, 4=4, 5=5, 6=dropped, 7=6, 8=7, 9=8, 10=9, 11=dropped, 12=10, 13=11, 14=dropped, 15=12, 16=13, 17=14, 18=15, 19=16, 20=17, 21=18, 22=19, 23=20, 24=21, 25=22, 26=23, 27=dropped, 28=24, 29=25, 30=26, 31=27, 32=28, 33=29, 34=30, 35=31, 36=32, 37=33, 38=34, 39=35, 40=36, 41=37, 42=38, 43=39, 44=40, 45=41, 46=42, 47=43, 48=44, 49=45, 50=46, 51=47, 52=48, 53=49, 54=50, 55=51, 56=52, 57=53, 58=54, 59=55, 60=56, 61=57, 62=58, 63=59, 64=60, 65=61, 66=62, 67=63, 68=64, 69=65, 70=66, 71=67, 72=68, 73=69, 74=70, 75=71, 76=72, 77=73, 78=74, 79=75, 80=dropped, 81=76, 82=77, 83=78, 84=79, 85=dropped, 86=80, 87=81, 88=82, 89=83, 90=84, 91=85, 92=86, 93=87, 94=88, 95=89, 96=90, 97=91, 98=92, 99=93, 100=94

Note: helper-fixes.md still refers to the OLD numbers (for example 'question 100' = new 94, 'Q7' and 'Q43' there are round 1 answers). I did not edit it, as told.

WORST DEFECTS FOUND

1. Old 11 (heal): said the keyboard still heals on one tap of H. False since the item wheel (v26.27/28); dropped.
2. Old 27 (ammo ring): said the cursor would get a fourth ring. A magazine ring already ships and he picked 'keep it'; dropped.
3. Old 13 (pad layout): said the pad guide has no button for the armour plate or air strike. Both exist; only melee is missing. Rewritten.
4. Old 14, 33, 68, 73 and others: stale (shipped or fixed since the draft); dropped or brought current.
5. Old 1 to 3, 37 and 38: asked about a two-TV test that may not have happened; made conditional with a skip line.
6. Old 20 (keys): 'keys 1 to 9 and 0' was wrong; nine gun keys, key 9 inert.
7. Old 23 (own explosives): the tripwire 'hurts nobody' and 'hurts whoever sets it off' in the same question.
8. Old 76 (Forge): said the screen shows the price in dollars; it shows points.
9. Old 9, 75, 91, 99, 100: misdated or overstated quotes (combo ring and events dates; 'a kill costs 50 percent' was KIA; 'your genre callout list' was my own; the 10/18 ruling on the disabled maps; 'failed ten times').
10. Old 19 (easy mode): an option made the gun aim by itself, which breaks his no-aim-assist ruling.
11. Old 72 and 96: code words and numbers (0.15 / 0.16) and an overstated 'which is not true' removed.

COULD NOT VERIFY

- Whether the first real two-window run happened (I have no record of it); new 1, 2, 3, 33, 34 are conditional for that reason.
- The real Console balance (about $50 is my estimate; only the owner can read it).
- Whether browser pad re-numbering after a wireless reconnect can swap the players (old 6 dropped because the code handles the common cases; real pads not tested here).
- The itch page being private: round 1 Q89 text says it asked for a password; only he can confirm.
- Stale lines in the game for helpers (not questions): Settings key list 'H heal (tap), armour plate (hold)', the HUD hint 'HEAL', GEARRULES 'keys 1 to 4', the test sheet text about the controls card.
- I did not run the game, a browser or any helper (as told); every game claim is from grep, code comments and git log at HEAD (about v31.11).
