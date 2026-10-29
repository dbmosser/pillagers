# o-00i-226 timelord-mode : superhot mode is called timelord mode
HIS WORDS 10-29 about 02:35 (in the Gameplay Edit Intaker chat): "rename superhot mode to timelord mode"

Text only. Every word a player can see that says superhot now says timelord, in the game's lower case voice ("timelord mode"). On HEAD (v36.23) the player-visible strings include: dark_raiders.html ~20683 'SUPERHOT MODE' (key list), ~47019 'superhot on/off', ~63103 'SUPERHOT ' (the toggle callout), ~73227 settings label 'Superhot mode', ~73844/73845 'Superhot follows the host...' and 'SUPERHOT FOLLOWS THE HOST', plus any What's New, help, pause, demo or controls card that names it (grep -i superhot, skip comments). The What's New history lines may stay as written; the current card and every live menu say timelord.
DO NOT rename the internal keys: CFG.superhot, the 'superhot' settings key, 'go_superhot', the saved profile value and the net word keep their names, so saves and parties keep working. Never change salvagerun:profile.
Check (must FAIL on the current build): the settings row reads "timelord mode"; the key list and the toggle callout say timelord; no visible string in the settings, pause, key list or callouts contains "superhot".
Rules: seed 4242 fingerprint must hold; never touch the pickup stack, loot sounds or loot rows. Retarget older checks that read the old words (fixq). DESIGN.md watch line: "superhot mode is now timelord mode". Model: Sonnet 5.5 high (text).
TASK DONE when it shipped and is ON HIS PC.
