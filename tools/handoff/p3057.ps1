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

# THE AUTO RIFLE KICKS THE SCREEN A LITTLE MORE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var GUN_SHAKE={shotgun:6.5,smg:1.9,pistol:3.6};
'@ @'
var GUN_SHAKE={shotgun:6.5,smg:1.9,pistol:3.6,rifle:2.7};   // v28.xx (cw-kickrifle): the Auto Rifle 2.2 to 2.7, one round 0.44 px to 0.66 px of camera kick and a held 25 round magazine (132 ms a round, trauma drains 0.185 a round, 2.7 adds 0.193) climbs slowly to under 3 px, so a burst has weight and a held mag never goes wild
'@

SubRx @'
var VER='30.56';
'@ @'
var VER='30.57';
'@

$pat = "(?m)^  now:'v30\.56:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.57: The Auto Rifle now gives the screen a small kick as you fire. Check 30.57 fails on v30.56',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
