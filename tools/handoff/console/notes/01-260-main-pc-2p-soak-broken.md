# 01-260-main-pc-2p-soak-broken (lane c, 11-01)

Verdict: (a) harness only. Details and the coordinator steps: notes/260/why.md. Fixed page: notes/260/nettest.html.new.
Scripts: S/mk-cw-260-patch.ps1 (builds the .new from tools/nettest.html), S/mk-cw-260-soak.ps1 (VM driver: own Chrome 9353,
serve.mjs on 8817 over a staging folder in %TEMP%\pillagers-260-stage; -Runs N -Soak S -Tag name; writes notes/260/run-TAG.txt).
Status at end of run 1: page fixed (17 edits), VM soak 3 of 6 (all failures half second frame hitches), handed to the coordinator
in alarms.md. A later run: if the main PC soak with this page still says "frames stalled", look for what hitches (map, menus,
saves under random keys), not the harness. Trial edits that did not help and were taken out: hiding copy B, a speed-relative stall rule.
Runs: run-a (old page, fails like the main PC), run-b..f (fix steps), run-g (first PASS), run-soak6 (6 x 120 s soak).
