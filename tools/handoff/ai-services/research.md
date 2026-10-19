# Which other AI services would speed up PILLAGERS? (research, 2026-10-19)

Written for the owner. Plain language. Every price and limit was checked against an official page where one could be opened; anything that could only be confirmed on a blog or a benchmark mirror is marked **unverified**. Some official pages (chatgpt.com/pricing, openai.com/api/pricing, grok.com, z.ai/subscribe, Cerebras/Groq free-plan tabs) refused to load or showed no numbers, so those facts are marked too.

---

## 1. Bottom line

Nothing else beats the Claude pipeline you already have on quality: in the independent Artificial Analysis "Coding Agent Index" (a score for the whole tool plus model, updated 2026-10-19 on the BenchLM mirror) **Claude Code with Sonnet 5.5 is number 1 at 68.4**, ahead of Google's Antigravity CLI with Gemini 4 Argon (63.8), OpenAI's Codex with GPT-6.1 Sol (62.9), xAI's Grok Build with Grok 4.7 (56.3), OpenCode with GLM-5.3 (53.6), Kimi Code (51.9) and Codex with DeepSeek V4 Pro (43.1). So the goal is not a better coder, it is a **second, separate weekly allowance** so the lanes do not stop when Claude runs out. The best value is: (1) **ChatGPT Plus, $20/month, for a Codex lane** (documented unattended mode, native Windows installer, near-Claude quality); (2) **a free local upgrade, qwen3.8:27b on your 7900 XTX, as the reviewer and screenshot critic** (it replaces the old qwen2.5-coder:32b and costs nothing); (3) **Google's Antigravity CLI** (try the free tier today, move to Google AI Pro at $20 only if the quota holds up); and (4) **a $10 prepaid DeepSeek API balance**, which plugs into your existing `claude -p` lane scripts by changing two environment variables and is cheap enough to use for review and small jobs (it is weaker, so expect more gate failures). Do not buy Grok, Perplexity, Venice, Cursor, Copilot, or the $100+ ChatGPT Pro plans yet. Run a one-day pilot (section 8) before spending more than about $50. Total first-month cost of the recommended set: about **$30 to $50**.

Also verified and already known to you: Max plans include monthly API credit ($100 on Max 5x, $200 on Max 20x) but it **cannot** be used in Claude Code or the Agent SDK, only in plain API calls (which is why `run-api.mjs` exists).

---

## 2. Ranked table

| Rank | Verdict | Service | Monthly cost | Best role | Expected speed-up (honest) |
|---|---|---|---|---|---|
| 1 | **BUY** | ChatGPT Plus + Codex CLI (`codex exec`) | $20 | Second coder lane, also reviewer | Adds an independent weekly pool with near-Claude quality. Size of the pool is not published; OpenAI's own estimate for Plus is 15 to 160 local tasks per 5 hours on GPT-6.1 Sol. Could plausibly add dozens of jobs per week. **Measure it.** |
| 2 | **FREE** | qwen3.8:27b local (Ollama, your GPU) | $0 | Reviewer, screenshot critic, tiny jobs | Removes review cost from Claude entirely. Not a trustworthy main coder. |
| 3 | **BUY (try free first)** | Google Antigravity CLI (`agy`), free tier then Google AI Pro | $0 then $20 | Third coder lane, reviewer | Same class as Codex (63.8 vs 62.9 on the index). Quota is vague and has been cut repeatedly. Gemini API also gives free Flash for bulk checks. |
| 4 | **BUY (small)** | DeepSeek API, prepaid | $10 balance, pay per use | Reviewer (V4.1 Flash), simple jobs (V4 Pro) through existing lane scripts | About 4 to 6 times cheaper per token than Sonnet 5.5, but quality is clearly lower. Code is sent to servers in China. |
| 5 | Baseline | Claude Max 5x to 20x | +$100 over Max 5x | Same lanes, no new work | Biggest zero-effort fix if he is on 5x. Weekly caps are not published; 4x the "usage" is the stated multiple. |
| 6 | Optional | Z.ai GLM Coding Plan Lite | from $18 | Cheap flat-rate coder via Claude Code | GLM-5.3 in OpenCode scored 53.6. Code goes to China. Only if the pilot shows DeepSeek is too weak. |
| 7 | FREE (test) | NVIDIA NIM free hosted models (lists deepseek-v4.1-flash) | $0 | Reviewer | **Unverified** limits. 15-minute test worth doing. |
| 8 | FREE (marginal) | OpenRouter `:free`, Groq free, Gemini API free key, Mistral free | $0 | Bulk text checks only | Tight daily or per-minute caps; several train on your prompts. |
| 9 | SKIP | SuperGrok / Heavy + Grok Build | $30 / ~$300 | none | Quotas unpublished, headless billing unclear, beta, lower score. |
| 10 | SKIP | GitHub Copilot Pro / Pro+ | $10 / $39 | none for now | Pro+ gives about $70 of model use at list price (Claude Sonnet 5.5 included): about 44% discount, roughly 17 to 35 jobs a month. Worse value than Codex Plus. |
| 11 | SKIP | ChatGPT Pro $100 / $200 / $500 | $100+ | none until Plus is proven | Allowances changed several times; no published multiples. |
| 12 | SKIP | Perplexity, Venice, Cursor, Windsurf/Devin, Kiro, Kimi Code, MiniMax, Alibaba plan, Mistral, Cerebras | various | none | See section 6. |
| dead | n/a | GitHub Models (retired 2026-07-30), Qwen Code free login (ended 2026-04-15), Gemini CLI with Google sign-in (ended 2026-06-18) | n/a | n/a | Do not plan on these. |

