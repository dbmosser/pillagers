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

# WEAK SPOT SHOWS ITS MULTIPLIER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function applyWeak(e,W){
'@ @'
// v27.xx (weakx), HIS ORDER (2026-10-14): "when we hit weak spot show the multiplier, e.g. 'weak spot 2.4x'". The label on a weak point hit reads WEAK SPOT and the multiplier
// the hit pays, one decimal and a lower case x (WEAK SPOT 3.4x on a Sentry vent, 2.0x on its optic), in the weak point colour, still once per target every half second. The
// Overseer core, exposed while it vents, pays 1.5 on every round and says WEAK SPOT 1.5x the same way (and the two multiply when a seam is hit while it vents). Only the words
// move; the multipliers, the effects and the damage are untouched. Pillagers have no weak spots.
function weakTxt(m){ return 'WEAK SPOT '+(Math.round((+m||1)*10)/10).toFixed(1)+'x'; }
function applyWeak(e,W){
'@

SubRx @'
label(en.x,en.y-Math.round(en.r*1.3),'WEAK SPOT',WK.c,0,true);
'@ @'
label(en.x,en.y-Math.round(en.r*1.3),weakTxt(WK.mult*((en.boss&&en.overheat>0)?1.5:1)),WK.c,0,true);
'@

SubRx @'
if(en.boss&&en.overheat>0) edmg*=1.5;
'@ @'
if(en.boss&&en.overheat>0){ edmg*=1.5; if(!WK&&!G.sim&&!(en.weakLblT>(G.t||0)-0.5)){ en.weakLblT=(G.t||0); label(en.x,en.y-Math.round(en.r*1.3),weakTxt(1.5),'#ffc04a',0,true); } }   // v27.xx (weakx): and the exposed core says its multiplier too
'@

SubRx @'
var VER='28.21';
'@ @'
var VER='28.22';
'@

$pat = "(?m)^  now:'v28\.21:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.22: A weak point hit now shows its multiplier, such as WEAK SPOT 3.4x. Check 28.22 fails on v28.21',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
