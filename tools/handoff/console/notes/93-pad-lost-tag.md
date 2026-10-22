
--- codex run 2026-10-22 08:05 ---
2026-10-22, v34.08: prepared cw-cx-padlosttag for lane o.
- Scope: only the unaffected pillager window teammate loss tag in netPadHud. Existing words, affected-window pause titles, controller ownership and raid timing remain as before.
- Design: shared uiPanel fill and border, 3px warn left bar, 24px controller glyph, 20px/600 condensed warn text, 48px panel height, 16px gap after the top message/score stack. Panel is centred near 30 percent screen height and scales with height. No new words or explaining line. Message rows are not removed because the task explicitly limits changes to this tag.
- New check stages actual partner-pad loss through pollPad in both host and p2 roles, captures the complete raid frame, requires one warning panel and one label, measures transformed font/panel coordinates, and checks spacing against real extract and score text with extraction active. The old build has no matching uiPanel and fails the check. Copied staging and cleanup from checks 31.90 and the barsame example.
- Local validation: mk prints written; its anchor matches exactly once; draft replacement, regression check, both camera scripts and camera expectations parse in Node; mk is ASCII. No game or fixture was edited. Browser regression remains for the lane.
- Camera recipe uses the job 62 real-pair recipe envelope and prelude, replacing its drop stages with the proven o-07 real linked demo loss stages. Only j8-p2-sees-p1-lost and j8-p1-sees-p2-lost are requested. Each exercises both pad-loss and reconnect ownership cases before its final picture. Unique task pair names avoid stale camera peers.
- Pending lane work: preflight and ship cw-cx-padlosttag, photograph both windows, return critic results (raid target 4). No fixture retarget is expected: the legacy own-controller fallback is unchanged.
- Watch on the TV: the teammate pad lost tag should be noticed at once and remain clear of extract and team score.
