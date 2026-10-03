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

# THE OFFER LINE AND THE BOSS BAR REACH THE SCREEN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
}function drawHUD(){
  try{ drawBossBar(); }catch(_bb){}   // v17.45: his pick 21
  try{ drawGiftLine(); }catch(_gl){}   // v17.52: an open trade offer stays on screen
  var p=G.player,T=G.tel,i;
'@ @'
}function drawHUD(){
  var p=G.player,T=G.tel,i;
'@

SubRx @'
  ctx.fillStyle=vg; ctx.fillRect(0,0,W,H);
  if(p.hp<32&&!p.downed){
'@ @'
  ctx.fillStyle=vg; ctx.fillRect(0,0,W,H);
  // v18.21, FOUND BY THE TRADE AUDIT (2026-10-03): THE BOSS BAR AND THE OFFER LINE WERE DRAWN AND THEN WIPED. Both were painted at
  // the top of this function, before the clearRect that starts every HUD frame, so THE OVERSEER's health bar (v17.45) and the
  // "NAME offers you ITEM, T or Y to take it, Ns" line (v17.52) never reached the screen; only the three second toast did,
  // which is why a player who looked away never knew an offer was waiting. Drawn here, after the clear and the vignette.
  try{ drawBossBar(); }catch(_bb){}   // v17.45: his pick 21
  try{ drawGiftLine(); }catch(_gl){}   // v17.52: an open trade offer stays on screen
  if(p.hp<32&&!p.downed){
'@

SubRx @'
var VER='18.20';
'@ @'
var VER='18.21';
'@

$pat = "(?m)^  now:'v18\.20:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.21: A trade offer now stays on screen with its countdown until it is taken, and THE OVERSEER shows its health bar. Check 18.21 fails on v18.20',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
