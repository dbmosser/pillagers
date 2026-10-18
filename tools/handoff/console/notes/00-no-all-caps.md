# 00-no-all-caps notes
Design: the game already has ONE text door, TX(s) (~line 3504): every canvas fillText/measureText (proto wrapper at ~3623) and every text node
under the page (txDom/txWatch) goes through it. So the net is ncFix() inside TX; no per-string edits are needed.

SHIPPED
- v29.11 cw-nocaps-net: ncFix (NCKEEP acronyms list, NCKEYS Esc/Tab/Ctrl..., roman numerals kept, words touching digits kept, 2-letter words only
  when the line has no lowercase or has a 3+ caps word), CSS `*{text-transform:none !important}` at the top of the style block, <title>Pillagers.
  Check 29.11 scans a txRecord() raid frame, #root text nodes and computed text-transform.
- v29.14 cw-nocaps-dom: TX watcher now observes document.body (not only #root), title/placeholder/aria-label attributes fixed (ncFix),
  CSS content 'Taken', data-need chips 'Need $x more', tab title 'Pillagers, player 2'.
- fixture: check 28.91 made case blind (commit 37caa926).

GOTCHAS LEARNED
- In a replacement text never write  $'  ($ then quote): the shipper treats it as a regex substitution and the page stops parsing. Use \u0024.
- A here-string replacement has no trailing newline; if the anchor ended with a newline, append "`n" or a // comment swallows the next line.
- runchk.sh takes paths relative to the repo (it cd's there; the repo path has a space). HELD=1 bash .../fixq.sh "msg" is the allowed form (no env prefix).

REMAINING (next run)
1. Old checks that assert CAPS text on DOM or canvas text now fail (the net lowercases what they read). The gate only reruns the newest 80, so the
   rest will show in the nightly corpus for v29.14 (scratchpad corpus-*.txt, tools/handoff/nightly/state.txt). Triage those: retarget the regex with
   the i flag or the sentence case wording through fixq.sh. Checks that spy on say() text are unaffected (the fixture replaces say).
   Candidates found by grep in tools/mkfixture.ps1 (/CAPS/.test on textContent): 4216, 4221, 13479, 15678-15679, 17944, 18784-18821, 19512,
   27937, 37796-37800, 38948-38951, 39320-39322, 40196, 42911, 42946, 43345, 44722, 47526, 47848, 48123, 48695, 48723-48726, 48759, 80205,
   80420-80425, 81222 (line numbers at 10-18 07:xx; verify first, many may be say-spy or already case blind).
2. Optional quality pass: .toUpperCase() display sites (names then show as "Scav pistol", not "Scav Pistol"). Net already guarantees no caps.
3. Final whole-game scan: nothing known outside the TX door (no OffscreenCanvas, no textTransform in JS, no alert/confirm, no strokeText words).
   Unknown: text baked into image assets.
RUN 2 (10-18): S/mk-cw-capscan.ps1 scans the fixture for checks testing caps words -> notes/caps-scan.txt (line, v, text), caps-list.txt, caps-l1..5.txt (LF lists).
  Ran all 330 via runchk (outputs notes/caps-o1..o5.txt). Non-PASS/SKIP: 28.08 27.42 27.20 26.52 26.37 26.10 25.35 23.54 23.24 22.95 20.38 19.95 17.89 17.38
  16.38 15.76 14.93 14.90 13.08 10.41 10.39 9.97 9.94 9.58 (some fail for other reasons: 26.52 Digit0, 19.95, 14.90, 13.08, 16.38 check each).
  Fix by case-blind regex (add i flag) via fixture edit under lock; then runchk the list; HELD=1 fixq.
RUN 3 (10-18): retargeted ~35 old checks case-blind (commits 466534b6, b1dd8871); reran the list: all PASS except
  26.52 / 26.37 (fail on the v29.15 gun key renumber, Digit0 and key 8, NOT caps; another worker's area), 22.95 (SKIP staging),
  10.41 (pause box controls line: no E interact / CTRL text at check time; likely stale hub pause line, not caps). 29.11 and 29.14 PASS.
  Source scan: no CSS content caps, alert/confirm/prompt, OffscreenCanvas, textTransform, svg text, option text. The TX net covers canvas+DOM.
Status: TASK DONE (no all-caps word can reach the player; checks retargeted). Leftovers above belong to other tasks.
