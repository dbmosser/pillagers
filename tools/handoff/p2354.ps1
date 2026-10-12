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

# 1 PLAYER ARCADE DEMO (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      <button class="deploy ghost moderow" id="modearcade" data-mode="arcade">2 PLAYER ARCADE DEMO</button>
'@ @'
      <button class="deploy ghost moderow" id="modearcade" data-mode="arcade">2 PLAYER ARCADE DEMO</button>
      <button class="deploy ghost moderow" id="modearcade1" data-mode="arcade1">1 PLAYER ARCADE DEMO</button>
'@

SubRx @'
  var co=g('modecoop'), pv=g('modepvp'), ar=g('modearcade'), rt=g('moderetry'), st=g('titlestart'), pl=g('p2line'), hide=['modecoop','modecoopsrv','modepvp','modepvpsrv','modearcade'], i, el, r;
'@ @'
  // v23.54 (arcade30): and the 1 PLAYER ARCADE DEMO row (arcadeSoloPick), hidden in the player 2 window too.
  var co=g('modecoop'), pv=g('modepvp'), ar=g('modearcade'), ar1=g('modearcade1'), rt=g('moderetry'), st=g('titlestart'), pl=g('p2line'), hide=['modecoop','modecoopsrv','modepvp','modepvpsrv','modearcade','modearcade1'], i, el, r;
'@

SubRx @'
  if(ar) ar.onclick=function(){ arcadePick(); };
'@ @'
  if(ar) ar.onclick=function(){ arcadePick(); };
  if(ar1) ar1.onclick=function(){ arcadeSoloPick(); };   // v23.54 (arcade30)
'@

SubRx @'
      if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on&&ARCADE.role==='host') netSamePost({t:'arcon',pair:NET.pair});   // v23.24 (arcade5): so a rebooted player 2 window always rejoins the arcade
'@ @'
      if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on&&ARCADE.role==='host'&&!ARCADE.solo) netSamePost({t:'arcon',pair:NET.pair});   // v23.24 (arcade5): so a rebooted player 2 window always rejoins the arcade (v23.54, arcade30: not the 1 player arcade)
'@

SubRx @'
  if(ARCADE.role==='host') netSamePost({t:'arcon',pair:NET.pair});
'@ @'
  if(ARCADE.role==='host'&&!ARCADE.solo) netSamePost({t:'arcon',pair:NET.pair});   // v23.54 (arcade30): the 1 player arcade tells nobody
'@

SubRx @'
  if(r==='p2'||r==='unsupported') NET.arcPick=0;
  return r;
}
'@ @'
  if(r==='p2'||r==='unsupported') NET.arcPick=0;
  return r;
}
// v23.54, HIS ORDER (2026-10-11 evening), arcade30: 1 PLAYER ARCADE DEMO. His words: "arcade mode also needs a single player option".
// The title has a 1 PLAYER ARCADE DEMO row next to the 2 player one. It enters the arcade in this one window: the same start the
// 2 player row runs and arcadeEnter as the host, with ARCADE.solo set, and no netSamePick, so no player 2 window opens, no pair
// channel is made and the net section stays off (a pair channel left from an earlier co-op pick with nobody linked is closed; a
// linked player 2 window has to be closed first). Everything else is the 2 player arcade as it is: endless, the shield, the random
// kit, extraction bonus and re-drop, waves, streaks, the arcade HUD, idle return, the attract loop, the controls card, Halloween,
// the operator lock, quick heal, the wake lock and the cull. The HUD says SCORE where it said TEAM SCORE, with no YOU and P2 split,
// and the RUN OVER card has one row. Solo runs go on their own list on the party board: every row carries its mode (m 1 or 2, an
// old row with none is a 2 player row), and TONIGHTS BEST, BEST EVER, NEW HIGH SCORE and the initials card read the list of the
// mode in play. Leaving the arcade clears ARCADE.solo, so the 2 player arcade and normal raids are exactly what they were.
function arcadeSoloPick(){
  if(ARCADE.on) return 'on';
  if((typeof NETP2!=='undefined'&&NETP2)||NET.same==='p2'||NET.role==='join'){ netModeMsg('THIS WINDOW IS PLAYER 2'); return 'p2'; }
  if(NET.on||(Array.isArray(NET.peers)&&netInCount()>0)){ netModeMsg('CLOSE THE PLAYER 2 WINDOW FIRST'); return 'linked'; }
  if(NET.bc||NET.same) netSameStop();   // a pair left from an earlier pick, with nobody linked
  NET.arcPick=0; netModeMsg('');
  WNSEEN=1;
  try{ if(typeof NET.start==='function') NET.start(); }catch(_ns){}
  ARCADE.solo=1;
  if(!arcadeEnter('host')){ ARCADE.solo=0; return 'fail'; }
  return 'solo';
}
'@

