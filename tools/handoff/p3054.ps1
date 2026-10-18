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

# A HIT SENTRY BARELY MOVES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var HIT_JOLT={crawler:8,raider:6.5};
'@ @'
var HIT_JOLT={crawler:8,raider:6.5,sentry:3};   // v28.xx (cw-joltsentry), his Q5 enemy feel: the Sentry (radius 22, the heaviest common machine) 5 to 3 px at the full 0.16 s flash, so it reads as plate that holds its ground
'@

SubRx @'
var VER='30.53';
'@ @'
var VER='30.54';
'@

$pat = "(?m)^  now:'v30\.53:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.54: A Sentry you hit now barely moves. Check 30.54 fails on v30.53',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
