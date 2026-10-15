#!/bin/bash
# gatetail.sh KEY: run after `draftgate.py KEY --keep` stopped ONLY on an external regression (e.g. the 27.15 what is new card stamp,
# which every build past a card's range trips until the PC restamps it). Runs the two gate steps that come after the recent-checks
# stage on the kept drafted build: the seed 4242 fingerprint and node --check. Then removes the kept files.
cd "$(dirname "$0")/../.."; K=$1
node tools/cloud/run.mjs verify gd-dry-$K.html 2>&1 | grep -v 'agent-proxy\|connect_rejected\|For details\|While this' | tail -1
python3 - "$K" <<'PY'
import re,sys,subprocess
k=sys.argv[1]; s=open('tools/gd-game-'+k+'.html',encoding='utf-8').read()
js='\n;\n'.join(re.findall(r'<script\b[^>]*>([\s\S]*?)</script>', s)); open('/tmp/gt-'+k+'.js','w').write(js)
p=subprocess.run(['node','--check','/tmp/gt-'+k+'.js'],capture_output=True,text=True); print('node --check:', 'OK' if p.returncode==0 else p.stderr[:600])
PY
rm -f tools/gd-dry-$K.html tools/gd-ctl-$K.html tools/gd-game-$K.html /tmp/gd-mk-$K.ps1 /tmp/gt-$K.js
