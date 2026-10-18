# cw-glyphs (lane g), 2026-10-18: real-time prompt switching (his order)
His order, verbatim: "player should get key prompts if that is the last input they used -- xbox controller prompts should only pop up if player is actively using the controller -- e.g. real time glyph switching -- fortnite does a great job with this"

## What exists (found 12:20, build v30.63)
- PAD.on = a pad is connected (pollPad sets it every frame a pad is read). padOn() (line ~17002) is "the one reader every prompt agrees on" and is just PAD.on.
- keyLabel(), uiKey(), hudKey() and about 38 canvas sites go through padOn(). About 20 more canvas sites read (PAD&&PAD.on) directly (F1 legend, mini legend, bag hints, hub hints, attract).
- DOM and CSS hints (pause keys, settings and keys ::after strips at ~1875, .kbrow/.padrow, #invkeybar/#invkeybarpad) all follow body.padon, which padBodyCls() (line ~17351) toggles from PAD.on.
- Chrome only exposes a pad after a button press, but a stub or an idle pad object still counts as "on" today, so plugging in switches every prompt.
- Same-PC pair: window 2 (NET.same==='p2') hands every key to window 1 (netKeyFwd, capture, stopImmediatePropagation) and has no mouse of its own. Its pad arrives through netPadTick (same buttons/axes shape).
- Pad code dispatches synthetic mousedown (bagPadAct, stashPadAct) and the net layer dispatches synthetic keydown on body (window 1 receiving window 2 keys): so mouse events count only when isTrusted, key events always count.

## Design
- INDEV = {dev:'kb'|'pad', legacy:false, ...}; listeners on window, capture, registered before the game's own handlers.
- kb: any keydown (not in the p2 window), trusted mousedown/wheel, trusted mousemove > 6 px from the anchor (zero-movement synthetic moves ignored).
- pad: indevPadTick(gp) from pollPad: a button newly pressed (edge) or a stick axis 0-3 newly past max(0.4, deadzone+0.15), with hysteresis. Drift and a held stick never re-flip.
- padOn() = PAD.on && (INDEV.dev==='pad' || INDEV.legacy || window is the p2 window). padBodyCls follows padOn() and is called on every flip, so DOM hints change the same frame.
- INDEV.legacy exists only so the 1000s of older fixture checks that set PAD.on=true by hand keep their meaning: the fixture sets it in __runPrep (guarded by typeof INDEV). My check turns it off.

## Ships
(see bottom, updated as they land)
