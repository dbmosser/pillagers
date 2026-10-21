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

# raid start map: no cache or strongbox words (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    mapLabel(CQ.opened?'LOOTED':'CACHE',qx,qy-20*_MZ,UIC.tx_1,null,qy);
'@ @'
    // v28.xx (cw-nocachelbl), HIS ORDER (2026-10-20): "map on this second preraid screen should not have caches labelled, makes the whole thing look messy". The raid start map keeps the cache ring and icon but no word; the m key map keeps its words.
    if(!mapFirstOn()) mapLabel(CQ.opened?'LOOTED':'CACHE',qx,qy-20*_MZ,UIC.tx_1,null,qy);
'@

SubRx @'
    mapLabel('STRONGBOX',sbx,sby-20*_MZ,UIC.tx_1,ctx.font,sby);
'@ @'
    // v28.xx (cw-nocachelbl): the strongbox word goes with the cache words on the raid start map; the icon and ring stay.
    if(!mapFirstOn()) mapLabel('STRONGBOX',sbx,sby-20*_MZ,UIC.tx_1,ctx.font,sby);
'@

SubRx @'
var VER='33.41';
'@ @'
var VER='33.42';
'@

$pat = "(?m)^  now:'v33\.41:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.42: The map at raid start shows cache and strongbox marks without the words. Check 33.42 fails on v33.41',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
