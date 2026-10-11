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

# THE STASH BELT KEYS ARE SQUARE AGAIN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #hub #hotplanwrap [data-plan]{ flex:1 1 0 !important; min-width:0 !important; max-width:76px; height:auto !important; aspect-ratio:1/1; }
'@ @'
  #hub #hotplanwrap [data-plan]{ flex:1 1 0 !important; min-width:0 !important; max-width:76px; height:auto !important; aspect-ratio:1/1; overflow:hidden; min-height:0 !important; }
  /* v23.14: the four gun keys of v22.45 put a gun picture on keys 1 to 4 of this row, and its box set the height, so at a narrow width every key grew taller than wide (35 by 42). Hidden overflow lets the square win again (v18.98). */
'@

SubRx @'
var VER='23.13';
'@ @'
var VER='23.14';
'@

$pat = "(?m)^  now:'v23\.13:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.14: The tactical belt keys on the stash screen are square again. Check 23.14 fails on v23.13',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
