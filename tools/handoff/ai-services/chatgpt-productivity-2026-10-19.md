# Getting more ChatGPT (Codex) work per dollar (research, sonnet agent, 2026-10-19)

Saved by the coordinator. The agent's sources:
- learn.chatgpt.com/docs/* (OpenAI's docs; developers.openai.com/codex redirects there).
- help.openai.com and openai.com blocked the fetcher (403), so those facts come from search snippets.

## Measured on his PC (coordinator, 10-19 11:47)
- **Usage:** `~/.codex/sessions` rollout shows plan_type plus. The 5-hour window was 50% used after ~1.5 h of lane work (resets 15:02). The weekly window is 8% used (resets Mon 10-26 10:02). No credits.
- **Models:** `~/.codex/models_cache.json` lists gpt-6.1-sol (in use), gpt-6-sol, gpt-6-astra, gpt-6-luna, and the gpt-5.6 models. gpt-6-luna efforts are low to max.
- **Lane runs:** input is 93-96% cached. A resumed thread grows every run: o-03 reached 7.45M tokens by run 5. Run 1 read 434k chars, 113k of them style guide and notes.

## Key facts
- **One allowance for everything.** The ChatGPT desktop app, IDE extension, CLI and cloud tasks all draw on it. Cloud tasks cost more than local ones.
  - The Codex app merged into the ChatGPT app on 2026-07-09.
  - ChatGPT agent mode was removed in about August 2026 and replaced by ChatGPT Work.
  - A desktop app adds nothing for the helper lane.
- **Plus limits.** A rolling 5-hour window, restored for Plus 2026-08-25, plus an unpublished weekly cap. Rough messages per 5 hours by model:

  | Model | Messages per 5 h |
  |---|---|
  | GPT-6.1 Sol | 15-160 |
  | GPT-6 Luna | 350-3000 |
  | GPT-6 Astra | 5-45 |

- **What costs more.** Model, context, reasoning, tools and caching all count.
  - Fast mode costs 2.5x and ultrafast 8x.
  - Credit rate card per 1M tokens:

    | Model | Input | Cached input | Output |
    |---|---|---|---|
    | gpt-6.1-sol | 50 | 2.5 | 250 |
    | gpt-6-luna | 2.5 | 0.25 | 12.5 |

  - Unverified: whether the plan allowance weighs cached tokens the same way.
- **Credits.** Plus can buy credits in Codex Settings > Usage > Credits. They are used only after the included allowance runs out, last 12 months, and are non-refundable.
  - Price unverified: about $0.04 a credit (secondary source).
  - Estimates: a typical Sol run costs about $0.40-0.70; the same run on Luna about $0.05.
- **Pro** is $100, $200 or $500 a month, with no 5-hour limit and a weekly cap only. The official multiples were removed. **Business** gives standard seats Plus-level limits.
- **Reasoning effort.** It is billed as output.
  - Cost per task for Sol (third party): low $0.13, medium $0.21, high $0.32, xhigh $0.39, max $0.72.
  - Coding scores (third party) are much closer:

    | Model | medium | high |
    |---|---|---|
    | Sol | 73.0% | 75.2% |
    | Luna | 44.5% | 59.3% |

  - OpenAI suggests Sol at medium for everyday coding and Luna at high for focused, repeatable tasks.
  - Avoid ultra, which spawns subagents.
- **Cache.** A cached prefix lives at least 30 minutes after its last use. Keep the stable text first and the job text last. Measure the cache ratio from `turn.completed` usage.
- **Parallel jobs** share the allowance: no gain, and they drain the window faster.
- **API keys.** Signing in with a key bills API prices. The lane refuses that already. Also pass `-c forced_login_method="chatgpt"`.
- **Training.** Plus chats may be used for training by default. The opt-out is ChatGPT Settings > Data Controls > "Improve the model for everyone", plus a separate Codex environment setting. This is HIS setting.

## Ranked changes
1. Send mechanical jobs to gpt-6-luna at high. That is about 20x less allowance per job. Pilot it first.
2. Make Sol medium the default and step up to high only on later tries. That is about 35% less per task.
3. Cut reading: an index of the game file, small reads, and a fresh thread instead of a fat resume. About 1.5-3x on heavy runs (estimate).
4. Keep the cache warm by running jobs back to back. Log cached/input per run.
5. Optional, his purchase: a small credit pack so work continues past a limit at a known price.
6. Pace the lane to the limits: read used_percent from the session log and sleep until the reset instead of failing mid-run.
7. Upgrade to Pro $100 only if credits would pass about $80 a month.
8. Skip the Windows app, the IDE extension, cloud tasks and parallel jobs. None of them adds allowance.
