# 0a trial-deepseek-gemini-grok : a fourth helper lane that runs cheap models (DeepSeek, Gemini, Grok) on small exact jobs, as a trial
model: opus
HIS WORDS 10-30 (to the CEO chat), after the CEO read about "Opus as principal dev, DeepSeek as its team": "yeah lets trial it -- i think we should consider involving gemini and grok too"
CEO plan he accepted: Claude stays the planner and writes exact job files; cheap models build only small, exactly specified jobs, and every change goes through the same full gate. Trial Sun 11/1 to Wed 11/4 while Codex is out (resets 11-04), with a daily spending cap, then compare pass rates with Codex.

Build (tools only; never the game file by hand):
1. ONE KEY FOR ALL THREE: OpenRouter (pay per use; it serves DeepSeek, Gemini and Grok models). The key is PILLAGERS_OPENROUTER_KEY, a Windows user variable. He enters it himself with the desktop shortcut "Pillagers - add OpenRouter key" (tools/ai-keys.ps1 openrouter, hidden input). Never print, log or copy it. Free extra: agy (Antigravity) is already signed in with his Google account (gemini flash, free tier) and can be a second Gemini route.
2. LANE d: reuse tools/console-lane.sh (the same harness, rules, gate and ship queue as lanes a, b and c), with the model and endpoint switchable by env or caps: Claude Code CLI pointed at OpenRouter's Anthropic-compatible endpoint (ANTHROPIC_BASE_URL plus the key in ANTHROPIC_AUTH_TOKEN, set only inside the lane's own process, never globally: a global ANTHROPIC_* var would bill or break his Claude sign-in). Check OpenRouter's current docs for the exact endpoint and the model ids (current DeepSeek, Gemini and Grok coding models); do not guess.
3. JOBS: lane d takes only d-*.md job files, which the CEO writes: one number, a label, a spacing fix, a retarget. Three model slots rotate per job (deepseek, gemini, grok), so all three get the same kind of work.
4. CAPS: caps-d.txt DAY_USD=5 for the trial, RUN_USD=1. Stop at the cap. Spend logged per model in console/spend-d.txt.
5. SCORECARD: console/notes/d-trial.md, one row per run: model, job, preflight pass or fail, number of tries, $ spent, ON HIS PC yes or no. On Wed 11/4 the CEO writes a 5-line verdict for him (which model, if any, earns more jobs).
6. Respect STOP and STOP-claude like the other lanes. Add lane d to checkin.sh's lane rows.
Check: --dry prints the model, the endpoint host and the job it would take, without calling anything; a run with no key says "no openrouter key" and exits cleanly.
Rules: never his 8802; never print keys; never touch the pickup stack, loot sounds or loot rows (the jobs it takes must not either). Model for THIS build job: Opus high.
TASK DONE when lane d has shipped one d- job ON HIS PC, or it is ready and waits only for his key.
