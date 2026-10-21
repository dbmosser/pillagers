# 85 shipped v33.42 (cw-nocachelbl)
- Two mapLabel calls (cache/looted, strongbox) now run only when mapFirstOn() is false. Rings and icons stay; all other labels stay. The m key map is unchanged.
- Check: forces 2 caches and 1 strongbox on seed 4242, draws the map with mapFirst 0 (control: words present) and 1 (0 cache, looted or strongbox words, extract words kept). Fingerprint held (ents 85/374, containers 165/593).
- Pictures not taken: the camera has no raid-start map screen (screen 22 is the m map). Adding one needs a question to him; critic not run.

--- codex run 2026-10-21 01:41 ---
2026-10-21, Codex lane o, source v33.50. This task already shipped in v33.42 (cw-nocachelbl). No duplicate ship or fixture edit is needed. Both mapLabel guards are present; rings/icons still draw before the guards. The m-key map is unchanged. Existing check 33.42 counts actual rendered loot words and retained extract words on seed 4242; the prior notes record the passing seed fingerprint (ents 85/374, containers 165/593).

Inspected his original picture at tools/handoff/console/notes/his-shots/2026-10-20-preraid-map-cache-labels.png. It is the requested sector map, with cache labels and long leaders spilling off the left. The prior 85-before folder contains a TITLE picture, not usable map evidence. The previous notes incorrectly said no raid-start recipe existed: tools/handoff/console/notes/shots/cw-mapstyle-recipes.json already has 60-mapfirst-1p. No new screen registration or owner question is needed.

Handed over camera-recipes.json with two seed-4242 raid-start views. Run BOTH at -Res 1080,4k on lane camera port 9364. First is explicitly a RECONSTRUCTED BEFORE: on a fresh disposable fixture page, temporarily bypass the two mapFirstOn label guards only during drawMapOverlayRaw. This restores old cache/looted/strongbox words and their leaders; G.mapFirst remains true, preserving the raid-start chrome and paused clock. Second uses the actual shipped renderer on another fresh page. Both assert raid-start state, three extract texts, and native cache and strongbox icons; before asserts loot words exist and after asserts zero. No synthetic containers, contracts or world rolls are added.

The reconstruction is not a historical before screenshot. Keep his original picture alongside it when reviewing. Suggested comparison order at each resolution: his original reference, 85-before-reconstructed-mapfirst, 85-after-mapfirst. Run critic with the reconstructed-before first and actual-after last. Return actual output paths, lint and critic findings. The supplied recipes use the camera default of both 1080 and 4k; do not force only 1080.

Local validation: JSON and camera staging JavaScript parse; camera-wrapper behavior checked locally. No browser, camera, preflight or shipping runs are possible in this sandbox. No new game changes this run. The existing owner question at questions.md line 52 already asks whether to remove the words from the m map; do not duplicate it.

Remaining: lane pictures at both resolutions, critic review of actual after, and final visible-change log with real picture paths. No new ship keys.
