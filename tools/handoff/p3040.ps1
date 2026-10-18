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

# THE COMPACT SMG NO LONGER BUILDS INTO A HEAVY SHAKE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var GUN_SHAKE={shotgun:6.5};
'@ @'
var GUN_SHAKE={shotgun:6.5,smg:1.9};   // v28.xx (cw-kicksmg): the Compact SMG 2.2 to 1.9, so a held magazine no longer climbs into a heavy shake (88 ms between rounds: 2.2 adds 0.157 trauma a round and 0.123 drains; measured worst shake of a full held magazine 4.65 px at 2.2, 1.41 px at 1.9)
'@

SubRx @'
var VER='30.39';
'@ @'
var VER='30.40';
'@

$pat = "(?m)^  now:'v30\.39:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.40: The Compact SMG now shakes the screen lightly and evenly while you hold the trigger. Check 30.40 fails on v30.39',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
