# cw-snip (lane h) - F8, an in game snipping tool: freeze, drag a box, copy it or save it
His words (2026-10-18): "add one that is an in game snipping tool so it pauses the game and i can snip whatever portion of the page that i like to send it to you",
then "i want option to copy to clipboard so i can easily send it wherever I want".

SHIPPED as v31.13 (check 31.13, fails on v31.12, passes twice on v31.13).

- Key: F8, an edge press, this machine only (DEV_LOCAL), same as F2. It is in KEYS_FIXED and listed in the Keys window locked rows as "snip the screen  f8".
- It reuses the F2 freeze: devFreeze() is true while a snip is up, so the raid stands still with the HUD on screen. Menus and the title are not raids, they just stay as they are.
- Flow: F8 -> dimmed screen with a small hint plate (left 8, top 68) -> drag a box (2px lime frame, size chip "w x h") -> release -> a panel with two buttons: `copy` and `save`.
  - copy: puts an image/png on the clipboard (navigator.clipboard.write), toast "copied".
  - save: POSTs to the collector /feedback (the same path as the feedback box), which writes exports/feedback-STAMP.txt and exports/feedback-STAMP.png in the project folder.
    If the collector is down, or DROP is not the local drop, it falls back to the browser's own download. Toast says which.
  - No third combined button (one control per job).
- Ends on ESC, F8 again, or a click outside the panel. That click is eaten, so it never fires a shot. ESC with nothing done says "snip cancelled". Nothing is left latched:
  keys, mouse.down and the heavy-hold arm are cleared on the way out (same devLetGo as F2).
- What is in the picture: the game canvas (world + HUD canvas) and, best effort, the page layer (menus and the top right block are DOM) drawn through an SVG foreignObject.
  The page layer is read through a data: URL on purpose (a blob: URL taints the canvas and the export throws). If it fails the picture is the canvases only and the toast says "page layer failed".
- Pad: mouse and keyboard only. The pad is not read while a snip is up (pollPad guard), so a button press cannot reach a menu hidden under the overlay. Not shown in the game: the plate lists the mouse steps only.
- 2 player: same as F2. The window whose F8 is on stands still, the world keeps running for the other window until every window is paused (press the key in each). Each window snips its own page.
- Check: stubs navigator.clipboard and fetch and fbFiles, forces LOCAL_DROP/DROP, restores in finally. It never writes a real file to exports/. It also covers the collector-down fall back.
  The page layer is switched off in the check (SNIP.dom=0) because checks are synchronous; step NINE only proves it starts. The layer itself was proven by camera
  (shots/cw-snip-after/92, 93, 94: title, settings and raid results).
- Risk: a party guest sitting on localhost could press F2/F8. They are DEV_LOCAL only, so never on itch.
- History: the first draft used a blob: URL for the page layer and the canvas threw "Tainted canvases may not be exported". The scratch fixture tools/fxsnip.html was swept into two ships by
  `git add -A` (v31.07, v31.08). Removed in v31.13. Two 12 MB blobs stay in history (no rebase allowed). Lesson: never put scratch files under tools/.
- Critic (shots/cw-snip-after/91, panel): score 2. P1s on my own elements: the buttons are small and look alike, the size chip is 13px, the dim is too light. The HUD findings were skipped on purpose (he wants to snip the HUD).

## cw-snip2 (v31.18): the panel made readable
Critic on the v31.13 panel (score 2) named three things of the snip's own: the two buttons small and alike, the size tag 13px and hugging the frame, the dim too light.
SHIPPED v31.18 (check 31.18, fails on v31.17, passes twice on v31.18; the older snip check 31.13 still passes):
- copy = shared `.ui-btn.pri` (lime fill), save = shared `.ui-btn` (secondary), each min 48px high / 128px wide, 16px gap, panel padding 12px. No new control, no new style, same data-snip names.
- size tag 16px, measured (offsetWidth/Height) so it sits 8px above the frame, never past the right edge or the top.
- dim outside the frame .6.
- Re-run of the critic: still 2, "same". Left on purpose (not the snip's own elements, and he wants to snip the HUD as it is): the controls cheat-sheet overlaps the frame bottom in the staged raid,
  two identical codex toasts stacked, the minimap clipped at the right edge, the blue-purple light tint inside the frame is the game's own light and not an overlay.
  Not done (critic ideas, left as taste): 20px labels / 56px high buttons, a darker .8 dim, no outer panel box, square corner handles, "x" as a multiply sign (check 31.13 reads "240 x 180", so it would need fixq).
- Pictures: shots/cw-snip2-after/91 (panel) and 94 (copied raid picture, proves the new button still copies).
