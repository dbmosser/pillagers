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

# AIM BREAKS A SPRINT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
if(_shHeld&&mg>0&&p.ads&&!p.downed&&p.stam>2&&!p.stamLock&&!p.stamRelease){ p.ads=false; if(typeof PAD!=='undefined'&&PAD){ PAD.adsTog=false; PAD.adsT=0; } }
'@ @'
// v28.xx (cw-adsbreaks), HIS ORDER 2026-10-20: "ADS should immediately break sprint, even if shift is still held down". The v16.81 drop of aim under a held sprint is gone: aim wins, the sprint is cut by the p.ads test below, and it comes back by itself when aim lets go with Shift still down.
'@

SubRx @'
if(G.sprintOn&&(mg===0||p.downed||p.stam<=2
'@ @'
if(G.sprintOn&&(mg===0||p.downed||p.ads||p.stam<=2
'@

SubRx @'
if((PAD.adsT>0||PAD.adsAim)&&!(pressed(10)&&G.player&&G.player.moving)){
'@ @'
if(PAD.adsT>0||PAD.adsAim){
'@

SubRx @'
var VER='33.29';
'@ @'
var VER='33.30';
'@

$pat = "(?m)^  now:'v33\.29:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.30: Aiming stops a sprint at once and holds with Shift down; let go of aim and the sprint comes back. Check 33.30 fails on v33.29',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
