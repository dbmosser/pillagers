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

# THE SUPPORT MG NO LONGER BUILDS INTO A HEAVY SHAKE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var GUN_SHAKE={shotgun:6.5,smg:1.9,pistol:3.6,rifle:2.7,magnum:5.5};
'@ @'
var GUN_SHAKE={shotgun:6.5,smg:1.9,pistol:3.6,rifle:2.7,magnum:5.5,lmg:2.0};   // v28.xx (cw-kicklmg): the Support MG 2.2 to 2.0, so a held 60 round magazine (105 ms a round, trauma drains 0.147 a round, 2.2 adds 0.157) no longer climbs into a heavy shake; 2.0 adds 0.143 and the measured shake of a held magazine stays about 0.3 px
'@

SubRx @'
var VER='30.63';
'@ @'
var VER='30.64';
'@

$pat = "(?m)^  now:'v30\.63:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.64: The Support MG no longer builds into a heavy shake. Check 30.64 fails on v30.63',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
