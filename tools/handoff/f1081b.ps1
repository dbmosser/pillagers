$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# ---- ONE PIN MOVES, the wall count, and only because walls were removed.
# ---- Measured, dial off against dial on, both maps at seed 4242:
# ----   COLD STORAGE  623 -> 610 walls, 2 buildings torn open, 13 runs gone
# ----   THE COLD MILE 2440 -> 2403 walls, 7 torn open, 37 runs gone
# ---- Entities and containers do not move at all: 85 and 374, 165 and 593,
# ---- identical either way, which is the whole point of running the pass after
# ---- everything that rolls.
SubRx @'
     if(mile.walls!==2440||cold.walls!==623)
       bad.push('control: the maps hold '+mile.walls+' and '+cold.walls+
                ' walls rather than 2440 and 623, so the split geometry moved');
'@ @'
     // v10.81: seven buildings on the mile and two on COLD STORAGE lose runs of
     // outer wall to the ruin pass. Entities and containers are unmoved.
     if(mile.walls!==2403||cold.walls!==610)
       bad.push('control: the maps hold '+mile.walls+' and '+cold.walls+
                ' walls rather than 2403 and 610, so the split geometry moved');
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
