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

# FROM THE 2026-09-06 READ-ONLY IN-RAID AUDIT (P2 TEXT vs CODE, verified by
# reading at v12.19): v9.35 gave the raid clock an OFF position (raidSec 0)
# and stopped the timer, the death on the timer and the ring closures from
# reading it, but two readers were missed. With the clock off G.timeLeft
# starts at 0 and never moves, and both of these read 0 as "one second left":
# the boarding window, min(30, max(3, timeLeft - 1)), came out at 3 seconds
# instead of 30, so the ship left after three; and the Pulled line, which
# says "The raid clock runs out first." whenever timeLeft is under the
# inbound wait, said it on every call. The HUD already knows the case
# (_noClk counts up instead of down). Both readers now ask whether there is
# a clock before they read it.
SubRx @'
z.hold=Math.min(30,Math.max(3,G.timeLeft-1)); z.holdMax=z.hold;
'@ @'
z.hold=(CFG.raidSec>0)?Math.min(30,Math.max(3,G.timeLeft-1)):30; z.holdMax=z.hold;   // v12.24: with the clock OFF (v9.35) there is nothing to run out; timeLeft sits at 0 and used to read as one second left, so the ship left after three
'@
SubRx @'
          (G.timeLeft<CFG.extractWait?'. The raid clock runs out first.':', then hold E to extract.')+
'@ @'
          ((CFG.raidSec>0&&G.timeLeft<CFG.extractWait)?'. The raid clock runs out first.':', then hold E to extract.')+   // v12.24: not with the clock OFF
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'WITH THE RAID CLOCK SWITCHED OFF, THE SHIP WAITS ITS FULL THIRTY SECONDS. It used to leave after three, and the call said the clock would run out first.',
'@

# STAMPS.
SubRx @'
var VER='12.23';
'@ @'
var VER='12.24';
'@
SubRx @'
var WHATSNEW_VER='12.23';
'@ @'
var WHATSNEW_VER='12.24';
'@
$cnt=([regex]::Matches($s,"now:'v12\.23:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.23 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.23:[^']*'",{ param($m) "now:'v12.24: in-raid audit: with the raid clock switched OFF (v9.35) the clock sits at zero, and two readers took zero for one second left: the boarding window came out at 3 seconds instead of 30, and every call said the raid clock would run out first. Both ask whether there is a clock before reading it. Check 12.24 calls the ship with the clock off, requires the call line without the warning and a landed hold of 30, and with the clock on at 12 seconds left requires the hold of 11 the clock rule gives; fails on v12.23.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
