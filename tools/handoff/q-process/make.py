# Writes questions.json for the 10-19 process questions page (his ask: "ask me 100 questions about this whole process
# that I can answer that would potentially make this more efficient for you/better work product"). Each row:
# (question, about, [options], pick, why). Ids are p-1 .. p-100 in this order.
import json, os
G = []
def g(heading, rows): G.append((heading, rows))

g('How you hear from me', [
 ('When you sit down after time away, what should my first message give you?', '',
  ['Three lines: what shipped, what broke, what needs you', 'A full report, area by area', 'Only what needs you'], 'a', 'fastest to read; details on request.'),
 ('Where do you mostly read my messages?', 'On a phone I keep lines shorter and put links where they open on the phone.',
  ['At the PC', 'On my phone', 'Both'], 'c', 'I keep them phone-short either way.'),
 ('Should I send your phone a notification when something truly needs you?', 'For example a sign-in, or a step only you can do that is holding work up.',
  ['Yes, only for those', 'Yes, and also when a big update ships', 'No notifications'], 'a', 'a ping only when waiting would cost hours.'),
 ('When many small updates ship overnight, how should the report list them?', 'Last night the helpers shipped 4 updates in 30 minutes.',
  ['Grouped by area (raid HUD, party screens, pads), one line each', 'Only the 3 to 5 that matter to you', 'Every update, one line each'], 'b', 'bottom line first.'),
 ('Do you want before and after pictures in reports?', '',
  ['Yes, for anything you can see that changed', 'Only when I want your opinion', 'No, I look in the game'], 'b', 'pictures cost your time; I send them when your eye decides something.'),
 ('How do you like to answer questions?', '',
  ['Click pages like this one', 'In chat', 'Picture surveys for anything visual, click pages for the rest'], 'c', 'you said the picture surveys worked well.'),
 ('How many questions at once is right?', '',
  ['10 to 20', 'Up to 50', '100 is fine'], 'a', 'small rounds get answered sooner.'),
 ('How often should a question page reach you?', '',
  ['One page a week', 'Every 2 or 3 days', 'Only when a decision is truly stuck'], 'b', 'often enough that nothing waits long.'),
 ('When something I said I would do slips, how do you want to hear it?', '',
  ['In the next report, one line with the new plan', 'Right away', 'Only if it touches the party'], 'a', ''),
 ('Is the "Next:" line at the end of my messages working for you?', '',
  ['Yes, keep it as is', 'Make it say only what you need to do, or "nothing for you"', 'Make it list my next 2 or 3 steps'], 'a', ''),
])

g('Your playtests', [
 ('Where will you play new builds during the week?', 'Pillagers no longer runs on the main PC. The main PC copy (the party plan) works for weekday play too: your pads, your graphics card, the same address as before.',
  ['The main PC copy, refreshed when I say a build is worth playing', 'Inside the VM window, keyboard and mouse', 'Both'], 'a', 'it is the real party setup, so every test is also a rehearsal.'),
 ('How often do you expect to play a new build before 10/30?', '',
  ['Every day', 'Every 2 or 3 days', 'Once or twice'], 'b', ''),
 ('How long is a typical play session?', '',
  ['Under 20 minutes', '20 to 60 minutes', 'Over an hour'], 'b', ''),
 ('How should your in-game notes and run reports reach me now?', 'The copy saves them on the main PC. The main PC link can only run jobs you approved; fetching your notes would be a new one, and picking a here is that approval.',
  ['Add a "fetch my notes" job to the main PC link', 'I drop them in the shared folder myself', 'I paste them in chat'], 'a', 'no work for you after each session.'),
 ('With each build worth playing, do you want a short "try this" list?', '3 to 5 things to look at, in plain words.',
  ['Yes', 'No, I play blind and tell you what I notice', 'Only for big changes'], 'a', ''),
 ('After a session, would a 1-minute click page of feel questions help?', 'Fun, clear, annoying, broken: a few taps instead of typing.',
  ['Yes', 'No, I type my own notes', 'Only after the rehearsal and the party'], 'a', ''),
 ('Do you use the in-game note key while playing?', 'A note taken in the game lands with the exact moment and screen, which is the fastest path to a fix.',
  ['Yes, often', 'Sometimes', 'Rarely, I forget it exists'], 'b', ''),
 ('When you find a bug, what is easiest for you?', '',
  ['The in-game note key', 'A phone photo of the screen, sent in chat', 'Describing it in chat'], 'a', ''),
 ('When you and your son disagree about something in the game, whose call wins?', '',
  ['Mine', 'His on fun and clarity, mine on everything else', 'We tell you case by case'], 'b', 'he is the kind of player the party is for.'),
 ('If something feels off but is hard to describe, could you record a short clip?', 'Windows can record the screen with Win + Alt + R.',
  ['Yes', 'No', 'Only for big problems'], 'c', ''),
])

