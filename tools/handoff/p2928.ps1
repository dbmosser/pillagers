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

# SETTINGS FIRST TAB IS GAME, NOT DISPLAY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var T=[['display','DISPLAY'],['rec','SEND PLAY DATA']];
'@ @'
var T=[['display','GAME'],['rec','SEND PLAY DATA']];   // v28.xx (cw-settab), c-30 menu map: the first Settings tab was called DISPLAY but holds every section (the raid, audio, controls, controller, display, accessibility), so Display sat inside Display. It is the game tab now; the Display section keeps its name.
'@

SubRx @'
var VER='29.27';
'@ @'
var VER='29.28';
'@

$pat = "(?m)^  now:'v29\.27:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.28: The first tab in Settings now reads Game. The Display section inside it keeps its name. Check 29.28 fails on v29.27',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