SubRx @'
  NET.arcPick=0; NET.arcBoot=0; ARCADE.wantIn=0;
'@ @'
  NET.arcPick=0; NET.arcBoot=0; ARCADE.wantIn=0;
  ARCADE.solo=0;   // v23.54 (arcade30)
'@

SubRx @'
  ctx.font=fs; ctx.fillStyle='#ffc04a'; hudText('TEAM SCORE',cx,Math.round(y-h*0.80));
'@ @'
  ctx.font=fs; ctx.fillStyle='#ffc04a'; hudText(ARCADE.solo?'SCORE':'TEAM SCORE',cx,Math.round(y-h*0.80));   // v23.54 (arcade30): SCORE in the 1 player arcade
'@

SubRx @'
  hudText('YOU '+arcadeN(mine),gx,Math.round(y-h*0.40));
  hudText((ARCADE.role==='p2'?'P1 ':'P2 ')+arcadeN(mate),gx,Math.round(y+h*0.15));
'@ @'
  if(!ARCADE.solo){   // v23.54 (arcade30): no YOU and P2 split in the 1 player arcade
    hudText('YOU '+arcadeN(mine),gx,Math.round(y-h*0.40));
    hudText((ARCADE.role==='p2'?'P1 ':'P2 ')+arcadeN(mate),gx,Math.round(y+h*0.15));
  }
'@

SubRx @'
  ctx.fillText('TEAM SCORE '+arcadeN(b.team),cx,y+LH(86));
'@ @'
  ctx.fillText((ARCADE.solo?'SCORE ':'TEAM SCORE ')+arcadeN(b.team),cx,y+LH(86));   // v23.54 (arcade30)
'@

SubRx @'
    ln=oc?[['aoh','RUN OVER'],['aos','TEAM SCORE '+arcadeN(o.team)],['aor',arcadeOverRow('P1',o.p1)],['aor',arcadeOverRow('P2',o.p2)]]:[];
'@ @'
    ln=oc?(ARCADE.solo?[['aoh','RUN OVER'],['aos','SCORE '+arcadeN(o.team)],['aor',arcadeOverRow('YOU',o.p1)]]   // v23.54 (arcade30): the 1 player arcade, one row
      :[['aoh','RUN OVER'],['aos','TEAM SCORE '+arcadeN(o.team)],['aor',arcadeOverRow('P1',o.p1)],['aor',arcadeOverRow('P2',o.p2)]]):[];
'@

SubRx @'
    out.push({run:x.run.slice(0,40),i:(typeof x.i==='string')?x.i.slice(0,3).toUpperCase():'',s:Math.max(0,Math.round(+x.s||0)),x:Math.max(0,x.x|0),k:Math.max(0,x.k|0),t:+x.t||0});
'@ @'
    out.push({run:x.run.slice(0,40),i:(typeof x.i==='string')?x.i.slice(0,3).toUpperCase():'',s:Math.max(0,Math.round(+x.s||0)),x:Math.max(0,x.x|0),k:Math.max(0,x.k|0),t:+x.t||0,m:(x.m===1)?1:2});   // v23.54 (arcade30): the mode, an old row is 2 player
'@

SubRx @'
    if(!o){ o=m[x.run]={run:x.run,i:x.i||'',s:x.s,x:x.x,k:x.k,t:x.t}; out.push(o); continue; }
'@ @'
    if(!o){ o=m[x.run]={run:x.run,i:x.i||'',s:x.s,x:x.x,k:x.k,t:x.t,m:(x.m===1)?1:2}; out.push(o); continue; }
