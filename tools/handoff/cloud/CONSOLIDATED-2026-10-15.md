# Cloud work consolidated into master (2026-10-15 ~07:30 EDT)

His order: "looks like you managed to spend all my cloud credits. shut down the whole cloud thing and consolidate. i am going to delete the cloud threads in an hour".

## What was shut down
- Routine trig_01HEDd8cmNkBQyJr5jdecPZp ("Check Pillagers cloud hunts", which restarted the hunt sessions hourly): disabled.
- Routine trig_01RyMeNpuRpjgDmm9ENSSiJX ("harness refresh + corpus on HEAD", run once at 03:13Z): disabled.
- Routine trig_01Nqmjg7sDVCub7Yr9NkN2Se (the 09-27 hourly build): was already disabled.
- All six cloud sessions were idle when this was done: Cloud Pillagers Development, and Cloud Hunt Two-Player Parity, Combat Feel and Frame Time, Raid Features, Menus Stash Settings, and Crashes Leaks Long Play. No cloud session was woken, because waking one would bill his plan now that the credit is gone.

## What is now in master (no change to dark_raiders.html)
- **The consolidated cloud branch (merged).** That is claude/missing-pillages-dcode-chats-batkhi, which brought in:
  - tools/handoff/cloud/: INDEX.md (READ FIRST: duplicates to drop, overlapping fixes, three drafts that need his ruling) and README.md;
  - the five hunt findings files: coop, feel, menus, raid, robust;
  - tools/handoff/CLOUD-DRAFTS.md;
  - 96 gated drafts, tools/handoff/drafts/draft-cloud-*.json;
  - tools/cloud/draftgate.py and a run.mjs `recent` command;
  - .gitignore (tools/gd-*.html).
- **cloud/harness (merged).** tools/cloud/README-2026-10.md, gate.sh, gate.py, corpus.sh, smoke/. Its run.mjs variant of `recent` now lives as `recent2` beside the consolidated `recent`, and gate.sh calls `recent2`. That harness was marked "work in progress" by its own session.
- **Three raid-hunt drafts that were not in the consolidated index:** draft-cloud-raid-bountycomma, chiponce and cluecount. They are probably superseded: v27.43 shipped the cloud review fixes for fires, crates, bounty, convoy and keys, and the clue hunt was cut at v27.47. Gate them before use, or drop them.
- **tools/handoff/research/cloud-review-2026-10-15.md**, the 35-finding static review. Most findings were handed to PC agents, and several shipped in v27.42-v27.52.
- **Already on master before this merge:** hud-spec (md and html), experimental-flags, tools/cloud/sound-pack/ and ui-cleanup.

## How to use the drafts on the PC
- Ship with the PC queue. Many drafts are based on v27.32-v27.52, and master has moved, so an anchor can STOP. That STOP is correct: re-draft or drop, never force.
- Follow INDEX.md: ship the first key of each duplicate pair and drop the rest. Ship one overlapping fix, then re-gate the others.
- Three need his ruling: cloud-coop-barrels-both-windows, cloud-coop-kid-firing-no-item and cloud-coop-mender-beams-seen.

## Branch tips (for the record; all content above is in master)
| Branch | Tip | Last commit |
|---|---|---|
| claude/cloud-hunt-coop | 95b7db57 | 2026-10-15 05:28 |
| claude/cloud-hunt-feel | fc4626e1 | 2026-10-15 06:34 |
| claude/cloud-hunt-menus | f790a3bc | 2026-10-15 05:31 |
| claude/cloud-hunt-raid | b6851407 | 2026-10-15 05:37 |
| claude/cloud-hunt-robust | e101975a | 2026-10-15 05:22 |
| claude/missing-pillages-dcode-chats-batkhi | b412b212 | 2026-10-15 08:41 |
| cloud/exp-flags | 63897229 | 2026-10-14 23:11 |
| cloud/harness | c456487e | 2026-10-15 03:19 |
| cloud/hud-spec | 00ed7686 | 2026-10-14 23:03 |
| cloud/review-2026-10-15 | f5f849b4 | 2026-10-14 22:54 |
| cloud/sound-pack | 35cb1352 | 2026-10-14 23:39 |
