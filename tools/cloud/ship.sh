#!/bin/bash
# ship.sh start PREV NEW | ship.sh commit NEW cmNEW.txt : cloud port of tools/handoff/ship.sh.
# No publish zip, no butler, no itch: tools/publish is gitignored and his PC builds and pushes it.
set -e
R="$(cd "$(dirname "$0")/../.." && pwd)"; cd "$R"; SP="$R/tools/handoff"
vstr(){ local t=$1; if [ ${#t} -ge 4 ]; then echo "${t:0:2}.${t:2}"; else echo "${t:0:1}.${t:1}"; fi; }
case "$1" in
  start)
    PREV=$2; NEW=$3; PV=$(vstr $PREV); NV=$(vstr $NEW)
    git show HEAD:dark_raiders.html > "tools/prev$PREV.html"
    tools/cloud/ps.sh "$SP/p$NEW.ps1"; tools/cloud/ps.sh "$SP/f$NEW.ps1"
    pwsh -NoProfile -File tools/mkfixture.ps1 -Src "$R/tools/prev$PREV.html" -Dst "$R/tools/fx$PREV.html" | tail -1
    pwsh -NoProfile -File tools/mkfixture.ps1 -Src "$R/dark_raiders.html" -Dst "$R/tools/fixture.html" | tail -1
    grep -n "var VER=" dark_raiders.html
    awk -v pv="## v$PV - " 'NR==FNR{a[n++]=$0;next} index($0,pv)==1{for(i=0;i<n;i++)print a[i]} {print}' "$SP/d$NEW.txt" DESIGN.md > /tmp/DESIGN.new && mv /tmp/DESIGN.new DESIGN.md
    awk -v pvv="v$PV" 'NR==FNR{a[n++]=$0;next} {print} !ins && /^\| / {nc=split($0,c,"|"); vc=c[3]; gsub(/^[ \t]+|[ \t]+$/,"",vc); if(vc==pvv){for(i=0;i<n;i++)print a[i]; ins=1}}' "$SP/a$NEW.txt" AUDIT.md > /tmp/AUDIT.new && mv /tmp/AUDIT.new AUDIT.md
    grep -n "^## v$NV \|^## v$PV " DESIGN.md | head -3
    grep -c "| v$NV |" AUDIT.md
    ;;
  commit)
    T=$2; CM=$3
    rm -f tools/prev*.html tools/fx[0-9]*.html tools/fxdry*.html tools/fxctl*.html
    grep -v "^Co-Authored-By:\|^Claude-Session:" "$SP/$CM" | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}' > /tmp/cm.txt
    printf "\nCo-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>\nClaude-Session: https://claude.ai/code/session_015DfKciDF8kE7yQPbzbpFm4\n" >> /tmp/cm.txt
    git add -A; git commit -q -F /tmp/cm.txt; git log --oneline -1
    ;;
  *) echo "usage: ship.sh start PREV NEW | ship.sh commit NEW CMFILE"; exit 2;;
esac
