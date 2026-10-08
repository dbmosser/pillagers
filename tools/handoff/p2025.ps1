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

# THE CRAFT RESOURCES ARE READABLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .cres{ display:flex; align-items:center; gap:8px; margin-bottom:7px; }
  .cres img{ width:22px; height:22px; flex:none; }
  .crn{ font-size:13px; color:#2a2721; flex:1; min-width:0; }
  .crv{ font-size:13.5px; font-weight:700; letter-spacing:.02em; }
'@ @'
  /* v20.25, seen on the 4K CRAFT screenshot (2026-10-08): the REQUIRED RESOURCES rows were 13px with 22px pictures, the smallest
     thing on the recipe card, and they are what you read to know whether you can craft. 16 and 17 now, with 30px pictures. */
  .cres{ display:flex; align-items:center; gap:10px; margin-bottom:9px; }
  .cres img{ width:30px; height:30px; flex:none; }
  .crn{ font-size:16px; color:#2a2721; flex:1; min-width:0; }
  .crv{ font-size:17px; font-weight:700; letter-spacing:.02em; }
'@

SubRx @'
return '<div class="cres">'+iconImgHTML(k,22)+
'@ @'
return '<div class="cres">'+iconImgHTML(k,30)+
'@

SubRx @'
var VER='20.24';
'@ @'
var VER='20.25';
'@

$pat = "(?m)^  now:'v20\.24:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.25: The resources a recipe needs are easier to read. Check 20.25 fails on v20.24',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
