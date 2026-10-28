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

# KIA CARD FITS AT 4K WITH A FULL HIT LIST (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  '#root #oc_manifest .ockia>div:first-child>div:nth-child(2){font-size:14px !important;letter-spacing:.06em}'+
'@ @'
  '#root #oc_manifest .ockia>div:first-child>div:nth-child(2){font-size:14px !important;letter-spacing:.06em}'+
  // v35.xx (cw-kiafit), menus master pass 2026-10-28, his 4K screen: with 8 hits the KIA card ran 71px past the card, so the how did that run feel button sat under log run.
  '#root #oc_manifest .ockia>div>div{line-height:1.4 !important;padding-top:1px !important;padding-bottom:1px !important}'+
  '#root #oc_manifest:has(.ockia) .ocloss{margin-bottom:12px !important}#root #oc_manifest:has(.ockia) .octiles{margin-bottom:8px !important}'+
'@

SubRx @'
var VER='35.99';
'@ @'
var VER='36.00';
'@

$pat = "(?m)^  now:'v35\.99:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.00: at 4k the kia card shows every hit and the run feel button without scrolling Check 36.00 fails on v35.99',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
