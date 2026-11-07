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

# SLEEPING MACHINES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function listenersHearInner(x,y,s,fromPlayer){
'@ @'
// v28.xx (cw-cx-sleepmachines): his g-25, "Yes, a few more sleepers". Machines in the open, never containers; no seeded draw.
function machineSleepCandidate(e,spawns){
  if(!e||(e.kind!=='sentry'&&e.kind!=='bulwark')||e.elite||e.camp||e.wave||e.waveN) return false;
  for(var i=0;i<spawns.length;i++) if(dist(e,spawns[i])<900) return false;
  return true;
}
function machineAsleep(e){ return !!(e&&(e.kind==='sentry'||e.kind==='bulwark')&&e.state==='dormant'); }
function machineWake(e,state,x,y){
  if(!e||!e.sleep||e.hp<=0) return false;
  e.sleep=0; e.state=state; e.tx=x; e.ty=y; e.heardX=x; e.heardY=y;
  e.alert=2.4; e.wakeT=0.6; e.windup=null; e.muzzle=0; e.moving=false;
  if(!G.sim) sfx('charge',e.x,e.y);
  return true;
}
function machineSleepDraw(e,draw){
  if(!machineAsleep(e)){ draw(e); return; }
  wc.save(); wc.filter='brightness(58%)';
  try{ draw(e); }finally{ wc.restore(); }
}
function listenersHearInner(x,y,s,fromPlayer){
'@

SubRx @'
if(e.kind!=='listener'&&e.kind!=='howler') continue;
'@ @'
if(e.kind!=='listener'&&e.kind!=='howler'&&!(e.sleep&&e.state==='dormant')) continue;
'@

SubRx @'
    var reach=LISTEN_R*(hasTerm('silence')?1.5:1);
'@ @'
    var reach=LISTEN_R*(e.sleep?0.6:1)*(hasTerm('silence')?1.5:1);
'@

SubRx @'
e.heardX=x; e.heardY=y;
    // The Howler
'@ @'
if(e.sleep&&e.state==='dormant'){ machineWake(e,'investigate',x,y); continue; }
e.heardX=x; e.heardY=y;
    // The Howler
'@

SubRx @'
  if(CFG.decks!==1){ map.plats=[]; map.ramps=[]; }   // v13.41: emptied before the ground bake below, which draws nothing from them
'@ @'
  // v28.xx (cw-cx-sleepmachines): mark only the final positions, after camps; the placement stream and counts stay intact.
  for(var _sl=0;_sl<ents.length;_sl++){
    var _sm=ents[_sl];
    if(machineSleepCandidate(_sm,map.spawns||[])&&((Math.imul(Math.round(_sm.x),73856093)^Math.imul(Math.round(_sm.y),19349663)^seed)>>>0)%5===0){
      _sm.sleep=1; _sm.sleepHp=_sm.hp; _sm.state='dormant';
    }
  }
  if(CFG.decks!==1){ map.plats=[]; map.ramps=[]; }   // v13.41: emptied before the ground bake below, which draws nothing from them
'@

SubRx @'
    e.moving=false;
    if(e.hitT>0) e.hitT-=dt;
'@ @'
    e.moving=false;
    // v28.xx (cw-cx-sleepmachines): damage or either nearby live player wakes once. Other alerts cannot quietly turn a sleeper on.
    if(e.sleep&&e.hp>0){
      if(e.hitT>0||e.hp<(e.sleepHp===undefined?e.maxhp:e.sleepHp)||(!p.downed&&!p.specOut&&dist(e,p)<70)) machineWake(e,'chase',p.x,p.y);
      else e.state='dormant';
    }
    if(e.hitT>0) e.hitT-=dt;
'@

SubRx @'
if(e.state==='possum'){
'@ @'
// v28.xx (cw-cx-sleepmachines): no turning, scanning, windup, movement or firing while asleep or during the wake beat.
    if(e.hp>0&&(machineAsleep(e)||((e.kind==='sentry'||e.kind==='bulwark')&&e.wakeT>0))){
      if(e.wakeT>0) e.wakeT=Math.max(0,e.wakeT-dt);
      e.windup=null; e.muzzle=0; e.moving=false;
      collide(e,G.map.walls); continue;
    }
if(e.state==='possum'){
'@

SubRx @'
    if(sc.state==='possum') continue;
'@ @'
    if(sc.state==='possum'||machineAsleep(sc)) continue;
'@

SubRx @'
    if(ne.state==='possum') continue;
'@ @'
    if(ne.state==='possum'||machineAsleep(ne)) continue;
'@

SubRx @'
function mbEye(e,T){
'@ @'
function mbEye(e,T){
  // v28.xx (cw-cx-sleepmachines): unpowered eye and shield lamp, in both windows.
  if(machineAsleep(e)) return ['#14171a',0,0];
'@

SubRx @'
  if(!e||e.hp<=0) return {c:'#000000',a:1,h:0};
'@ @'
  if(machineAsleep(e)) return {c:'#14171a',a:0,h:0};
  if(!e||e.hp<=0) return {c:'#000000',a:1,h:0};
'@

SubRx @'
wc.fillStyle=(EY.h>0)?EY.c:'#8a949c'; wc.fillRect(x-fl*(3.5+lean*0.6)*S-0.7*S,yb-54*S,1.4*S,1.4*S);
'@ @'
wc.fillStyle=machineAsleep(e)?'#14171a':((EY.h>0)?EY.c:'#8a949c'); wc.fillRect(x-fl*(3.5+lean*0.6)*S-0.7*S,yb-54*S,1.4*S,1.4*S);
'@

SubRx @'
  wc.fillStyle='rgba(255,255,255,.85)'; wc.fillRect(lx-1.3*S,ly-1.4*S,0.9*S,0.9*S);
'@ @'
  if(!machineAsleep(e)){ wc.fillStyle='rgba(255,255,255,.85)'; wc.fillRect(lx-1.3*S,ly-1.4*S,0.9*S,0.9*S); }
'@

SubRx @'
else if(e2.kind==='sentry') drawSentryS(e2);
'@ @'
else if(e2.kind==='sentry') machineSleepDraw(e2,drawSentryS);
'@

SubRx @'
else if(e2.kind==='bulwark') drawBulwarkS(e2);
'@ @'
else if(e2.kind==='bulwark') machineSleepDraw(e2,drawBulwarkS);
'@

SubRx @'
function pixMachEye(e){
'@ @'
function pixMachEye(e){
  if(machineAsleep(e)) return -1;
'@

SubRx @'
if(!q||q.k!==p.k||q.m!==p.m||q.size!==p.size||q.day!==p.day||
'@ @'
if(!q||machineAsleep(q.q)!==machineAsleep(p.q)||q.k!==p.k||q.m!==p.m||q.size!==p.size||q.day!==p.day||
'@

SubRx @'
function pixMachLive(e,p,dy){
'@ @'
function pixMachLive(e,p,dy){
  if(machineAsleep(e)) return;
'@

SubRx @'
var VER='37.52';
'@ @'
var VER='37.53';
'@

$pat = "(?m)^  now:'v37\.52:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.53: Sleeping machines stay still and dark until noise, a hit or a close step wakes them, with a 0.6 second charge beat before firing. Check 37.53 fails on v37.52',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