---

## 3. Yardstick: what the benchmarks actually say

- **Best single measure for this job**: Artificial Analysis Coding Agent Index (tool plus model together; average of DeepSWE, Terminal-Bench v2 and SWE-Atlas-QnA). BenchLM mirror, captured 2026-10-19. The Artificial Analysis site itself shows only charts, so I could not read the numbers there: treat the exact digits as **unverified**, the ordering as reliable.
  - Claude Code + Sonnet 5.5 (max effort): 68.4. At lower effort it drops hard: high 55.0, medium 45.9, low 42.1. Opus 5.5 (max) 66.0, Fable 5.1 62.2, Haiku 5.5 (max) 36.5. **Sonnet 5.5 at max is the best and the cheapest on limits; make sure the lanes do not use Opus or Fable.**
  - Antigravity CLI + Gemini 4 Argon (high): 63.8. Codex + GPT-6.1 Sol (xhigh): 62.9, (medium) 61.4. Grok Build + Grok 4.7 (xhigh): 56.3. OpenCode + GLM-5.3: 53.6. Kimi Code CLI + K3: 51.9. Claude Code + Qwen3.8 Max: 43.3. Codex + DeepSeek V4 Pro: 43.1. Codex + DeepSeek V4 Flash: 38.7.
- **SWE-bench Verified** (Vals AI, same open harness for every model, 2026-09-01): Claude Opus 5 97.0, DeepSeek V4 Pro 96.4, GPT-5.6 Sol 96.2, Grok 4.6 95.6, GLM 5.3 95.4, Kimi K3 93.4, Qwen3.8-27B 86.0, Claude Sonnet 5 79.6, MiniMax M3 75.0. Vals says this test is saturated and archived, so it no longer separates models well; it flatters the cheap Chinese models relative to the agent index above.
- **Terminal-Bench 2.1** (BenchLM page for Vals data, 2026-10-19; BenchLM itself says scores are mostly provider-reported): GPT-5.6 Sol 91.9, DeepSeek V4.1 Flash 90.6, Kimi K3 88.3, GLM-5.3 88.2, Claude Mythos 5 88.0, DeepSeek V4 Pro 87.9, Qwen3.8 Max 86.6, Claude Fable 5 84.3, Grok 4.5 83.3, Claude Sonnet 5 80.4, Qwen3.8-27B 73.0, MiniMax M3 66.0. Treat as a rough guide only.
- **Why this matters for you**: all of these are small-repo tests. Your game is one 5.5 MB file and the bar is "AAA polish" plus a headless-Chrome gate. Nobody has benchmarked that. The only trustworthy test is a pilot on your own jobs.

---

## 4. Per-option notes (the eight areas you asked about)

### 4.1 OpenAI: ChatGPT plans + Codex CLI

- **Plans and prices** (official, learn.chatgpt.com/docs/pricing, fetched 2026-10-19): Free $0, Go $8, **Plus $20**, **Pro "from $100"** with tiers at $100, $200 and $500, Business $20 to $25 per user. API key is billed per token.
- **Capacity**: Plus gets estimated local Codex messages per 5 hours: GPT-6.1 Sol 15 to 160, GPT-6 Sol 15 to 150, GPT-6 Astra 5 to 45, GPT-6 Luna 350 to 3,000. "Weekly limits may also apply"; **no weekly number is published**. Pro plans "currently have no five-hour limit", so only the weekly cap applies; OpenAI no longer publishes a multiple of Plus for any Pro tier. Third-party reports (not official): the $200 Pro was paused for new sign-ups 2026-09-10 and reopened 2026-09-29 with roughly half the old allowance; existing $200 subscribers keep the old allowance until 2026-10-29; the $500 tier is the only one with the "Ultrafast" modes. Limits have moved several times this year, so expect change.
- **Models**: Plus includes GPT-6.1 Sol and GPT-6 Luna (and the others in the table above). GPT-5.5 left Codex for ChatGPT sign-in on 2026-10-14. GPT-5.6 Sol has promotional pricing at least through 2026-11-21.
- **Headless**: `codex exec "..."` is documented for scripts and CI. Default sandbox is read-only; `--sandbox workspace-write` allows edits. `--json`, `-o file`, `--output-schema`, `codex exec resume --last`. Needs a git repo (yours is). Sign-in: it reuses the saved ChatGPT login; OpenAI calls this "advanced, for trusted runners" and notes `~/.codex/auth.json` is a secret and gets refreshed, so keep it on one machine. API key is the "simpler default" (`CODEX_API_KEY`). `--full-auto` no longer exists.
- **Windows**: native PowerShell installer or `npm install -g @openai/codex` (github.com/openai/codex README, Apache-2.0). Native Windows sandbox exists (elevated or unelevated mode). One open GitHub issue (v0.80.0) reported sandboxed commands failing on PowerShell 5.1. Git Bash use of `codex exec` was **not found documented**: test it.
- **Terms**: OpenAI's written terms forbid automated or programmatic extraction in generic words; the Codex lead has publicly endorsed using Codex login tokens in other harnesses (Feb 2026); the official Codex docs describe ChatGPT-login CI use. Reading: tolerated and documented, not fully spelled out (Zylos, 2026-07-13: secondary).
- **API alternative** (prices per million tokens, list): GPT-6.1 Sol $2 in / $10 out (cached $0.10); GPT-6 Sol $2 / $10; GPT-6 Astra $10 / $50; GPT-6 Luna $0.10 / $0.50. Same list price as Claude Sonnet 5.5, so the API route is no cheaper than your $4-per-job Claude API route. The subscription is where the value is.
- **Strength**: Codex + GPT-6.1 Sol 62.9 on the agent index; GPT-5.6 Sol is #2 on Terminal-Bench 2.1 (91.9).
- **Role**: second coder lane (best choice), also a good reviewer.
- **Owner does**: create or use a ChatGPT account, subscribe to Plus, install Codex, run `codex` once and choose "Sign in with ChatGPT" (browser). A helper then writes the lane script. Note the existing lane allow-list for `claude -p` does not carry over; Codex uses sandbox plus approval rules, so a helper must port the lockdown.
- **Risks**: weekly pool size unknown; plan changes mid-month; ChatGPT consumer data-controls setting decides whether your prompts may train models (check Settings > Data controls; not verified here); Windows sandbox quirks.

