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

# HARNESS REPAIR, SECOND HALF: EMPTYING THE RAID SUMMONED PILLAGERS.
#
# r1334b removed every entity so no crier could speak. The control run on v13.32 then
# showed "Another wave of pillagers has entered." inside the window. The wave spawner
# counts live pillagers, and with fewer than four alive (raiderFloorN) one arrives
# every eight seconds (raiderFloorGap) regardless of the budget, each with a plain say()
# that writes over the line on screen. Emptying the raid made it urgent.
#
# The check now also puts the raid wave clock far in the past, so the spawner waits out
# its gap for the length of the check. G.waveT belongs to the raid being measured and
# dies with it; nothing in CFG is touched. Anchored on r1334b's own comment, because
# G2.ents.length=0 appears in several other checks.
SubRx @'
       // one seed kept the line busy past the stepping window.
       G2.ents.length=0;
'@ @'
       // one seed kept the line busy past the stepping window.
       G2.ents.length=0;
       // r1334c: and no wave either. With nobody alive the spawner sends a man every
       // eight seconds with a line of its own; its clock is held back for the check.
       G2.waveT=-1e9;
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
