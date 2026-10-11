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

# ARCADE: ACTION COMES TO YOU (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function arcadeTeam(){ return Math.max(0,ARCADE.mine|0)+Math.max(0,ARCADE.mate|0); }
'@ @'
function arcadeTeam(){ return Math.max(0,ARCADE.mine|0)+Math.max(0,ARCADE.mate|0); }
// v23.37, HIS ORDER (2026-10-11), build 14 of 20 (arcade14): ACTION COMES TO YOU. A walk-up player should never wander a quiet map
// looking for a fight. arcadeWaveTick runs on the host or solo (never in a linked player 2 window, never in the sim) and only in an
// arcade raid. The tier is the team score over 4,000 (0 to 8). Every max(10, 22 - 2 tier) seconds, while the live hostiles within
// 1,400 of the playing players number fewer than min(24, 6 + 2 tier), a pack of min(6, 2 + tier/2) drops 770 to 1,060 from one
// playing player (and at least 700 from every one), on open, reachable floor outside any shut room, picked with Math.random. The pack
// comes for him like the siege arrivals do: alert 3, investigate, aimed within 60 of where he stands, flagged arcWave. Crawlers
// always, sentries from tier 1, hostile pillagers from tier 2, and from tier 4 the first body of each pack is an elite. WAVE n is
// called in the warn lane. The bodies reach player 2 like any body that arrives after the build. A normal raid never runs any of it.
var ARCADE_WAVE={near:1400,minR:770,maxR:1060,tries:40};
function arcadeWaveMen(){
  var a=[], p=G.player, i, u;
  if(p&&!p.specOut&&!p.dying&&isFinite(p.x)&&isFinite(p.y)) a.push(p);
  if(typeof NET==='object'&&NET&&NET.on&&Array.isArray(NET.up)){
    for(i=0;i<NET.up.length;i++){ u=NET.up[i]; if(u&&u.seat!==NET.seat&&!u.dn&&isFinite(u.x)&&isFinite(u.y)) a.push(u); }
  }
  return a;
}
function arcadeWaveLive(men){
  var n=0, i, j, e;
  for(i=0;i<G.ents.length;i++){
    e=G.ents[i];
    if(!e||!(e.hp>0)||e.neutral||e.kind==='peddler'||e.kind==='stray') continue;
    if(e.kind==='raider'&&!e.hostile) continue;
    for(j=0;j<men.length;j++) if(dist(e,men[j])<ARCADE_WAVE.near){ n++; break; }
  }
  return n;
}
function arcadeWaveOk(men,q,x,y,lo,hi){
  var j, d;
  if(!(x>30&&y>30&&x<WORLD_W-30&&y<WORLD_H-30)) return false;
  if(!spotFree(G.map,x,y,22)||!navReachable(G.map,x,y)||shutRoomAt(G.map,x,y)) return false;
  d=dist({x:x,y:y},q); if(d<lo||d>hi) return false;
  for(j=0;j<men.length;j++) if(dist({x:x,y:y},men[j])<700) return false;
  return true;
}
function arcadeWaveSpot(men,q){
  var k, a, r, x, y;
  for(k=0;k<ARCADE_WAVE.tries;k++){
    a=Math.random()*Math.PI*2; r=ARCADE_WAVE.minR+Math.random()*(ARCADE_WAVE.maxR-ARCADE_WAVE.minR);
    x=q.x+Math.cos(a)*r; y=q.y+Math.sin(a)*r;
    if(arcadeWaveOk(men,q,x,y,ARCADE_WAVE.minR-1,ARCADE_WAVE.maxR+1)) return {x:x,y:y};
  }
  return null;
}
function arcadeWaveBody(men,q,c){
  var k, x, y;
  for(k=0;k<6;k++){
    x=c.x+Math.random()*72-36; y=c.y+Math.random()*72-36;
    if(arcadeWaveOk(men,q,x,y,700,1200)) return {x:x,y:y};
  }
  return {x:c.x,y:c.y};
}
function arcadeWaveRaider(x,y){
  var idn=null, i, j, c, t, R, w=ARCADE.waveN|0;
  for(i=0;i<IDENTITIES.length;i++){
    c=IDENTITIES[(i+w*3)%IDENTITIES.length]; t=false;
    for(j=0;j<(G.roster||[]).length;j++) if(G.roster[j].name===c.tag){ t=true; break; }
    if(!t){ idn=c; break; }
  }
  if(!idn){ c=IDENTITIES[w%IDENTITIES.length]; idn={id:c.id+'_a'+w, tag:c.tag+'_'+(w+2), coat:c.coat}; }
  R=mkRaider(x,y,idn,false);
  R.hostile=true;
  if(Array.isArray(G.roster)) G.roster.push({ref:R,name:R.name,crew:R.crew,val:0,out:false});
  return R;
}
function arcadeWaveElite(e){
  if(!e||e.elite) return e;
  var hm=(CFG.eliteHp===undefined?2.2:CFG.eliteHp);
  e.elite=1; e.hp=Math.round(e.hp*hm); e.maxhp=Math.round(e.maxhp*hm); e.r=Math.round(e.r*1.12);
  return e;
}
function arcadeWaveTick(dt){
  if(!G||!G.arcade||G.over||G.sim||!G.map||!Array.isArray(G.ents)) return 0;
  if(ARCADE.role==='p2'||netEntsPeer()) return 0;
  var tier=Math.max(0,Math.min(8,Math.floor(arcadeTeam()/4000))), iv=Math.max(10,22-2*tier), cap=Math.min(24,6+2*tier),
      pack=Math.min(6,2+Math.floor(tier/2)), men, live, q, c, n, i, e, s, kd, kinds, made=0;
  ARCADE.waveT=(+ARCADE.waveT||0)+((dt>0)?dt:0);
  if(ARCADE.waveT<iv) return 0;
  men=arcadeWaveMen(); if(!men.length) return 0;
  live=arcadeWaveLive(men);
  if(live>=cap){ ARCADE.waveT=iv-1; return 0; }   // full: look again in a second
  q=men[Math.floor(Math.random()*men.length)];
  c=arcadeWaveSpot(men,q);
  if(!c){ ARCADE.waveT=iv-0.5; return 0; }   // no floor this time: try again shortly
  n=Math.min(pack,cap-live);
  kinds=['crawler','crawler']; if(tier>=1) kinds.push('sentry'); if(tier>=2) kinds.push('raider');
  for(i=0;i<n;i++){
    s=arcadeWaveBody(men,q,c); kd=kinds[Math.floor(Math.random()*kinds.length)];
    e=(kd==='sentry')?mkSentry(s.x,s.y):(kd==='raider')?arcadeWaveRaider(s.x,s.y):mkCrawler(s.x,s.y);
    if(!e) continue;
    if(tier>=4&&i===0) arcadeWaveElite(e);
    e.arcWave=1; e.alert=3; e.state='investigate';
    e.tx=q.x+(Math.random()*120-60); e.ty=q.y+(Math.random()*120-60);
    G.ents.push(e); made++;
  }
  ARCADE.waveT=0;
  if(made){ ARCADE.waveN=(ARCADE.waveN|0)+1; say('WAVE '+ARCADE.waveN,'warn'); }
  return made;
}
'@

SubRx @'
  ARCADE.deaths=0; ARCADE.holdT=0;   // v23.22 (arcade3)
'@ @'
  ARCADE.deaths=0; ARCADE.holdT=0;   // v23.22 (arcade3)
  ARCADE.waveT=0; ARCADE.waveN=0;   // v23.37 (arcade14): the wave clock and count start again
'@

SubRx @'
      if(!G.over){ updateEnts(dt); }
'@ @'
      if(!G.over){ updateEnts(dt); }
      if(G.arcade&&!G.over) try{ arcadeWaveTick(dt); }catch(_awt){}   // v23.37 (arcade14): action comes to you, host or solo only
'@

SubRx @'
var VER='23.36';
'@ @'
var VER='23.37';
'@

$pat = "(?m)^  now:'v23\.36:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.37: In the arcade a pack of hunters drops in near the players every 10 to 22 seconds, bigger and tougher as the team score climbs, with WAVE n called out. Check 23.37 fails on v23.36',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
