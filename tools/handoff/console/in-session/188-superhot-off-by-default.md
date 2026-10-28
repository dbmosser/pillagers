# 188-superhot-off-by-default : every game starts with Superhot off
Queue: his order 10-27 ~20:35 in chat (verbatim): "superhot mode should be off by default". Fix, allowed before 11/1.
effort: medium
Worked in: a Claude session started from his orders thread. Lanes skip in-session/.

What is true now (checked 10-27): the built-in default is already off (CFG superhot:0, dark_raiders.html line ~4179; Settings row ~71717 Off/On). But the setting is saved in his profile, and every export since 10-25 shows superhot:1, so the game opens with it on for him, and on the party night it would open on for his guests (they play on his PC and profile). The toggle key is the one left of 1 (backquote, his 10-18 order), right next to the gun key 1, so it is easy to turn on by accident.
Reading of his order: the game starts every sitting with Superhot off. It is no longer remembered across loads.
1. On load (and on a profile restore), Superhot starts off whatever the saved value says. The Settings row and the key still turn it on for that sitting; nothing writes it back as on for the next load. Keep the storage key salvagerun:profile unchanged.
2. The 2 player arcade demo starts with it off too; on a linked window the host rule (v16.74) still decides for the party during a raid.
3. Leave the key, the row, the state word and Superhot itself as they are.
Checks (must FAIL on v35.28): a profile saved with superhot 1 loads with CFG.superhot 0; turning it on in Settings then reloading gives 0; the demo starts at 0. Control: the Settings row still turns it on in the same sitting.
Ship: preflight on lane h (check no other preflight runs on h first), then shipq. Rules: player text lower case; no storage key change; seed fingerprint unchanged.
TASK DONE when shipped and his main PC reports the build (git show origin/spare-results:spare/JUL26/status.txt, game=VER). Then move this file to console/done/ and report one line: build, on his PC, and that the key left of 1 still turns it on for one sitting.
