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

# WHEN THE WHOLE PARTY PAUSES, THE GAME PAUSES. His order of 2026-09-27.

SubRx @'
  if(!G||G.over||(G.paused&&!netUpShared())) return;   // v16.11, backcheck: a pause in a shared raid is an overlay (v16.04), so the storm runs on
'@ @'
  if(!G||G.over||(G.paused&&!netPauseLive())) return;   // v16.11: a pause in a shared raid is an overlay (v16.04), so the storm runs on; v16.20: unless the whole party is paused
'@

SubRx @'
  if((!G.paused||netUpShared())&&!G.over&&G.deathBeat!==undefined&&G.deathBeat!==null){
'@ @'
  if((!G.paused||netPauseLive())&&!G.over&&G.deathBeat!==undefined&&G.deathBeat!==null){
'@

SubRx @'
  else if((!G.paused||netUpShared())&&!G.over){   // v16.04: in a shared co-op raid pause is an overlay: the world and the clock run on
'@ @'
  else if((!G.paused||netPauseLive())&&!G.over){   // v16.04: in a shared co-op raid pause is an overlay: the world and the clock run on; v16.20: everyone paused stops it
'@

SubRx @'
      if(G.paused&&netUpShared()) netPausedStep(dt);   // v16.04: paused in a shared co-op raid, he stands still while the world runs on
'@ @'
      if(G.paused&&netPauseLive()) netPausedStep(dt);   // v16.04: paused in a shared co-op raid, he stands still while the world runs on
'@

SubRx @'
       c:(G.pCrouch||crouchHeld())?1:0,sp:G.sprinting?1:0,dn:p.downed?1:0,w:(p.wep&&p.wep.id)?String(p.wep.id):''};
'@ @'
       c:(G.pCrouch||crouchHeld())?1:0,sp:G.sprinting?1:0,dn:p.downed?1:0,w:(p.wep&&p.wep.id)?String(p.wep.id):'',pz:G.paused?1:0};   // v16.20: pz, this player is paused
'@

SubRx @'
  if(up){ g.cr=m.c?1:0; g.sp=m.sp?1:0; g.dn=m.dn?1:0; g.w=netClean(m.w,24); g.sd=(+m.sd)>>>0; }   // v15.79: crouched, sprinting, downed, the gun in hand and the seed of the raid he is in
'@ @'
  if(up){ g.cr=m.c?1:0; g.sp=m.sp?1:0; g.dn=m.dn?1:0; g.w=netClean(m.w,24); g.sd=(+m.sd)>>>0; g.pz=m.pz?1:0; }   // v15.79: crouched, sprinting, downed, the gun in hand and the seed of the raid he is in; v16.20: paused
'@

SubRx @'
    if(up){ out.k='r'; out.sd=g.sd; out.c=g.cr; out.sp=g.sp; out.dn=g.dn; out.w=g.w; }   // v15.79: passed on as it came
'@ @'
    if(up){ out.k='r'; out.sd=g.sd; out.c=g.cr; out.sp=g.sp; out.dn=g.dn; out.w=g.w; out.pz=g.pz; }   // v15.79: passed on as it came
'@

SubRx @'
function netPausedStep(dt){
'@ @'
// v16.20, HIS ORDER: WHEN THE WHOLE PARTY PAUSES, THE GAME PAUSES. A pause in a shared raid is an overlay (v16.04) so one player
// cannot stop the world on the others; when this player is paused and every teammate up top on the party seed says he is paused
// too (pz in his state word), nobody is playing, so the world, the clock and the storm stop as in solo. Any one unpausing starts it.
function netAllPaused(){
  var i, g, n=0;
  if(typeof G==='undefined'||!G||!G.paused) return false;
  for(i=0;i<NET.up.length;i++){ g=NET.up[i]; if(!netUpShown(g)) continue; if(!g.pz) return false; n++; }
  return n>0;
}
function netPauseLive(){ return netUpShared()&&!netAllPaused(); }
function netPausedStep(dt){
'@

SubRx @'
var VER='16.19';
'@ @'
var VER='16.20';
'@

$pat = "(?m)^  now:'v16\.19:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.20: WHEN THE WHOLE PARTY PAUSES, THE GAME PAUSES. His order. In co-op one player pausing still leaves the world running for the others, but when every player in the raid is paused the world, the clock and the storm stop, as in solo. Any one unpausing starts it again. No number moved. Check 16.20 fails on v16.19',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
