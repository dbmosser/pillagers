coord-02-stable-known-red : the known-red list and 30 robot minutes on the corpus build, so stable moves past v29.09 (planner draft 2026-10-20)
effort: medium

COORDINATOR ONLY (lanes cannot write tools/handoff/stable-known-red.txt or start runs). Pairs with lane job 58. Do not move into tasks/.
Source: tools/handoff/q-round3/helper-fixes.md item 16: "Create the known-red tests list"; q-round3/answers.md 3.40: "b: The newest version that passed all the tests".
Not done (planner, 10-20): ls tools/handoff/stable-known-red.txt -> "No such file" (tools/stable.sh line 17 reads it); stable-status.txt
"Latest stable: v29.09 (2026-10-18 10:23)", "Result: no change" (checked 12:56); every corpus line there shows "robots 0 min/0
problems"; tools/stable.sh rule 3 (line 9) needs the robots to play 30+ minutes on exactly that version. The skeptic found every fuzz run
since 10-19 22:24 ended on low RAM, and the one long run (54.9 min) was on v32.79 to v32.81, not a corpus build.

The runner already starts a corpus on each new HEAD (tools/nightly.sh lines 122-129) and fuzz2 on the corpus copy (lines 160-164), so do
NOT build a new night run.
1. When corpus-1020-1250 (v32.90, started 12:50) finishes: write tools/handoff/corpus-fails-v32.90.txt and move job 58 into tasks/.
2. Create tools/handoff/stable-known-red.txt from 58's notes/58-known-red-proposal.txt: out-of-date checks only, one reason each, never a
   real bug (his Q48 process).
3. Tonight, when the VM has its night memory (his 45 a, host-night-memory.ps1 at 23:00), make sure fuzz2 gets 30+ clean minutes on that
   same fxcorpus copy; watch the FUZZ END lines.
4. Check stable.sh promotes, stable.html moves past v29.09 and gets a tag. Repeat each night so a party version exists before the Thu
   10/29 lock (3.40 b) and a stable one for his play window (Q12).
Party risk: low for the game (no game change); high for the party if skipped (by his rule the party version would be v29.09).
Done when: stable.html is v32.9x and stable-status.txt says why.
