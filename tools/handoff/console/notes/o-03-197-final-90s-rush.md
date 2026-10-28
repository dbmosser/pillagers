
--- codex run 2026-10-28 11:52 ---
2026-10-28, first preparation run (HEAD v35.82)
- Checked HEAD first: arcadeWaveTick at dark_raiders.html:65715 already ramps waves, and arcadeKill at :68003 already applies streak/hot-ground bonuses, but neither has a final 90-second rush. No existing final-rush implementation found.
- Prepared cw-cx-finalrush, following the latest decision of 1.05x rather than the superseded 1.5x brief. It applies only to the two-player demo, with a positive raid clock at or below 90 seconds. Career, solo demo, simulations and finished raids are excluded.
- Waves get one extra body, always a crawler or sentry, 20 percent shorter intervals and two additional nearby slots. Existing breathers, extraction holds, authority checks and safe spawn positions remain in use. No seeded build code or storage key changed.
- One short lowercase callout per raid: final rush / kills x1.05 sp. It is evaluated before the wave authority guard, so both windows receive it from their shared clock. Kill awards use the same scoring path on the host and partner.
- Playtest watch is in the draft why field, which the shipping generator copies into DESIGN.md: both windows announce once at 1:30; a fresh sentry kill pays 105 sp before other bonuses; watch for more machines while breathers and called rings still hold waves.
- Local validation: mk script prints written; all five anchors match once; applied replacements in memory; the complete inline game script, new regression check and both camera scenes parse in Node; mk and recipes are ASCII. The browser check was not run in the sandbox.
- Regression stages a real demo raid, tests the 90-second boundary and expiry, host/partner kill credit, the actual alert object, one callout per seat, solo/career/simulation/finished exclusions, wave interval and added machine, cap, breather and extraction hold. It fails on HEAD because the rush functions are absent.
- Camera recipes reuse the proven real-window linking setup from job 62, with separate player 1/player 2 photographs. Each scene checks 1.05x scoring in both real windows before photographing the start callout. The lane must run these, critic, preflight, ship and ON HIS PC confirmation.

--- codex run 2026-10-28 12:03 ---
2026-10-28, camera correction after shipping
- cw-cx-finalrush shipped as v35.83. Lane confirmed ON HIS PC v35.83: 8802 served 35.83, 49 seconds after shipping. The owner reloads to play.
- Viewed round 1 images: player 1 was still at the attract board, player 2 at the title. Both scenes reported NOT STAGED, so the critic scored unrelated screens. Those findings do not assess final rush and do not justify changing the scoreboard or title in this task.
- Found the camera fault: recipe queries used cxRush197p1 / cxRush197p2, but netPairOf at dark_raiders.html:59781 accepts only [a-z0-9]{4,16}. The uppercase R caused player 2 to reject the pair ID before the handshake.
- Corrected both IDs to cxrush197p1 / cxrush197p2 in camera-recipes.json. No new ship key or game change. Real paired-window camera scenes and critic review remain for the lane.

--- codex run 2026-10-28 12:06 ---
2026-10-28, camera correction after round 2
- Both real windows linked in all four scenes (1080p and 4k). Camera verified got=105 / want=105 for host and p2 in every scene. Lint: 0 issues at 1080p, 1 small item at 4k.
- Viewed the attached round 2 pictures. The initial want easy mode question covered the final rush alert, even though G.alert was correctly set and scoring was verified. This was a missing camera interaction: a normal 8.5-minute run would already have answered or timed out that initial prompt.
- Camera now calls the existing easyAnswer(false) to choose normal after both raids have started and before the rush capture; it explicitly uses smooth look (CFG.xfPix=0). The scene predicate now requires both the final rush alert and no active easy-mode question.
- Renamed the pictures finalrush-host-raid / finalrush-partner-raid so the critic sees the intended raid subject, rather than carrying over title/scoreboard screen identity from failed round 1. Round 2 P0 about recapturing the title and P1 about the unrelated easy question do not justify changing those screens for this job.
- No game change or new key. cw-cx-finalrush remains shipped v35.83 and confirmed ON HIS PC. Remaining work: clear raid pictures and critic finish line for the rush itself.

