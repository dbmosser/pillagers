# o-00y3-248 text-size-default-100 : text size starts at 100%, in the demo too
HIS WORDS 10-31 (in the Gameplay Edit Intaker chat): "text size should default to 100%"
PARTY RELEVANT: the arcade demo starts every player at TV-size text, but the party is now two PCs on monitors with mouse and keyboard (his 10-29 plan), so the demo text is oversized. CEO decides under his 10-30 order (fixes critical for two player play).

What is on v36.55: dark_raiders.html ~65959, the arcade sandbox and new profile defaults carry uiScale:1.5, menuZoom:1.25 (cw-tvtext, his answer Q21 of 10-18, "TV-size text is on by default in the demo", when the party was two TVs 6 to 10 ft away); UISCALES ~13341 [1.0,1.2,1.5,1.75,2.0]; hudSizeStep ~18714 sets the pair; the - and = keys step it; HUD SIZE row (hudTv) ~74094 is separate (STANDARD default).
Build: the default text size is 100%: uiScale 1.0 with its matching menu zoom (the pair hudSizeStep gives step 0) for a NEW profile and for the arcade demo start (both windows). A saved profile keeps what it has unless it still holds exactly the old untouched default (1.5 / 1.25 and never changed by him): then load it as 100% too. Settings and the - = keys still change it. Check the 4K scaling still reads right at 100% (hudRes scales with the screen).
Check (must FAIL on v36.55): a fresh profile and a fresh arcade demo start have uiScale 1.0; a profile that set 1.75 keeps 1.75.
Rules: take pictures (uishots: raid HUD and a menu at 100%, 1080p and 4K) and look at them; seed 4242 fingerprint must hold; never change salvagerun:profile; never touch the pickup stack, loot sounds or loot rows. DESIGN.md watch line: "text starts at 100%". Model: Codex or Sonnet 5.5 high.
TASK DONE when it shipped and is ON HIS PC.
