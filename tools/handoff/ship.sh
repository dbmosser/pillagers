#!/bin/bash
# ship.sh: the per-build shell chain, so each build is one call and one shape.
#   ship.sh commit 1000 cm1000.txt      -> rm control fixtures, archive, zips, git commit -F
#   ship.sh start 1000 1001            -> prev1000 from HEAD, apply p1001 + f1001, build fx1000 + fixture, insert d1001/a1001 after the v10.00 rows, copy cm1001
# Versions are given as 4-digit tags (1000 = v10.00, 999 = v9.99).
set -e
cd "/c/claudecode/dark raiders"
SP="${SP:-/c/claudecode/dark raiders/tools/handoff}"
vstr(){ local t=$1; if [ ${#t} -ge 4 ]; then echo "${t:0:2}.${t:2}"; else echo "${t:0:1}.${t:1}"; fi; }
case "$1" in
  commit)
    T=$2; CM=$3
    rm -f tools/prev*.html tools/fx[0-9]*.html
    powershell -NoProfile -ExecutionPolicy Bypass -File tools/archive-build.ps1 2>&1 | tail -1
    cp dark_raiders.html tools/publish/index.html
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Compress-Archive -Force -Path 'C:\claudecode\dark raiders\tools\publish\index.html' -DestinationPath 'C:\claudecode\dark raiders\tools\publish\dark_raiders_web.zip'; Compress-Archive -Force -Path 'C:\claudecode\dark raiders\tools\publish\index.html' -DestinationPath 'C:\claudecode\dark raiders\tools\publish\pillagers-web.zip'"
    # THE ITCH PUSH, and it does nothing until he has set it up. butler is itch's
    # own uploader; it is not installed here and needs an API key only he can make.
    # The guard means this line is inert today and live the moment tools/HOSTING.md
    # has been followed, with no further change to this file.
    if command -v butler >/dev/null 2>&1 && [ -n "$BUTLER_API_KEY" ] && [ -n "$ITCH_TARGET" ]; then
      echo "itch: pushing $ITCH_TARGET"
      butler push tools/publish/pillagers-web.zip "$ITCH_TARGET" --userversion "v$(vstr $T)" 2>&1 | tail -2
    else
      echo "itch: not pushed (butler, BUTLER_API_KEY or ITCH_TARGET missing; see tools/HOSTING.md)"
    fi
    git add -A
    git commit -q -F "$SP/$CM" 2>/dev/null || git commit -q -F "/tmp/$CM"
    git log --oneline -1
    ;;
  start)
    PREV=$2; NEW=$3; PV=$(vstr $PREV); NV=$(vstr $NEW)
    git show HEAD:dark_raiders.html > "tools/prev$PREV.html"
    powershell -NoProfile -ExecutionPolicy Bypass -File "$SP/p$NEW.ps1"
    powershell -NoProfile -ExecutionPolicy Bypass -File "$SP/f$NEW.ps1"
    powershell -NoProfile -ExecutionPolicy Bypass -File tools/mkfixture.ps1 -Src "tools/prev$PREV.html" -Dst "tools/fx$PREV.html" 2>&1 | tail -1
    powershell -NoProfile -ExecutionPolicy Bypass -File tools/mkfixture.ps1 2>&1 | tail -1
    grep -n "var VER=" dark_raiders.html
    # DESIGN: insert the new entry before the previous version's heading (newest first)
    awk -v pv="## v$PV - " 'NR==FNR{a[n++]=$0;next} index($0,pv)==1{for(i=0;i<n;i++)print a[i]} {print}' "$SP/d$NEW.txt" DESIGN.md > /tmp/DESIGN.new && mv /tmp/DESIGN.new DESIGN.md
    # AUDIT: insert the new row(s) after the FIRST table row whose version cell (2nd column) is exactly v$PV, then stop.
    # (A version can carry more than one row - e.g. a fix row plus a harness-repair row - and matching every one duped the insert: v11.40->41->42.)
    awk -v pvv="v$PV" 'NR==FNR{a[n++]=$0;next} {print} !ins && /^\| / {nc=split($0,c,"|"); vc=c[3]; gsub(/^[ \t]+|[ \t]+$/,"",vc); if(vc==pvv){for(i=0;i<n;i++)print a[i]; ins=1}}' "$SP/a$NEW.txt" AUDIT.md > /tmp/AUDIT.new && mv /tmp/AUDIT.new AUDIT.md
    cp "$SP/cm$NEW.txt" "/tmp/cm$NEW.txt"
    grep -n "^## v$NV \|^## v$PV " DESIGN.md | head -3
    grep -c "| v$NV |" AUDIT.md
    ;;
  *) echo "usage: ship.sh commit TAG CMFILE | ship.sh start PREVTAG NEWTAG"; exit 2;;
esac
