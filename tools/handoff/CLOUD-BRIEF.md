# CLOUD BRIEF (read first in a cloud session)

Written 2026-09-26 when the session moved to the cloud. The local session kept these facts in private memory the cloud cannot see.

## The game
- PILLAGERS, one file: `dark_raiders.html` (canvas 2D extraction raid game). v15.84 at the move. Hosted on itch.io; the itch push (butler + his API key) happens ONLY on his PC. Never try to push to itch from the cloud and never ask for or handle his key.
- After every shipped build: `git push origin master` (repo dbmosser/pillagers) so his PC can pull.

## His standing rules (binding)
- No balancing: numbers, dials and loot tables are frozen. Bug fixes only.
- Never reword a sentence that is a key in the TXSHIP table (`var TXSHIP=`); his baked edits match whole sentences.
- Player text uses his words: never "boarding", "ship" (as a word), "touchdown", "hotbar", "bag" (as a word). Say backpack, tactical belt, ascend, extract, hire, Undercroft.
- Bandages and resting heal only to 85; only a Medkit reaches 100 (2026-09-16).
- Coming back empty: death or abandon returns with nothing; loadout goes back to the stash.
- No automatic switch to a gun. No raid music. Hills, verticality and woods are vetoed.
- Multiplayer (2026-09-25): co-op first, PvP later; up to 4; invite codes first, server later; push-to-talk and open mic with per-teammate mute, proximity chat for PvP enemies. Co-op: NO team damage at all; host dropping mid-raid (ending the party, losing the link) counts as ABANDON for everyone; the host extracting, dying or abandoning makes the host SPECTATE (2026-09-26, v16.14): the raid runs on in the host window until every friend is out; teammate revives in the first co-op version. Same-PC play: two windows on two screens, player 2 on a controller, title mode menu with his five rows (two SERVER rows greyed "coming later").
- Keep reports short and plain.

## Ship flow (tools/handoff)
Each build NNNN (version V = NNNN/100, e.g. 1585 = 15.85; 1600 = 16.00) has five files: `pNNNN.ps1` (SubRx whole-line anchors into the game, VER bump, DEVNOW `now:` line), `fNNNN.ps1` (inserts check `{v:'V',...}` above `  {v:'PV',what:` in `tools/mkfixture.ps1`), `dNNNN.txt`, `aNNNN.txt`, `cmNNNN.txt` (commit message ending with the Co-Authored-By line).
1. `powershell -File tools/handoff/dryrun.ps1 -Prev PREV -New NEW` builds `tools/fxdryNN.html` (patched game + patched fixture) and `tools/fxctlNN.html` (previous game + patched fixture) from scratch copies.
2. Gates: `parsecheck.html?f=fxdryNN.html` must read PASS; the new check must PASS twice on fxdryNN and FAIL (not SKIP) on fxctlNN.
3. `bash tools/handoff/ship.sh start PREV NEW` applies the build to the real files and rebuilds `tools/fixture.html`.
4. On fixture.html: the new check passes twice, and `__verifySafe()` returns pass true with ents {0:85,1:374} and containers {0:165,1:593} (the seed 4242 fingerprint; a change means a seeded draw moved).
5. `bash tools/handoff/ship.sh commit NEW cmNEW.txt` commits (its butler step does nothing without his key), then push to origin.
- These scripts are Windows PowerShell 5.1. In the cloud use tools/cloud (added 2026-09-26): install pwsh 7 to /opt/pwsh, then
  `tools/cloud/shipone.sh PREV NEW` runs the whole gated ship (dry run, parse, new check x2 on dry, FAIL on control, apply,
  parse, check x2 and fingerprint on fixture.html, node --check, commit with this session's attribution, push). Pieces:
  `dryrun.sh`, `ship.sh start|commit`, `ps.sh` (runs a handoff .ps1 with its C:\ paths mapped), `run.mjs parse|check|verify|seq|
  range|net|eval` (headless Chromium 1920x1080, own http server; `seq FILE A B` runs the corpus one check at a time, use at most
  3 shards on 4 cores or heavy checks time out; `net FILE run|runsame`, NETQ='&voice=1' adds the voice step), and `gen.py` with
  bNNNN.py files that write pNNNN/fNNNN in the house format. Never pipe dryrun.sh into head: SIGPIPE kills it before the control
  fixture is built. Patch scripts must stay ASCII.
- The fixture runner does NOT await promises: checks are synchronous. Parse gate: write `return (/re/).test(x)`, never `return /re/.test(x)`.
- Tests need a browser: serve the repo root and `tools/` over http (locally :8802 play, :8800 and :8803-8810 serve tools/) and drive headless Chromium at 1920x1080. 17 checks always fail in a full hidden-pane corpus and pass alone: 13.23 12.94 12.89 12.80 12.79 12.74 12.21 12.05 11.92 11.85 11.65 11.63 11.39 10.52 10.44 9.93 9.71. A real headless run may differ; rerun any red alone before believing it.
- Two-window multiplayer live test: `tools/nettest.html?f=fxdryNN.html` (RUN and RUN SAME MACHINE buttons).

## Shipped in the cloud session of 2026-09-26
v15.85 to v16.10. 1591 folded in his playtest bug (a guest took the lift alone into another raid). New since the queue: 16.03
lightning shows you to them at FLASH_SEE=2 times their sight (his order), 16.04 pause/Superhot/death beat in co-op, 16.05
teammate revives, 16.06 host owns clock, weather, bolts and rings (beacon for the party), 16.07 card, 16.08 party on the map,
16.09 voice (host hears all, friends hear the host; friend to friend needs a host relay), 16.10 voice by distance.
v16.11 to v16.14: backcheck fixes and the host spectates. HIS ORDER 2026-09-26: no more voice work (no relay, no lift radio); the game itself comes first. Card due by 16.22.

## Standing order and queue (2026-09-27)
HIS ORDER: never stop working. An hourly routine (trig_01Nqmjg7sDVCub7Yr9NkN2Se) wakes this session; it stops itself at $190 of
session spend (his $200 credit). Shipped v16.20 to v16.25: party pause, tracers and sounds shared, revive bar, teammate damage
numbers both ways, bandages and plates on a teammate, split speakers. NEXT, in order (mark each [done vX.YY] when shipped):
1. [done v16.26] Teammate health and armour bars on the HUD.
2. [done v16.41] An edge-of-screen arrow to a teammate who is off screen.
3. [done v16.43, live PASS] A ping key: mark a spot or an enemy for the party.
4. [done v16.42, live PASS] A kill feed: NAME killed CRAWLER.
5. [done v16.26] A downed teammate on the HUD with his bleed-out time.
6. [done v16.40, live test PASS] An end-of-raid party summary: each player's kills, loot, out or not.
7. [done v16.33] The what is new card refresh.
HIS NOTES 2026-09-27, in this order ahead of 2 to 4 and 6 (target: 4K fullscreen; test at 3840x2160):
a. [done v16.27] Pause when every player is paused; Superhot runs while either acts; teammate rows off the belt.
HIS PRINCIPLE 2026-09-27: in gameplay player 2 must equal player 1 in every way. HIS ANSWER 2026-09-27: fix player 2 parity, and do not ask him to confirm what his principle already decides. Kit choice for
player 2 [done v16.37].
CONTROLLERS [done v16.35] (his rule): player 1 plays mouse and keyboard; player 2 takes the first controller; a second controller goes to player 1.
P2 SHOTS [done v16.36: live test shows P2 hits, damages and kills host bodies; firstContact fixed]: his run reports (v16.25) show player 2 fired 24 shots at 0% accuracy, 0 kills, firstContact none in 339 s of co-op: check
   in a live nettest step that player 2's rounds hit the host's bodies, count as hits, and kill.
P2. PLAYER 2 FIRST (his notes, 2026-09-27 night): (i) [done v16.29] player 2 hears no audio at all: make SPLIT SPEAKERS the default for a same
   machine pair so both windows play (P1 left, P2 right); (ii) [done v16.32: Took lines already reached P2 (live test); the items-left count did not] player 2's looting shows no item names (the loot word path,
   netLootTake, should give the same labels and Took lines as a local search); (iii) [done v16.34, live test PASS] player 2's CURRENT PILLAGERS board is broken
   (it is built from bodies the host runs: names and values must come across); (iv) 'extract incoming' wording: use INBOUND.