### 4.2 Google: Gemini CLI vs Antigravity CLI

- **Confirmed from Google's own blog (2026-05-19)**: Gemini CLI and the Gemini Code Assist IDE extensions stopped serving **Google AI Pro, Google AI Ultra and free Code Assist for individuals on 2026-06-18**. Kept: Code Assist Standard/Enterprise customers and anyone using a **paid** Gemini or Enterprise Agent Platform API key. Replacement: **Antigravity CLI (`agy`)**, built in Go, "available to everyone", same agent harness as Antigravity 2.0. The reports are right; none refuted. The blog does not say whether Antigravity has a free tier or give a license.
- **Free tier exists** (antigravity.google/pricing, "Individuals, generally available, $0"): unlimited Tab completions and command requests, "basic weekly rate limits", "a variety of agent models"; the plans doc says all plans including free get the CLI and Gemini 3.8 Flash as the core model. No numbers published. Third parties report the free limit has been cut repeatedly and that Claude models on the free tier end 2026-11-02 (unverified).
- **Paid** (Google blog 2026-05-19): **Google AI Pro $20/month**; **AI Ultra $100/month = 5x Pro's tokens**; **Ultra $200/month = 20x Pro's tokens**. Pro and Ultra get Gemini 4 Argon in Antigravity; Ultra also gets "third-party models". Quota is refreshed every five hours and capped weekly; "AI credits" are now only for overage. Gemini Flash and Pro share one limit, drawn down at API price. Google says limits "are subject to modification". Forum reports of multi-day lockouts after hitting the cap (anecdotal).
- **Headless** (official docs): `agy -p "..."`, `--output-format text|json|stream-json`, `--json-schema`, `--model`, `--effort`, `--print-timeout` (default 5m), `--dangerously-skip-permissions`, or scoped allow rules in `~/.gemini/antigravity-cli/settings.json` (for example `command(git)`). Uses cached sign-in: authenticate once interactively; an unauthenticated run exits with an error instead of hanging. API-key auth is **not** documented on the headless page.
- **Windows**: a PowerShell installer is reported by a how-to site (`irm https://antigravity.google/cli/install.ps1 | iex`); Google's blog does not mention Windows (unverified from an official page).
- **Terms**: Google's developer docs say harvesting the Gemini CLI login via third-party tools breaks its terms and can end in account closure. Using `agy` itself is first-party, so fine; do not point other tools at your Google login.
- **Gemini API free key** (ai.google.dev, rate-limits page updated 2026-10-15; pricing page updated 2026-10-16): free-tier models include Gemini 3.8 Flash, 3.6 Flash, 3.5 Flash-Lite, 3.1 Flash-Lite, 2.5 Pro and Flash. Gemini 4 Argon and 3.1 Pro Preview are **not** free. **Requests-per-day and tokens-per-minute are not published on the page** (it says to look in AI Studio). Third-party lists say roughly 5 to 15 requests/minute and 20 to 1,500/day (unverified). Free-tier prompts may be used to improve Google products outside the EEA/UK/Switzerland (secondary sources). Paid price: Gemini 4 Argon $2 / $10 per million; 3.8 Flash $0.75 / $3.75.
- **Strength**: 63.8 on the agent index (Argon). The free-tier Flash model is far weaker (Antigravity SDK + 3.8 Flash 41.9).
- **Role**: third coder lane (Pro), reviewer or bulk checker (free).
- **Owner does**: install `agy`, run it once and sign in with the Google account; for Pro, subscribe at one.google.com.
- **Risks**: vague and shrinking quota; lockouts; no API key path documented for unattended use.

### 4.3 xAI Grok

- **Grok Build CLI**: official docs (docs.x.ai/build/overview) give a Windows installer (`irm https://x.ai/cli/install.ps1 | iex`), headless `grok -p "..."` with `--output-format plain|json|streaming-json`, `--always-approve`, `--cwd`, and sign-in by browser or the `XAI_API_KEY` variable. Docs do not say which subscriptions include it, publish **no quotas**, and do not say whether headless runs bill the subscription or the API key. Launched 2026-05-14 as beta for SuperGrok Heavy, later opened to SuperGrok ($30) and X Premium+ ($40) per secondary sources (**unverified**; grok.com blocked). Heavy about $300, with unconfirmed promos near $99; one October blog lists a $100 "SuperGrok Plus" tier (**unverified**).
- **API** (official docs.x.ai/docs/models): grok-4.7 $2 in / $6 out (cached $0.50), 500k context; grok-build-0.1 $1 / $2 (256k); grok-4.3 $1.25 / $2.50. 
- **Quality**: Grok Build + Grok 4.7 scored 56.3 on the agent index (Grok Build + Grok 4.5 scored 76 on the earlier July index). Vals SWE-bench Verified 95.6 for Grok 4.6. One source mentions an agentic-coding regression in 4.6 (unverified).
- **Verdict**: skip. Cheaper than Claude per token but lower quality, unpublished subscription quotas, beta. If ever needed, use pay-per-token with an API key, not the $300 plan.