g('What I decide on my own', [
 ('If a feature keeps breaking and is not in your orders, may I switch it off until after the party and tell you after?', '',
  ['Yes', 'Ask me first', 'Never switch anything off'], 'a', 'a steady party matters more.'),
 ('When the screen judge and your style guide disagree, which wins?', '',
  ['The style guide (your rules)', 'The judge\'s score', 'Show me both with pictures'], 'a', ''),
 ('May I use free art, sound and music with open licences, with credits listed?', 'For example Kenney, OpenGameArt or Freesound.',
  ['Yes', 'Only as placeholders until something better', 'No, keep it all made here'], 'a', ''),
 ('If a paid tool or service would clearly speed things up, do you want the pitch?', 'I would never buy anything myself; you decide each one.',
  ['Yes, any time it clearly pays off', 'Only under about $20 a month', 'No paid extras'], 'a', ''),
 ('When your notes are unclear, what should I do?', '',
  ['Take my best guess, ship it, tell you how I read it', 'Ask first and wait', 'Guess now and ask in the next round'], 'c', 'no waiting, and you can still correct me.'),
 ('When a helper finishes early, may it start polish that is not on your list?', 'Spacing, contrast, text that clips: small fixes, never new features.',
  ['Yes, polish is always welcome', 'Only fixes the screen judge asked for', 'No, wait for orders'], 'b', 'judge findings are evidence, not invention.'),
 ('May I reword on-screen text (still lower case and short) when clarity calls for it?', '',
  ['Yes', 'Only labels, not the names of things', 'Ask first'], 'b', ''),
 ('If a change from your notes makes something else worse, what do you want?', '',
  ['I keep the better of the two and tell you', 'Undo it and ask', 'Ship both and you choose'], 'a', ''),
 ('May I cut a step guests do not need (for example a confirm screen) to make the party flow faster?', '',
  ['Yes, tell me after', 'Show me first', 'No'], 'b', 'it changes what guests see, so you see it first.'),
 ('When two of your older answers clash, how should I settle it?', '',
  ['The newest answer wins', 'Ask you once, quoting both', 'Whichever fits the party best'], 'a', ''),
])

g('Your plans and the helpers', [
 ('Do you use this same Claude plan for other things?', 'Your work, or the other two Pillagers projects. The helpers stop at 85% of each 5-hour window today.',
  ['Yes, a lot', 'A little', 'No, Pillagers has it to itself'], 'b', ''),
 ('While you are at the PC, how much of each 5-hour window should the helpers leave for you?', '',
  ['15% (as now)', '30%', '50%'], 'a', ''),
 ('And while you are away or asleep?', '',
  ['Let them use up to 95%', 'Keep the 85% stop', 'The same as when I am here'], 'a', 'nothing else needs it at night.'),
 ('Your Console credit resets to $200 on Nov 1. What should it go to first?', '',
  ['More helper runs right away', 'The screen judge (keeps your plan free for helpers)', 'Spread it evenly through Thanksgiving'], 'c', 'the release crunch will want some left.'),
 ('Do you want a cost line in each morning report?', 'Plan usage this week and Console spend.',
  ['Yes, one line', 'Only when something is unusual', 'No'], 'b', ''),
 ('ChatGPT (Codex) does one helper\'s work on your ChatGPT plan. Does that plan have room to use harder?', 'It costs no Claude usage.',
  ['Yes, push it', 'Keep it as now', 'I need it for other things, use it less'], 'a', ''),
 ('Would you pay for a second plan or seat if it clearly doubled the helpers?', 'Only a pitch with real numbers; nothing is bought without you.',
  ['Yes, pitch it', 'Maybe after the party', 'No'], 'b', ''),
 ('The local AI rests during your usual PC hours (6-9, 1-4, 7-10) so your graphics card stays free. Still right now the main PC is your work PC?', '',
  ['Yes', 'It may run any time unless I am gaming', 'Change the hours (write them)'], 'a', ''),
 ('Do you play other games on the main PC?', 'The VM borrows most of the graphics card. If you game, I would pause the VM\'s camera work while you play.',
  ['Yes, often', 'Sometimes', 'Rarely'], 'b', ''),
 ('Until 10/30, should helpers work only on the party, or also on release prep in the background?', 'Release prep means things like the store page and the feedback collector, never game features after the 10/26 cutoff.',
  ['Party only', 'Mostly party, a little release prep', 'Whatever is next on the list'], 'b', ''),
])