--- codex run 2026-10-28 12:17 ---
2026-10-28, rush presentation follow-up after round 3
- Viewed both round 3 images. The rush is now visible in both real linked windows; all four scenes again verify 105 sp / 105 sp kills. 1080p lint has zero findings. Critic scores are 2/5 for both full raid HUDs, with the rush sharing an overfull top-centre stack.
- Prepared cw-cx-rushlayout (15 unique edits). During the final rush only: clock and score retain separate windows, clock stays larger and above score (his cw-clockcard order); their gap becomes 16px; score uses the smaller head font with a 96 percent graphite backing; bottom padding accounts for the partner line. Existing extraction chip and arrow move together to the left of the clock. No control is added or removed.
- The finalrush alert uses a minimum 416px panel at the normal text scale, about 16px inner inset, 24px clear space below the score, and a 96 percent graphite fill. It retains the shared red alert glyph/title and the existing alert lifetime. The existing world-nameplate occlusion check now includes this banner, so a teammate tag cannot cross it.
- Gameplay is unchanged by this follow-up: 1.05x kill SP, wave timers, cap, pack and director holds stay as shipped v35.83. DESIGN watch is in the draft why field: inspect navigation, score and banner in both windows at 1:30.
- Local verification: mk prints written, 15 anchors each match once, in-memory patched game and new regression parse, both updated camera scenes parse, files ASCII. The browser regression measures actual draw calls for both seats: clock/score size order and gap, extraction left of clock, wide neutral rush panel with clearance, and world-nameplate masking. It fails on v35.83 because the score gap is still 6px and the banner is narrow/red.
- Camera now allows the real join notice to finish for 4 seconds before advancing to 90.5 seconds, and sets warnPrev to 90.5 with the clock. This avoids creating an overdue 2 minutes left message by skipping 8.5 minutes in one camera step. It still uses real linked windows and checks both awards.
- Kept the established health colour scheme: style-guide.md:74 explicitly says health stays on the HUD scheme, and :79 explicitly exempts the HUD from the 5 percent margin rule. The critic proposal to force the HUD inward and replace the health treatment does not govern this task.
- Kept vacant belt keys without full tiles and owned gold rings. Current regression 35.64 explicitly preserves both; adding full empty tiles and replacing gold with lime would reverse the existing HUD work during a rush-only change. Other inherited HUD findings are recorded in the coordinator handoff rather than mixing a belt/vitals redesign into this task.
- Next lane work: preflight and ship cw-cx-rushlayout, ON HIS PC confirmation, fourth camera round and critic review. Original cw-cx-finalrush is already shipped and ON HIS PC v35.83.

--- codex run 2026-10-28 12:20 ---
2026-10-28, preflight correction for cw-cx-rushlayout
- Lane preflight returned: rush panel lacks clear space below score / PASS. No follow-up build shipped; current game remains v35.83.
- Found the actual first-frame defect: drawHUD calls msgLayout near its beginning, before arcadeScoreHud updates HUDTOPB for the current rush header. The first alert draw therefore used the old header bottom, and the second draw passed with the now-current bounds.
- Updated the same cw-cx-rushlayout script to refresh msgLayout after the header is measured and before drawing its message lanes during the rush. This fixes the rendered first frame rather than relaxing the spacing assertion or warming up the check.
- Strengthened the check: clear HUDTOPB before each seat draw, requiring the spacing to work without a cached previous header. The 20px minimum physical clearance assertion remains unchanged.
- Mk prints written; all 16 edit anchors match once; the patched full game script and regression parse in Node. Lane must rerun preflight, ship, confirm ON HIS PC and capture the fourth picture round for review.
