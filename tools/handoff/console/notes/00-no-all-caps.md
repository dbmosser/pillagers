# 00-no-all-caps notes
Plan: the game already has ONE text door, TX(s) (line ~3504): every canvas fillText/measureText (proto wrapper) and every text node under #root (txDom/txWatch) goes through it.
So the net is ncFix() inside TX (cw-nocaps-net, mk-cw-nocaps-net.ps1) + CSS `*{text-transform:none !important}` + title Pillagers.
Keep list NCKEEP (acronyms), NCKEYS (Esc, Tab...). Check scans txRecord() output of a raid frame + #root text nodes.
Run 1 status: mk script written, preflight next.
Later: source cleanup of .toUpperCase() display sites (names then render properly as Scav pistol etc), by area, optional.
Areas: [net] pending
