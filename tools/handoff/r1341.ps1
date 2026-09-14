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

# HARNESS REPAIR for v13.41: check 9.81 counts every wall on both maps as a control on
# the split geometry. v13.41 takes the deck edge walls out of a finished raid, 14 on THE
# COLD MILE and 6 on COLD STORAGE (check 13.41 counted them), so 2205 and 551 became
# 2191 and 545. Nothing else about the geometry moved.
SubRx @'
     if(mile.walls!==2205||cold.walls!==551)
       bad.push('control: the maps hold '+mile.walls+' and '+cold.walls+
                ' walls rather than 2205 and 551, so the split geometry moved');
'@ @'
     // v13.41: 2205 and 551 became 2191 and 545. The raised decks are gone, and with
     // them 14 and 6 deck edge walls.
     if(mile.walls!==2191||cold.walls!==545)
       bad.push('control: the maps hold '+mile.walls+' and '+cold.walls+
                ' walls rather than 2191 and 545, so the split geometry moved');
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
