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

# ARCADE: THE WORLD STAYS LIGHT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      if(G.arcade&&!G.over) try{ arcadeWaveTick(dt); }catch(_awt){}   // v23.37 (arcade14): action comes to you, host or solo only
'@ @'
      if(G.arcade&&!G.over) try{ arcadeWaveTick(dt); }catch(_awt){}   // v23.37 (arcade14): action comes to you, host or solo only
      if(G.arcade&&!G.over) try{ arcadeCullTick(dt); }catch(_act){}   // v23.53 (arcade29): the world stays light, the run authority only
'@

SubRx @'
function arcadeRunId(){
'@ @'
// v23.53, HIS YES (2026-10-11) to the five recommendations, arcade29 (found by the 3-hour arcade soak of 2026-10-11): THE WORLD STAYS
// LIGHT. Over 3 hours of nonstop play the bodies grew from 41 to 217 and the containers from 154 to 598: the waves land near the
// players and the old ones stay where they were left, and every kill leaves a body or a wreck. Once a second the run authority (the
// host, or the player 2 that took the raid over, the same rule as arcadeWaveTick) takes off a wave body that has been more than
// 2,200 from every player for 60 s straight while not chasing, alarmed or hunting, and an opened or empty body, wreck or dropped
// pile more than 1,500 from every player and older than 5 minutes. A body leaves player 2 by the gone word any body that leaves the
// host world sends (netEntsTick). A box leaves by an arcade-only gone word (netContWord), told again to a window that joins late
// (netContHello), and a box that arrives after a cull is numbered by its missing number (netContNumber). Nobody on the map: nothing
// goes. Only an arcade run reaches any of it.
var ARCADE_CULL={entFar:2200,entT:60,boxFar:1500,boxT:300,step:1};
function arcadeCullMen(){
  var a=[], p=G.player, i, u;
  if(p&&!p.specOut&&isFinite(p.x)&&isFinite(p.y)) a.push(p);
  if(typeof NET==='object'&&NET&&NET.on&&Array.isArray(NET.up)){
    for(i=0;i<NET.up.length;i++){ u=NET.up[i]; if(u&&u.seat!==NET.seat&&isFinite(u.x)&&isFinite(u.y)) a.push(u); }
  }
  return a;
}
function arcadeCullFar(o,men,r){ var j; for(j=0;j<men.length;j++) if(dist(o,men[j])<=r) return false; return true; }
function arcadeCullTick(dt){
  if(!G||!G.arcade||G.over||G.sim||!Array.isArray(G.ents)||!Array.isArray(G.containers)) return 0;
  if((ARCADE.role==='p2'&&!G.netWasJoin)||netEntsPeer()) return 0;
  var men, i, j, e, ct, st, now=+G.t||0, n=0, host=false;
  G.arcCullT=(+G.arcCullT||0)+((dt>0)?dt:0);
  if(G.arcCullT<ARCADE_CULL.step) return 0;
  st=G.arcCullT; G.arcCullT=0;
  men=arcadeCullMen(); if(!men.length) return 0;
  for(i=G.ents.length-1;i>=0;i--){
    e=G.ents[i];
    if(!e||!e.arcWave||e.boss||!(e.hp>0)) continue;
    if(e.state==='chase'||e.state==='alarm'||e.state==='hunt'||!arcadeCullFar(e,men,ARCADE_CULL.entFar)){ e.arcFar=0; continue; }
    e.arcFar=(+e.arcFar||0)+st;
    if(e.arcFar<ARCADE_CULL.entT) continue;
    if(Array.isArray(G.roster)) for(j=0;j<G.roster.length;j++) if(G.roster[j]&&G.roster[j].ref===e){ G.roster[j].out=true; G.roster[j].outAt=elapsed(); break; }
    G.ents.splice(i,1); n++;
  }
  host=(typeof netContHost==='function')&&netContHost();
  if(host) netContNumber();   // every box numbered before any leaves the list
  for(i=G.containers.length-1;i>=0;i--){
    ct=G.containers[i];
    if(!ct||!(ct.type==='body'||ct.type==='botwreck'||ct.dropped)) continue;
    if(typeof ct.arcAt!=='number'){ ct.arcAt=now; continue; }   // first seen now: its five minutes start here
    if(!(ct.opened||!(ct.loot&&ct.loot.length))) continue;
    if(now-ct.arcAt<ARCADE_CULL.boxT||G.searching===ct||(typeof ct.netBy==='number'&&ct.netBy>=0)) continue;
    if(!arcadeCullFar(ct,men,ARCADE_CULL.boxFar)) continue;
    G.containers.splice(i,1); n++;
    if(typeof ct.cid==='number'){
      (G.arcCull=Array.isArray(G.arcCull)?G.arcCull:[]).push(ct.cid);
      if(NET.contMap) delete NET.contMap[ct.cid];
      if(host) netBroadcast({t:'cont',st:'gone',cid:ct.cid});
    }
  }
  return n;
}
function arcadeRunId(){
'@

SubRx @'
function netContNumber(){
  var ct, n=0;
  if(!NET.contMap) NET.contMap={};
'@ @'
function netContNumber(){
  var ct, n=0, i;
  if(!NET.contMap) NET.contMap={};
  if(G.arcade&&Array.isArray(G.arcCull)&&G.arcCull.length){   // v23.53 (arcade29): the cull took boxes out of the list, so a box that arrived is the one with no number
    for(i=0;i<G.containers.length;i++){
      ct=G.containers[i]; if(!ct||typeof ct.cid==='number') continue;
      ct.cid=NET.contN; if(typeof ct.netBy!=='number') ct.netBy=-1; ct.netOpen=ct.opened?1:0; ct.netLn=ct.loot?ct.loot.length:0; ct.netPu=ct.pulled|0;
      NET.contMap[NET.contN]=ct; NET.contN++;
      netBroadcast(netContNewWord(ct)); n++;
    }
    return n;
  }
'@

SubRx @'
  for(i=0;i<NET.contN0;i++){ ct=NET.contMap[i]; if(ct&&ct.netTold&&!ct.opened) netSend(peer,netContLeftWord(ct)); }
'@ @'
  for(i=0;i<NET.contN0;i++){ ct=NET.contMap[i]; if(ct&&ct.netTold&&!ct.opened) netSend(peer,netContLeftWord(ct)); }
  if(G.arcade&&Array.isArray(G.arcCull)) for(i=0;i<G.arcCull.length;i++) if(G.arcCull[i]<NET.contN0) netSend(peer,{t:'cont',st:'gone',cid:G.arcCull[i]});   // v23.53 (arcade29): a box from the build the cull took
'@

SubRx @'
  ct=netContOf(cid); if(!ct) return 'cont:unknown';
'@ @'
  ct=netContOf(cid); if(!ct) return 'cont:unknown';
  if(st==='gone'){   // v23.53 (arcade29): the run authority took a far, old, searched box off the list in an arcade raid; it leaves here too
    if(!G.arcade) return 'bad';
    i=G.containers.indexOf(ct); if(i>=0) G.containers.splice(i,1);
    delete NET.contMap[cid];
    if(NET.srch&&NET.srch.cid===cid) NET.srch=null;
    if(G.searching===ct){ G.searching=null; G.searchT=0; }
    return 'cont:gone';
  }
'@

SubRx @'
var VER='23.52';
'@ @'
var VER='23.53';
'@

$pat = "(?m)^  now:'v23\.52:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.53: In the arcade, far idle wave enemies and old searched bodies and wrecks are cleared away, so a long party night stays smooth. Check 23.53 fails on v23.52',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
