// node tools/lint/lint.mjs [--file PATH] [--gate] : free, exact bug finder for the game file (ESLint, no AI, about 10 s).
// Only rules that mean a real bug, never style. "error" rules (an undefined name, a duplicate key or case, a second function with the
// same name...) stand at zero on the game: --gate (preflight.sh) fails on any of them, so a typo that would throw in the raid is caught
// before the ship. "warn" rules (code after a return, x===x...) are leads for a person, never a gate: this game switches old code off
// with a bare return on purpose.
// Line numbers are the game file's own (the ones grep shows). Writes tools/lint/out/report.txt.
// Setup once: cd tools/lint && npm install (eslint and globals are pinned in package.json; node_modules is gitignored).
// A false alarm goes in tools/lint/known.txt as "rule start-of-the-trimmed-line", one per line.
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const argv = process.argv.slice(2), gate = argv.includes("--gate");
const fi = argv.indexOf("--file"), game = fi >= 0 ? argv[fi + 1] : path.join(here, "..", "..", "dark_raiders.html");
let ESLint, globals;
try { ({ ESLint } = await import("eslint")); globals = (await import("globals")).default; }
catch (e) { console.log("lint: SKIP (run npm install in tools/lint)"); process.exit(0); }

const lines = fs.readFileSync(game, "utf8").split("\n");
const a = lines.findIndex(l => /<script>/.test(l)), b = lines.findIndex((l, i) => i > a && /<\/script>/.test(l));
// blank out everything outside the script so the script keeps its place in the file
const src = lines.map((l, i) => (i > a && i < b) ? l : (i === a ? l.replace(/^.*<script>/, "") : "")).join("\n");
// names the game hangs on window (window.titleNameShown=...) are globals too
const winNames = Object.fromEntries([...src.matchAll(/\bwindow\.([A-Za-z_$][\w$]*)\s*=(?!=)/g)].map(m => [m[1], "writable"]));

const RULES = {
  "no-undef": "error", "no-dupe-keys": "error", "no-self-assign": "error", "no-dupe-else-if": "error",
  "no-duplicate-case": "error", "no-const-assign": "error", "no-unsafe-negation": "error", "use-isnan": "error",
  "valid-typeof": "error", "no-loss-of-precision": "error", "no-unsafe-finally": "error", "getter-return": "error",
  "no-setter-return": "error", "no-compare-neg-zero": "error", "no-redeclare": ["error", { builtinGlobals: false }],
  "no-dupe-class-members": "error", "no-empty-character-class": "error", "no-invalid-regexp": "error",
  "no-useless-backreference": "error",
  "no-unreachable": "warn", "no-self-compare": "warn", "no-constant-binary-expression": "warn", "no-sparse-arrays": "warn",
};

const eslint = new ESLint({
  overrideConfigFile: true,
  overrideConfig: [{
    languageOptions: { ecmaVersion: "latest", sourceType: "script", globals: { ...globals.browser, ...winNames } },
    linterOptions: { reportUnusedDisableDirectives: "off" },
    rules: RULES,
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
const kf = path.join(here, "known.txt");
const known = fs.existsSync(kf) ? fs.readFileSync(kf, "utf8").split("\n").map(s => s.trim()).filter(s => s && !s.startsWith("#")) : [];
const isKnown = (m, t) => known.some(k => { const [r, ...rest] = k.split(" "); return r === m.ruleId && t.trim().startsWith(rest.join(" ")); });
const keep = m => {
  const t = lines[gameLine(m) - 1] || "";
  if (isKnown(m, t)) return false;
  if (m.ruleId !== "no-redeclare") return true;
  return new RegExp("function\\s+" + nameOf(m).replace(/[$]/g, "\\$") + "\\b").test(t);
};
const msgs = res.messages.filter(m => !m.ruleId || keep(m));
const errs = msgs.filter(m => m.severity === 2 || !m.ruleId);
const clip = s => (s || "").trim().slice(0, 140);
const row = m => `  ${gameLine(m)}: ${m.ruleId || "parse"}: ${m.message} | ${clip(lines[gameLine(m) - 1])}`;
let out = `lint of ${path.basename(game)} ${new Date().toISOString().slice(0, 16)}: ${errs.length} bug hit(s), ${msgs.length - errs.length} lead(s)\n`;
out += `\n== bugs (must stay at zero)\n${errs.map(row).join("\n")}\n\n== leads (read, often on purpose)\n`;
out += msgs.filter(m => !errs.includes(m)).map(row).join("\n") + "\n";
fs.mkdirSync(path.join(here, "out"), { recursive: true });
fs.writeFileSync(path.join(here, "out", "report.txt"), out);
if (gate) {
  if (errs.length) { console.log(`lint: FAIL ${errs.length}\n${errs.slice(0, 5).map(row).join("\n")}`); process.exit(1); }
  console.log("lint: PASS");
} else console.log(`${errs.length} bug hit(s), ${msgs.length - errs.length} lead(s). Full list: tools/lint/out/report.txt`);
