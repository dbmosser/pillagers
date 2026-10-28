# Model escalation research (2026-10-27)

Bottom line: your current ladder is close to what the evidence supports. Two changes: never use Sonnet at xhigh or max (Opus is the better buy there), and try the new Advisor feature on mid-weight jobs. Vendor pages were fetched today; other sources are dated. Reddit could not be fetched, so r/ClaudeAI, r/vibecoding and r/gamedev practice is unverified.

## What others do
- Cheap first, escalate on failure. Anthropic's own help page (undated, current) says Sonnet for features, tests, known bugs and refactors; Opus for hard debugging, wide refactors and architecture; Haiku for renames and boilerplate ([source](https://support.claude.com/en/articles/14552983-models-usage-limits-in-claude-code)).
- Failure counts. The open-source [agent-router](https://github.com/SuperIsOleg/agent-router) climbs haiku, sonnet medium, opus high, opus xhigh, moving up after the second failed check or at once on context overflow. [Evolink](https://evolink.ai/blog/claude-sonnet-5-coding-agents-routing) (Jul 1, updated Sep 29 2026): retry a failing test once, escalate if Sonnet fails twice.
- Strong plans, cheap builds. Anthropic recommends planning with Opus, executing with Sonnet. A game-dev blog ([Sorceress](https://sorceress.games/blog/which-ai-model-is-best-for-coding-indie-game-dev-2026), Jun 13 2026) says the same, but it sells a product.
- Second vendor. In [Hacker News threads](https://news.ycombinator.com/item?id=48849126) (about July 2026), people have Claude review Codex output, loop the two to consensus, or buy Codex because its limits last longer.

## What the tools offer now
All confirmed in current Anthropic docs ([models](https://code.claude.com/docs/en/model-config), [subagents](https://code.claude.com/docs/en/sub-agents), [advisor](https://code.claude.com/docs/en/advisor), [caching](https://code.claude.com/docs/en/prompt-caching)).
- opusplan exists: Opus in plan mode, Sonnet to execute. Each plan toggle is a model switch with a fresh cache.
- Subagent frontmatter takes `model` (sonnet, opus, haiku, fable, full ID, inherit) and `effort`. Order: per-call parameter, frontmatter, `CLAUDE_CODE_SUBAGENT_MODEL`, main model. Haiku 5.5 (Oct 7 2026) is pitched for subagents ([tip](https://wmedia.es/en/tips/claude-code-haiku-5-5-subagents)).
- Effort low to max, default medium. Docs: medium for clear-scope work, high for bug fixes in existing code, max "prone to overthinking". Changing effort keeps the cache on 5.5 models.
- Advisor (experimental): `/advisor opus`. Sonnet 5.5 works while Opus 5 or later advises. Claude decides when to ask: before an approach, on a recurring error, before declaring done. Advisor tokens count against plan limits; toggling keeps the cache. Anthropic's [Apr 9 2026 post](https://claude.com/blog/the-advisor-strategy) reports +2.7 points and 11.9% lower cost per task on older models; unverified on 5.5.
- Fast mode is Opus only and bills usage credits, not your plan: skip. Fable 5.1 sits above Opus ($10/$50); not on your list.
- Codex ([OpenAI docs](https://learn.chatgpt.com/docs/models)): Astra flagship, Sol near Astra and cheaper, Terra fast, Luna smallest. GPT-5.5 left Codex on Oct 14 2026, so older blogs are stale. Plus gets roughly (per 5 hours, [pricing](https://learn.chatgpt.com/docs/pricing)) Astra 5 to 45, Sol 15 to 160, Terra 35 to 285, Luna 350 to 3,000 local messages. Effort Low to Extra High; start at default. A [preset example](https://dev.to/gabrielanhaia/one-command-per-kind-of-task-model-and-effort-presets-for-claude-code-and-codex-fgp) (Oct 19 2026): chore Luna low, feature Sol medium, deep Sol xhigh.

## Cost versus quality evidence
Prices per million tokens in/out: Opus 5.5 $4/$20, Sonnet 5.5 $2/$10, Haiku 5.5 $0.10/$0.50 ([pricing](https://platform.claude.com/docs/en/about-claude/pricing)).

Artificial Analysis Intelligence Index, score / cost to run the index (pages read today; general intelligence, not game coding; [example](https://artificialanalysis.ai/models/comparisons/claude-opus-5-5-high-vs-claude-sonnet-5-5-xhigh)):

| Effort | Sonnet 5.5 | Opus 5.5 |
|---|---|---|
| low | n/a | 35 / $980 |
| medium | 30 / $679 | 48 / $2,031 |
| high | 41 / $1,268 | 52 / $2,716 |
| xhigh | 50 / $2,902 | 57 / $4,766 |
| max | 54 / $7,981 | 58 / $8,910 |

Reading it: Sonnet high is the cheapest sensible level. Above it, Opus wins: Opus high beats Sonnet xhigh for less money, Opus xhigh beats Sonnet max at 60% of the cost. Opus max adds one point over xhigh for 87% more. Sonnet at max writes about 60% more tokens ([Codersera](https://codersera.com/blog/claude-sonnet-5-5-vs-opus-5-5-2026/amp/), secondary), and Anthropic says it sometimes makes out-of-scope edits.

Anthropic's launches ([Sonnet 5.5](https://www.anthropic.com/news/claude-sonnet-5-5), Sep 28; [Opus 5.5](https://www.anthropic.com/news/claude-opus-5-5), Sep 22): Sonnet suits well-scoped work; Opus is "clearly stronger" on open-ended work. Gaps: CursorBench 55.5 vs 57.8, FrontierCode 46.2 vs 54.4. CodeRabbit's vendor test (13 cases, [Oct 2026](https://coderabbit.ai/blog/sonnet-5-5-model-review)): Sonnet found 6, Opus 8 standard, 10 at max. I found no solid retry-rate data and no published plan-limit multiplier per model; Anthropic says only that Opus uses "meaningfully more" quota.

## Escalation triggers that work
- Two failed attempts on the same rung (agent-router, Evolink).
- One failed test: retry once, then move up.
- Context overflow or a looping agent: summarize and restart before spending a higher rung.
- A recurring error, or "before declaring done": the Advisor's own trigger points.
- Final audit by a different model than the writer.
- Raise effort before adding tools: a 90-run study ([secondary summary](https://codex.danielvaughan.com/2026/07/06/reasoning-effort-not-tool-access-first-try-reliability-agentic-code-generation-codex-cli-reasoning-configuration/), Jul 6 2026) found high to xhigh lifted perfect first runs from 28% to 89% for 9 to 29% more cost; one app, so treat as a hint.

## Recommendation for this project
Ladder, start each job here:
1. Free: qwen reviews every diff. Haiku 5.5 low as Explore and log-reading subagent (define `Explore` with `model: haiku`).
2. Codex Plus: small, exactly specified fixes on Sol medium; one-number and rename chores on Luna or Terra low. Two failed gate runs, move to Claude.
3. Sonnet 5.5: text and one-number jobs at medium; layout at high. Never xhigh or max.
4. Opus 5.5 high: normal fixes (docs: high for bugs in existing code). Opus medium for clear-scope polish.
5. Opus 5.5 xhigh: crashes, second-failure jobs, rendering and netcode mysteries. Skip max.

Moves up: two failed gate runs on one rung, a new check that will not fail on the old build, or qwen flags a real bug the writer then misses. Restart the higher rung fresh with a short failure summary (my inference).

Moves down: after Opus finds the root cause, hand the mechanical edit to Sonnet medium or Codex with an exact written spec. Text-only changes never touch Opus.

Trial after Nov 1: Sonnet high with `/advisor opus` on ten mid-weight fixes against Opus high, comparing `/usage` share and gate pass rates. Log rung, retries and usage per job.
