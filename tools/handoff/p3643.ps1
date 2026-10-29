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

# EXTRACTION INBOUND 20 SECONDS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var DEF={coneDeg:130,viewFar:620,ambient:190,raidSec:540,pSpeed:158,extractWait:30,
'@ @'
var DEF={coneDeg:130,viewFar:620,ambient:190,raidSec:540,pSpeed:158,extractWait:20, // v28.xx (cw-cx-extractwait20): his 10-28 order, "change inbound pre-extraction time from 30 secs to 20 secs".
'@

SubRx @'
function applyCfg(base,over){ CFG=cloneObj(base); if(over){ for(var k in over) if(k in DEF) CFG[k]=over[k]; } }
'@ @'
// v28.xx (cw-cx-extractwait20): migrate only the old default on load; preserve preset C and every other saved dial value. No storage key or profile format changes.
function extractWaitLoad(v){ return v===30?20:v; }
function applyCfg(base,over){ CFG=cloneObj(base); if(over){ for(var k in over) if(k in DEF) CFG[k]=(k==='extractWait'?extractWaitLoad(over[k]):over[k]); } }
'@

SubRx @'
    if(m.cfg&&typeof m.cfg==='object') for(k in m.cfg) if(Object.prototype.hasOwnProperty.call(DEF,k)&&(typeof m.cfg[k]==='number'||typeof m.cfg[k]==='string'||typeof m.cfg[k]==='boolean')) CFG[k]=m.cfg[k];
'@ @'
    if(m.cfg&&typeof m.cfg==='object') for(k in m.cfg) if(Object.prototype.hasOwnProperty.call(DEF,k)&&(typeof m.cfg[k]==='number'||typeof m.cfg[k]==='string'||typeof m.cfg[k]==='boolean')) CFG[k]=(k==='extractWait'?extractWaitLoad(m.cfg[k]):m.cfg[k]); // v28.xx (cw-cx-extractwait20): old party settings load the same 20 s default.
'@

SubRx @'
function siegeIvOf(GR){ return SIEGE_IV-SIEGE_IV_HAUL*clamp(GR,0,1); }
'@ @'
// v28.xx (cw-cx-extractwait20): the arrival rate was tuned to a 30 s inbound wait. Compress shorter live waits proportionally, keeping the same arrivals by landing and the same cap. The headless sim keeps its arrival rate.
function siegeIvOf(GR){ return (SIEGE_IV-SIEGE_IV_HAUL*clamp(GR,0,1))*((typeof G!=='undefined'&&G&&!G.sim)?Math.min(1,CFG.extractWait/30):1); }
'@

SubRx @'
  // open, not one global beacon: pull once to call, wait 30s inbound, then pull
'@ @'
  // v28.xx (cw-cx-extractwait20): open, not one global beacon: pull once to call, wait the inbound dial (20 s by default), then pull
'@

SubRx @'
// waits the extractWait dial, 30 by default, so a DEMO ship arrived in half the time.
'@ @'
// v28.xx (cw-cx-extractwait20): waits the extractWait dial (now 20 by default); the former 15 s DEMO overlay arrived sooner.
'@

SubRx @'
extraction takes 30 seconds to arrive and stays 30
'@ @'
extraction takes 20 seconds to arrive and stays 30
'@

SubRx @'
var VER='36.42';
'@ @'
var VER='36.43';
'@

$pat = "(?m)^  now:'v36\.42:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.43: The ship lands 20 s after the call in career and demo. Old saved 30 s defaults load as 20 s. Watch the shorter wait and siege arrivals. Check 36.43 fails on v36.42',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
