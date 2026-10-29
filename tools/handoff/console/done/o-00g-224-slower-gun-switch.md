# o-224 slower-gun-switch : switching guns takes longer
HIS WORDS 10-29 about 02:00 (in the Gameplay Edit Intaker chat): "make it take longer to switch guns"

What is on HEAD (v36.23): dark_raiders.html ~27513 DRAWT={pistol:0.25,magnum:0.35,smg:0.4,carbine:0.5,rifle:0.55,shotgun:0.6,sniper:0.85,lmg:1.0,lance:1.0,rocket:1.0} (seconds, 0.5 for any other gun), used by drawTime/drawTick; swapGuns ~27525; the 'SWITCHING GUNS' status (~47228) uses a flat 0.45 s.

Build: every draw time 1.5x (pistol 0.38 ... lmg/lance/rocket 1.5; default 0.75), so a switch is clearly felt and heavy guns still cost the most. The SWITCHING GUNS status reads the real draw time instead of 0.45. Keep the reload cancel on swap and the active reload break on swap. Both windows; pad, wheel, number keys and hotbar all pay the same.
Check (must FAIL on the current build): swap to the rifle: drawT starts at 0.825 and the gun cannot fire before it reaches 0.
Rules: seed 4242 fingerprint must hold; never touch the pickup stack, loot sounds or loot rows. DESIGN.md watch line: "switching guns takes half again as long". Model: Sonnet 5.5 high (numbers).
TASK DONE when it shipped and is ON HIS PC.

CLOSED by the CEO 10-29 00:05: shipped v36.28, ON HIS PC. Left undone: the camera never captured the switching status from both seats (camera flakes, job after-nov1/220); he plays it in the morning, and that is the review.
