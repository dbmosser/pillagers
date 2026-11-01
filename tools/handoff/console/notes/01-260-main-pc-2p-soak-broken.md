# 01-260-main-pc-2p-soak-broken (lane c, 11-01)

Verdict: (a) harness only. Details and the coordinator steps: notes/260/why.md. Fixed page: notes/260/nettest.html.new.
Scripts: S/mk-cw-260-patch.ps1 (builds the .new from tools/nettest.html), S/mk-cw-260-soak.ps1 (VM driver: own Chrome 9353,
serve.mjs on 8817 over a staging folder in %TEMP%\pillagers-260-stage; -Runs N -Soak S -Tag name; writes notes/260/run-TAG.txt).
Runs: run-a (old page, fails like the main PC), run-b..f (fix steps), run-g (first PASS), run-soak6 (6 x 120 s soak).
