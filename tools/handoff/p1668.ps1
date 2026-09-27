$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# A TEAMMATE PICK UP IS CALLED REVIVED BEFORE IT TOOK, AND A HELD E THEN DOES NOTHING (stability pass, 2026-09-27; drafted by a review agent, reviewed by a second).

SubRx @'
function netRevHold(p,dt){
  var s=-1, nm;
  try{ s=netMateDown(p); }catch(e){ s=-1; }
  if(!keys['KeyE']) G.netRevDone=-1;
'@ @'
function netRevHold(p,dt){
  var s=-1, nm, w, g, rose;
  try{ s=netMateDown(p); }catch(e){ s=-1; }
  // v16.68, stability: A PICK-UP IS CALLED DONE ONLY WHEN IT TOOK. The window of the teammate refuses the word when he is not
  // down any more or is in the death fade, or it last heard this player out of reach, and the word can fail to reach it; he
  // stays down, yet this line said he was revived the moment the word went, and E held on stayed on him doing nothing until it
  // was let go. The line and the blip now wait for his own state word to show him up with health. Still down NET_HUB_STALE
  // seconds on (the age at which his word counts as stale), or gone from the list, the hold lets go of him, so E held on over
  // him starts a fresh pick-up. No number moved: reach, pick-up time and the health he gets up on are as they were.
  if(typeof G.netRevWait==='number'&&G.netRevWait>=0){
    w=G.netRevWait; g=NET.up[w]; G.netRevW=(G.netRevW||0)+dt;
    rose=!!(netUpShown(g)&&!g.dn&&g.hp>0);
    if(rose||!netUpShown(g)||G.netRevW>=NET_HUB_STALE){
      G.netRevWait=-1; if(G.netRevDone===w) G.netRevDone=-1;
      if(rose){ say((netSeatName(w)||'PILLAGER')+' revived.'); blip('pick'); }
    }
  }
  if(!keys['KeyE']) G.netRevDone=-1;
'@

SubRx @'
  G.netRevT=0; G.netRevS=-1; G.netRevDone=s;
  if(NET.role==='host') netRevPass(s,NET.seat);
  else for(var i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in') netSend(NET.peers[i],{t:'rev',s:s});
  say(nm+' revived.'); blip('pick');
'@ @'
  G.netRevT=0; G.netRevS=-1; G.netRevDone=s; G.netRevWait=s; G.netRevW=0;   // v16.68, stability: he is called revived when his word says he is up (above), not here
  if(NET.role==='host') netRevPass(s,NET.seat);
  else for(var i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in') netSend(NET.peers[i],{t:'rev',s:s});
'@

SubRx @'
var VER='16.67';
'@ @'
var VER='16.68';
'@

$pat = "(?m)^  now:'v16\.67:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.68: A TEAMMATE PICK UP IS CALLED REVIVED ONLY WHEN IT TOOK. Stability pass before a co-op session. When the pick up bar filled the game said REVIVED at once, but the other window could still refuse it (he was already in the death fade, or it last saw the reviver out of reach), so he stayed down while the reviver was told he was up, and holding E or X on over him then did nothing. The line now waits for his own word to show him up, and a pick up that did not take lets go after three seconds so the hold starts a fresh one. Check 16.68 fails on v16.67',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