### 4.4 GitHub Copilot

- **Official docs** (docs.github.com, fetched 2026-10-19): since 2026-06-01 Copilot is usage-billed in "AI credits", 1 credit = $0.01, billed at each model's token price. Free: small unstated credit allowance, auto model only. **Pro $10** = 1,500 credits ($15). **Pro+ $39** = 7,000 credits ($70). No rollover. Extra use via a dollar budget, same price. Copilot CLI is included in all plans.
- **Models include** Claude Sonnet 5.5 ($2/$10), Opus 5.5 ($4/$20), Haiku 5.5, Fable 5.1; GPT-6.1 Sol, GPT-6 Astra; Gemini 4 Argon; Grok 4.7; Kimi K3. Prices equal the vendors' list prices.
- **Headless**: `copilot -p "..." --allow-all-tools --no-ask-user --model claude-sonnet-5.5`, token in `COPILOT_GITHUB_TOKEN`. Windows not mentioned on the page; Copilot CLI is believed to support Windows (unverified here).
- **Answer to your question**: yes, it gives Claude-model capacity outside the Max plan, but only about $70 of it for $39, about 17 to 35 finished jobs a month at your $2 to $4 per job. No Copilot CLI entry on the agent index, so quality is unknown. Not meaningful enough. Skip unless you want one bill.

### 4.5 Cheaper coding plans and APIs (Claude Code compatible)

| Service | Price | Claude Code plug-in | Quality |
|---|---|---|---|
| **DeepSeek API** | `deepseek-v4-pro` (0813) $0.66 in-miss / $0.022 cache-hit / $1.98 out off-peak, double at peak (peak = weekdays 01:00-04:00 and 06:00-10:00 UTC). `deepseek-flash` (V4.1 Flash 1017) $0.15 / $0.003 / $0.60 off-peak. 1M context. | **Yes**, official: `ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic` | Pro: SWE-bench Verified 96.4 (Vals), Terminal-Bench 87.9, but 43.1 on the agent index. Flash: Terminal-Bench 90.6, 38.7 on the agent index. |
| **Z.ai GLM Coding Plan** | Lite "from $18/month" (official); Pro about $72 and Max about $160 per third parties, **unverified**. Limits in credits: Lite 2,000 per 5h / 10,000 per week; Pro 12,000 / 60,000; Max 28,000 / 140,000. Off-peak 50% cheaper. Models GLM-5.3 and GLM-5.3-Flash. | **Yes**, official: `ANTHROPIC_BASE_URL=https://api.z.ai/api/anthropic` plus `ANTHROPIC_AUTH_TOKEN`; Windows needs Git for Windows and manual config (their script does not support Windows). | GLM-5.3: SWE-bench Verified 95.4, Terminal-Bench 88.2, agent index (OpenCode) 53.6. API list $1.40 / $4.40. |
| **Moonshot Kimi** | K3 API $3 in / $15 out (Artificial Analysis). Kimi Code tiers about $19 / $39 / $99 / $199 (**unverified**; kimi.com pages did not show prices). | Docs say its Messages API is Anthropic-compatible; the exact Claude Code base URL was not on the page I could read. | Kimi Code CLI + K3 51.9; Terminal-Bench 88.3; SWE-bench Verified 93.4. |
| **MiniMax** | New plan names Go / Explore (3x) / Build (7.5x); prices not on the official page I could open. | Official page says it connects to Claude Code (setup details not read). | M3 weak: Terminal-Bench 66.0, SWE-bench Verified 75.0. Skip. |
| **Alibaba / Qwen** | Coding Plan listed at CNY 200/month with 6,000 requests per 5h, limited daily slots, restocked 09:30 China time (official help.aliyun.com snippet). Pay-as-you-go Qwen3.8 Max about $2 / $6 (third party). | Community-documented `dashscope-intl.aliyuncs.com/apps/anthropic` | Qwen3.8 Max inside Claude Code 43.3. Skip. |

All of these send your code to servers in China (training policy **unverified** for each). The game is yours and pre-release, so decide whether that is acceptable. US hosts such as DeepInfra serve DeepSeek V4 Pro at about $1.30 / $2.60 (its page says zero retention; blog dated 2026-04-30, prices accessed Oct 2026).

### 4.6 Routers and others

- **OpenRouter** (official pricing and docs): 5.5% fee when you buy credits; 500+ models; works with Claude Code via `ANTHROPIC_BASE_URL=https://openrouter.ai/api` and an empty `ANTHROPIC_API_KEY` (its own docs warn Claude Code is tuned for Anthropic models). Free models: 20 requests/minute, **50/day, or 1,000/day after buying $10 of credit**. Account settings can block routing to providers that train on prompts. Worth having only as one key for many models.
- **Cursor** (Hobby free, Pro $20, Pro+ $60, Ultra $200; secondary sources), **Windsurf / Devin** (Free, Pro $20, Max $200; secondary), **Kiro** (Free 50 credits/month, Pro $20 = 1,000 credits, overage $0.04/credit; Kiro CLI 2.0 with native Windows and headless per an April 2026 changelog, secondary). None showed a strong headless story or a score on the agent index. Skip.
- **Mistral**: Devstral 2 $0.40 / $2, Devstral Small 2 $0.10 / $0.30 (official pricing snippet); open weights; free "Experiment" tier trains on your data unless you opt out. Not competitive on the index. Skip.
- **Factory, Amazon Q**: nothing relevant found; Amazon Q is now Kiro.