g('The VM and the main PC', [
 ('Will you leave the Claude window in the VM open all the time?', 'My half-hourly check-ins live in that window. When it closes they stop until you say "check in".',
  ['Yes', 'Mostly, I sometimes close it', 'I close it when I am done'], 'a', ''),
 ('Windows updates in the VM can restart it at a bad moment. What do you want?', 'The VM now signs back in by itself, but an update mid-ship can still cost an hour.',
  ['Pause VM updates until after 10/30 (you click it)', 'Leave them on', 'Install them only when I am around'], 'a', ''),
 ('Same for the main PC around the party?', '',
  ['Pause updates until after 10/30', 'Leave them on', 'I will handle it'], 'a', 'an update on party night would hurt most.'),
 ('More memory is the biggest speed-up: today only 1 or 2 of the 3 helpers fit, and the crash robot keeps waiting. Which would you consider?', 'The main PC has 32 GB. With 64 GB the VM could have about 24 GB: every helper and the robot at once.',
  ['Close programs on the main PC so the VM can have 12 GB', 'Add memory to the main PC (I can price it)', 'Neither, keep 10 GB'], 'b', 'the one change that frees everything else.'),
 ('Would you be OK with the VM taking more memory only at night, back to normal by morning?', 'Only if I can make it safe; you would approve the setup once.',
  ['Yes', 'No, keep it fixed'], 'a', ''),
 ('Does the main PC stay on all the time?', 'When the main PC is off, the VM is off too.',
  ['It runs 24/7', 'I restart it now and then', 'I shut it down at night'], 'a', ''),
 ('Should the VM keep a weekly safety snapshot you can roll back to?', 'A Hyper-V checkpoint, set up once on the main PC. GitHub already keeps the game; this would keep the VM setup itself.',
  ['Yes, set it up', 'No, GitHub is enough'], 'a', ''),
 ('If the VM breaks badly before the party, what is the plan?', '',
  ['The main PC copy for the party, fix the VM after', 'Rebuild the VM right away', 'Bring Pillagers back to the main PC'], 'a', ''),
 ('While you play the copy on the main PC, should the VM go light?', 'Fewer helpers and no camera work, so nothing competes with your game.',
  ['Yes', 'No, it does not bother me'], 'a', ''),
 ('On rehearsal and party night, should the VM stop all work?', 'The party runs on the main PC; the VM shares its graphics card and processor.',
  ['Yes, pause everything that evening', 'Keep it light', 'Keep it running'], 'a', 'zero risk of a stutter from my side.'),
])

g('Quality and the look', [
 ('Would you grade a few screens yourself now and then?', 'A click page with pictures, 1 to 5. Your scores teach the screen judge your taste.',
  ['Yes, weekly', 'Yes, only before the party', 'No, trust the judge'], 'a', ''),
 ('Besides ARC Raiders and Fortnite menus, which games should the judge measure against?', '',
  ['Keep those two', 'Add Zero Sievert', 'Add others (name them)'], 'b', 'you named it as part of the feel.'),
 ('For a new screen design, do you want to pick from mockups first?', '',
  ['Yes, 2 or 3 mockups for every new screen', 'Only for big screens (title, pre-raid, HUD)', 'No, build it and show me'], 'b', ''),
 ('When the judge scores low a screen you like, what should happen?', '',
  ['Your taste wins, keep it', 'Improve it anyway', 'Ask me with pictures'], 'c', ''),
 ('Where do you judge the look: the TV or your monitor?', '',
  ['The TV', 'The monitor', 'Both'], 'a', 'the party is on the TVs.'),
 ('Should helpers also polish the Career screens, or only the party screens until 10/30?', '',
  ['Party screens only', 'Both', 'Party first, Career after 10/26'], 'c', ''),
 ('I cannot hear. How should sound changes be checked?', '',
  ['You listen to a short list after each sound update', 'Trust the loudness checks', 'Hold sound changes until after the party'], 'a', ''),
 ('Should the game show a small version number during the party?', 'It ties a bug report to the exact build.',
  ['Yes, small, in a corner', 'No, hide it at the party', 'Only inside a menu'], 'c', ''),
 ('Options like bigger text or colourblind-friendly markers: when?', '',
  ['Before Thanksgiving', 'Later', 'Not needed'], 'b', ''),
 ('When the judge passes a screen, should helpers stop touching it?', '',
  ['Yes, freeze it unless you complain', 'Keep polishing if time allows', 'Freeze it only after you approve it'], 'a', ''),
])

