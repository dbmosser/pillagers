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

# THE WHAT IS NEW CARD CARRIES THE REST OF THE STABILITY PASS (it had fallen sixteen builds behind).

SubRx @'
var WHATSNEW_VER='16.54';
'@ @'
var WHATSNEW_VER='16.71';
'@

SubRx @'
  'STEADIER CO-OP. A search keeps running after the host has left the raid, the pause box shuts when a raid ends under it, a controller tap on the map places your marker and shuts the map, a controller can no longer hand itself to the wrong window from the PARTY window, and the buttons in Settings that would drop you out of a raid are greyed out until you are back in the Undercroft.',
'@ @'
  'STEADIER CO-OP. A teammate still reading his run card goes up with the party, a search keeps running and the enemies stay audible after the host has left the raid, a pick up is called revived only once it took, pinging twice marks danger, the pause box shuts when a raid ends under it, a controller tap on the map places your marker and shuts the map, B backs out of the map and the backpack, and the buttons in Settings that would drop you out of a raid are greyed out until you are back in the Undercroft.',
'@

SubRx @'
var VER='16.70';
'@ @'
var VER='16.71';
'@

$pat = "(?m)^  now:'v16\.70:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.71: THE WHAT IS NEW CARD CARRIES THE REST OF THE STABILITY PASS. It was written at v16.54 and had fallen sixteen builds behind. Its STEADIER CO-OP line now also says that a teammate on his run card goes up with the party, that searches and enemy sounds go on after the host leaves, that a pick up is called revived only once it took, that pinging twice marks danger and that B backs out of the map and the backpack. Check 16.71 fails on v16.70',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
