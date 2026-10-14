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

# AIM, CROUCH AND SPRINT: HOLD OR TOGGLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  {k:'rumble', label:'Controller rumble',
'@ @'
  // v26.xx (settings2), HIS ORDER 2026-10-14 ("ok add all this stuff to settings"): HOLD OR TOGGLE for AIM, CROUCH and SPRINT, each its own row.
  // The defaults are today: aim down sights is held on the right mouse button, crouch is a toggle (Ctrl or C), sprint is held. AIM TOGGLE: one
  // press of the right button aims, the next stops. CROUCH HOLD: crouched only while the key is down (a controller B stays a tap). SPRINT TOGGLE:
  // one press (the key, or a pad stick click) runs until the next press, until you stop moving or until the breath runs out.
  {k:'aimMode', label:'AIM (RIGHT MOUSE)', sec:'CONTROLS',
   hint:'HOLD: AIM WHILE THE BUTTON IS DOWN. TOGGLE: PRESS ONCE TO AIM, AGAIN TO STOP.',
   opts:[
     {n:'HOLD',   cfg:{aimTgl:0}},
     {n:'TOGGLE', cfg:{aimTgl:1}}
   ], def:0},
  {k:'crouchMode', label:'CROUCH', sec:'CONTROLS',
   hint:'TOGGLE: ONE PRESS CROUCHES, THE NEXT STANDS. HOLD: CROUCHED ONLY WHILE THE KEY IS DOWN. KEYBOARD ONLY.',
   opts:[
     {n:'TOGGLE', cfg:{crouchHold:0}},
     {n:'HOLD',   cfg:{crouchHold:1}}
   ], def:0},
  {k:'sprintMode', label:'SPRINT', sec:'CONTROLS',
   hint:'HOLD: RUN WHILE THE KEY IS DOWN. TOGGLE: PRESS ONCE TO RUN, UNTIL YOU STOP OR TIRE. THE PAD STICK CLICK TOO.',
   opts:[
     {n:'HOLD',   cfg:{sprintTgl:0}},
     {n:'TOGGLE', cfg:{sprintTgl:1}}
   ], def:0},
  {k:'rumble', label:'Controller rumble',
'@

SubRx @'
if(e.button===2){ if(G&&!G.over) G.player.ads=true; return; }
'@ @'
if(e.button===2){ if(G&&!G.over) G.player.ads=(CFG.aimTgl===1)?!G.player.ads:true; return; }   // v26.xx (settings2): AIM TOGGLE flips it, HOLD sets it
'@

SubRx @'
if(e.button===2){ if(G) G.player.ads=false; }
'@ @'
if(e.button===2&&CFG.aimTgl!==1){ if(G) G.player.ads=false; }   // v26.xx (settings2): a toggled aim stays on until the next press
'@

SubRx @'
G.crouchTog=!G.crouchTog;
'@ @'
G.crouchTog=(CFG.crouchHold===1&&ev)?true:!G.crouchTog;   // v26.xx (settings2): CROUCH HOLD (a real key; the pad B is a tap and stays a toggle)
'@

SubRx @'
window.addEventListener('keyup',function(e){ keys[keyRemap(e.code)]=false;
'@ @'
window.addEventListener('keyup',function(e){ keys[keyRemap(e.code)]=false; if(CFG.crouchHold===1&&G&&!G.over&&(keyRemap(e.code)==='ControlLeft'||keyRemap(e.code)==='ControlRight'||keyRemap(e.code)==='KeyC')) G.crouchTog=false; /* v26.xx (settings2): CROUCH HOLD stands up with the key */
'@

SubRx @'
keys={}; try{ HHOLD.arm=0; }catch(_hh){} mouse.down=false; if(G) G.sprinting=false;
'@ @'
keys={}; try{ HHOLD.arm=0; }catch(_hh){} mouse.down=false; if(G) G.sprinting=false; if(G&&CFG.crouchHold===1) G.crouchTog=false; /* v26.xx (settings2): a held crouch is let go with the keys */
'@

SubRx @'
  var _shHeld=!!(keys['ShiftLeft']||keys['ShiftRight']);
'@ @'
  var _shHeld=!!(keys['ShiftLeft']||keys['ShiftRight']);
  // v26.xx (settings2), HIS ORDER 2026-10-14: SPRINT TOGGLE. With the SPRINT row on TOGGLE a fresh press of the key (or of the pad stick click, which holds
  // the same key) turns sprint on, the next press turns it off, and it also ends when you stop moving, go down or run out of breath (the lock then
  // needs a new press, as a held key needs letting go). On HOLD, the default, none of this runs and the key is read as it always was.
  if(CFG.sprintTgl===1){
    if(_shHeld&&!G.shWas&&!p.downed) G.sprintOn=!G.sprintOn;
    G.shWas=_shHeld;
    if(G.sprintOn&&(mg===0||p.downed||p.stam<=2||p.stamLock||p.stamRelease)) G.sprintOn=false;
    _shHeld=!!G.sprintOn;
  } else { G.sprintOn=false; G.shWas=_shHeld; }
'@

SubRx @'
var VER='26.39';
'@ @'
var VER='26.40';
'@

$pat = "(?m)^  now:'v26\.39:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.40: Controls has hold or toggle for aim, crouch and sprint. Check 26.40 fails on v26.39',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
