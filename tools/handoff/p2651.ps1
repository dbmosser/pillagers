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

# STICK SENSITIVITY, DEADZONE, INVERT AND VIBRATION (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  {k:'raiders', label:'Other pillagers',
'@ @'
  // v26.xx (settings10), HIS ORDER 2026-10-14 ("ok add all this stuff to settings, including rebinding keys and controller"): THE STICK ROWS, in
  // CONTROLLER, after Controller rumble. STICK SENSITIVITY is how far a stick has to travel to reach full (a higher one reaches full sooner, for the
  // walking stick and the aim stick alike); STICK DEADZONE is the dead travel round the middle; INVERT AIM STICK flips up and down on the aim stick
  // only (the item wheel and the map cursor keep their natural direction); VIBRATION STRENGTH scales what the rumble sends, and the row is only drawn where the
  // browser can vibrate a pad at all. The defaults are what the pad always did: 100%, 0.22, off, standard.
  {k:'padSens', label:'STICK SENSITIVITY', sec:'CONTROLLER',
   hint:'HOW FAR A STICK MOVES TO REACH FULL TILT: WALKING AND AIMING. HIGHER IS QUICKER.',
   opts:[
     {n:'LOW',       cfg:{padSens:0.75}},
     {n:'STANDARD',  cfg:{padSens:1}},
     {n:'HIGH',      cfg:{padSens:1.25}},
     {n:'VERY HIGH', cfg:{padSens:1.5}}
   ], def:1},
  {k:'padDz', label:'STICK DEADZONE', sec:'CONTROLLER',
   hint:'HOW FAR A STICK MOVES BEFORE THE GAME SEES IT. RAISE IT IF A WORN STICK DRIFTS.',
   opts:[
     {n:'SMALL',    cfg:{padDz:0.12}},
     {n:'STANDARD', cfg:{padDz:0.22}},
     {n:'LARGE',    cfg:{padDz:0.32}},
     {n:'HUGE',     cfg:{padDz:0.4}}
   ], def:1},
  {k:'padInvY', label:'INVERT AIM STICK', sec:'CONTROLLER',
   hint:'THE AIM STICK UP BECOMES DOWN. THE ITEM WHEEL AND THE MAP KEEP THEIR OWN WAY.',
   opts:[
     {n:'OFF', cfg:{padInvY:0}},
     {n:'ON',  cfg:{padInvY:1}}
   ], def:0},
  {k:'rumbleK', label:'VIBRATION STRENGTH', sec:'CONTROLLER',
   show:function(){ return typeof Gamepad!=='undefined'&&!!Gamepad&&!!Gamepad.prototype&&('vibrationActuator' in Gamepad.prototype); },
   hint:'HOW HARD THE PAD BUZZES WHEN CONTROLLER RUMBLE IS ON.',
   opts:[
     {n:'LIGHT',    cfg:{rumbleK:0.5}},
     {n:'STANDARD', cfg:{rumbleK:1}},
     {n:'STRONG',   cfg:{rumbleK:1.5}}
   ], def:1},
  {k:'raiders', label:'Other pillagers',
'@

SubRx @'
function padAxis(v){
'@ @'
// v26.xx (settings10): THE STICK ROWS. padDz is the dead travel (0.22 as it always was), padSens how far a stick must go to reach full (1 as it always was; padAxis
// clamps at 1), padInv flips up and down on the aim stick where it is placed, rumbleK is the factor on what padRumble sends.
function padDz(){ var d=+CFG.padDz; return (d>=0.02&&d<=0.6)?d:0.22; }
function padSens(){ var s=+CFG.padSens; return (s>=0.3&&s<=3)?s:1; }
function padInv(v){ return CFG.padInvY===1?-v:v; }
function rumbleK(){ var k=+CFG.rumbleK; return (k>=0&&k<=3)?k:1; }
function padAxis(v){
'@

SubRx @'
  var dz=0.22;
'@ @'
  var dz=padDz();   // v26.xx (settings10): STICK DEADZONE
'@

SubRx @'
  return Math.sign(v)*((a-dz)/(1-dz));
'@ @'
  return Math.sign(v)*Math.min(1,((a-dz)/(1-dz))*padSens());   // v26.xx (settings10): STICK SENSITIVITY
'@

SubRx @'
PAD.aimA=Math.atan2(ry,rx);   // v16.77, his order: the angle the idle frames keep the crosshair on
'@ @'
PAD.aimA=Math.atan2(padInv(ry),rx);   // v16.77, his order: the angle the idle frames keep the crosshair on; v26.xx (settings10): INVERT AIM STICK
'@

SubRx @'
padCursorPut(psx,psy,rx*_rr2*pz,ry*_rr2*pz);
'@ @'
padCursorPut(psx,psy,rx*_rr2*pz,padInv(ry)*_rr2*pz);
'@

SubRx @'
if(CFG.rumble===0||!(s>0)||!(ms>0)) return 'off';
'@ @'
if(CFG.rumble===0||!(s>0)||!(ms>0)) return 'off';
  s=s*rumbleK();   // v26.xx (settings10): VIBRATION STRENGTH
'@

SubRx @'
var VER='26.50';
'@ @'
var VER='26.51';
'@

$pat = "(?m)^  now:'v26\.50:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.51: Controller has stick sensitivity, deadzone, invert aim and vibration strength. Check 26.51 fails on v26.50',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
