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

# PIXEL HUB BAKE BUDGET (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawHubWorld(dt){
'@ @'
function drawHubWorld(dt){
  pixFrame(); // v28.xx (cw-cx-pixhubframe): the Undercroft has its own frame path, so its crowd and FASHION must get a fresh two-build budget too
'@

SubRx @'
  x2.imageSmoothingEnabled=!pixOn();
'@ @'
  x2.imageSmoothingEnabled=true; // v28.xx (cw-cx-pixhubframe): keep the existing soft ground shadow; pxBlit independently disables smoothing for each 4x body layer
'@

SubRx @'
var VER='33.74';
'@ @'
var VER='33.75';
'@

$pat = "(?m)^  now:'v33\.74:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.75: The Undercroft starts each frame with the existing two-build budget, shared with the FASHION turntable. The preview keeps the original soft ground shadow under its nearest 4x body. Check 33.75 fails on v33.74',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
