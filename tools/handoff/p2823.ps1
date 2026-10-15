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

# LEADERBOARD HEADS SIT OVER THEIR COLUMNS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
'.lbp .lbh{color:#9a8f78;font-size:.8em;border-bottom:1px solid rgba(154,143,120,.35);margin-bottom:.15em}'+
'@ @'
'.lbp .lbh{color:#9a8f78;border-bottom:1px solid rgba(154,143,120,.35);margin-bottom:.15em}.lbp .lbh span{font-size:.8em}'+   /* v27.NN (cboard5): the column heads are smaller on their own, so the grid columns (in em of the row) stay the width the rows have and every head sits over its figures */
'@

SubRx @'
var VER='28.22';
'@ @'
var VER='28.23';
'@

$pat = "(?m)^  now:'v28\.22:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.23: The leaderboard column heads now sit over their columns. Check 28.23 fails on v28.22',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
