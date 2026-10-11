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

# ARCADE: SCREEN WAKE LOCK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function arcadeEnter(role){
  role=(role==='p2')?'p2':'host';
'@ @'
// v23.47, HIS YES (2026-10-11) to the five recommendations, arcade24: SCREEN WAKE LOCK. The party machine sits on the attract loop
// for hours with nobody touching it, and a monitor that goes to sleep looks like a broken game. While the arcade is on, each
// window holds a screen wake lock (navigator.wakeLock.request('screen')). The browser drops the lock whenever the tab is hidden,
// so it is asked for again when the tab comes back (visibilitychange), and it is let go at leave (arcadeLeave, which the operator
// chord and the host arcoff both reach). The API is missing or refused in some browsers and contexts, so every call is wrapped and
// a refusal changes nothing else. Only the arcade asks for it; normal play never holds a wake lock.
var ARCADE_WAKE={lock:null,want:0,pend:0,asks:0};
function arcadeWakeOn(){
  ARCADE_WAKE.want=1;
  if(ARCADE_WAKE.pend) return false;
  if(ARCADE_WAKE.lock&&!ARCADE_WAKE.lock.released) return false;
  ARCADE_WAKE.lock=null;
  var wl=null, pr=null;
  try{ wl=navigator.wakeLock; }catch(_wn){ wl=null; }
  if(!wl||typeof wl.request!=='function') return false;
  try{
    ARCADE_WAKE.pend=1; ARCADE_WAKE.asks++;
    pr=wl.request('screen');
    if(pr&&typeof pr.then==='function') pr.then(function(s){
      ARCADE_WAKE.pend=0;
      if(!s) return;
      if(!ARCADE.on||!ARCADE_WAKE.want){ try{ var q=s.release(); if(q&&q.catch) q.catch(function(){}); }catch(_wr){} return; }
      ARCADE_WAKE.lock=s;
    },function(){ ARCADE_WAKE.pend=0; });
    else ARCADE_WAKE.pend=0;
  }catch(_wq){ ARCADE_WAKE.pend=0; return false; }
  return true;
}
function arcadeWakeOff(){
  ARCADE_WAKE.want=0;
  var s=ARCADE_WAKE.lock;
  ARCADE_WAKE.lock=null;
  if(!s||s.released) return false;
  try{ var q=s.release(); if(q&&q.catch) q.catch(function(){}); }catch(_wo){}
  return true;
}
function arcadeWakeVis(){
  try{ if(!document.hidden&&ARCADE.on&&ARCADE_WAKE.want) arcadeWakeOn(); }catch(_wv){}
}
try{ document.addEventListener('visibilitychange',arcadeWakeVis); }catch(_wvl){}
function arcadeEnter(role){
  role=(role==='p2')?'p2':'host';
'@

SubRx @'
  arcadeAttStart();   // v23.40 (arcade17): the attract loop from the top
  return true;
}
'@ @'
  arcadeAttStart();   // v23.40 (arcade17): the attract loop from the top
  try{ arcadeWakeOn(); }catch(_aw){}   // v23.47 (arcade24): the screens stay awake while the arcade is on
  return true;
}
'@

SubRx @'
  var hadRaid=arcadeRaidStop('leave'), r=arcadeSandboxOut();
'@ @'
  var hadRaid=arcadeRaidStop('leave'), r=arcadeSandboxOut();
  try{ arcadeWakeOff(); }catch(_aw2){}   // v23.47 (arcade24): the screens may sleep again
'@

SubRx @'
var VER='23.46';
'@ @'
var VER='23.47';
'@

$pat = "(?m)^  now:'v23\.46:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.47: While the arcade is on the screens stay awake, and leaving the arcade lets them sleep again. Check 23.47 fails on v23.46',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
