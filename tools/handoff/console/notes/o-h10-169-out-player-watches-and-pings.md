
--- codex run 2026-11-07 16:24 ---
2026-11-07 - task o-h10-169-out-player-watches-and-pings, first run, base v37.53.

Prepared cw-cx-outwatch. Extracted demo host and player 2 follow the remaining partner without the attract loop. Only the camera and sight origin follow; the real player object, host simulation, rewards and both-out ending remain in their existing paths. The waiting HUD has one small lower-case line and the existing ping markers. Own-body controls, mouse firing, pad movement, searches, menus and unbench input are held back while watching. N, middle mouse and the mapped pad ping still work, including danger on a double press. A retained career host also watches and pings, with its already-settled outcome card shown when its partner finishes.

The draft why includes the requested Watch line for DESIGN.md: frame rate while the watcher still runs the simulation; watcher sender identity; waiting must not look like run over.

Sandbox verification: mk printed written; all 29 anchors occur once and do not overlap; generated game JS and fixture check parse; changed functions pass no-undef and duplicate-key lint. Local Node smoke exercises the actual new watch-state, camera, ping and pad functions: partner camera following; crawler identity; sender seat; danger; career map bypass; player 2 out; ping release edges; no movement or fire from pad. No Chrome, full fixture gate, preflight, shipping or live transport ran in the sandbox. The draft gate check stages both roles, dispatches real KeyN events and delivers the sent png through netOnMsg on the receiving role. It also renders the actual watch camera and rejects input that would act or rejoin.

An older source-based fixture check (16.43) requires the original literal N-key condition. That condition is preserved for normal play; the watch path returns earlier. No fixture retarget is needed and tools/mkfixture.ps1 is untouched. The seed-generation path is untouched; the lane still needs to run the seed fingerprint gate.

camera-recipes.json has three smooth-look scenes: extracted host watching; extracted player 2 watching; player 2 displaying a crawler ping sent through the extracted host input path and delivered through the real receiver. These are per-role fixture scenes with staged body packets, not a live connected pair. Their source is make-recipes.cjs. The lane must supply the pictures and critic results; no self-score is claimed. No before pictures exist for these custom scenes.

LINKED REVIEW NEEDED: synced. Uses existing st body packets and png ping packets; no new packet fields. A live linked pair must still confirm host extraction keeps simulation moving, host camera follows moving player 2, watcher N/middle mouse/pad pings arrive under player 1 identity, player 2 out can watch/ping in the reverse case, no action or rejoin is possible, and the run ends when the remaining player leaves. Require pictures from both real windows and the ON HIS PC ship result before closing.

