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

# RAID HUD HAS ONE HERO (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
hudZoomIn('gear',W,H);                 // v8.08: grows up and left from the corner
'@ @'
hudZoomIn('gear',W,H);                 // v8.08: grows up and left from the corner
  if(typeof G.beaconT==='number'&&G.beaconT>0) ctx.globalAlpha=0.6;   // v28.xx (cw-h103hero), the critic on screen 37 ('the extraction banner still lacks hero weight'): while the ship is inbound the extract line is the one hero, so the ammo card steps down; it is back at full strength the moment the countdown ends
'@

SubRx @'
  if(G.legendOn===1){
    var MN=(padOn()
'@ @'
  if(G.legendOn===1){
    ctx.save();   // v28.xx (cw-h103hero)
    var MN=(padOn()
'@

SubRx @'
    if(!padOn()) ctx.fillText(legendKeys('F1')+'  full list',mx,my+LH(7)+MROW*_mr+LH(3));
    return;
'@ @'
    if(!padOn()) ctx.fillText(legendKeys('F1')+'  full list',mx,my+LH(7)+MROW*_mr+LH(3));
    ctx.restore();   // v28.xx (cw-h103hero)
    return;
'@

SubRx @'
hudChev(mx-8+MW-4,my+LH(4),true);
'@ @'
ctx.globalAlpha*=0.8; hudChev(mx-8+MW-4,my+LH(4),true);   // v28.xx (cw-h103hero), the critic on screens 21 and 19 ('the keys cheat sheet is big and always on'): the words of the compact list are drawn at 80 percent (the panel keeps the one shared fill), so it reads as a reference and not as a second hero
'@

SubRx @'
var VER='34.28';
'@ @'
var VER='34.29';
'@

$pat = "(?m)^  now:'v34\.28:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.29: While you wait for the extraction ship the ammo card fades back. The controls list is a bit quieter. Check 34.29 fails on v34.28',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
