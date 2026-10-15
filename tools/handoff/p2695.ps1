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

# TEAM COMBO (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  try{ pwrKill(k,el,boss,x,y,ke); }catch(_pk){}   // v26.xx (party2): a kill may drop a power-up
'@ @'
  try{ pwrKill(k,el,boss,x,y,ke); }catch(_pk){}   // v26.xx (party2): a kill may drop a power-up
  try{ teamKill(x,y); }catch(_tk){}   // v26.xx (party4): a kill within 2 s and a short way of the partner's builds the TEAM combo
'@

SubRx @'
  if(m.t==='arcsc') return arcadeScTake(m);   // v23.29 (arcade8): the teammate score, both ways
'@ @'
  if(m.t==='arcsc') return arcadeScTake(m);   // v23.29 (arcade8): the teammate score, both ways
  if(m.t==='arckill') return arcadeTeamTake(m);   // v26.xx (party4): the partner kill, for the TEAM combo
'@

SubRx @'
    try{ styleDraw(ctx,p,rx0,ry0); }catch(_sdw){}   // v26.xx (party1): the combo ring and the medal plates   // v26.xx (settings6): the middle, the 2 pixel square it was by default
'@ @'
    try{ styleDraw(ctx,p,rx0,ry0); }catch(_sdw){}   // v26.xx (party1): the combo ring and the medal plates   // v26.xx (settings6): the middle, the 2 pixel square it was by default
    try{ teamDraw(ctx,p,rx0,ry0); }catch(_tdw){}   // v26.xx (party4): the TEAM combo ring
'@

SubRx @'
// PARTY-MODULE-END (the next party builds add their code above this line)
'@ @'
// v26.xx (party4), HIS YES (2026-10-14) to suggestion 49, the TEAM COMBO, in the 2 player DEMO: "kills by both players within 2 s and a short distance build a
// shared TEAM multiplier". Each window tells the other about every kill it credits (arckill: where it fell, and whether it paired). A kill pairs with the
// partner's latest kill that has not been paired yet when it comes inside TEAM.win (2 s) and TEAM.r (52 m) of it: the window that makes the SECOND kill pays
// TEAM.pts (40) times the chain, to the team score (a TEAM COMBO medal, a TEAM COMBO callout and a note), and tells the other window that the pair was made
// (lk), so a kill is in one pair only and the figure is paid once. A pair that comes within 2 s of the last pair makes the chain longer, up to x5 (200); a
// longer gap starts again at x1. Both windows hold the same chain, drawn as a cyan ring just outside the personal combo ring that drains over the 2 s, with
// TEAM xN beside it. The 1 player DEMO sends and draws nothing. Nothing is drawn from the seeded stream.
var TEAM={win:2,r:520,pts:40,max:5};
var TEAM_SND=[[0,659,659,0.1,'triangle',0.05],[0.06,988,988,0.1,'triangle',0.05],[0.12,1319,1319,0.3,'triangle',0.05],[0,330,330,0.3,'sine',0.03]];
function teamKill(x,y){
  var now=Date.now(), mk, T, n, p, paid=0, lk=0;
  if(typeof ARCADE!=='object'||!ARCADE.on||ARCADE.solo||!G||!G.arcade||G.sim||G.over||!G.player) return 0;
  p=G.player; if(!isFinite(x)||!isFinite(y)){ x=p.x; y=p.y; }
  mk=ARCADE.mk;
  if(mk&&!mk.used&&now-mk.at<TEAM.win*1000&&Math.hypot(x-mk.x,y-mk.y)<=TEAM.r){
    T=ARCADE.team; n=(T&&now-T.at<TEAM.win*1000)?Math.min(TEAM.max,T.n+1):1;
    ARCADE.team={n:n,at:now}; mk.used=1; lk=1;
    paid=styMedal('TEAM COMBO x'+n,TEAM.pts*n,x,y);
    try{ say('TEAM COMBO','ext',{sub:'x'+n}); }catch(_s){}
    try{ styTone(TEAM_SND); }catch(_t){}
  }
  netSamePost({t:'arckill',pair:NET.pair,x:Math.round(x),y:Math.round(y),lk:lk,tn:lk?ARCADE.team.n:0});
  return paid;
}
// the partner's kill word: remembered as the kill the next kill here may pair with (used when it was itself the second of a pair)
function arcadeTeamTake(m){
  var now=Date.now();
  if(!ARCADE.on||ARCADE.solo) return 'ignored';
  if(!isFinite(+m.x)||!isFinite(+m.y)) return 'bad';
  ARCADE.mk={x:+m.x,y:+m.y,at:now,used:m.lk?1:0};
  if(m.lk&&(m.tn|0)>0) ARCADE.team={n:Math.min(TEAM.max,m.tn|0),at:now};
  return 'arckill';
}
// the TEAM ring at the cursor (rx, ry), outside the personal combo ring
function teamDraw(c,p,rx,ry){
  var T, f, z, xs, r, col='95,245,228';
  if(!G||G.sim||!G.arcade||typeof ARCADE!=='object'||!ARCADE.on||ARCADE.solo||!isFinite(rx)||!isFinite(ry)) return;
  T=ARCADE.team; if(!T||!(T.n>=1)) return;
  f=1-(Date.now()-T.at)/(TEAM.win*1000); if(!(f>0)) return;
  z=Math.max(1,hudRes()); xs=xhSize();
  r=(8+7+4+10)*z*xs+bloomPx(p)*z*xs+8*z;
  c.save(); c.lineCap='round'; c.lineWidth=2.6*z;
  c.strokeStyle='rgba('+col+',.2)'; c.beginPath(); c.arc(rx,ry,r,0,6.2832); c.stroke();
  c.strokeStyle='rgba('+col+',.95)'; c.beginPath(); c.arc(rx,ry,r,-1.5708,-1.5708+6.2832*Math.min(1,f)); c.stroke();
  c.font=hudFS(TYPE.micro); c.textAlign='right'; c.fillStyle='rgba('+col+',1)';
  hudText('TEAM x'+T.n,Math.round(rx-r-7*z),Math.round(ry+4*z));
  c.restore();
}
// PARTY-MODULE-END (the next party builds add their code above this line)
'@

SubRx @'
var VER='26.94';
'@ @'
var VER='26.95';
'@

$pat = "(?m)^  now:'v26\.94:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.95: In the 2 player demo, kills by both players close together build a shared TEAM combo. Check 26.95 fails on v26.94',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
