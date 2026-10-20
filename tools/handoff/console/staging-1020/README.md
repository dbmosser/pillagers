# staging-1020: the next queue for the idle lanes (planner draft, Tue 2026-10-20 about 13:00, game v32.90)

Nothing here is in tasks/ yet, and nothing is committed. The coordinator checks each draft's Source and Not done lines, then moves it.
Bottom line: 13 Claude lane jobs (58-70), 7 Codex jobs (o-13 to o-19) and 10 coordinator jobs fit this week's plan. 2 more are
stretch (71, 72). 3 are held for after the party (73, 74, coord-11).

## Ranked list (rank follows the brief: release steps and ordered features before Mon 10/26, then his notes, then quality, then bugs, then test health)
Job numbers are the order lanes pick in (lanes take tasks sorted by name), so stretch jobs carry the highest numbers.
RISK = risky for the Fri 10/30 party build; each RISK draft has a hard stop ("not shipped by the cutoff: wait until after 10/30").

A. Release steps and ordered features (features must ship by Mon 10/26)
 1. coord-01-fetch-my-notes      coordinator  his notes and run reports from the main PC copy into the VM (p-14 a); none since 10-18
 2. coord-03-itch-push-in-vm     coordinator  itch push dead in the VM: butler path, licence files in the zip, RULES line 98, his one step
 3. 58-corpus-reds-v32-90        lane, high   sort the reds of the first full run on v32.90 (WAITS for corpus-1020-1250, about 16:30)
    coord-02-stable-known-red    coordinator  known-red file plus 30 robot minutes on the corpus build, so stable leaves v29.09 (3.40 b)
 4. 59-demo-run-reports          lane, small  FEATURE: demo runs post their run report to the local collector (p-66, 2.92 b)
 5. o-13-reduced-flashing-default Codex       FEATURE: reduced flashing on for new players, about 3 flashes a second cap (2.61 b)
 6. o-14-daily-save-backup       Codex        FEATURE: 3 rolling daily save copies, restore from Settings (third50, binding)
 7. 60-crash-reloads-title       lane, medium FEATURE: a fault repeating 5 s reloads into the title with a short note (third50); strict trigger
 8. 61-experimental-menu         lane, large  FEATURE, RISK: Settings opens an experimental menu of on/off switches, all on (R4 b, 10-15 #1)
 9. 62-share-drop-ping           lane, medium FEATURE, RISK: a dropped item pings the teammate's map, minimap and world (#48, 3.48 c)
10. 63-seed-of-the-day           lane, medium FEATURE: opt-in date-seeded Cold Storage raid (2.98 c); else after 10/30
11. 64-audio-picks               lane, large  FEATURE, RISK: picks 74, 70, 72, 69, 73, one ship each, under the limiter (3.48 c)
12. o-15-hide-coming-later-row   Codex        hide the "2 player co-op (server) / coming later" title row (R6 b)
13. coord-05-rules-refresh       coordinator  one rule set before the cutoff (release first, 3.37 c, 2.81 c, itch line)
14. coord-06-itch-iframe-2p-test session agent RISK if the pairing changes: does 2-player link inside itch's frame? measure first
15. coord-04-release-sheet       coordinator  PUBLISH.md to his answers 71-79; dated one-line messages to him (pay what you want, payouts)
16. coord-07-weak-pc-measure     session agent frame times at 1080p under 4x CPU throttle (third50 "5-year-old laptop"); measure only
B. His notes and rules
17. 65-raid-corner-dollar        lane, small  raid corner still says "credits 900": $ on money rows, hub line too (Q59)
18. o-16-golden-callout-names    Codex        "golden sentry down", not "golden enemy down" (3.84 b)
C. Quality
19. 66-party-status-callouts     lane, small  2-player status sentences become short callouts ("pillager joined")
20. 71-undercroft-windows        lane, large  STRETCH: b-31's last five windows (hire, gambler, contracts, stats, bar) to critic 3
21. 72-hub-floor                 lane, medium STRETCH: hub floor title block, labels and hint pill to the style guide
D. Bugs
22. 67-controls-card-hand-panel  lane, small  the compact controls list covers the item-in-hand panel's title (o-02 alarm)
23. o-17-pad-layout-selector     Codex        pad layout arrow overlaps the name box by 6x48 (o-11 alarm)
24. o-18-alert-mark-top-edge     Codex        a bot's ? or ! lands on its name at the top edge (o-04 alarm)
25. 68-head-scale-body           lane, small  the 1.2 head scale also scales pauldrons (1.344) and chest marks; his a01 D / a05 B spec
E. Test health
26. coord-08-camera-p2-pairs     coordinator  close o-07 and o-08, then make the camera stage player 2 of a real pair (needed by 62)
27. o-19-duplicate-check-ids     Codex        8 check ids name 22 checks; 14 cannot be run alone (job 50 judged the wrong 8.58)
28. coord-09-corpus-slices-reason coordinator keep the " -> " reason in corpus lists (one line; wait until no corpus runs)
29. coord-10-critic-recipe-records coordinator record recipe pictures in accept.json; pass follows 3.51 a
30. 69-critic-rescore-sweep      lane, small  fresh critic scores for 14 never-scored screens and stale ones; fixes nothing
31. 70-pad-crawl-test            lane, medium pad-only crawl check over the hub (2.91 a, J3); gaps pinned, fixes after 10/30
HOLD (after Fri 10/30, next week's budget; do not move yet)
    73-colour-cue-backups        shape or brightness backup for every colour cue (2.79 a, p-59 a); audit first
    74-circle-only-text          no "paste it to Daniel" or "this is an alpha" in the 11/26 build
    coord-11-store-screenshots   six store screenshots (round 2 Q97 pick stands)

Move into tasks/ now: 59-70 and o-13 to o-19. Later: 58 (when corpus-fails-v32.90.txt exists), 71 and 72 (Fri, only under the line below),
73, 74 (after 10/30). The coord-* files never go into tasks/: a lane with an empty list takes any file there (console-lane.sh line 88).

## Budget (his Claude week)
- Reading now: 64% at 12:55 (plan-usage-log.txt last line), not 62%; this planning run used about 2 points. Target 85% by Sun 10/25
  05:00Z leaves 21 points for about 108 hours.
- The runner has NO weekly stop: caps.txt PLAN_PACE=0 since his 10-19 order ("forget about the pacing rule"); only the 5-hour stop
  (PLAN_SESSION_MAX=85) holds lanes back. The queue size and the coordinator are the only brake.
- What a lane job costs (cli-spend.txt, runs.log): 41 Claude jobs with logged spend, median $1.63; big screen jobs $4 to $8 (b-31 $7.63,
  22 $5.52); 232 critic runs at about $0.16 each; 10-20 logged $76 over 292 runs.
- Dollars to points: 10-20 00:00 to 10:00 lanes and critic logged about $55 while the week rose 4 to 5 points (the coordinator also
  worked), so 1 point is about $10 to $12 of logged lane spend: a median job's own runs are about 0.15 to 0.2 point.
- All in: from 10-19 21:00 to 10-20 12:00 the week rose 51 to 61 while about 20 Claude jobs closed and the coordinator handled them, so
  about 0.5 point per job counting critic runs, retries and the coordinator's handling. A large job counts 2 to 3 units.
- The coordinator is the big swing: from 11:30 to 12:55 today the week rose 3 points while lanes logged $1.40.
- Sizing: 21 points, minus about 4.5 for the coordinator's own daily work (1 a day), minus 2 in reserve for fixes the v32.90 corpus will
  turn up, leaves about 14.5 points, about 29 units of 0.5.
  The 13 lane jobs 58-70 are about 21.5 units (10.75 points); the 10 coordinator jobs are about 8.5 units (4.25 points, same Claude
  week). Together about 15 points: at the line. Stretch 71 and 72 add about 2.5 points.
  The 7 Codex jobs run on the ChatGPT plan; only their critic pictures touch the Claude week (about 0.3 point in all).
- Throughput is not the limit (about 20 jobs closed in 15 hours yesterday), so at that speed the lanes clear this queue by about Thu;
  the budget is the limit. Checkpoints to land at 85: about 69% Wed 13:00, 74% Thu 13:00, 78% Fri 13:00, 83% Sat 13:00.
  Ahead of them: cut from the bottom (his 3.58 c: least progress for the usage first): 72, 71, 70, 69, then 68.

## Merged duplicates (one draft each)
- stable (stable-stuck-2909 x2, stable-green-party-build) -> 58 (lane triage) + coord-02 (known-red file, robots, promotion)
- raid corner $ (raid-column-dollar, raid-corner-dollar, raid-corner-money-dollar) -> 65, with the hub "stash 0 bag 0" line added
- controls list over the hand panel (3 survivors) -> 67, with the fix direction "move the panel or the list, never hide or shrink the list"
- pad layout overlap (2) -> o-17; hide coming-later row (2) -> o-15; seed of the day (2) -> 63; corpus reasons (2) -> coord-09
- itch push (itch-release-setup, itch-push-dead-in-vm) + zip licences -> coord-03 (same two scripts); itch-release-settings -> coord-04
- pad-only crawl test + pad-only hub pass -> 70 (test now, fixes after 10/30)
- two-window pictures, p2-window-pad-verify, camera-p2-never-stages -> coord-08
- accessibility-shape-cues (kept) and colour-cues-have-shapes (knocked out) -> HOLD 73, audit first, after 10/30, as both readers said

## Left out (not drafted)
- Knocked out by the skeptic, not drafted: hold-mouse-p1 (party rig only, risky aim change), pad-aim-reach (no order, tuning without
  data), pad-hold-craft-guard (misread v12.17 design), robots-ram-starved (night memory installed today; folded into coord-02),
  outside-sounds-vs-made-here (a question for his next round, not work), itch-gets-stable-only (reverses his daily-push order),
  couch-mode-up-front-title (ambiguous, moves ENTER default), settings-backup-false-success (folded into coord-06), old-itch-saves-load
  (no order, few saves), f1-full-controls-list (c-02 used 6 tries), robots-career-share (75% demo is his order), stash-tile-density
  (5 of 6 tries used; needs his mockup pick), shared-css-literal-debt (invisible to players).
- undercroft-screens-at-2: one reader knocked it out, the other kept it; drafted only as stretch 71, narrowed to five screens.

## What the coordinator must decide
1. Brake: nothing stops lanes at 85% of the week (PLAN_PACE=0 by his 10-19 order). Either watch the checkpoints above or add a hard week
   ceiling; his 10-18 "pace for like 85%" and his 10-19 "forget about the pacing rule" pull opposite ways, and the newest wins (30 a).
2. Lanes cannot do the coord-* work (tools/*.sh, tools/bridge, critic.mjs, uishots.ps1, stable files are outside their write list). It
   needs the coordinator or session agents d, g, h, on the same Claude week.
3. Four drafts come out of the parked cut/16-party-raid-pacing.md ("Do not resume unless he asks for it"): o-13 (2.61), o-15 (R6 b),
   61 (R4 b), 73 (2.79). The drafts read them as game-wide, not party-only. Confirm or drop them.
4. 61 experimental menu: large and risky six days before the cutoff. The 10-15 note held its drafts "for him"; his 10-18 R4 b is newer.
   Queue it now, or hold it until after 10/30.
5. 59 does not build the screen recordings in his answer 66 (stutter is his #1 worry); it adds a question instead. Confirm.
6. 58 and coord-09 wait for corpus-1020-1250 (started 12:50). 62 counts as done only with coord-08's two-window pictures.
7. coord-03 needs his one step: two Windows values in the VM (the butler key and the itch target). Helpers never see the key.
