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

# THE GAME NO LONGER FREEZES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  do{
    hit=false;
    for(i=0;i<WLTEXT.boxes.length;i++){
      q=WLTEXT.boxes[i];
      if(b.x<q.x+q.w+gap&&b.x+b.w>q.x-gap&&b.y<q.y+q.h+gap&&b.y+b.h>q.y-gap){b.y=q.y-gap-b.h;hit=true;break;}
    }
  }while(hit&&b.y>=gap);
'@ @'
  // v28.xx (cw-tagloop), HIS WORDS (2026-10-28): "whoa i think my game crashed". THE NAME TAG STACK ALWAYS ENDS. A tag pushed up to sit on the one below it
  // could land a rounding hair over it (y - gap - h, plus h again, came out above y - gap), so it still counted as touching, was put back on the same spot
  // and the loop never ended: the page froze (his two freezes of 10-28 night, and the robots' hangs; a paused robot page showed wlTagPlace on top of the stack). Every move now
  // goes up at least one pixel, and the stack gives up after twice the tags plus 8 passes: that tag is skipped for the frame and one crash note says so.
  var _np=0, _ny, _cap=WLTEXT.boxes.length*2+8;
  do{
    hit=false;
    if(++_np>_cap){ if(!WLCAP.told){ WLCAP.told=1; try{ noteCrash('hang','name tag stack capped','wlTagPlace'); }catch(_wn){} } return null; }
    for(i=0;i<WLTEXT.boxes.length;i++){
      q=WLTEXT.boxes[i];
      if(b.x<q.x+q.w+gap&&b.x+b.w>q.x-gap&&b.y<q.y+q.h+gap&&b.y+b.h>q.y-gap){_ny=q.y-gap-b.h;b.y=(_ny<b.y)?_ny:b.y-1;hit=true;break;}
    }
  }while(hit&&b.y>=gap);
'@

SubRx @'
var WLTEXT={g:null,boxes:[]};
'@ @'
var WLTEXT={g:null,boxes:[]}, WLCAP={told:0};   // v28.xx (cw-tagloop): the cap tells the crash catcher once a sitting
'@

SubRx @'
DRS.frameStart=performance.now(); // v28.xx (cw-cx-ladderwindow): own work starts before frame setup and simulation.
'@ @'
DRS.frameStart=performance.now(); // v28.xx (cw-cx-ladderwindow): own work starts before frame setup and simulation.
  try{ hbTick(); }catch(_hbt){}   // v28.xx (cw-tagloop): the raid heartbeat, once a second
'@

SubRx @'
function crashWhere(stack){
'@ @'
// v28.xx (cw-tagloop), HIS WORDS (2026-10-28): "whoa i think my game crashed", and no report reached us. A frozen page cannot write anything, so a live raid
// leaves a small heartbeat in localStorage once a second (its own key, never the profile), and a clean leave (the page closed or reloaded, the raid over)
// wipes it. A heartbeat still there on the next load means the last raid stopped answering or was killed: one crash entry says so, with the build and the
// raid second, so the next freeze reaches his run report. The test pages never write one (unless a check asks).
var HBEAT_KEY='salvagerun:hb'+(NETP2?':p2':'')+(NETSLOT?(':'+NETSLOT):''), HBEAT={at:0,on:false};
function hbTest(){ return typeof __runPrep==='function'&&!window.__hbTest; }
function hbTick(){
  var now, live;
  if(hbTest()) return;
  live=(typeof state!=='undefined'&&state==='raid'&&G&&!G.over&&!G.sim);
  if(!live){ if(HBEAT.on) hbClear(); return; }
  now=Date.now(); if(HBEAT.on&&now-HBEAT.at<1000) return;
  HBEAT.at=now; HBEAT.on=true;
  try{ localStorage.setItem(HBEAT_KEY,JSON.stringify({v:VER,t:now,rs:Math.round(+G.t||0)})); }catch(_h1){}
}
function hbClear(){ HBEAT.on=false; try{ localStorage.removeItem(HBEAT_KEY); }catch(_h2){} }
function hbCheck(){
  var s=null, h=null;
  if(hbTest()) return null;
  try{ s=localStorage.getItem(HBEAT_KEY); localStorage.removeItem(HBEAT_KEY); }catch(_h3){ return null; }
  if(!s) return null;
  try{ h=JSON.parse(s); }catch(_h4){ return null; }
  if(!h||!(h.t>0)||Date.now()-h.t>86400000) return null;
  noteCrash('hang','the raid stopped answering (build '+h.v+', raid '+h.rs+' s)','heartbeat');
  return h;
}
try{ window.addEventListener('pagehide',hbClear); }catch(_h5){}
try{ hbCheck(); }catch(_h6){}
function crashWhere(stack){
'@

SubRx @'
var VER='36.25';
'@ @'
var VER='36.26';
'@

$pat = "(?m)^  now:'v36\.25:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.26: the game no longer freezes in busy fights Check 36.26 fails on v36.25',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
