# 186i-every-hud-panel-movable : every raid HUD element can be grabbed and moved
Queue: HIS ORDER 10-28 morning, HUD Improver chat (verbatim): "ideally every single Hud element would be grabbable/ movable". A new feature, so it waits for 11/1 (his 10-27 order: "Ok no new features until Nov 1"); back to tasks/ on 11/1.
effort: high (Opus)
Key: cw-hudmoveall

What is true: six raid panels already drag (hudOff keys body, cond, gear, legend, mmap, raiders; the drag is screen pixels scaled by the corner zoom, saved in the profile). The rest are fixed: the clock and score cards, the extraction pill and arrow, the gun card, the belt, the air strike plate, the teammate strip, the left feed, the danger banner, the power-up chips.
Build: give each of them a hudOff key with the same grab, drag, save and reset behaviour as the six; one "reset hud layout" in Settings puts them all back. Panels that steer around other panels (ringBadgeSlide, airPlateAt, the alert layout) read the moved boxes. Two player windows keep their own layouts.
Check (must FAIL on the build before): each listed element takes a drag, keeps it after a reload, and returns on reset.
Pictures: uishots 21, 33, 34, 50 with two panels moved; look at them.
Watch-for line for him: whether grabbing a panel ever fires the gun or opens something under it.
TASK DONE when shipq prints ON HIS PC.
