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

# PAD SPRINT TOGGLE DEFAULT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  {k:'sprintMode', label:'SPRINT', sec:'CONTROLS',
   hint:'Hold: run while the key is down. Toggle: press once to run, until you stop or tire. The pad stick click too.',
   opts:[
     {n:'HOLD',   cfg:{sprintTgl:0}},
     {n:'TOGGLE', cfg:{sprintTgl:1}}
   ], def:0},
'@ @'
  // v28.xx (cw-cx-padsprintdefault): his 10-25 g-68, "Pad defaults to toggle"; saved choices 0 and 1 keep their meaning.
  {k:'sprintMode', label:'SPRINT', sec:'CONTROLS',
   hint:'hold: run while held. toggle: click once to run. hold, pad toggle: keys hold, the stick click toggles.',
   opts:[
     {n:'HOLD',   cfg:{sprintTgl:0}},
     {n:'TOGGLE', cfg:{sprintTgl:1}},
     {n:'hold, pad toggle', cfg:{sprintTgl:2}}
   ], def:2},
'@

SubRx @'
  // v26.xx (settings2), HIS ORDER 2026-10-14: SPRINT TOGGLE. With the SPRINT row on TOGGLE a fresh press of the key (or of the pad stick click, which holds
  // the same key) turns sprint on, the next press turns it off, and it also ends when you stop moving, go down or run out of breath (the lock then
  // needs a new press, as a held key needs letting go). On HOLD, the default, none of this runs and the key is read as it always was.
  if(CFG.sprintTgl===1){
    if(_shHeld&&!G.shWas&&!p.downed) G.sprintOn=!G.sprintOn;
    G.shWas=_shHeld;
    if(G.sprintOn&&(mg===0||p.downed||p.ads||p.stam<=2||p.stamLock||p.stamRelease)) G.sprintOn=false;
    _shHeld=!!G.sprintOn;
  } else { G.sprintOn=false; G.shWas=_shHeld; }
'@ @'
  // v28.xx (cw-cx-padsprintdefault): g-68, keys hold and the local pad stick click toggles by default; no hub input change.
  var _padSh=!!(PAD.on&&PAD.held&&PAD.held.ShiftLeft);
  if(CFG.sprintTgl===2){
    if(_padSh&&!G.shWasPad&&!p.downed) G.sprintOn=!G.sprintOn;
    G.shWasPad=_padSh;
    G.shWas=_shHeld;
    if(G.sprintOn&&(mg===0||p.downed||p.ads||p.stam<=2||p.stamLock||p.stamRelease||p.shotSprintRelease)) G.sprintOn=false;
    _shHeld=(_shHeld&&!_padSh)||!!G.sprintOn;
  } else {
    G.shWasPad=_padSh;
    if(CFG.sprintTgl===1){
      if(_shHeld&&!G.shWas&&!p.downed) G.sprintOn=!G.sprintOn;
      G.shWas=_shHeld;
      if(G.sprintOn&&(mg===0||p.downed||p.ads||p.stam<=2||p.stamLock||p.stamRelease)) G.sprintOn=false;
      _shHeld=!!G.sprintOn;
    } else { G.sprintOn=false; G.shWas=_shHeld; }
  }
'@

SubRx @'
var VER='36.65';
'@ @'
var VER='36.66';
'@

$pat = "(?m)^  now:'v36\.65:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.66: One sprint row gains hold, pad toggle as the default. Saved hold and toggle choices keep their indexes. LOCAL: no linked review. Check 36.66 fails on v36.65',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
