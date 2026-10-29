# o-00l-230 undercroft-no-hint-bars : the Undercroft loses its key bar and the lift's option line
HIS WORDS 10-28 about 22:25 EDT (in the Gameplay Edit Intaker chat), with a screenshot: "get rid of all this shit in the undercroft, none of it is helpful"

THE SCREENSHOT shows, at the lift in the Undercroft (v36.23), under a station prompt that reads "[e] enter raid" (cut off at the top):
1. a line of lift options: "[e] go up  [r] quick ascent  [t] the terms  [f] party  > cold storage" (the lift's key table, dark_raiders.html ~51320-51345: KeyR quick ascent, KeyT the terms, ...);
2. the boxed footer key bar: "wasd walk | shift jog | e use station | m map" (hubFootY ~49358 and the footer draw; key names come from ~19488).

Build: remove BOTH from the Undercroft: the footer key bar entirely, and the lift's option line under the station prompt (and the same kind of option line under any other station, if one draws). The KEYS keep working exactly as now (R quick ascent, T the terms, F party, E, M); only the text goes. Keep the one station prompt ("[e] enter raid" style) so a station still says what E does there. The pad's equivalent hint rows go too. Check the controls page/help still lists these keys so nothing becomes undiscoverable for good.
Check (must FAIL on the current build): standing at the lift, no element shows "quick ascent", "the terms", "use station" or "wasd"; pressing R still starts a quick ascent.
Rules: take pictures (uishots: the Undercroft at the lift and mid-room, 1080p and 4K, pad and keyboard) and look at them; seed 4242 fingerprint must hold; never touch the pickup stack, loot sounds or loot rows. Retarget older checks that read those words (fixq). DESIGN.md watch line: "the undercroft has no key bars". Model: Sonnet 5.5 high (UI removal).
TASK DONE when it shipped and is ON HIS PC.