### 4.7 Free and local: what runs on the 7900 XTX (24 GB)

- **Best pick: `qwen3.8:27b`** on Ollama (library page: 18 GB download, 256K context, text plus image input, thinking on by default; Alibaba release 2026-08-14, Apache 2.0, dense 27B). Needs Ollama 0.32.15 or newer (a guide says older builds lack it). Alibaba's own numbers (vendor-reported, not independent): SWE-bench Pro 61.7, Terminal-Bench 2.1 73.0 (versus 78.2 for Claude Opus 4.6 Max), NL2Repo 42.3. Independent: Vals SWE-bench Verified 86.0 (rank 15), Terminal-Bench 73.0 (Vals/BenchLM). This is a different league from qwen2.5-coder:32b (2024 model).
- **Speed**: guesses only. Theoretical ceiling about 60 tokens/second (bandwidth maths; a 2026-09-29 guide); real Windows numbers for a 27B model were not found. Ollama lists the 7900 XTX on Windows; Vulkan is the fallback. Measure with `ollama run qwen3.8:27b --verbose`.
- **Memory warning (my reasoning, not from a source)**: 18 GB of weights leaves about 6 GB for the working memory, so the usable context will be far below 256K. Reviewing a whole diff plus nearby code is fine; reading big slices of the 5.5 MB file is not.
- **Alternatives**: Devstral Small 2 24B (Apache 2.0, Dec 2025, SWE-bench Verified about 65.8 to 68.0, 14 GB); Qwen3-Coder 30B-A3B (fast mixture model); gpt-oss 20B (fast, weaker). Qwen3.8-27B appears to be the strongest fit.
- **Roles**: reviewer (yes), screenshot critic and text checks such as the all-lower-case rule (yes, it reads images), simple jobs (maybe, test it), main coder (no).

### 4.8 Baseline: more Anthropic capacity

- **Prices** (claude.com/pricing, fetched 2026-10-19): Pro $20 (or $17 on annual); Max 5x and Max 20x "from $100", the page does not separate them (secondary sources: $100 and $200). Max is "5x or 20x more usage than Pro"; all plans share a five-hour window plus **weekly** caps, no weekly numbers published. Web, desktop, mobile and Claude Code share one pool. A separate weekly limit for Fable models exists on Max.
- **More capacity**: upgrade 5x to 20x; or turn on **usage credits** (pay API rates when the cap is hit: Claude Code can continue on credits); or buy Console API credit for `run-api.mjs`.
- **Max API credits**: $100 (Max 5x) or $200 (Max 20x) per billing cycle, claimed by linking a Console organization; **they cover the Claude API, Managed Agents, the Agent SDK and the Playground, and do NOT cover Claude Code**; expire each cycle, no rollover; new subscribers can claim after 7 days (official docs). `run-api.mjs` already calls the plain API for this reason.
- **API prices per million tokens (official)**: Sonnet 5.5 $2 / $10 (cache read $0.10); Opus 5.5 $4 / $20; Haiku 5.5 $0.10 / $0.50 (up to 100K prompt); Fable 5.1 $10 / $50. Batch API is 50% cheaper but not interactive.
- **Side finding from your own files**: `console-worker.sh` and `console-lane.sh` give `run-api.mjs` default prices of $3 in / $15 out (Sonnet 4.x prices) for `claude-sonnet-5-5`, whose list price is $2 / $10. If the script's own budget tracker produced the "$4 per finished job" figure, the true cost may be about one third lower. Check the Console Cost page for the real number.
- **Automation terms**: `claude -p` with a Pro/Max login is treated as inside the rules (official unattended path; Zylos 2026-07-13). Anthropic's February 2026 clarification bans using consumer OAuth tokens in other products, including the Agent SDK. A planned June 15 change that would move `claude -p` onto a separate capped credit pool was reported as paused on June 16 (conflicting secondary reports); watch for it, because it would hit your lanes directly.

---

## 5. FREE AND CHEAP: EVERYTHING ELSE

Honest summary first: free hosted AI in October 2026 mostly means small models or small daily caps. Several free tiers have died this year (GitHub Models retired 2026-07-30; Qwen Code's free login ended 2026-04-15; Cerebras now needs a card for its $5 trial credit; Gemini CLI's free sign-in ended 2026-06-18). Use the free tiers for review and bulk checks, never as the main coder. Roles: A = headless coding jobs, B = read-only diff review, C = bulk cheap work (text checks, reading screenshots).

