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

# THE REWARD LIST LINES UP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #opane_rew{ max-width:1080px; width:100%; margin:0 auto; }
'@ @'
  #opane_rew{ max-width:1080px; width:100%; margin:0 auto; }
  /* v20.96, from the 4K visual pass of 2026-10-08 (V-C2): THE REWARD MARKS STAND IN ONE COLUMN. Each REWARDS row ends in a box with
     the XP that reward unlocks at, and each box was only as wide as its number, so 7,200 was narrower than 16,800 and 100,800, and
     the boxes and the to go figures beside them zigzagged down the list. Every box is now wide enough for the biggest mark
     (1,200,000, nine characters with its commas), with figures of one width, so the boxes and the figures line up. */
  #seasonlist .row button{ min-width:calc(9ch + .8em + 40px); font-variant-numeric:tabular-nums; }
'@

SubRx @'
var VER='20.95';
'@ @'
var VER='20.96';
'@

$pat = "(?m)^  now:'v20\.95:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.96: On the REWARDS list the XP boxes and the to go figures now line up in straight columns. Check 20.96 fails on v20.95',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
