# o-00y2 2p-lifecycle-test : run the narrowed 2 player lifecycle test o-00y prepared, and fix what it finds
camera: 3
His 10-30 order: "Over the next 30 hours, Make any edits you see as critical for two player play, and test them... try to blow Codex instead". o-00y used both camera rounds before its corrected test ran. Its words: "Coordinator action is now required to execute the corrected narrowed lifecycle test ... A single 1080p run per role is sufficient".
Run the corrected lifecycle mode of online-audit.js with camera-recipes.json, both prepared in /c/claudecode/pillagers-codex/.codex-work/o-00y-2p-online-party-critical/. Copy them into this job's work folder. It covers:
- repeat raids after extract, death and abandon
- host death, then return to the hub while the guest keeps playing
- saved names under separate keys
- play going on after either side's link closes
- both seats linked in a final raid
Findings so far: notes/o-00y-findings.md (the two-PC test on his real PCs passed 10 of 10; the guest's minute up top was the test's own 60 s wait, not the game).
A real break gets a fix through the full gate and the 2-window checks. A pass goes as one line per case in notes/o-00y-findings.md. Also fix the p2.mjs guest 60 s wait as o-00z described: home() after the same 3 s as the host, and record extract-to-home ms.
TASK DONE when every fix is ON HIS PC and the findings list every lifecycle case.
