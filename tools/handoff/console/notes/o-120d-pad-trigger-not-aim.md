
--- codex run 2026-10-28 00:03 ---
2026-10-28: Prepared cw-cx-rtsteady against v35.49. Six exact, unique anchors passed against the workspace game. No tracked game or fixture file was changed.

RT now keeps PAD.adsT as the existing 0.35 second accuracy settle, while only PAD.adsAim (LT) sets player.ads. The shot spread multiplier, movement bloom bonus and bloom cone use shotSteady, which also accepts the local pad settle. All existing accuracy factors stay the same. padRelease clears the settle so a menu or disconnected pad cannot keep its bonus.

The new fixture check drives the real pollPad and netPadTick in host and p2 roles, using controller slots 1 and 0 respectively. It covers repeated RT pulls during held and toggled LS sprint, scoped magnification, LT aim and sprint cancellation, LT release, walking speed, actual fireWeapon spread bounds, both bloom bonuses, and pad release. It fails the old build on RT aim, scope and sprint. Check 33.30 still tests intentional aim directly and needs no retarget.

Four custom camera stages cover RT and LT in each window in the smooth look. Each stage checks RT sprint and unscoped view plus LT scoped view and sprint cancellation, then photographs the requested state. The recipe records its observed input results in the camera return value. No new player text or fire-ends-sprint rule was added.

The draft why field contains the requested DESIGN.md playtest watch line; the normal ship generator writes that field into DESIGN.md.

Local verification: the mk script printed written; all six draft replacements applied exactly once to an output-only candidate; node --check passed for the candidate game script, regression check and camera helper. The mk script is ASCII. The local lint command skipped because this worktree lacks its installed dependencies; lane preflight must run the normal lint and Chrome gates. Chrome checks, fingerprint, shipping, ON HIS PC confirmation and camera/critic results remain the lane work.