g('Party night', [
 ('About how many guests will play?', '',
  ['Under 6', '6 to 12', 'More than 12'], 'b', ''),
 ('Should the board be cleared after the rehearsal so the party starts fresh?', '',
  ['Yes', 'No, rehearsal scores are the ones to beat'], 'a', ''),
 ('Who are the guests mostly?', '',
  ['Kids', 'Adults who game', 'Adults who rarely game', 'A real mix'], 'd', ''),
 ('What would make the night a success to you?', '',
  ['People keep coming back to play', 'Nobody needs help to start', 'No crash or stutter all night', 'Honest feedback'], 'a', ''),
 ('Will you host the game most of the night, or should it run itself?', '',
  ['I host it', 'It runs itself, I check in now and then', 'Someone else hosts'], 'b', ''),
 ('May the party save each run\'s report on the main PC for me?', 'Run reports hold no personal details; they show where guests died, quit or got stuck.',
  ['Yes', 'Yes, and screen recordings too', 'No recording'], 'a', ''),
 ('After the party, how do you want to tell me what happened?', '',
  ['A click page of questions I write from the run reports', 'Tell me in chat in your own words', 'Both'], 'c', ''),
 ('Who plays at the rehearsal on Wed 10/28?', '',
  ['Me alone with two pads', 'Me and my son', 'The whole family'], 'b', ''),
 ('If something breaks mid-party, what is the plan?', 'The copy folder can keep the previous good build as a spare.',
  ['Restart the game and carry on', 'Switch to the spare build', 'Stop the game'], 'b', ''),
 ('Will both TVs and pads be set up for the rehearsal, so it is the real setup?', '',
  ['Yes', 'No, the rehearsal is on my desk', 'Not sure yet'], 'a', ''),
])

g('The Thanksgiving release', [
 ('Where should the release live?', 'itch.io can go live the same day. Steam needs a $100 fee, a store page up some weeks ahead and a review.',
  ['itch.io', 'itch.io now, Steam later', 'Steam at Thanksgiving'], 'b', ''),
 ('Price?', '',
  ['Free', 'Pay what you want', 'A fixed price (write it)'], 'b', ''),
 ('Who plays between the party and Thanksgiving?', '',
  ['Friends and family, private link', 'A public page right away', 'No one until release'], 'a', ''),
 ('The feedback collector (friends\' run reports reach me automatically) still waits on a free Cloudflare setup on your side. Do it before friends play?', 'About 15 minutes with my steps.',
  ['Yes, walk me through it', 'Later', 'Skip it, friends send files by hand'], 'a', ''),
 ('The store page text: who writes it?', '',
  ['I write a tagline and page, you pick', 'You write it', 'Keep it bare'], 'a', ''),
 ('Should the release include Career mode, or only the 2-player couch mode?', 'You ruled that the couch mode leads the release.',
  ['Both, couch mode up front', 'Couch mode first, Career later', 'Career first'], 'a', ''),
 ('A trailer or moving picture for the page?', '',
  ['Yes, the helpers make one from game captures', 'No', 'I will make it'], 'a', ''),
 ('Do you want a public devlog (short posts as we go)?', '',
  ['Yes, I post what you draft', 'No'], 'b', ''),
 ('Should saves move between computers (an export and import code)?', '',
  ['Yes, before release', 'Later', 'No'], 'b', ''),
 ('After Thanksgiving, what comes next?', '',
  ['More content (maps, weapons, enemies)', 'Online co-op', 'Polish only, then rest'], 'a', ''),
])

