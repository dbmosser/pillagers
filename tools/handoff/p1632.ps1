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

# PLAYER 2 SEARCH BAR COUNTS ITEMS (his note: player 2 looting shows no item names).

SubRx @'
  if(m.ca) ct.cache=1; if(m.sg) ct.strong=1; if(m.cp) ct.camp=1; if(m.dr) ct.dropped=1;
'@ @'
  if(m.ca) ct.cache=1; if(m.sg) ct.strong=1; if(m.cp) ct.camp=1; if(m.dr) ct.dropped=1;
  if(typeof m.n==='number'&&m.n>=0) ct.netLeft=m.n|0;   // v16.32, his note: player 2 search bar shows how many items are left, as player 1 does
'@

SubRx @'
  if(m.ok){ s.ok=1; if(ct&&typeof m.prog==='number'&&isFinite(m.prog)) ct.prog=clamp(m.prog,0,ct.time||1); return 'srch:ok'; }
'@ @'
  if(m.ok){ s.ok=1; if(ct&&typeof m.prog==='number'&&isFinite(m.prog)) ct.prog=clamp(m.prog,0,ct.time||1); if(ct&&typeof m.n==='number'&&m.n>=0) ct.netLeft=m.n|0; return 'srch:ok'; }
'@

SubRx @'
    where=openContainer(at,items);
'@ @'
    where=openContainer(at,items);
    if(ct&&typeof ct.netLeft==='number') ct.netLeft=Math.max(0,ct.netLeft-items.length);   // v16.32: the count on the bar falls as each item comes out
'@

SubRx @'
      var _left=_sc.loot?_sc.loot.length:0;
'@ @'
      var _left=(_sc.net&&typeof _sc.netLeft==='number')?_sc.netLeft:(_sc.loot?_sc.loot.length:0);   // v16.32: a box on a linked window holds no list, only the count the host sends
'@

SubRx @'
var VER='16.31';
'@ @'
var VER='16.32';
'@

$pat = "(?m)^  now:'v16\.31:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.32: PLAYER 2 SEARCH BAR COUNTS ITEMS. His note: player 2 looting shows no item names. The live two window test shows the Took lines do reach player 2; what player 2 lacked was the count over the search bar (2 items left), because its copy of a box holds no list. The host now sends the count with each box and each granted search, and it falls as each item comes out. Check 16.32 fails on v16.31',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
