$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# ============ HIS NOTE: HOLD SHIFT TO SPRINT, NOT A TOGGLE.
# ============
# ============ This REVERSES half of v10.07, which made crouch and sprint both
# ============ toggles on his own answer 35 of 2026-09-03. He named SPRINT only,
# ============ so crouch stays a toggle and its key handling is untouched.
# ============
# ============ WHAT WAS THERE: a keydown flipped G.sprintTog, and the movement
# ============ code read that flag as though it were the key. Press and release
# ============ Shift and the operator kept running.
# ============
# ============ WHAT REPLACES IT: the movement code reads the KEY. The pad already
# ============ maps its left stick click onto ShiftLeft in the same keys object,
# ============ so the controller keeps working with no second path.
# ============
# ============ THE EXHAUSTION RULE SURVIVES UNCHANGED and it is the reason this
# ============ is not simply deleting a flag. v8.73 found a hold that flipped
# ============ sprint on and off 25 times in 20 seconds when stamina ran out, and
# ============ made the footsteps stutter between two tempos. The cure was
# ============ stamRelease: run yourself out and you must RELEASE and press again.
# ============ That already keys off the held state and works exactly as well for
# ============ a real hold as it did for the toggle.
# ============
# ============ NO DIAL MOVES. Sprint speed stays 1.62, the stamina cost, the
# ============ noise radius and the footstep tempo are all untouched. This changes
# ============ what turns sprinting on, and nothing else.
SubRx @'
  if((code==='ShiftLeft'||code==='ShiftRight')&&G&&!G.over&&!G.sim&&!repeat){
    G.sprintTog=!G.sprintTog; if(G.sprintTog) G.crouchTog=false;
  }
'@ @'
  // v10.87, HIS NOTE: sprint is HELD, not toggled, so there is no keydown
  // handler for it at all. updatePlayer reads the key itself. Crouch is
  // untouched and stays a toggle, which is still his answer 33.
'@
SubRx @'
    G.crouchTog=!G.crouchTog; if(G.crouchTog) G.sprintTog=false;
'@ @'
    G.crouchTog=!G.crouchTog;
'@
SubRx @'
  // v10.07, his answer 35: sprint is a toggle. Running out of breath clears
  // it, so the v8.73 sawtooth cannot happen and he presses again when he can.
  if(G.sprintTog&&(p.stamLock||p.stam<=2)) G.sprintTog=false;
  var _shHeld=!!G.sprintTog;
'@ @'
  // v10.87, HIS NOTE: hold to sprint. This read G.sprintTog, a flag a keydown
  // flipped, so a press and release left the operator running. It reads the KEY
  // now. The pad maps its left stick click onto ShiftLeft in this same keys
  // object, so the controller needs no second path.
  // The v8.73 exhaustion rule is untouched and still does its job: running
  // yourself out sets stamRelease, and the line below clears it only when the
  // key is actually let go, so a held Shift cannot saw sprint on and off.
  var _shHeld=!!(keys['ShiftLeft']||keys['ShiftRight']);
'@

SubRx @'
  'CROUCH AND SPRINT ARE TOGGLES. Press CTRL or C once to crouch and once to stand; press SHIFT once to run. Aiming down sights is held on RMB.',
'@ @'
  'HOLD SHIFT TO SPRINT. Let go and you stop running, which is his note of 2026-09-04. CROUCH IS STILL A TOGGLE: press CTRL or C once to crouch and once to stand. Aiming down sights is held on RMB.',
'@

SubRx @'
var WHATSNEW_VER='10.80';
'@ @'
var WHATSNEW_VER='10.87';
'@
SubRx @'
var VER='10.86';
'@ @'
var VER='10.87';
'@
SubRx @'
  now:'v10.86: the same hum, the way most people will actually meet it. The whole raid update sits behind a not-paused guard and the ambient bed is turned down inside it, so opening the pause box froze the bed at its last level and it hummed under the menu. Pausing happens many times a raid; dying happens once.',
'@ @'
  now:'v10.87: hold SHIFT to sprint, your note. It was a toggle since v10.07, so a press and release left you running. The movement code reads the key itself now; crouch stays a toggle, which is still what you asked for. Speed, stamina and noise are all unchanged.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
