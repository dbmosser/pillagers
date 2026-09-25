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
  // rule sprint itself has, so a held Shift while standing still changes nothing.
  if(_shHeld&&mg>0&&G.crouchTog&&!p.downed){ G.crouchTog=false; crouch=false; }
'@ @'
  // rule sprint itself has, so a held Shift while standing still changes nothing.
  // v15.64, stealth audit finding: C CROUCHES WITH SHIFT HELD WHEN NO SPRINT CAN START. This line asked only for Shift and
  // movement, so it took the crouch off every frame Shift was held, even when the sprint lines below then refused the sprint:
  // out of breath (the v8.73 release latch keeps a held Shift from sprinting until the key is let go), aiming (p.ads) or
  // wading in deep water. Fleeing with Shift and W still down he pressed C, raidKey turned the toggle on and this line turned
  // it off the next frame, so he jogged on at full height with no sprint, no crouch, full footstep noise and no word why:
  // the key looked broken exactly when he needed it to break the chase. His note is that activating sprint stops crouching;
  // where no sprint can start there is nothing to activate. The line now asks the same questions the sprint does (breath
  // above 2, no lock, no latch, not aiming, not in deep water at the same wading edge used below), so sprint still wins
  // whenever it can start. inWaterDeep only reads the map. No number, dial or seeded draw moved.
  if(_shHeld&&mg>0&&G.crouchTog&&!p.downed&&p.stam>2&&!p.stamLock&&!p.stamRelease&&!p.ads&&!inWaterDeep(p.x,p.y,(CFG.wadeInset===undefined?11:CFG.wadeInset))){ G.crouchTog=false; crouch=false; }
'@
SubRx @'
var VER='15.63';
'@ @'
var VER='15.64';
'@

$pat = "(?m)^  now:'v15\.63:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.64: C CROUCHES WITH SHIFT HELD WHEN NO SPRINT CAN START. Out of breath with Shift still held, or aiming, or wading in deep water, pressing C to break a chase did nothing: the sprint-cancels-crouch line took the crouch off the next frame although no sprint could start. That line now asks the same questions the sprint does, so C crouches there and Shift still stands him up whenever a sprint can start. Check 15.64 steps one frame crouched with Shift and W held out of breath, aiming and wading, and once with full breath as the control; it fails on v15.63',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
