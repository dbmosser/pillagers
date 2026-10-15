# CLOUD DRAFTS (written 2026-10-15 by the cloud session; read this first in any cloud session that finds or drafts fixes)

## Why this exists
His order 2026-10-15: spend the cloud credits on Pillagers development. The PC session keeps shipping to master, so the
cloud never ships and never pushes to master. The cloud FINDS problems, proves them in headless Chromium, and writes
ship-ready drafts in the PC's own format (tools/handoff/drafts/draft-KEY.json). Each draft has passed the same gates the PC
runs. The PC ships one with `bash tools/handoff/shipone.sh KEY PREV NEW`, which costs it almost nothing.

## Setup in a fresh cloud container (about 1 minute)
    mkdir -p /opt/pwsh && cd /opt/pwsh && curl -sSL -o p.tgz https://github.com/PowerShell/PowerShell/releases/download/v7.4.6/powershell-7.4.6-linux-x64.tar.gz && tar xzf p.tgz && rm p.tgz && chmod +x pwsh && ln -sf /opt/pwsh/pwsh /usr/local/bin/pwsh
    cd <repo> && git fetch origin master && git merge --no-edit origin/master     # always gate against the newest game
    pwsh -NoProfile -File tools/mkfixture.ps1 -Root "$PWD" -Src "$PWD/dark_raiders.html" -Dst "$PWD/tools/fixture.html"
Playwright and Chromium are preinstalled (/opt/pw-browsers). tools/fixture.html is the game plus window.__* test hooks.

## Tools (tools/cloud)
- `node tools/cloud/run.mjs eval fixture.html 'JS'` runs JS in a freshly loaded fixture at 1920x1080 and prints the result.
  Use it to PROVE a bug before drafting: drive the game through the hooks the checks use (__deploy, __state, __frame,
  __endRaid, __runPrep, __topClear, __resetCfg, __cleanProfile, __pinDefaults, w2s ...). Read recent checks in
  tools/mkfixture.ps1 for how they set up a raid, a two-player pair, a menu, a 4K viewport.
- `node tools/cloud/run.mjs check fixture.html V N` runs the checks with v===V N times. `recent fixture.html all 80` runs the
  newest 80. `verify fixture.html` is the seed 4242 fingerprint. `net FILE runsame` is the two-window test.
- `python3 tools/cloud/draftgate.py KEY` is THE GATE for tools/handoff/drafts/draft-KEY.json against this checkout's game:
  anchors match once, ASCII, fixture builds, parse PASS, new check PASS x2 on the drafted build, FAIL (not SKIP) on the
  current build, no new failure in the newest 80 checks, fingerprint ents {0:85,1:374} containers {0:165,1:593},
  node --check. It prints GATE PASS or STOP <reason>. About 4 minutes. At most 2 gates at once on 4 cores.
- Baseline at v27.23 in cloud headless: of the newest 80 checks only 27.14 fails ("the stack drew 3 of its 6 rows at
  1918x1078"); everything else passes; fingerprint unchanged.

## Draft format (exactly what tools/handoff/drafts/gen-draft.ps1 reads)
    {"title": "SHORT CAPS TITLE",
     "why": "plain words: what was wrong, how it was proven, what changes",
     "now": "one player-facing sentence for the what is new line",
     "edits": [{"anchor": "whole existing line(s) of dark_raiders.html, exact, matching ONCE",
                "replacement": "the new line(s), with a comment // v27.xx (cloud-KEY), CLOUD HUNT 2026-10-15: why"}],
     "check": "  {v:'VER',what:'KEY: what must be true',\n   run:function(){ ... return null on pass, a string on failure, 'SKIP: ...' only when the fixture cannot run it }},"}
- Anchors are whole lines (the gate escapes each line and allows \r\n). Keep anchors short but unique. ASCII only.
- The check is synchronous (no promises), restores everything it changes (try/finally), and must FAIL on the current build.
  Parse gate: write `return (/re/).test(x)`, never `return /re/.test(x)`. Never put a line starting with '@ in a draft.
- One thing per draft. KEY is `cloud-<area>-<slug>` (lowercase, dashes) so it never collides with a PC draft.

## Rules (binding; tools/handoff/RULEBOOK.md outranks this file)
- Fix only what you can PROVE with output: bugs, crashes, dead controls, stuck states, wrong or cut-off text, a player 2
  window that does not see or feel what the host does, a menu that dead-ends or that the controller cannot reach,
  frame time over 16 ms at 1080p. No new features. No design or feel changes.
- His 50 open polish questions (tools/handoff/research/polish-50-questions-2026-10-15.md) are HIS to answer: never draft a
  change to anything they ask about (keep, cut, size, rate, colour, position of those features). A crash or a plain bug
  inside one of those features is still a bug and may be drafted.
- Never reword a sentence that is a key in `var TXSHIP=`. Player text uses his words (backpack, tactical belt, ascend,
  extract, hire, Undercroft; never boarding, ship as a word, touchdown, hotbar, bag as a word).
- Never change the storage key salvagerun:profile or the save format without a migration. Simulation, AI, collision and
  line of sight stay in flat top-down coordinates; rendering and HUD stay a separate layer. No 3D, no WebGL, no libraries.
- Never commit dark_raiders.html or tools/mkfixture.ps1. Commit only drafts, findings and tool changes under tools/.
- Never push to master and never touch itch. Push only to the branch your session was given.
- Findings that need his ruling, or that are too big for one draft, go in tools/handoff/cloud/<area>-findings.md with the
  proof (the eval output), never as a draft.

## Output of a cloud hunt
- tools/handoff/drafts/draft-cloud-*.json, each with GATE PASS.
- tools/handoff/cloud/<area>-findings.md: one row per finding: what, proof, draft key or why not drafted, gate result.
