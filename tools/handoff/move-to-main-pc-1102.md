# Move HTML Pillagers dev to the main PC (his order 11-02)

His words: "move pillagers html development to the main PC permanently", "start working on FnP on the main PC", "shut down the VM (for now)", "use the JTPC for pillagers html testing", "do anything ancillary or necessary related to these tasks", "put everything you can on bypass mode so that I don't have to manually approve anything".

Rules that hold: no tests on the main PC (build checks included); 4 GB free on the main PC; FnP has first call on memory; 8802 and the party copy keep following master; his work login on the terminal Claude stays untouched; he enters his own keys and sign-ins; the repo is PUBLIC, so memory notes and scratch files never go through git; only one machine ships at a time.

## Pieces
A. Remote gate. Build checks run on the JTPC. tools/handoff/console/caps.txt GATE_REMOTE=1 turns it on. Notes: tools/handoff/console/notes/move/remote-gate.md
B. Move kit. tools/migrate/main-dev-*.ps1 and vm-go-dark. Notes: tools/handoff/console/notes/move/kit.md
C. FnP. The "FnP main PC" chat works from docs/goals-saturday-1107.md now; it does not wait for A or B.

## Order
1. Build and prove A from the VM, with the VM still the only shipper.
2. Build B. Pack scratch and memory to the bridge share in parts of 12 MB or less, secret scan first.
3. Main PC Claude runs the setup: old folder kept under a new name, fresh clone, restore, tasks on with STOP in place.
4. His one sitting at the main PC: bypass opt-in, helper sign-in (separate config folder), his keys, one new desktop chat in C:\claudecode\dark raiders with tools/handoff/main-pc-first-message.md.
5. VM goes dark: STOP files, its runner off, stay-off startup rule. The new chat lifts STOP on the main PC and ships one build. ON HIS PC line.
6. CHANGED by his order 11-02 evening: the VM stays up, because his TbT work runs in it. vm-wanted.txt stays in the bridge share. Only Pillagers dev leaves the VM.

## Done when
A build shipped from the main PC, checked on the JTPC, shows ON HIS PC; the VM has stopped developing and shipping Pillagers (it stays up for TbT); the main PC has 4 GB free or more with the editor open; helpers, check-ins, dashboard and itch run from the main PC.

## FnP clicks only he can do (from the FnP chat, 11-02)
1. Allow the island chat's click request in the editor if it comes up again (he said "Allowed" about 07:35; no island on disk at 07:40).
2. Tue 11/3: friend join test on a blank island (he already said yes).
3. Epic's adult check, for him and his friend.
4. Two-factor on his Epic account, if it isn't on.
5. Any Epic sign-in or terms screen.
Open, no rush: his order to switch the main PC terminal Claude to his personal account rested on a wrong report and was held; the move does not need it.
