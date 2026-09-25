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

SubRx @'
  // v10.07, his answers 33 and 35: crouch and sprint are toggles, and they
  // exclude each other.
  if((code==='ControlLeft'||code==='ControlRight'||code==='KeyC')&&G&&!G.over&&!G.sim&&!repeat){
    G.crouchTog=!G.crouchTog;
  }
'@ @'
  // v10.07, his answers 33 and 35: crouch and sprint are toggles, and they
  // exclude each other.
  // v15.65, stealth audit finding: CTRL WITH THE MOUSE WHEEL SIZES THE HUD WITHOUT TOGGLING CROUCH. Ctrl is crouch (v9.92) and
  // Ctrl with the wheel sizes the HUD (v9.95), and since crouch became a toggle (v10.07) the Ctrl press that starts the HUD
  // gesture flipped the stance here and letting go never flipped it back. Sizing the HUD standing left him crouched at .52
  // speed with no word; sizing it crouched to hide stood him up and gave the hide away. The stance before a keyboard Ctrl press
  // is kept in G.ctrlUndo, and the canvas wheel listener gives it back when the press turns into Ctrl with the wheel. C and the
  // controller right stick click (ev is null) are never a modifier and keep nothing; letting go of Ctrl or losing the keys
  // forgets it. A plain Ctrl press still crouches at once, one change per press. No number, dial or seeded draw moved.
  if((code==='ControlLeft'||code==='ControlRight'||code==='KeyC')&&G&&!G.over&&!G.sim&&!repeat){
    G.ctrlUndo=(ev&&code!=='KeyC')?G.crouchTog:null;
    G.crouchTog=!G.crouchTog;
  }
'@
SubRx @'
  // v9.95, HIS NOTE: ctrl and the wheel size the HUD, as - and = do. One notch
  // is one step, whatever the device reports for a notch.
  if(e.ctrlKey){ if(e.deltaY!==0) hudSizeStep(e.deltaY<0?1:-1); return; }
'@ @'
  // v9.95, HIS NOTE: ctrl and the wheel size the HUD, as - and = do. One notch
  // is one step, whatever the device reports for a notch.
  // v15.65, stealth audit finding: CTRL WITH THE MOUSE WHEEL SIZES THE HUD WITHOUT TOGGLING CROUCH. The Ctrl press that began
  // this gesture flipped the crouch in raidKey, so the first notch gives back the stance he had before that press, once, and
  // forgets it; later notches only size. Only while a keyboard Ctrl is really held: a trackpad pinch sends ctrlKey with no
  // Ctrl key down and leaves the stance alone. The HUD step itself is unchanged.
  if(e.ctrlKey){
    if(G.ctrlUndo!=null&&(keys['ControlLeft']||keys['ControlRight'])) G.crouchTog=G.ctrlUndo;
    G.ctrlUndo=null;
    if(e.deltaY!==0) hudSizeStep(e.deltaY<0?1:-1); return; }
'@
SubRx @'
window.addEventListener('keyup',function(e){ keys[e.code]=false; });
'@ @'
// v15.65, stealth audit finding: CTRL WITH THE MOUSE WHEEL SIZES THE HUD WITHOUT TOGGLING CROUCH. A Ctrl let go with no wheel
// was a plain crouch press, so the stance kept for the wheel is forgotten here, and a later Ctrl with the wheel cannot give
// back the stance from an older press.
window.addEventListener('keyup',function(e){ keys[e.code]=false; if((e.code==='ControlLeft'||e.code==='ControlRight')&&G) G.ctrlUndo=null; });
'@
SubRx @'
  // The reticle also hides for an open bag, and alt-tabbing with the bag open
  // left that panel latched too. Cleared with the keys, for the same reason.
  if(G){ G.bagOpen=false; G.drag=null; }
'@ @'
  // The reticle also hides for an open bag, and alt-tabbing with the bag open
  // left that panel latched too. Cleared with the keys, for the same reason.
  if(G){ G.bagOpen=false; G.drag=null; }
  // v15.65, stealth audit finding: CTRL WITH THE MOUSE WHEEL SIZES THE HUD WITHOUT TOGGLING CROUCH. A Ctrl held when the
  // window loses focus never sends its keyup here, so the stance kept for Ctrl with the wheel is forgotten with the keys.
  if(G) G.ctrlUndo=null;
'@
SubRx @'
var VER='15.64';
'@ @'
var VER='15.65';
'@

$pat = "(?m)^  now:'v15\.64:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.65: CTRL WITH THE MOUSE WHEEL SIZES THE HUD WITHOUT TOGGLING CROUCH. Holding Ctrl and rolling the wheel to size the HUD also flipped the crouch on the Ctrl press, and letting go did not flip it back, so he was left crouched without asking, or stood up out of a hide. The first wheel notch with Ctrl held now gives back the stance he had before that press, and a plain Ctrl press still crouches. Check 15.65 sizes the HUD with Ctrl and the wheel standing and crouched, with a plain Ctrl press and a trackpad pinch as controls; it fails on v15.64',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
