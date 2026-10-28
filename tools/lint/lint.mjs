// node tools/lint/lint.mjs [rule ...] : free, exact bug finder for dark_raiders.html (ESLint, no AI, about 10 s).
// Checks only rules that mean a real bug (an undefined name, a duplicate key, code after a return...), never style.
// Line numbers are the game file's own (the ones grep shows). Writes tools/lint/out/report.txt; prints the counts.
// Setup once: cd tools/lint && npm install (eslint and globals are pinned in package.json; node_modules is gitignored).
// Hits are leads: read the lines before fixing. Known false alarms go in tools/lint/known.txt ("rule line-text-start", one per line).
import { ESLint } from "eslint";
import globals from "globals";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const game = path.join(here, "..", "..", "dark_raiders.html");
const lines = fs.readFileSync(game, "utf8").split("\n");
const a = lines.findIndex(l => /<script>/.test(l)), b = lines.findIndex((l, i) => i > a && /<\/script>/.test(l));
// blank out everything outside the script so the script keeps its place in the file
const src = lines.map((l, i) => (i > a && i < b) ? l : (i === a ? l.replace(/^.*<script>/, "") : "")).join("\n");

const RULES = {
  "no-undef": "error", "no-dupe-keys": "error", "no-unreachable": "error", "no-self-assign": "error",
  "no-self-compare": "error", "no-dupe-else-if": "error", "no-duplicate-case": "error", "no-const-assign": "error",
  "no-unsafe-negation": "error", "use-isnan": "error", "valid-typeof": "error",
  "no-loss-of-precision": "error", "no-sparse-arrays": "error", "no-unsafe-finally": "error", "getter-return": "error",
  "no-setter-return": "error", "no-compare-neg-zero": "error", "no-constant-binary-expression": "error",
  "no-redeclare": ["error", { builtinGlobals: false }], "no-dupe-class-members": "error", "no-empty-character-class": "error",
  "no-invalid-regexp": "error", "no-unused-private-class-members": "error", "no-useless-backreference": "error",
};
const only = process.argv.slice(2);
const rules = only.length ? Object.fromEntries(only.map(r => [r, RULES[r] || "error"])) : RULES;

const eslint = new ESLint({
  overrideConfigFile: true,
  overrideConfig: [{
    languageOptions: { ecmaVersion: "latest", sourceType: "script", globals: { ...globals.browser } },
    linterOptions: { reportUnusedDisableDirectives: "off" },
    rules,
  }],
});
const [res] = await eslint.lintText(src, { filePath: "dark_raiders.js" });

// ESLint also breaks lines at a lone CR and at U+2028/2029: map its line:column to a char offset, then to the line grep shows
const starts = [0];
const brk = new RegExp("\r\n|[\r\n" + String.fromCharCode(0x2028, 0x2029) + "]", "g");
for (const mm of src.matchAll(brk)) starts.push(mm.index + mm[0].length);
const nl = [0];
for (let i = 0; i < src.length; i++) if (src.charCodeAt(i) === 10) nl.push(i + 1);
const gameLine = m => {
  const off = starts[m.line - 1] + (m.column - 1);
  let lo = 0, hi = nl.length - 1;
  while (lo < hi) { const mid = (lo + hi + 1) >> 1; if (nl[mid] <= off) lo = mid; else hi = mid - 1; }
  return lo + 1;
};
// reusing a var name inside one function is this codebase's style; only a second "function NAME" (the later one silently wins) is kept
const nameOf = m => (m.message.match(/'([^']+)'/) || [])[1] || "";
const known = fs.existsSync(path.join(here, "known.txt"))
  ? fs.readFileSync(path.join(here, "known.txt"), "utf8").split("\n").map(s => s.trim()).filter(s => s && !s.startsWith("#")) : [];
const isKnown = (m, t) => known.some(k => { const [r, ...rest] = k.split(" "); return r === m.ruleId && t.trim().startsWith(rest.join(" ")); });
const keep = m => {
  const t = lines[gameLine(m) - 1] || "";
  if (isKnown(m, t)) return false;
  if (m.ruleId !== "no-redeclare") return true;
  const n = nameOf(m).replace(/[$]/g, "\\$");
  return new RegExp("function\\s+" + n + "\\b").test(t);
};
const msgs = res.messages.filter(m => !m.ruleId || keep(m));
const by = {};
for (const m of msgs) (by[m.ruleId || "parse"] ||= []).push(m);
const clip = s => (s || "").trim().slice(0, 140);
let out = `lint of dark_raiders.html ${new Date().toISOString().slice(0, 16)}: ${msgs.length} hit(s)\n`;
for (const [r, ms] of Object.entries(by).sort((x, y) => x[1].length - y[1].length)) {
  out += `\n== ${r}: ${ms.length}\n`;
  for (const m of ms) out += `  ${gameLine(m)}: ${m.message} | ${clip(lines[gameLine(m) - 1])}\n`;
}
fs.mkdirSync(path.join(here, "out"), { recursive: true });
fs.writeFileSync(path.join(here, "out", "report.txt"), out);
const counts = Object.entries(by).map(([r, ms]) => `${r} ${ms.length}`).join(", ");
console.log(`${msgs.length} hit(s): ${counts || "none"}. Full list: tools/lint/out/report.txt`);
