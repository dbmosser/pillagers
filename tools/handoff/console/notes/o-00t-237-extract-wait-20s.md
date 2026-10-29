
--- codex run 2026-10-29 06:46 ---
2026-10-29: Prepared cw-cx-extractwait20 for the lane. DEF extractWait becomes 20 for career and demo. The saved-config loader changes only numeric 30 to 20; 18 and all other custom waits survive. The party raid-word loader uses the same migration. No save keys or storage format changes, no direct game edits, and no pickup/loot edits.

The siege interval was fixed at 6.4 to 4.4 standard seconds, divided by siegeVol. Shorter live waits now scale that interval by wait/30; waits at least 30 retain the old rate. At the shipped 0.6 dial this preserves two low-haul arrivals and four full-haul arrivals before landing. Caps remain two and seven; boarding stays 30 s. The shared interval helper covers active and spectating hosts. The headless sim retains its original siege arrival interval. No seeded draws were added or moved; extractWait is not read during buildRaid, so the seed-4242 build fingerprint has no new timing dependency. The lane must still run its fingerprint gate.

Retarget queued for check 17.98: accept either default (30 or 20), require the actual called timer to equal that default, and keep the 30 s boarding assertion. This retarget should pass before and after the ship. New check stages actual career/demo calls in both roles, a partner call accepted by the host, a world timer received by player 2, and 80 quarter-second ticks to landing. It also checks saved/custom settings, siege rate/counts, and the quiet middle. Existing check 36.24 already exercises 3 s opening, 14 s quiet middle, 3 s approach at a 20 s wait.

Local validation passed: seven unique game anchors, one unique fixture anchor, generated game/check JavaScript syntax, old/new saved-default behavior 30/20, custom values 18/27, and siege interval arithmetic retaining two/four inbound arrivals. Chrome checks cannot run in this sandbox. Screen 37 is queued for before/after pictures and critic review. Updated the old on-screen October 3 note because its 30 s inbound claim would be false under the new order; no authored wording otherwise changed. DESIGN.md receives the draft why text including: Watch: the ship lands 20 s after the call.

LINKED REVIEW NEEDED: synced. The bcn call, cfg field in the raid word, and wd.z beacon timer carry this rule between windows. The CEO helper must verify actual calls and landings in both linked windows, career and demo, with pictures from each. Pending lane preflight, ship, ON HIS PC, critic, and linked review.


--- codex run 2026-10-29 06:53 ---
2026-10-29 completion: cw-cx-extractwait20 shipped in v36.43, commit b7d33a9eb. Fixture retarget committed as b5ad5b6b1 after check 17.98 passed on v36.42. The lane confirmed ON HIS PC v36.43, 17 s after shipment. The new gate check is installed as 36.43. The task's required ship and ON HIS PC conditions are met.

Reviewed the attached screen 37 after picture: the inbound band shows 9 s at the camera's staged point, consistent with changing its 0.6-times-default start from 18 to 12 s and then waiting 3 s. Critic round 1 scored 2, same as before. This is not a visual acceptance pass. Its P0/P1 findings concern the existing ammo panel, expanded run info, banner hierarchy, contract hint, and pickup pills; they were not introduced by the timer change. A UI redesign would mix layout work into this timing task, and its pickup-pill changes would directly violate the task's order never to touch the pickup stack or loot rows. No UI follow-up shipped. Those findings are handed to the coordinator, and the UI screen remains below its finish line.

Before picture: C:/claudecode/dark raiders/tools/handoff/console/notes/shots/o-00t-237-extract-wait-20s-before/37-raid-extracting-countdown-1080.jpg
After picture: C:/claudecode/dark raiders/tools/handoff/console/notes/shots/o-00t-237-extract-wait-20s-after/37-raid-extracting-countdown-1080.jpg

LINKED REVIEW NEEDED: synced. The existing coordinator handoff remains: actual linked-window verification and pictures are not available in this sandbox. The shipped regression exercises career/demo calls in both roles, host acceptance of partner calls, peer receipt of the world timer, and exact 20 s landing. Do not treat that as an actual two-window review.

