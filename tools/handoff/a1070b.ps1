$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\AUDIT.md'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
| INVENTORY = BACKPACK + HOTBAR. An item is in one or the other, never both | a model change, affects the belt assignment map |
'@ @'
| ~~INVENTORY = BACKPACK + HOTBAR. An item is in one or the other, never both~~ | DONE, and both halves re-measured at v10.70. The raid grid stopped drawing a copy claimed by a key at v8.78 and the Undercroft grid at v6.60; measured today, packing three items and putting one on key 3 takes the backpack count from 3 to 2 while the key count goes to 1. G.bag stays the single store on purpose, because moving items between two real arrays would touch every loot, drop, sell, death and extraction path in the file |
'@

SubRx @'
| INVENTORY = BACKPACK + HOTBAR. An item is in one or the other, never both | model change; affects the belt assignment map |
'@ @'
| ~~INVENTORY = BACKPACK + HOTBAR. An item is in one or the other, never both~~ | DONE, re-measured at v10.70: the raid grid since v8.78, the Undercroft grid since v6.60, counted per key so one of three medkits on a key leaves two in the backpack. The row above it in this table is the same ask and carries the numbers |
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
