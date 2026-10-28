# 120f-pad-x-reload-prompt : the pad x prompt says reload when x will reload; a held x searches after the reload
Queue (coordinator 10-25 12:45): his question "What can you do to improve gameplay/smoothness/mechanics" (Sun 10-25). Party fix (Fri 10/30 first). Read notes/gameplay-next-1025.md, idea 7, for the why, the cautions and the line numbers (check them on HEAD; they were read on v34.78).
Since v34.81 the SMOOTH look is the default (his 10-25 order "I want the graphics smooth"): test and take pictures in the smooth look.
effort: small

Do: at a container in a fight with an empty or part magazine, the prompt names what X will do ("[x] reload" when it reloads), and a held X starts the search once the reload ends. Keyboard unchanged. Checks: the prompt matches the action in both cases; a held X searches after the reload.

Rules: the seed 4242 fingerprint (ents 85/374, containers 165/593) must hold unless this brief says otherwise; the check must FAIL on the build before; both windows; player text all lower case. Say in DESIGN.md what he should watch for in a playtest.
TASK DONE when it shipped; TASK PARTIAL with what is left.