| Service | Free or cheap terms (Oct 2026) | Card? | Trains on your data? | Useful for |
|---|---|---|---|---|
| **Perplexity** | Pro $20/mo (secondary); official API page: Sonar $1 in / $1 out plus $5 to $12 per 1,000 requests, Sonar Pro $3 / $15. Its new Agent API just resells Claude, GPT, Gemini, Grok, GLM, DeepSeek and Kimi at list price plus tool fees. One blog says Sonar is deprecated 2026-09-27; the official pricing page still lists it. | Yes (paid) | not checked | **Nothing for coding.** Web lookup with citations only (for example "what do other extraction shooters do for X"). Sonar scores poorly on code. |
| **Venice AI** | Free: 10 text prompts/day. Pro $18/mo (100 credits, unlimited text on its models); Pro Plus $68; Max $200. API resells Claude Sonnet 5.5 at $2 / $10 (labelled "Anonymized"), DeepSeek V4 Pro $1.65 / $3.30 and V4 Flash $0.13 / $0.26 and Qwen3 Coder 480B Turbo $0.35 / $1.50 (labelled "Private"). | Free no; API needs credits | Says private/anonymized; retention terms **unverified** | **Only if privacy is the goal.** No discount on Claude; no headless coding tool. C/B possible at the cheap private models. Skip otherwise. |
| **Google AI Studio free key** | Free Gemini 3.8 / 3.6 Flash, 3.5 / 3.1 Flash-Lite, 2.5 Pro and Flash. Limits not published on the page; blogs say about 5 to 15 requests/minute. | No | **Yes outside EEA/UK/CH** (secondary) | B and C: reading screenshots, checking text, small reviews. |
| **Antigravity free** | Weekly "basic" cap, Gemini 3.8 Flash, CLI included. | No | not checked | B, trial for A. |
| **Groq** | Free plan reported at 30 requests/min, 1,000/day, **8,000 tokens/min, 200,000 tokens/day** for gpt-oss-120b, gpt-oss-20b and qwen3.8-27b (DEV post 2026-10-07; the official page I opened showed the paid Developer table with the same numbers). | No | Not stated | C only. 8K tokens/min cannot take a real diff. |
| **Cerebras** | Official docs: free trial lists gpt-oss-120b and qwen-3.8-27b at 5 requests/min, 1M tokens/day, **but the key stays inactive until you add a verified payment method**; $5 credit expires in 30 days. | **Yes** | No (per blog) | Skip. |
| **SambaNova** | Sources conflict (200K tokens/day with no card vs card required). | ? | ? | **Unverified**, skip. |
| **Mistral (La Plateforme "Experiment")** | Roughly 1B tokens/month or $10/month credit, conflicting; Codestral included. | Phone check | **Yes unless you opt out** | C only. |
| **GitHub Models** | **Retired 2026-07-30** (official docs). | n/a | n/a | Dead. |
| **OpenRouter `:free`** | 20/min, 50/day (1,000/day after $10 top-up all-time). Models like nemotron-3-super-120b and gemma-4-31b. | No | Free providers may log prompts; account toggle blocks training providers | C only. |
| **Cloudflare Workers AI** | 10,000 Neurons/day free; only older qwen2.5-coder-32b and gpt-oss on the free path; GLM and Kimi need paid Workers ($0.011 per 1,000 Neurons). | No | Not stated | C only. |
| **Hugging Face Inference** | $0.10/month free credit (DEV post). | No | Varies by provider | Skip. |
| **NVIDIA NIM (build.nvidia.com)** | "Free inference"; lists deepseek-v4.1-flash, nemotron-3.5 models. Blogs: 40 requests/min, up to 10,000/day, NVIDIA Developer Program signup. Official page gave no limits. | No (disputed) | Not stated | **B: best free reviewer to test**, unverified limits. |
| **Together, Fireworks, DeepInfra, Novita, SiliconFlow** | Pay-per-token hosts of open models. DeepSeek V4 Pro 0813 about $1.30 to $1.60 in / $2.60 to $3.96 out; Novita GLM-5.3-Flash $0.15 / $0.50. No meaningful free tier. | Yes | DeepInfra lists zero retention | A or B at DeepSeek-level quality with US hosting. A little dearer than DeepSeek direct off-peak. |
| **Chutes** | $3 / $10 / $20 plans, limits changed to dollar-based caps in Feb 2026; cheapest plan lost the frontier models (secondary). | Yes | ? | Skip. |
| **DeepSeek direct** | See 4.5. Off-peak half price. Note: search/fetch tool calls through Claude Code or Codex are free until 2026-11-01. | Yes (prepaid) | **Unverified**; servers in China | A (simple) and B. |
| **Kilo Code / Cline / Roo / OpenCode** | Free tools; you bring a key. Kilo gateway reports a free pool (200 requests/hour per IP). OpenCode Zen free models list changes; data collected in the free period may be used to improve models. | No | **Yes on free pools** | Skip: you already have a working harness. |
| **Qwen Code CLI** | Tool free; **free hosted login ended 2026-04-15.** | n/a | n/a | Dead (use API key). |
| **Amazon Kiro** | Free 50 credits/month. | No | not checked | Skip. |
| **Cursor Hobby / Windsurf Free / Copilot Free** | Tiny agent allowances; Copilot Free includes the CLI with auto model only and an unstated credit amount. | No | not checked | Skip. |

**Bulk work recommendation (role C)**: local qwen3.8:27b first (free, reads images); then the Gemini free key (watch the training flag), then Claude Haiku 5.5 ($0.10 / $0.50) or GPT-6 Luna ($0.10 / $0.50) if you are paying anyway.

---

## 6. Privacy and "trains on my code" flags

| Service | Flag |
|---|---|
| Gemini API free key | Prompts may improve Google products outside EEA/UK/CH (secondary sources). Paid key avoids it. |
| Mistral Experiment | Free-mode prompts may train models unless you opt out. |
| OpenRouter free models | Providers may log prompts; set the privacy toggle. |
| OpenCode Zen free models | Free-period data may be used to improve the model. |
| DeepSeek, Z.ai, Moonshot, MiniMax, Alibaba | Data processed in China; training terms not verified. |
| ChatGPT Plus (Codex) | Consumer "improve the model" setting applies; check Settings > Data controls. Not verified here. |
| Antigravity / Google AI Pro | Consumer Google terms; not verified here. |
| Copilot | Fable 5 / 5.1 keep data by default for safety classifiers (official GitHub docs). |
| Venice | Claims private or anonymized; not verified. |
| Local Ollama | Nothing leaves the PC. |

