coord-03-itch-push-in-vm : itch uploads stopped when work moved into the VM; restore the push and pack the licence files (planner draft 2026-10-20)
effort: low

COORDINATOR, plus ONE step only he can do. Do not move into tasks/ (lanes may not edit tools/*.sh or RULES.md).
Source: memory pillagers-github-and-cloud.md (10-15): "please push the game to itch once a day so we always have a backup"; q-process/answers.md 71: "b) itch.io now, Steam later".
Not done (planner, 10-20): tools/handoff/nightly/nightly.log "10-20 00:05 daily: itch not set up"; tools/itch-daily.sh line 13
B=/c/Users/User1/bin/butler.exe and tools/handoff/ship.sh line 32 default to the old host's butler path; ship.sh line 43 prints "itch:
not pushed" without the key and target; the skeptic's presence-only check (no values read) found BUTLER_API_KEY and ITCH_TARGET unset in
the VM. tools/publish/pillagers-web.zip (10-20 11:30) holds only index.html (planner's zip listing), though tools/PUBLISH.md lines 67 and
70 say the font and sound licence files must travel with it.

1. Point itch-daily.sh and ship.sh at the VM's butler (C:\Users\VM Oct26\bin\butler.exe, or command -v butler).
2. Licence files in the zip, in both ship.sh (about line 23) and itch-daily.sh (about line 18): tools/fonts/OFL-*.txt, plus OFL texts for
   Titan One and Rubik, which the game also embeds (@font-face lines 14 and 16) and which tools/fonts lacks; tools/sounds/LICENCES.txt
   and the four kenney_*_License.txt files, while those sounds stay (his 23 c "keep it all made here" is a question for the next round,
   not a removal).
3. Fix RULES.md line 98 now ("itch pushes only once his key is set in the VM").
4. His one step, told in chat in two plain lines (no steps page, his 86 b): set the two Windows user values in the VM (the butler key and
   the target). Helpers never see or print the key. His 10-15 order is already the yes that 2.84 a asks for; do not ask again. Check first
   whether the 08-25 itch project exists (memory dark-raiders-itch-publish.md; pillagers-github-and-cloud.md line 50 records the target), so
   he only sets values instead of making a new project.
5. After: the next ship logs "itch: pushing" and the itch channel is at HEAD. The page stays password-locked until he opens it.
Party risk: low (tools and his account only).
Done when: an itch push has run from the VM and the zip lists the licence files.

DONE 10-20 13:50 (coordinator, 85fd178d): butler was already reachable (C:\Users\User1 is a junction to the VM profile). ITCH_TARGET set in the VM. tools/itch-zip.ps1 now builds the zip for ship.sh and itch-daily.sh with all 10 licence files at the top level; Titan One and Rubik OFL texts added (copyright lines read from the embedded fonts). ai-keys.ps1 has an itch slot. Left: his key (for-you.md), then the next ship logs "itch: pushing". RULES.md line 98 goes with coord-05.
