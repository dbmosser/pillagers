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

# v9.81: THE WALL FINGERPRINT FOLLOWS v11.18 BY ONE SEGMENT A MAP. Partitions
# that reached into a doorway are cut back; a cut in the middle splits one
# segment into two and a cut at an end that leaves under 3 units drops it, and
# the sum came to one fewer on each map. Entities 374 and 85 on the line below
# are the half that says the seeded stream did not move, and this time the
# furniture did not either.
SubRx @'
     if(mile.walls!==2206||cold.walls!==552)
       bad.push('control: the maps hold '+mile.walls+' and '+cold.walls+
                ' walls rather than 2206 and 552, so the split geometry moved');
'@ @'
     // v11.18: 2206 and 552 became 2205 and 551. Partitions reaching into a
     // doorway are cut back at the end of the build; net one segment a map.
     if(mile.walls!==2205||cold.walls!==551)
       bad.push('control: the maps hold '+mile.walls+' and '+cold.walls+
                ' walls rather than 2205 and 551, so the split geometry moved');
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
