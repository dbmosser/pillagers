
--- codex run 2026-10-28 00:03 ---
2026-10-28: Prepared cw-cx-rtsteady against v35.49. Six exact, unique anchors passed against the workspace game. No tracked game or fixture file was changed.

RT now keeps PAD.adsT as the existing 0.35 second accuracy settle, while only PAD.adsAim (LT) sets player.ads. The shot spread multiplier, movement bloom bonus and bloom cone use shotSteady, which also accepts the local pad settle. All existing accuracy factors stay the same. padRelease clears the settle so a menu or disconnected pad cannot keep its bonus.

The new fixture check drives the real pollPad and netPadTick in host and p2 roles, using controller slots 1 and 0 respectively. It covers repeated RT pulls during held and toggled LS sprint, scoped magnification, LT aim and sprint cancellation, LT release, walking speed, actual fireWeapon spread bounds, both bloom bonuses, and pad release. It fails the old build on RT aim, scope and sprint. Check 33.30 still tests intentional aim directly and needs no retarget.

Four custom camera stages cover RT and LT in each window in the smooth look. Each stage checks RT sprint and unscoped view plus LT scoped view and sprint cancellation, then photographs the requested state. The recipe records its observed input results in the camera return value. No new player text or fire-ends-sprint rule was added.

The draft why field contains the requested DESIGN.md playtest watch line; the normal ship generator writes that field into DESIGN.md.

Local verification: the mk script printed written; all six draft replacements applied exactly once to an output-only candidate; node --check passed for the candidate game script, regression check and camera helper. The mk script is ASCII. The local lint command skipped because this worktree lacks its installed dependencies; lane preflight must run the normal lint and Chrome gates. Chrome checks, fingerprint, shipping, ON HIS PC confirmation and camera/critic results remain the lane work.


--- codex run 2026-10-28 00:17 ---
2026-10-28 follow-up: cw-cx-rtsteady shipped as v35.51, commit 253ec3a52. The lane preflight passed; shipped fixture check 35.51 passed twice. verifySafe passed with unchanged fingerprints (85/374 entities, 165/593 containers). The ship log states: ON HIS PC v35.51: his 8802 serves 35.52 (163s after the ship). He reloads to play it.

Reviewed all four attached smooth-look pictures from recipes round 1. Both roles reported RT aim=false, opticMag=1, sprint=true and firing=true; LT aim=true, opticMag=4 and sprint=false. Host owns controller slot 1, p2 owns slot 0. This verifies the task behavior in each window.

Critic round 1 scores: host RT 3, host LT 3, p2 RT 3, p2 LT 2. The critic findings concern existing HUD presentation (vitals, roster, minimap, timer, player tags) and the camera equipment staging. The manual scoped weapon assignment left the selected belt slot empty, producing a misleading two-highlight state and empty-slot prompt; clearing every enemy also falsely made the roster look entirely dead. Corrected those recipe issues for round 2: use setHot on the equipped rifle slot and retain the original live enemies. No gameplay edits or new ship key are needed. Camera helper syntax check passed. Full raid HUD restyling would mix a UI job into this control-feel fix, which the rules prohibit; broader findings are handed to the coordinator separately.

