# 113-ui-settings-play-data-and-superhot : the send play data page leads with its action instead of a raw text dump, and the superhot pane has no clipped row (coordinator 2026-10-24)
Queue (coordinator 10-24 17:20): keeps three jobs waiting for the helpers (his 10-24 order to spend the week before the reset). Feed
order: a screen the critic scored under 4. Friends and family get the private link before the Thanksgiving release, and this page is how
their play data reaches him.
effort: medium

Screens (names as in tools/handoff/shots/ui-screens-js.json and notes/ui/accept.json):
- 31-settings-send-play-data 2, target 4 (10-21): "a raw debug dump filling the screen ... does not read as a polished player-facing
  settings tab". The pane is spane_rec in #settingsmodal (openSettings('rec'); the export text is #exporttext, filled by buildExport()).
- 92-settings-superhot-pane 2, target 4 (10-18): "a flat, same-weight list with a clipped row, a mixed-up tab strip and an explanation
  block". Old score: start with a fresh picture and score on HEAD; if it already meets 4, record it and stop on that screen.
Start with fresh pictures and a fresh critic score on HEAD for both.

Fix, in this order:
1. A clipped row is a defect: if 92 still clips a row, find why (job 107 fixed the settings scroll clip elsewhere) and fix it; a check.
2. The play data page: one hero (the send or copy action, the guide's primary button) and a short muted line of what will be sent (for
   example the number of runs and notes recorded), with the raw export text kept but folded away behind a "show data" ghost button,
   closed by default. Keep every control it has now (copy, clear recorder with its arm-then-confirm, the export text itself), keep what
   the copy sends exactly as it is, and keep the v13.21 fallback (the text stays selectable for Ctrl+C when the clipboard is refused).
3. Then the critic's points the guide agrees with (one tab strip, list rows at the guide's pitch, no explaining block).
These are WINDOWS (style-guide.md: a 90 percent card), so size points count.

Rules: read style-guide.md and shared-style.md first. All player text lower case, short, no explaining sentence; log any reworded or
removed line with its reason in notes/ui/changes.md (Q8). Rendering and layout only: no change to what the recorder keeps, what the copy
sends, saves or the storage key salvagerun:profile.
Checks (each must FAIL on the old build): the export text is hidden on open and shown by the show data button with the same text
buildExport() returns; copy still copies that text; and the clipped row in 92's state (if found) is fully inside its pane.
Pictures: camera-recipes.json with 31 and 92 at 1080p, then the critic.
TASK DONE when each reaches 4 from the critic (never your own grade) or the fixes shipped and the scores are written, with the reason
for any point left; TASK PARTIAL with what is left.

--- COORDINATOR 2026-10-24 21:10: the full run corpus-1024-1829 on v34.53 has nine settings checks newly red; they are yours (same
screen, so no second helper works it). Before TASK DONE run each alone, drop any that pass, then fix the game or re-aim (never loosen):
v33.56 public recorder bounded preview -> "raw preview exceeds 240px: height 0, zoom 1.3" (your fold: open it before measuring, as 33.70);
v33.33 experimental group names -> "group raid is 0px tall" (all four); v33.28 experimental layout -> "detail repeats the chip";
v31.75 settings detail pane -> "detail pane is 200 tall against the list 793"; v31.59 settings rows -> "2 different heights: 1,50";
v30.05 rebind callout -> "the detail pane still repeats the row value"; v29.33 shared look -> "NEW raw colour or font-size literal in:
#root #settingsmodal.expmode #setlist"; v28.38 D-pad up settings -> "highlighting the jump chips moved the list from 2000 to 1984";
v26.38 settings sections -> "ONE: Settings draws no go_minimap". Likely ships v34.35 to v34.38 and your v34.51 to v34.53.
