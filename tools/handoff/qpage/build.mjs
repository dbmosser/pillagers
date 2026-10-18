// Builds the open-questions click page from the round 2 and round 3 question files.
// node build.mjs  ->  writes index.html next to this script
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
const here = path.dirname(fileURLToPath(import.meta.url));
const H = 'C:/claudecode/dark raiders/tools/handoff';
const r2 = JSON.parse(fs.readFileSync(H + '/q100/questions.json', 'utf8'));
const r3 = JSON.parse(fs.readFileSync(H + '/q-round3/questions.json', 'utf8'));

// The eight round 2 corrections from the round 3 file, written for this page. [[id]] becomes a link.
const FIX = {
  '7': 'This assumes the run starts the moment anyone presses a button. In the picture survey you picked "start when both players are ready", which is a different flow. Answer [[r3-04]] first; if you choose "wait until both are ready", skip this one.',
  '9': 'The controls card the game showed for a few seconds as each player arrived was removed on 10/18 after your no-tutorial answer (the how-to page on the waiting screen and the F1 list still exist). Read this as: the on-screen card is gone, so a printed card is the only reminder.',
  '10': 'This assumes a video clip. On 10/18 you ruled "no attract clip, use the live map", so skip it: the screen shows the live map instead.',
  '32': 'On 10/18 you ruled "no new people before the party", so option b is not available.',
  '34': 'On 10/18 you ruled "no new people before the party". Skip this unless you want to change that ruling.',
  '80': 'This puts performance fourth. Your own 10/18 list puts stutter or harsh sound first, then crash or freeze, then player 2\'s pad or window failing, then guests not knowing how to start. If you agree with your list, pick c and write "my 10/18 list first, then the rest".',
  '81': 'This calls the locked copy "stable". The stable version today is an old one (29.09), and the locked copy does not exist yet: it is made on Thursday (see [[r3-40]] and [[r3-41]]). Read "stable" as "the copy made on Thursday".',
  '82': 'Its pick assumed more credit was left. By my estimate only about $50 of the $198 is left for the 12 days to go. Read it with that number in mind, together with [[r3-46]], [[r3-56]] and [[r3-57]].',
  'R3': 'On 10/18 you already told the helpers to do the extras you said yes to this week, and rise from underground and the light shafts are already in the game. Only slow motion is still open: read it as "slow motion only" (a = no slow motion before the party, b = add it).'
};
// Picks that the corrections change.
const REPICK = {
  '32': ['a', 'your 10/18 ruling took b off the table.'],
  '34': ['c', 'your 10/18 ruling was no new people before the party.'],
  '80': ['c', 'your own 10/18 worry list should lead: stutter or harsh sound, crash or freeze, player 2\'s pad or window, guests not knowing how to start.']
};

const round2 = {
  key: 'r2', short: '2', title: 'Round 2',
  intro: 'Written on the morning of 10/18, before you answered round 1. The numbers are round 2\'s own: 2.7 is round 2 question 7. The yellow boxes on 9 of them say what changed after they were written.',
  groups: r2.groups.map(g => ({
    heading: g.heading.charAt(0).toUpperCase() + g.heading.slice(1),
    questions: g.questions.map(q => {
      const rp = REPICK[q.id];
      let why = rp ? rp[1] : (q.pick_reason || '');
      if (!rp && q.pick_note) why += ' (' + q.pick_note + ')';
      return { id: 'r2-' + q.id, label: '2.' + q.id, about: q.about || '', question: q.question,
        options: q.options.map(o => ({ key: o.key, text: o.label })), pick: rp ? rp[0] : q.pick, why, fix: FIX[q.id] || '' };
    })
  }))
};

const order = [];
const byGroup = {};
r3.forEach(q => { if (!byGroup[q.group]) { byGroup[q.group] = []; order.push(q.group); } byGroup[q.group].push(q); });
const fixR2Refs = s => s.replace(/round 2 question (\d+)/gi, (m, n) => '[[r2-' + n + '|' + m + ']]');
const round3 = {
  key: 'r3', short: '3', title: 'Round 3',
  intro: 'Written on the afternoon of 10/18, after your answers to round 1. Inside this round, "question 4" means 3.4 here, and links take you to any round 2 question it names.',
  groups: order.map(g => ({
    heading: g,
    questions: byGroup[g].map(q => {
      const n = String(parseInt(q.id.slice(3), 10));
      return { id: q.id, label: '3.' + n, about: fixR2Refs(q.about || ''), question: q.question,
        options: q.options.map(o => ({ key: o.key, text: o.text })), pick: q.pick, why: q.why || '', fix: '' };
    })
  }))
};

const helpers = {
  key: 'h', short: 'H', title: 'From a helper today',
  intro: 'Two choices the helper that made the two windows match ran into. It changed nothing here and waits for you.',
  groups: [{ heading: 'The two windows', questions: [
    { id: 'h-1', label: 'H1', question: 'In the 2 player arcade demo, should the two players walk the Undercroft before the drop?',
      about: 'In the 2 player arcade demo the Undercroft is only a blurred picture behind the party screens: nobody walks there, and a press drops straight into a raid. In 2 player co-op on one machine the two walk the Undercroft and now see each other (since v30.84).',
      options: [{ key: 'a', text: 'Keep the straight drop; the Undercroft stays a backdrop' }, { key: 'b', text: 'Let both walk the Undercroft first, then drop in together' }],
      pick: 'a', why: 'your walk-up order wants a guest in a raid within seconds, and walking first adds a step nobody explains.', fix: '' },
    { id: 'h-2', label: 'H2', question: 'Should the demo put both windows on the default screen layout and normal damage?',
      about: 'In the 2 player arcade demo each window plays on a copy of its own save and keeps that save\'s screen layout and kid-damage setting (your 10/11 order). Player 2 is a fresh save, so if your save has a moved layout or kid damage on, the two TVs differ.',
      options: [{ key: 'a', text: 'Yes, both windows use the defaults in the demo' }, { key: 'b', text: 'Player 2 copies player 1\'s layout and damage' }, { key: 'c', text: 'Leave it: each window keeps its own save\'s settings' }],
      pick: 'a', why: 'two TVs side by side should match, and guests never see your Career setup.', fix: '' }
  ] }]
};

const data = { rounds: [round2, round3, helpers] };
const total = data.rounds.reduce((n, r) => n + r.groups.reduce((m, g) => m + g.questions.length, 0), 0);
const lede = 'Round 2 has ' + round2.groups.reduce((m, g) => m + g.questions.length, 0) + ' questions and round 3 has ' + round3.groups.reduce((m, g) => m + g.questions.length, 0) +
  ', plus 2 from a helper: ' + total + ' in all. <b>Click a letter to answer, and click it again to undo.</b> Every pick saves by itself, and I read them from here. Answer in any order and in parts. Skip any you like: for anything you skip I go with my pick. "Not answered yet" in the bar hides the ones you have done.';
let html = fs.readFileSync(path.join(here, 'template.html'), 'utf8');
html = html.replace('/*LEDE*/', lede);
const json = JSON.stringify(data).replace(/</g, '\\u003c');
html = html.replace('/*DATA*/', () => json);
fs.writeFileSync(path.join(here, 'index.html'), html);
console.log('questions', total, 'bytes', html.length);
