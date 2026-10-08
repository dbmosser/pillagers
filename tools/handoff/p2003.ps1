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

# YOUR TEAMMATE SEES YOUR BUILD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var NET_LOOK=['hair','hat','skin','fit','cut','beard','eyes','face','boots','gloves','pack','patch','tattoo','outfit'];
'@ @'
var NET_LOOK=['hair','hat','skin','fit','cut','beard','eyes','face','boots','gloves','pack','patch','tattoo','outfit','build'];   // v20.03, his answer (2026-10-08): everyone sees your build
'@

SubRx @'
       gloves:lk.gloves,pack:lk.pack,patch:lk.patch,tattoo:lk.tattoo,outfit:lk.outfit,own:g});
'@ @'
       gloves:lk.gloves,pack:lk.pack,patch:lk.patch,tattoo:lk.tattoo,outfit:lk.outfit,build:lk.build,own:g});
'@

SubRx @'
       gloves:lk.gloves,pack:lk.pack,patch:lk.patch,tattoo:lk.tattoo,outfit:lk.outfit});
'@ @'
       gloves:lk.gloves,pack:lk.pack,patch:lk.patch,tattoo:lk.tattoo,outfit:lk.outfit,build:lk.build});
'@

SubRx @'
var VER='20.02';
'@ @'
var VER='20.03';
'@

$pat = "(?m)^  now:'v20\.02:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.03: In co-op your teammate sees your build, and you see theirs. Check 20.03 fails on v20.02',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
