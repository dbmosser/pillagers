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

# FOLDED CONTROLS STAY CLEAR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    ctx.save();
    if(G.legendOn===2){
'@ @'
    ctx.save();
    // v28.xx (cw-cx-foldedhint): the critic saw a ghost panel under the bot list. The folded hint already has a screen-space anchor; only the compact list needs its old bottom shift and zoom.
    if(!G.legendOn||HOL.c){ ctx.translate(_legDX,_legDY); }
    else if(G.legendOn===2){
'@

SubRx @'
    drawLegend(G.legendOn===2?_fz:1);   // v20.74 (H40): the full list is told its zoom
'@ @'
    drawLegend(G.legendOn===2&&!HOL.c?_fz:1); // v28.xx (cw-cx-foldedhint): the full-list fit scale belongs only to the open full list.
'@

SubRx @'
  if(!G.legendOn){
    ctx.font=MONO; ctx.fillStyle='rgba(140,152,163,.55)';
'@ @'
  if(!G.legendOn){
    ctx.font=uiFont('label',Math.max(1,uiScale())); ctx.fillStyle=UIC.tx_2; // v28.xx (cw-cx-foldedhint): at least 16px now that the hint no longer borrows the compact-panel zoom.
'@

SubRx @'
var VER='34.15';
'@ @'
var VER='34.16';
'@

$pat = "(?m)^  now:'v34\.15:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.16: The folded f1 controls hint uses its screen anchor and keeps its drag offset. The open controls lists keep their existing placement and timing. Check 34.16 fails on v34.15',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
