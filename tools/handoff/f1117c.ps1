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

# v9.81: THE WALL FINGERPRINT FOLLOWS v11.17. Furniture in interior doorways
# and furniture wedged in a body-width gap are not placed. Measured at seed
# 4242: 2308 to 2206 on the mile, 580 to 552 on cold storage. Entities 374 and
# 85 on the line below are the half that says the seeded stream did not move.
SubRx @'
     if(mile.walls!==2308||cold.walls!==580)
       bad.push('control: the maps hold '+mile.walls+' and '+cold.walls+
                ' walls rather than 2308 and 580, so the split geometry moved');
'@ @'
     // v11.17: 2308 and 580 became 2206 and 552. Furniture in interior doorways
     // and furniture wedged in a body-width gap are not placed any more.
     if(mile.walls!==2206||cold.walls!==552)
       bad.push('control: the maps hold '+mile.walls+' and '+cold.walls+
                ' walls rather than 2206 and 552, so the split geometry moved');
'@

# v9.65: THE COVER FINGERPRINT FOLLOWS TOO, 488 to 490, the same way as before:
# the wall list spotFree asks against is shorter and two more spots are taken.
SubRx @'
     if(wrecks.length!==488)
       bad.push('the mile has '+wrecks.length+' pieces of outdoor cover rather than 488, so a footprint moved');
'@ @'
     // v11.17: 488 to 490. Fewer furniture walls, two more candidate spots
     // accepted. Entities are still 374 on the line below.
     if(wrecks.length!==490)
       bad.push('the mile has '+wrecks.length+' pieces of outdoor cover rather than 490, so a footprint moved');
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
