
--- codex run 2026-10-21 01:03 ---
2026-10-21, first run, starting build v33.40.

Prepared two keys in order: cw-cx-publicreports, cw-cx-shortnews. No tracked game or fixture file was edited.

Public report copy: replaced the recorder help, hidden outcome hint, both matching TXSHIP entries, the old report news entry, embedded-download fallback and both success callbacks. Success now says "report copied". Embedded download refusal says "download blocked: use copy report". Copy and failure behavior stays intact.

Q8 reason for overriding the owner's TXSHIP wording: strangers do not know Daniel. A private contact instruction on a bare itch page gives them no usable action. The replacement names the raid log or confirms a successful copy. The outcome hint was already hidden and remains hidden.

News: wnList now returns the first three short real notes, for both the floor card and the pause news window: "experimental switches in settings", "one feed for loot, kills and sp", "full raid log with copy report". Removed the alpha warning and all 43 polish filler entries from WHATSNEW. Historical real entries remain below those three for existing feature/vocabulary regression checks; neither news view displays that archive. This avoids retargeting dozens of unrelated historical checks.

Five fixture checks are retargeted in fixture-retarget.json: 11.32 and 13.21 accept both old capitalized and new lowercase successful-copy text; 23.81 and 10.38 require a real opening note instead of the alpha line; 33.29 accepts the old card or the three short notes while retaining the stamp drift check. All five are designed to pass before and after these keys. The two new checks exercise successful report copy, scan the relevant live text/functions and TXSHIP, and validate the actual pause news window and shared floor-card note formatter. Browser execution belongs to the lane.

Local validation passed under Windows PowerShell: both mk scripts printed written; all eight report anchors and both news anchors matched exactly once; sequential application to a private proposed copy passed; every retarget anchor matched exactly once. JavaScript syntax passed for the proposed game's inline script, both new checks and all five retargeted checks. No check or game code was executed locally. The proposed source scan found no Daniel outside comments, no alpha warning and no polish filler. All mk scripts, drafts, retarget and camera JSON are ASCII.

Camera recipes cover the actual pause news window, the recorder page, and existing screen 40's floor card. The old screen 31 recipe selects settings tabs that no longer exist, so the custom recorder recipe opens the existing rec section directly. Per the Codex addendum custom recipes have no before photograph. Picture paths and critic results remain for the lane.

WHATSNEW_VER is deliberately not changed by these keys: RULES-codex.md requires a Claude-lane card refresh through a card ship. The existing genP.sh/template cannot run unchanged after this work: it anchors the removed alpha line and adds a forbidden polish filler. The card-refresh handoff is in questions-new.md as explicitly required by the addendum, with the technical details also in alarms-new.md. A compatible card refresh must stamp the new real list, preserve the three short notes, and update the template/check so later refreshes do not restore alpha or filler text. At the starting build the old stamp is 33.29, so these two ships alone remain within the 0.15 drift limit; other ships can change that.

Remaining: lane preflight/ship, photographs and critic; Claude-lane compatible card-stamp refresh. Do not mark the task complete until all are confirmed. Watch line: report copying should still confirm success, and What is New should show exactly three short notes.


--- codex run 2026-10-21 01:20 ---
2026-10-21, retry against refreshed master v33.46.

Confirmed public report text shipped in 2a5da11b (v33.43). The original five fixture retargets are already committed in 5e40ca46 and are not repeated in the new retarget file.

The stopped shortnews draft passed its own dry check and failed its control as intended. Its sole reported regression was a new 33.46 card check introduced by the intervening card ship: that check demanded polish pass 44 and the alpha line. Replaced fixture-retarget.json with ONE new full-check retarget for 33.46, dependent only on cw-cx-shortnews. It keeps the version/stamp drift check, accepts the exact three real notes with lowercase/length/whole-note checks, and retains the legacy expectations on the current build before shipping. The game-change script and key cw-cx-shortnews stay the same.

Current master includes card ships 7653a301 (v33.45) and 09bb190a (v33.46), so WHATSNEW_VER is already fresh at 33.46. This resolves the immediate card-refresh step that the first run handed to a Claude lane. The retry preserves that stamp; its expected next build is only 0.01 ahead. No additional card ship is needed for this retry. The earlier warning about genP's alpha anchor and polish filler still matters for future refreshes, which must respect this public-text task.

Revalidated on v33.46: the new retarget anchor matches exactly once; the unchanged mk script prints written; both game anchors match exactly once; the proposed game script, both new checks and the new retarget compile. The proposed source scan again finds no Daniel outside comments, no alpha warning and no polish filler. No tracked game/fixture file was edited, and no game or check code was executed locally.

The existing keys list keeps the shipped publicreports key (lane skips it) followed by the pending shortnews key. Existing camera recipes remain ready for the actual pause news window, recorder and floor card. Remaining work belongs to the lane: apply/check the new retarget, retry cw-cx-shortnews, take pictures and run the critic.
