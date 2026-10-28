
--- codex run 2026-10-28 00:52 ---
2026-10-28, first run, starting v35.54. Read gameplay-next-1025.md idea 7 and the existing pad, reload and prompt paths. No earlier task notes existed.

Prepared cw-cx-xreloadsearch. The container prompt now uses the same X choice as the press, including the narrowed active reload sweet spot. During a held press it follows the latched action. The new reload callout is [x] reload, without a misleading container/item subtitle. Full magazines, no spare rounds and calm searches retain the existing search label. The extraction ring retains its separate Y search prompt.

A successful reload stamps completion on the player. The pad observes that stamp and the same gun before changing this hold from R to E at a container. This also works if RT uses a round on the completion frame. Cancellation and gun swaps do not qualify. The ring search grace restarts at the handoff. Keyboard code and input priorities are unchanged.

The check drives actual pad polling and updatePlayer in host/p1 (second pad) and p2 (first pad). It captures the real container HUD prompt, then holds X through empty, partial, active and limited-reserve reloads, including RT held for the limited-reserve case. It also checks full-magazine search, no-reserve search, revive priority, cancellation and keyboard E. It restores pad, network, input, rumble and configuration state and ends the raid in finally. The old build necessarily fails the reload prompt and held-search claims. No older check needs retargeting; 31.89 keeps its held-choice assertion before any reload completes.

Local validation: mk prints written; all six anchors match exactly once; every replacement changes its anchor; the full candidate inline game script and the new check parse; mk is ASCII. No tracked game or fixture file was edited. Browser checks, seed 4242 fingerprint, shipping and ON HIS PC confirmation remain the lane work.

camera-recipes.json requests four pictures: reload and search after a real held reload in each pad window, smooth look. Each stage checks its real pad slot and actual HUD words; the after stage must complete a held reload and start a search before release. Please capture at 1080p and 4k. Custom recipes have no before images. Critic review is pending. Record the actual picture paths in the visible-change log after capture.

The draft why text includes the required DESIGN.md playtest watch line; the normal generator writes it into DESIGN.md. Watch both windows while holding X at a box in a fight: reload first, then search without release; also try a full magazine, no spare rounds and an active reload. Nothing changes seeded map generation.


--- codex run 2026-10-28 00:53 ---
2026-10-28, preflight correction on v35.54. The draft failed only the keyboard prompt assertion in host and p2, twice. Found the cause at tools/mkfixture.ps1:108945: __runPrep sets INDEV.legacy=true so old checks can request pad hints without simulating last-input state. This overrides INDEV.dev=kb in padOn(). The check now disables that compatibility flag after preparation, exercising the actual live prompt-switch rule, and restores the original INDEV state in finally. It also reports captured words if keyboard labeling ever fails again. No game edits changed. All reload and held-search assertions passed in the reported drafted-build runs.

Regenerated the draft: written; six unique anchors; candidate game and check parse; mk remains ASCII. Same key and camera recipes are ready for lane preflight, shipping, ON HIS PC confirmation and picture review. No fixture retarget is needed.

