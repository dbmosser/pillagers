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

# A DISPLACED ALERT IS NEVER LOST (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function alertShow(m,k,o,now){
'@ @'
// v22.xx, the raid text rewrite (fix after batch 3, tr3fixa): A DISPLACED ALERT IS NEVER LOST. The alert lane promised that a line
// is never lost, but an alert another line replaced after it had shown 0.6 s was simply thrown away. So EXTRACTION CALLED and its
// detail (the wait, or that the raid clock runs out first) showed for about half a second before THE SIEGE took the slot; at six
// minutes left in every default raid one ring CLOSED and another ring CLOSING flashed for half a second; and a held alert
// (TEAMMATE DOWN while he stays down, the Crier mark while it runs) vanished for good the moment any crit came in. Now an alert
// that is replaced while it still has more than a second of life, or while its condition still holds, goes back to the alert
// queue with the life it had left. It waits there without pushing anything aside and returns as soon as the slot is free: up to
// 5 s, or up to 8 s while its condition holds, and if it still cannot show it drops into the feed as before. A held line whose
// condition ends while it waits has nothing left to say and is dropped.
function alertShow(m,k,o,now){
'@

SubRx @'
  if(a&&a.m!==m&&now-a.at<0.6) alertEnq(a.m,a.k,{sub:a.sub,key:a.key,hold:a.hold,icon:a.icon,c:a.c},a.at);   // a crit took it before it was read: it waits, from when it first showed
'@ @'
  if(a&&a.m!==m&&(now-a.at<0.6||alertHeld(a)||(a.T>1.0&&!a.hold)))   // v22.xx (tr3fixa): it goes back to the queue with the life it had left
    alertEnq(a.m,a.k,{sub:a.sub,key:a.key,hold:a.hold,icon:a.icon,c:a.c,life:alertHeld(a)?Math.max(a.T,1.5):a.T},now,1);
'@

SubRx @'
function alertEnq(m,k,o,now){
'@ @'
function alertEnq(m,k,o,now,back){   // v22.xx (tr3fixa): back, an alert another line displaced
'@

SubRx @'
  q.push({m:m,k:k,o:o||null,key:key,t:now});
'@ @'
  q.push({m:m,k:k,o:o||null,key:key,t:now,back:back?1:0});
'@

SubRx @'
  for(i=q.length-1;i>=0;i--) if(now-q[i].t>1.5) alertToFeed(q.splice(i,1)[0]);   // waited 1.5 s: into the feed, never lost
'@ @'
  for(i=q.length-1;i>=0;i--){
    e=q[i];
    if(e.back&&e.o&&e.o.hold&&!alertHeld({hold:e.o.hold})){ q.splice(i,1); continue; }   // v22.xx (tr3fixa): its condition is over
    if(now-e.t>(e.back?((e.o&&e.o.hold)?8:5):1.5)) alertToFeed(q.splice(i,1)[0]);   // waited 1.5 s (a displaced alert 5 s, a held one 8 s): into the feed, never lost
  }
'@

SubRx @'
  a=alertUp(); b=0; br=-1e9;
'@ @'
  a=alertUp(); b=-1; br=-1e9;
'@

SubRx @'
  for(i=0;i<q.length;i++) if(MSGK[q[i].k].r>br){ br=MSGK[q[i].k].r; b=i; }
'@ @'
  for(i=0;i<q.length;i++) if((!a||!q[i].back)&&MSGK[q[i].k].r>br){ br=MSGK[q[i].k].r; b=i; }   // v22.xx (tr3fixa): a displaced alert waits for a free slot
'@

SubRx @'
  if(!a||(br>=MSGK[msgKind(a.k)].r&&now-a.at>=0.6)){ e=q.splice(b,1)[0]; alertShow(e.m,e.k,e.o,now); }
'@ @'
  if(b>=0&&(!a||(br>=MSGK[msgKind(a.k)].r&&now-a.at>=0.6))){ e=q.splice(b,1)[0]; alertShow(e.m,e.k,e.o,now); }
'@

SubRx @'
var VER='22.43';
'@ @'
var VER='22.44';
'@

$pat = "(?m)^  now:'v22\.43:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.44: An alert pushed aside by a more urgent one comes back when that one ends, so EXTRACTION CALLED and TEAMMATE DOWN stay readable. Check 22.44 fails on v22.43',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