b. [done v16.28] The HP bar can be folded or pushed under the belt: the vitals block must never fold, and the belt must fit around the vitals
   and gear blocks as the player has sized and moved them (hudUserZ, hudOff), shrinking slots rather than overlapping.
c. [done v16.30] The 5-minutes-left alarm (and the other clock alarms) are far too loud.
d. [warning done v16.38; host migration not built] Host leaving: either player 2 takes over as host, or the host's screen clearly says You are hosting. Quitting ends the raid for
   your party. (Do the warning first; host migration is large.)
e. Something blocks player 2's face in the Undercroft: not found yet (name tag uses the station camera; ask him for a screenshot).
f. [done v16.39] One hit of blotter should be less intense; blotter and liquor should affect the menu screens too.
g. [NOT shipped: b1647 caps the fog and light layers at 1920 wide; headless software raster at 3840x2160 measured it SLOWER (about 165 to 195 ms a frame), and SwiftShader is too slow to measure. Needs a real GPU measurement from his PC before shipping. tools/cloud/prof.mjs is the profiler.] Frame rate: improve it without losing anything (profile render2D and updateEnts at 4K).
h. [done v16.40] Item 6 (end-of-raid party summary) is his pick for next of the original list.
HIS ORDERS 2026-09-27 midday: [done v16.44] kid mode (player 2 damage 1/2, 1/4, 1/5, 1/10); [done v16.45] Settings in a raid, live;
[done v16.46] ping on D-UP (tap ping, hold map), shared map markers, danger ping, Fortnite practice. Live test covers ping and marker.
Player text: plain game language (his note), no retired words.

## Queue at the move (ship in this order)
- 1585 emote bar while downed (drafted, check it is complete), 1586 a controller can choose a sector (HIGH), 1587 night hour on the sector map, 1588 sector run count, 1589 hire never walks to a cache behind a locked door, 1590 pillagers never spawn in a locked room (verify the seed fingerprint). Findings: `tools/handoff/audit-wvw8zcvyw.json`.
- 1591 multiplayer: loot per player (host owns containers, one searcher per container) and the host leaving ends the run as abandon for everyone. Only p/f partly drafted: redraft. Design: `tools/multiplayer/plan.md`, `net.md`, `critique.md`; shipped net builds are described in `tools/handoff/d1574.txt` to `d1580.txt`.
- 1592 what's new card refresh (drafted; it anchors on v15.91).
- 1593-1600 credits, ghost and weather fixes (drafted). 1601-1602 not drafted: weather findings index 9 (use its correctedFix) and 10 in `tools/handoff/audit-wwhovd0n0.json`.
- Then the next multiplayer slices: revives, extraction per player, pause and Superhot rules in co-op; the what's new card every ~10 builds (WHATSNEW_VER must stay within 0.15 of VER).
