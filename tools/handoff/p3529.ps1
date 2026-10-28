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

# GUNS FIRST ON THE EXTRACTED CARD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
keys.sort(function(a,b){ return ival(b)-ival(a); });
'@ @'
keys.sort(function(a,b){ return (((ITEMS[b]&&ITEMS[b].use==='gun')?1:0)-((ITEMS[a]&&ITEMS[a].use==='gun')?1:0))||(ival(b)-ival(a)); });   // v35.xx (cw-gunsfirst), HIS ORDER (2026-10-27): "on the extracted screen, always show guns first, that's the best thing to extract, regardless of color/rarity". Guns lead the strip, the dearest gun first, so a gun is never cut by the eight tile cap; everything after them keeps the value order. The reveal still runs right to left, so the guns land last.
'@

SubRx @'
var VER='35.28';
'@ @'
var VER='35.29';
'@

$pat = "(?m)^  now:'v35\.28:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.29: guns lead the haul on the extracted card Check 35.29 fails on v35.28',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
