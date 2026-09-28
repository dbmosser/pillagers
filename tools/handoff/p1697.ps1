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

# PLAYER 2 SEARCH BAR COUNTS THE ITEMS THE HOST BOX REALLY HOLDS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  for(i=0;i<g.containers.length;i++){ ct=g.containers[i]; ct.cid=i; ct.netBy=-1; ct.netOpen=ct.opened?1:0; NET.contMap[i]=ct; }
'@ @'
  for(i=0;i<g.containers.length;i++){ ct=g.containers[i]; ct.cid=i; ct.netBy=-1; ct.netOpen=ct.opened?1:0; NET.contMap[i]=ct; }
  // v16.97, co-op hunt 2026-09-28: on a linked window the host list is the truth, so every box numbered here reads the count the
  // host sends, as a box the host adds later does. The bar read this window own copy of the list, which never falls as the host
  // hands out items and is emptied by a restock, so it showed the count rolled at the build, or none after a restock.
  if(NET.role==='join') for(i=0;i<g.containers.length;i++){ ct=g.containers[i]; ct.net=1; ct.netLeft=ct.loot?ct.loot.length:0; }
'@

SubRx @'
var VER='16.96';
'@ @'
var VER='16.97';
'@

$pat = "(?m)^  now:'v16\.96:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.97: Co-op hunt 2026-09-28, loot: the search bar reads the host count (netLeft) only on a box marked net, and only netContMake marked boxes that way, so on a linked window every map-built box that netContInit numbered fell back to its own local loot list. That list never shrinks as the host hands out items and is emptied by a restock shut word, so the bar showed the count rolled at the build and a restocked box showed none, while the ok answer and each loot word kept netLeft right unseen. netContInit on a linked window now marks each numbered box net and starts netLeft at the list it rolled, which matches the host at the build; the ok answer then gives the host count and each loot word lowers it. The host is untouched. No number moved and no new words. Check 16.97 fails on v16.96',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
