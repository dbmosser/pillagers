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
  if(!on&&!G){
    var _fn=document.getElementById('pausenote'), _ft=_fn?_fn.value.trim():'';
'@ @'
  if(!on&&!G){
    // v14.47, floor audit finding 3: CLOSING THE PAUSE BOX ON THE FLOOR ARMS THE E LOCK. A key or pad button held while the
    // box closed (A on its button, or E held through P) read as a fresh station press on the next frame, because the box was
    // not opened by a station and the lock was off: standing at the lift, the sector page opened at once. The lock clears
    // itself once E, R, F and T are all let go.
    if(typeof HB!=='undefined'&&HB) HB.eLock=true;
    var _fn=document.getElementById('pausenote'), _ft=_fn?_fn.value.trim():'';
'@
SubRx @'
var VER='14.46';
'@ @'
var VER='14.47';
'@

$pat = "(?m)^  now:'v14\.46:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.47: A BUTTON HELD WHILE THE FLOOR PAUSE BOX CLOSES DOES NOT FIRE A STATION. A held A or E carried through the box closing read as a fresh press at the station he stood at, so the sector page could open at once. Closing the pause box on the floor now arms the E lock, which clears when the keys are let go. Check 14.47 opens and closes the pause box on the floor with the lock off; it fails on v14.46',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
