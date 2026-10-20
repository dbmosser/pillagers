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

# MONEY IN THE RAID CORNER READS $ (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(!trDemo()){ trRow(i++,'credits',TRV.c); trRow(i++,'xp',TRV.x); trRow(i++,'stash',TRV.sv); trRow(i++,'backpack',TRV.bv); }
'@ @'
  // v33.xx (cw-raiddollar), his rule (Q59: "$ for money, SP for score"): the money row is the figure alone, $900 as in the Undercroft,
  // and the stash and backpack rows are money too (item values), so they carry $. xp stays a plain number.
  if(!trDemo()){ trRow(i++,'','$'+TRV.c); trRow(i++,'xp',TRV.x); trRow(i++,'stash','$'+TRV.sv); trRow(i++,'backpack','$'+TRV.bv); }
'@

SubRx @'
<span class="trsub">STASH '+sv.toLocaleString()+' BAG '+bv.toLocaleString()+'</span>';
'@ @'
<span class="trsub">STASH $'+sv.toLocaleString()+' BAG $'+bv.toLocaleString()+'</span>';   // v33.xx (cw-raiddollar): his Q59, the stash and bag values are money
'@

SubRx @'
var VER='33.13';
'@ @'
var VER='33.14';
'@

$pat = "(?m)^  now:'v33\.13:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.14: In a raid the corner reads $900 with no credits word, and the stash and backpack values read $ there and in the Undercroft. Check 33.14 fails on v33.13',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