g('Making me faster', [
 ('Many small updates a day, or one build a day worth playing?', '',
  ['Many small (as now)', 'Fewer, bigger updates', 'Small updates, plus one "worth playing" build a day'], 'c', ''),
 ('When I need a decision, do you want my recommendation first?', '',
  ['Yes, my pick first (as now)', 'No, show the options without a pick'], 'a', ''),
 ('Do you want a weekly plain-words summary: what got better, what is next?', '',
  ['Yes, on Sundays', 'No'], 'a', 'Sunday is your busiest day at the PC.'),
 ('Are there times you want no messages from me?', '',
  ['No, any time', 'Quiet on weekends', 'Quiet in the evenings'], 'a', ''),
 ('When one of your rules costs a lot of time for little gain, may I propose dropping it?', '',
  ['Yes, in a question round', 'No, the rules stand'], 'a', ''),
 ('Would a small page listing only your open steps help?', 'Like tonight\'s list: one place that always shows what is waiting on you.',
  ['Yes', 'No, the chat is enough'], 'a', ''),
 ('The game\'s GitHub page is public. Keep it public after release?', 'The party copy downloads from it without a sign-in.',
  ['Yes', 'Make it private before release'], 'a', ''),
 ('Should I put the rehearsal (Wed 10/28), the lock (Thu 10/29) and the party (Fri 10/30) on your Google Calendar?', '',
  ['Yes', 'No'], 'a', ''),
 ('Would you like the morning report by email too?', '',
  ['Yes, to me', 'No, chat is enough'], 'b', ''),
 ('Do you keep game ideas anywhere I should read?', '',
  ['Yes, in Notion', 'Yes, in Google Docs or Drive', 'No, they come to you in chat'], 'c', ''),
])

g('The bigger picture', [
 ('What frustrates you most about how we work today?', '',
  ['Chasing problems I should have caught', 'Too much reading', 'Too many questions', 'Progress I cannot see'], '', 'only you know this one.'),
 ('What do you want more of?', '',
  ['Visible game changes', 'Fewer interruptions', 'Clearer explanations', 'More pictures'], '', 'only you know this one.'),
 ('How do you judge progress day to day?', '',
  ['What I see when I play', 'The report', 'The number of updates'], 'a', ''),
 ('When can I call something done?', '',
  ['It passed the tests and the pictures', 'You played it', 'A friend played it'], 'a', 'you play the important ones anyway.'),
 ('Close to the party, what is your default for a risky change?', '',
  ['Leave it until after the party', 'Change it if the tests pass', 'Ask me'], 'a', ''),
 ('Should I keep a page of ideas the helpers and I have, for you to pick from after the party?', '',
  ['Yes, one page with pictures', 'No, only my ideas count'], 'a', ''),
 ('Would a fixed weekly "play with me" slot help, with a build and questions ready for it?', '',
  ['Yes, Sunday afternoon', 'Yes, another time (write it)', 'No'], 'a', 'Sunday afternoon is your busiest time at the PC.'),
 ('How much do you want to know about how the helpers work?', '',
  ['Nothing, results only', 'A little, in plain words', 'A lot'], 'a', ''),
 ('Is there anything I do today that you want me to stop?', '',
  ['No', 'Yes (write it)'], '', 'only you know this one.'),
 ('Anything you wish I had asked?', '',
  ['No', 'Yes (write it)'], '', ''),
])

out, n = [], 0
for heading, rows in G:
    assert len(rows) == 10, heading
    for (q, about, opts, pick, why) in rows:
        n += 1
        out.append({'id': 'p-%d' % n, 'label': str(n), 'group': heading, 'question': q, 'about': about,
                    'options': [{'key': 'abcd'[i], 'text': t} for i, t in enumerate(opts)], 'pick': pick, 'why': why})
for x in out:
    assert x['pick'] in ('', ) + tuple(o['key'] for o in x['options']), x['id']
    for s in [x['question'], x['about'], x['why']] + [o['text'] for o in x['options']]:
        assert '—' not in s and '–' not in s, x['id']
here = os.path.dirname(os.path.abspath(__file__))
json.dump(out, open(os.path.join(here, 'questions.json'), 'w', encoding='utf-8'), indent=1, ensure_ascii=False)
print('questions', len(out))
