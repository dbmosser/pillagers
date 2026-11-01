# 136-save-second-copy : the profile keeps a second copy in IndexedDB and asks the browser to keep it
Queue (coordinator 10-25 14:00): his request "Conduct fresh deep internet research that you think will best help accelerate and improve development of this game" (Sun 10-25). Source: reports/Top down extraction shooter research.md and research_notes/Top down extraction shooter research/fit_*.md (line numbers read on v34.83; check them on HEAD). Release fix (itch.io, Thanksgiving): games on itch's default domain share one storage area that other games can read or clear; Safari with tracking prevention can delete script data after seven days without a click.
Since v34.81 the SMOOTH look is the default: test and take pictures in the smooth look.
effort: medium

Do: the profile lives only in localStorage (storeSet about line 4993); IndexedDB is only used for attract clips (attDb about 50830). Mirror every successful profile save into IndexedDB, read it back when localStorage is empty or fails to parse, and call navigator.storage.persist() once after a user gesture. Never change the storage key salvagerun:profile and never change the profile shape (no migration needed). The check proves a cleared localStorage restores from the copy.

Rules: the seed 4242 fingerprint (ents 85/374, containers 165/593) must hold unless this brief says otherwise; the check must FAIL on the build before; both windows; player text all lower case. Say in DESIGN.md what he should watch for in a playtest.
TASK DONE when it shipped; TASK PARTIAL with what is left.
