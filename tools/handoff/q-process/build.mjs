// Builds the 10-19 process questions page from questions.json (made by make.py) and the open-questions template in ../qpage.
// node build.mjs  ->  writes index.html next to this script. Answers land in the page's db collection "answers", ids p-1 .. p-100.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
const here = path.dirname(fileURLToPath(import.meta.url));
const qs = JSON.parse(fs.readFileSync(path.join(here, 'questions.json'), 'utf8'));
const order = [], byGroup = {};
qs.forEach(q => { if (!byGroup[q.group]) { byGroup[q.group] = []; order.push(q.group); } byGroup[q.group].push(q); });
const round = {
  key: 'p', short: 'P', title: 'How we work',
  intro: 'Asked on the night of 10/19, after the move into the VM, because you asked for questions that would make the work faster or better. Nothing here repeats an answer you already gave.',
  groups: order.map(g => ({ heading: g, questions: byGroup[g].map(q => ({ id: q.id, label: q.label, about: q.about, question: q.question,
    options: q.options, pick: q.pick, why: q.why, fix: '' })) }))
};
const lede = qs.length + ' questions in ' + order.length + ' groups of 10. <b>Click a letter to answer, and click it again to undo.</b> Every pick saves by itself, and I read them from here. Answer in any order and in parts, on the PC or your phone. Skip any you like: for anything you skip I go with my pick. The box under each one takes your own words.';
let html = fs.readFileSync(path.join(here, '..', 'qpage', 'template.html'), 'utf8');
html = html.replace('<title>Pillagers Open Questions</title>', '<title>Pillagers Process Questions</title>')
  .replace('<h1>Open questions, rounds 2 and 3</h1>', '<h1>100 questions about how we work</h1>')
  .replace('/*LEDE*/', lede)
  .replace('/*DATA*/', () => JSON.stringify({ rounds: [round] }).replace(/</g, '\\u003c'));
fs.writeFileSync(path.join(here, 'index.html'), html);
console.log('questions', qs.length, 'bytes', html.length);
