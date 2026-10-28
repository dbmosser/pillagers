# 212-red-29.33-pause-sp-gold-token : the pause box sp gold is a raw #ffc04a inside the shared look block, so check 29.33 stops there
Queue (stable triage 10-28 12:31, run corpus-1028-0934 on v35.76, rerun alone on v35.82 and v35.83). Fix, tiny, LOW (no player sees it: the sp numbers draw in the right gold; but check 29.33 returns at its literal scan, so its title and mode menu asserts never run).
effort: low (Sonnet is enough)

What check 29.33 expects (his order 2026-10-18, one shared look; job 57 put back the block wide literal scan): no rule in <style id="ui-shared"> may carry a NEW raw colour or font-size literal.
The pinned DEBT list (20 selectors, DEBT_N 20) may only shrink. The block header in dark_raiders.html (about line 1802) says the same: every rule reads the :root tokens, no hex, no rgba.
What the build does now (master v35.84, unchanged since v35.75): two pause box rules added by v35.75 (b69fce6e0, cw-pausesp, the pause box shows what the raid pays in sp) hard code the gold:
  about line 2131: #root #pausebox #pausesp .psph b{ font:700 var(--fs-title)/1 var(--f-cond); color:#ffc04a; font-variant-numeric:tabular-nums; }
  about line 2136: #root #pausebox #pausesp .psprow b, #root #pausebox #pausesp .psprule b{ text-align:right; color:#ffc04a; font-variant-numeric:tabular-nums; }
That makes 22 literals and two new selectors. The check names only the first, so a fix that covers line 2131 alone just moves the red to 2136.
No :root token holds #ffc04a (the nearest are --r-gold #ffc72e and --warn #f5b73b), and UIC has no such key.
Suspect ship: v35.75 (the pause sp panel is his 10-28 order and is fine; only the raw colour slipped in, and the gate missed it because 29.33 is outside the newest ~80 checks).
Fix: add one token to the :root block beside --r-gold (about line 118), for example --score-gold:#ffc04a, outside ui-shared. Do not use a --sp-* name: that prefix is the 8px space grid and
29.33 loops over UIT.sp. Use var(--score-gold) in both rules (2131 and 2136). No visual change. Do not grow DEBT: the list may only shrink, and the token is the right fix.
Check (must FAIL on the current build): the ui-shared block text (comments stripped) has no #ffc04a, the computed --score-gold on :root is #ffc04a, and the computed colour of a .psph b
and a .psprow b in #pausesp is rgb(255, 192, 74). Then run 29.33 itself: it must pass past the literal step (20 literals, no new selectors) and through its mode row, 56px button,
uiFont and uiPanel asserts.
Rules: menu and HUD styling only; no storage key change; seed 4242 fingerprint unchanged; looting and pickup rows are never touched; no other pause box change.
TASK DONE when check 29.33 passes again and the gate passes.
