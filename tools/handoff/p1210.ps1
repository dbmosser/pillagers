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

# FIRST TEN MINUTES AUDIT, 2026-09-06: the controls card behind H still
# teaches "X swaps primary/sidearm" (and Y on a pad). There is no KeyX
# handler anywhere in the build and no pad swap button: the key was deleted
# when the belt took over, and this one surface was missed. The swap today
# is the belt: pressing the key of the stowed gun brings it up.
SubRx @'
  ['WEAPONS',function(){ return (PAD&&PAD.on)?'Y swaps primary/sidearm.':'X swaps primary/sidearm.'; }],
'@ @'
  // v12.10: there is no X (or pad Y) swap; the belt is the swap. Pressing the
  // key of the stowed gun brings it up (setHot, the v8.67 rule).
  ['WEAPONS','Belt keys 1 and 2 bring up either gun.'],
'@

# STAMPS.
SubRx @'
var VER='12.09';
'@ @'
var VER='12.10';
'@
SubRx @'
var WHATSNEW_VER='12.09';
'@ @'
var WHATSNEW_VER='12.10';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE CONTROLS CARD NO LONGER PROMISES AN X KEY THAT DOES NOT EXIST: belt keys 1 and 2 bring up either gun.',
'@
$cnt=([regex]::Matches($s,"now:'v12\.09:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.09 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.09:[^']*'",{ param($m) "now:'v12.10: from the 2026-09-06 first-ten-minutes audit, the controls card behind H still taught X swaps primary and sidearm (Y on a pad) and no such handler exists; the belt keys are the swap. The card says so now. Check 12.10 reads the WEAPONS rule and requires no X or Y swap claim and the belt keys named; fails on v12.09.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