---

## 7. What you need to do (top 3, plus the small one)

**1. ChatGPT Plus + Codex ($20/month)**
1. Subscribe to Plus on chatgpt.com (use a ChatGPT account you control; do not share the login).
2. In PowerShell run the Windows installer from github.com/openai/codex (or `npm install -g @openai/codex`).
3. In the game folder run `codex` once, choose "Sign in with ChatGPT", finish in the browser. Then tell a helper "Codex is signed in"; it writes `codex-lane.sh` with `codex exec --sandbox workspace-write`, ports the command allow-list, and runs the pilot.
4. In ChatGPT Settings > Data controls decide on the "improve the model" switch.

**2. Local reviewer, free**
1. Update Ollama to 0.32.15 or newer.
2. Run `ollama pull qwen3.8:27b` (about 18 GB).
3. Run `ollama ps` while a prompt runs and confirm it says 100% GPU. Tell a helper to swap it in for qwen2.5-coder:32b in the overnight audit and the screenshot critic.

**3. Google Antigravity (free now, $20 only if good)**
1. Install with the PowerShell line above (`irm https://antigravity.google/cli/install.ps1 | iex`) or from antigravity.google.
2. Run `agy` once and sign in with a Google account.
3. Run the pilot on the free tier. Subscribe to Google AI Pro ($20, one.google.com) only if Gemini 4 Argon access and the quota hold up for two days.

**4. Small extra: DeepSeek ($10)**
1. Create an account at platform.deepseek.com, add $10, create an API key.
2. Give the key to the lane through a Windows environment variable (never paste it into chat or a file in the repo). A helper sets `ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic` and the model names in one lane copy.

---

## 8. One-day pilot before spending more

Pick five finished jobs from the queue (two small, two medium, one UI job). Run each through: Codex Plus, Antigravity, DeepSeek V4 Pro through `claude -p`, and the baseline Claude lane. Record for each: gate passed or failed, number of attempts, minutes, and how much of the weekly allowance moved (`/status` in Codex, the usage page in Google and Claude, the DeepSeek dashboard). Keep any lane whose gate pass rate is within one job of Claude's. That is the only reliable answer for a single 5.5 MB file.

Timing: the feature cutoff is Mon 10/26, so the pilot should run 10/19 to 10/20.

---

## 9. Biggest uncertainties

1. Weekly allowance size for Codex Plus and Google AI Pro is not published; the pilot decides.
2. Whether a Codex lane can run unattended under Git Bash on Windows with the sandbox on, and whether the Claude command allow-list can be ported with the same safety.
3. Whether Anthropic moves `claude -p` onto a separate credit pool (a planned 2026-06-15 change was reported paused; reports conflict).
4. Whether cheap models (DeepSeek, GLM) pass the headless-Chrome gate often enough to save money after retries.
5. Quotas and plan names are changing monthly (OpenAI Pro tiers, Google Ultra, Grok tiers); anything bought now may change by the 11/26 release.

---

## 10. Sources (fact, date)

Date shown is the publication or last-update date when the page gave one; "undated" means none was visible and the page was fetched 2026-10-19.

**OpenAI**
- Plans, Codex limits, credits, model retirement notice: https://learn.chatgpt.com/docs/pricing (redirect from developers.openai.com/codex/pricing); undated, notices up to 2026-11-21.
- `codex exec`: https://learn.chatgpt.com/docs/non-interactive-mode; undated.
- Install, Windows PowerShell installer, Apache-2.0: https://github.com/openai/codex; undated.
- Pro-tier history, Plus table, "checked 2026-10-02": https://simplemetrics.xyz/chatgpt-codex-limits-2026/; updated 2026-10-19 (secondary).
- $200 Pro pause and reopen dates: https://www.developersdigest.tech/blog/codex-usage-limits-pricing-2026; published 2026-09-28, updated 2026-09-29 (secondary).
- API prices GPT-6.x (matches OpenAI credit table): https://docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing; undated.
- Windows sandbox: https://developers.openai.com/codex/windows (search result only).
- Subscription-auth policy comparison: https://zylos.ai/research/2026-07-13-subscription-auth-boundaries-official-cli-agent-automation; 2026-07-13 (secondary).

**Google**
- Gemini CLI to Antigravity CLI: https://developers.googleblog.com/an-important-update-transitioning-gemini-cli-to-antigravity-cli/; 2026-05-19.
- Plan prices and multiples: https://www.antigravity.google/blog/changes-to-antigravity-plans; 2026-05-19.
- Plans and limits wording: https://antigravity.google/docs/plans and https://antigravity.google/pricing; undated.
- Headless mode: https://antigravity.google/docs/cli/headless; undated. Migration: https://antigravity.google/docs/cli/gcli-migration; undated.
- Gemini API free-tier models and prices: https://ai.google.dev/gemini-api/docs/pricing; updated 2026-10-16. Rate-limit framework: https://ai.google.dev/gemini-api/docs/rate-limits; updated 2026-10-15.
- Google AI plan coding benefits: https://one.google.com/about/google-ai-plans/; undated, no prices shown.
- Windows installer line (unofficial): https://www.how2shout.com/how-to/how-to-install-antigravity-cli-on-windows-11.html; undated.

