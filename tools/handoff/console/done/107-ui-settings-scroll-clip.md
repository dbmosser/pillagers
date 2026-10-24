# 107-ui-settings-scroll-clip : Settings never clips its focused row or runs rows past the card, and its pages reach 3 (coordinator 2026-10-24)
effort: medium

Queue (coordinator 10-24 14:20): keeps jobs waiting for the three helpers (his 10-24 order to spend the week before the reset). The
next known work is screens the critic scored under their target; these name real defects (a clipped focused row, rows past the card
edge), so fix those first. c-31 (pause and settings, 20 screens at once) failed on its size; this is only the Settings window.

Screens (names as in tools/handoff/shots/ui-screens-js.json and notes/ui/accept.json), target 3:
- 27-settings-scroll-600 2 (10-21): "the focused row is clipped at the top, the audio list runs on into controls rows with no section
  break, and the detail pane is mostly empty".
- 29-settings-scroll-1800 2 (10-21): "the scrolled controller page has a clipped focused row, mismatched tab and row state, a dead
  detail pane and a very flat hierarchy".
- 73-settings-sec-accessibility 2 (10-21): "a stray full-width lime button that outshouts everything, a focus state that is ambiguous
  across the rail and the list, and an explaining paragraph in the detail pane".
- 18-settings-hub 3 (passes, keep it at 3 or better): "the rows run past the card edge in one flat tone".
Start with fresh pictures on HEAD (Settings changed since); if a page already meets 3, record it.

Fix, in this order:
1. Scrolling a list by keys or pad always brings the whole focused row into view (never clipped at the top or bottom of the list
   viewport), and no row is drawn past the card edge. These are defects: a check for each.
2. A section break (the guide's section header) where one group of rows ends and the next begins.
3. One focus at a time: the rail and the list never both look focused; the tab and the row state agree.
4. One primary per screen (Settings window rule, his Q43 and the guide): the full-width lime button on the accessibility page steps
   down to the guide's style for its kind of action.
5. Explaining paragraphs in the detail pane: shorten or remove with a logged reason (Q8, notes/ui/changes.md). Never remove a setting.

Rules: read style-guide.md, shared-style.md and notes/ui/pause-settings.md first. All player text lower case, short. Layout and look
only: no setting is added, removed, renamed in meaning or changed in what it does; the saved settings and the storage key are
untouched. The minimap row stays OFF by default (his 10-20 order).

Checks (each must FAIL on the old build): the focused row's box inside the list viewport after scrolling to the end and back by keys;
no row box past the card's right edge at 1080p; only one element drawn in the focused style at a time.
Pictures: camera-recipes.json with the four screens at 1080p, then the critic.
TASK DONE when the defects are gone (checked) and each page reaches 3 from the critic (never your own grade) or is stopped at 6 tries
with its best two versions noted; TASK PARTIAL with what is left.
