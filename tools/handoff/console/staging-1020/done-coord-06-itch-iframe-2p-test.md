coord-06-itch-iframe-2p-test : prove the 2-player same-machine mode links inside itch's frame, and plan a fix if it does not (planner draft 2026-10-20)
DONE 10-21 02:50 (coordinator): measured (workflow wf_0eba117f-79c): the real game does NOT link in a cross-site frame; the opener postMessage path works there. Write-up notes/coord-06.md. Fix queued as tasks/85a-itch-couch-link.md (first in line), the own-process split as tasks/95-p2-own-process.md (after 85a, behind an experimental switch). The real itch draft test stays open as part of 85a.
effort: high

SESSION AGENT (d, g or h) OR COORDINATOR. Not a lane job: it needs a lane test port, a framing page under tools/ and Chrome started by
hand; job 47 failed for exactly this reason ("Needs a session with those permissions"). Do not move into tasks/.
Source: tools/handoff/q-process/answers.md 76: "Both, couch mode up front | NOTE: couch mode IS career mode"; q-round3/answers.md 2.94: "b: The 2-player couch mode (it is the unique thing)".
Not done (planner, 10-20): the two windows find each other only over a BroadcastChannel (netSameChan, dark_raiders.html 55792-55794,
after window.open about 55861); grep -c window.opener dark_raiders.html = 0, so there is no fallback; reportEmbedded() (65934) shows the
game knows it runs in a frame. No iframe or cross-site test exists in tools/mkfixture.ps1 or tools/handoff (skeptic grep). Chrome
partitions BroadcastChannel and storage for third-party frames, and itch serves the game from html-classic.itch.zone inside itch.io, so
the frame and the top-level player 2 window very likely cannot link (UNVERIFIED).

1. Measure first, on a lane test port, never 8802: a page on 127.0.0.1:PORT frames the game from localhost:PORT2 (different sites, so it
   reproduces the partition).
2. In the frame: start the 2-player same-machine mode. Do both windows link and play a raid? Do pads work in the frame? Does a download
   work (the Settings backup set_backup, about 68041-68050, always says "backed up to downloads"), or does it fail silently?
3. Write the results in plain words in notes/coord-06.md.
4. If the link fails: draft a fallback that runs only when reportEmbedded() is true (window.opener postMessage, or open both windows top
   level). The localhost path must not change. If the download fails silently, draft an honest message for the frame case.
Party risk: HIGH if the pairing code changes before the party (the party runs this exact code on localhost). Measure now; ship a fix after
the Thu 10/29 lock, or before it only if the gate proves it runs only when reportEmbedded() is true.
Done when: the frame test result is written, and a fix is drafted or not needed.