'@

SubRx @'
function arcadeBoardSave(rows){
  var r=arcadeBoardDedupe(rows), h=Math.floor(ARCADE_BOARD.keep/2), all, out=[], seen={}, i, x;
  all=r.slice().sort(function(p,q){ return q.s-p.s; }).slice(0,h).concat(r.slice().sort(function(p,q){ return q.t-p.t; }).slice(0,h));
'@ @'
// v23.54 (arcade30): the mode of the arcade in play, 1 or 2, and whether a row is on that list (a row with no mode is 2 player)
function arcadeBoardMode(){ return ARCADE.solo?1:2; }
function arcadeBoardIn(x,md){ return ((x&&x.m===1)?1:2)===md; }
function arcadeBoardSave(rows){
  var r=arcadeBoardDedupe(rows), h=Math.floor(ARCADE_BOARD.keep/2), all=[], out=[], seen={}, i, x, md, rm;
  for(md=1;md<=2;md++){   // v23.54 (arcade30): each list keeps its own best and newest, so one mode never pushes the other off
    rm=[]; for(i=0;i<r.length;i++) if(arcadeBoardIn(r[i],md)) rm.push(r[i]);
    all=all.concat(rm.slice().sort(function(p,q){ return q.s-p.s; }).slice(0,h),rm.slice().sort(function(p,q){ return q.t-p.t; }).slice(0,h));
  }
'@

SubRx @'
function arcadeBoardTonight(now){
  now=+now||Date.now();
  var r=arcadeBoardDedupe(arcadeBoardLoad()), out=[], i;
  for(i=0;i<r.length;i++) if(r[i].t>=now-ARCADE_BOARD.night&&r[i].t<=now+60000) out.push(r[i]);
'@ @'
function arcadeBoardTonight(now,md){
  now=+now||Date.now();
  md=(md===1||md===2)?md:arcadeBoardMode();   // v23.54 (arcade30): the list of the mode in play
  var r=arcadeBoardDedupe(arcadeBoardLoad()), out=[], i;
  for(i=0;i<r.length;i++) if(arcadeBoardIn(r[i],md)&&r[i].t>=now-ARCADE_BOARD.night&&r[i].t<=now+60000) out.push(r[i]);
'@

SubRx @'
function arcadeBoardBest(){ var r=arcadeBoardLoad(), b=0, i; for(i=0;i<r.length;i++) if(r[i].s>b) b=r[i].s; return b; }
'@ @'
function arcadeBoardBest(md){ md=(md===1||md===2)?md:arcadeBoardMode(); var r=arcadeBoardLoad(), b=0, i; for(i=0;i<r.length;i++) if(arcadeBoardIn(r[i],md)&&r[i].s>b) b=r[i].s; return b; }   // v23.54 (arcade30): the best of the mode in play
'@

SubRx @'
  r.push({run:id,i:ini,s:s,x:Math.max(0,(ARCADE.ext|0)+(ARCADE.mateX|0)),k:Math.max(0,(ARCADE.kills|0)+(ARCADE.mateK|0)),t:Date.now()});
'@ @'
  r.push({run:id,i:ini,s:s,x:Math.max(0,(ARCADE.ext|0)+(ARCADE.mateX|0)),k:Math.max(0,(ARCADE.kills|0)+(ARCADE.mateK|0)),t:Date.now(),m:arcadeBoardMode()});   // v23.54 (arcade30): tagged with its mode
'@

SubRx @'
function arcadeHiSay(t){ try{ say('NEW HIGH SCORE','ext',{sub:'TEAM SCORE '+arcadeN(t)}); }catch(_hs){} }
'@ @'
function arcadeHiSay(t){ try{ say('NEW HIGH SCORE','ext',{sub:(ARCADE.solo?'SCORE ':'TEAM SCORE ')+arcadeN(t)}); }catch(_hs){} }   // v23.54 (arcade30)
'@

SubRx @'
var VER='23.53';
'@ @'
var VER='23.54';
'@

$pat = "(?m)^  now:'v23\.53:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.54: The title has a 1 PLAYER ARCADE DEMO row: the arcade party mode for one player in one window, with its own scoreboard. Check 23.54 fails on v23.53',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
