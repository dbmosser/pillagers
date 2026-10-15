#!/bin/bash
# Cloud proof runner: bash tools/cloud/ev.sh FILE.js [fixture]
# Runs the JS in FILE.js INSIDE the game scope (direct eval through window.__ev) in a freshly loaded fixture at 1920x1080
# and prints the result. The scratch fixture tools/fx1.html is tools/fixture.html plus one line:
#   window.__ev=function(s){ return eval(s); };   placed just before window.__REGRESS=[
# Rebuild it after every fixture rebuild:  bash tools/cloud/ev.sh --rebuild
# FILE.js is an expression (wrap statements in an IIFE) and should return a JSON-able value or a string.
cd "$(dirname "$0")/../.."
if [ "$1" = "--rebuild" ]; then sed 's/^window\.__REGRESS=\[/window.__ev=function(s){ return eval(s); };\nwindow.__REGRESS=[/' tools/fixture.html > tools/fx1.html; grep -c "__ev=" tools/fx1.html; exit 0; fi
FX=${2:-fx1.html}
node tools/cloud/run.mjs eval "$FX" "__ev($(node -e 'process.stdout.write(JSON.stringify(require("fs").readFileSync(process.argv[1],"utf8")))' "$1"))" 2>&1 | grep -v '^\[agent-proxy\]\|connect_rejected\|For details: curl\|While this command ran'
