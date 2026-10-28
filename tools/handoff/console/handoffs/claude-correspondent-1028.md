# Claude Correspondent handoff, 10-28 19:05 Eastern

**Role, his words (10-27 night):** "your job is to make sure we are getting the most bang for our buck out of our claude usage". He is not a developer ("i don't understand what any of this means. Im not a dev."): plain words, short, a chart when comparing chats, no em or en dashes.

**His standing orders to this seat**
- 10-27 night "this has to be AAA top to bottom": the model follows the job (model ladder in START-HERE.md); save by running fewer things at once, never by a weaker model for a hard job.
- 10-28 "do everything you've recommended" and "ok do all this" (the cost chart below).
- Pacing: the line in console/status-a.txt. At 18:34 the week was 84% against a line now aiming at 99% (83.3% at that hour). Burn fell from about 1.9 points an hour (10-27 evening) to about 0.5 (10-28 afternoon). The week resets Sun 11/1 1 am Eastern.

**Cost chart status (his "ok do all this")**
- Done: Dashboard Correspondent Opus high; Itch Correspondent and Reporter Sonnet high (CEO did these); HUD Improver and Gameplay Edit Intaker 2 archived; Main PC and Menus moved local and the Auditor's work queued (CEO, his "move them all to this pc").
- Open, unless the move to his PC already covered them: CEO and Efficiency Czar Opus high, Ultracode off; JT PC Correspondent Opus high, Ultracode off; Codex Correspondent Sonnet high, Ultracode off; Gameplay Edit Intaker Ultracode off (keeps Opus high); this seat Sonnet high. Chats opened from his app accept setting changes only from his own device; no tool turns Ultracode off.

**Shipped work**
- master a1495568: `.claude/settings.json` makes any session that names no model start on Opus 5.5 at effort high (ladder rung 3), plus a "Default model" line in START-HERE.md. An explicit model or effort still wins.
- Branch claude/exciting-noether-tbd76d: 2f48fac2 has the same content as master then, plus this file. Nothing else is unpushed.

**Check-ins**
- trig_01NLJiQDXCCBn2gUmThrX5XJ "Claude cost check (every 4 hours)": cron 28 */4 * * * UTC, starts a fresh cloud chat on Sonnet each run, phone alert. Test run 17:34Z worked; last fired 20:28Z. DISABLED (not deleted) at this handoff; it would next have run 00:28Z (8:28 pm Eastern). Re-enable it with update_trigger enabled=true, or replace it with your own check, not both.
- trig_01HXrsRgSVD6W3m3Ca4w4JZs deleted earlier: it fired into this chat and failed ACCESS_DENIED after his trusted-device approval.

**Do not**
- Call a model too strong for a hard job, or push Sonnet onto fix, polish or rendering work.
- Route around the trusted-device rule through another chat.
- Archive a chat he renamed or still uses without his yes.
- Quote usage from a stale local copy: fetch master first.
- Quote prices or model cost ratios from memory.