**xAI**
- Grok Build install, headless: https://docs.x.ai/build/overview and https://docs.x.ai/build/cli/headless-scripting; undated.
- API prices: https://docs.x.ai/docs/models; undated (Grok 4.7 cutoff May 2026).
- Subscription prices and tiers: secondary only (cloudzero, ai-toolbox.co updated 2026-10-08): **unverified**.

**GitHub**
- Plans and credits: https://docs.github.com/en/copilot/get-started/plans and https://docs.github.com/en/copilot/concepts/billing/usage-based-billing-for-individuals; undated (change effective 2026-06-01).
- Models: https://docs.github.com/en/copilot/reference/ai-models/supported-models; undated.
- CLI flags: https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-programmatic-reference; undated.
- GitHub Models retired 2026-07-30: https://docs.github.com/en/github-models/use-github-models/prototyping-with-ai-models.

**Anthropic**
- Plans, weekly limits, usage credits: https://claude.com/pricing and https://support.claude.com/en/articles/11145838-using-claude-code-with-your-pro-or-max-plan; undated ("updated this week").
- Max API credits: https://platform.claude.com/docs/en/about-claude/api-credits-for-subscribers; undated.
- API prices: https://platform.claude.com/docs/en/about-claude/pricing; undated.

**Cheap and Chinese models**
- DeepSeek prices, Anthropic endpoint, peak hours: https://api-docs.deepseek.com/quick_start/pricing; undated (V4 Pro 0813 = 2026-08-13; V4.1 Flash 1017).
- Z.ai plan and Claude Code setup: https://docs.z.ai/devpack/overview and https://docs.z.ai/devpack/tool/claude; undated. Pro/Max prices: https://hyscaler.com/insights/glm-coding-plan-review (July 2026, secondary).
- Kimi: https://platform.kimi.ai/docs/guide/agent-support; undated. K3 price: https://artificialanalysis.ai/articles/four-frontier-launches-in-eight-days-six-labs-now-field-a-model-above-50-on-the-artificial-analysis-intelligence-index; 2026-07-17.
- MiniMax: https://platform.minimax.io/docs/token-plan/intro; undated. Alibaba: https://help.aliyun.com/en/model-studio/coding-plan; undated (search snippet).
- DeepInfra DeepSeek hosts: https://deepinfra.com/blog/deepseek-v4-pro-pricing-guide-2026-providers-cost-analysis; 2026-04-30, prices accessed Oct 2026.

**Benchmarks**
- Agent index (mirror): https://benchlm.ai/benchmarks/aacodingagents; captured 2026-10-19. Original: https://artificialanalysis.ai/agents/coding-agents. Earlier index article: 2026-07-17 (link above).
- SWE-bench Verified, Vals AI: https://www.vals.ai/benchmarks/swebench; 2026-09-01.
- Terminal-Bench 2.1 (Vals data on BenchLM): https://benchlm.ai/benchmarks/valsterminalbench21; 2026-10-19.

**Local models**
- Ollama page: https://ollama.com/library/qwen3.8; undated ("3 weeks ago").
- Qwen3.8-27B release, vendor benchmarks: https://letsdatascience.com/news/alibaba-releases-qwen38-27b-for-local-ai-workloads-ce2a4a89; Alibaba release 2026-08-14.
- 7900 XTX guide (estimates only): https://bestllmfor.com/guide/llm-radeon-rx-7900-xtx/; updated 2026-09-29.
- Devstral Small 2: https://vercel.com/ai-gateway/models/devstral-small-2; release 2025-12-09 (secondary).

**Free and cheap services**
- Perplexity API prices: https://docs.perplexity.ai/docs/getting-started/pricing; undated.
- Venice: https://venice.ai/pricing and https://docs.venice.ai/overview/pricing; undated.
- OpenRouter limits, pricing, privacy: https://openrouter.ai/docs/api-reference/limits , https://openrouter.ai/pricing , https://openrouter.ai/docs/features/privacy-and-logging; undated. Free-API comparison: https://openrouter.ai/blog/tutorials/free-llm-apis-compared/; 2026-06-15, updated 2026-09-24 (partly stale).
- Free tiers snapshot: https://dev.to/tariqnasser/free-llm-api-tiers-in-october-2026-whats-left-and-how-i-chain-them-227l; 2026-10-07 (secondary).
- Groq limits: https://console.groq.com/docs/rate-limits; undated (Developer plan shown). Cerebras: https://inference-docs.cerebras.ai/support/rate-limits; undated.
- Cloudflare Workers AI: https://developers.cloudflare.com/workers-ai/platform/pricing/; undated. NVIDIA: https://build.nvidia.com/; undated.
- Qwen Code free login ended: https://inventivehq.com/blog/qwen-code-still-free-2026-shutdown (secondary). Kiro: https://usagebar.com/blog/kiro-pricing-and-rate-limits (secondary). Cursor: https://www.jetadmin.io/blog/cursor-pricing-explained-plans-credit-system-and-real-costs-in-2026/ ; 2026-07-27 (secondary). Windsurf/Devin: https://www.morphllm.com/comparisons/windsurf-vs-copilot (secondary).

Unverified list (could not confirm on an official page): Codex weekly caps; Google Pro/Ultra weekly caps; Grok subscription prices and quotas; Z.ai Pro/Max prices; Kimi Code tiers; all China-hosted training terms; NVIDIA free limits; Gemini free-tier numbers; Copilot CLI on Windows; Antigravity on Windows (official); Groq free-plan tab numbers; SambaNova; Chutes.
