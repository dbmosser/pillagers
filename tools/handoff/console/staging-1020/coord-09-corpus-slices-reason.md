coord-09-corpus-slices-reason : the corpus failure list keeps the reason for long check names (planner draft 2026-10-20)
effort: low

COORDINATOR ONLY (lanes may not edit tools/*.sh). Do not move into tasks/.
WAIT: edit only while no corpus runs. One started 12:50 today (about 3.5 hours), and bash reads a running script as it goes (memory
dark-raiders-never-edit-a-running-bash-script).
Source: tools/handoff/console/alarms.md (o-02, 10-20): "corpus failure reasons are still lost for long check descriptions".
Not done (planner, 10-20): tools/corpus-slices.sh line 30 still applies slice(0,240) to the whole failure string (planner read the line);
the file's last commit 77cdb711 only flattened line breaks; in tools/handoff/corpus-fails-v32.83.txt the 27.36, 26.92 and 24.47 lines end
mid-description with no " -> " reason (114 lines, 74 with a reason, per the skeptic).

1. Always keep the version and the text after the last " -> "; shorten only the description in between.
2. Check it on the next corpus list: every red line shows a reason.
Party risk: none (test tooling).
Done when: the next corpus list has a " -> " reason on every red line. Small: one line of code.

COORDINATOR 10-20 16:23: step 1 done (no full run was going; swapped in as a new file, so a running bash would keep the old copy).
A failure line now keeps "vNN.NN", at most 140 characters of description (then "..."), and " -> " with up to 400 characters of reason.
stable.mjs keys a check on its first 80 characters, which are unchanged, so old and new runs still match. Step 2 is left: read the
next corpus list and confirm every red line has a reason, then rename this file done-coord-09.
