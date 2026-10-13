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

# SCOPES START AT 2X (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  rifle:{optic:1.25,id:'rifle'
'@ @'
  rifle:{optic:2,id:'rifle'
'@

SubRx @'
  dmr:{optic:1.9,id:'dmr'
'@ @'
  dmr:{optic:3,id:'dmr'
'@

SubRx @'
  sniper:{optic:2.4,id:'sniper'
'@ @'
  sniper:{optic:4,id:'sniper'
'@

SubRx @'
  lmg:{optic:1.15,id:'lmg'
'@ @'
  lmg:{id:'lmg'
'@

SubRx @'
  whisper:{optic:1.1,id:'whisper'
'@ @'
  whisper:{id:'whisper'
'@

SubRx @'
  lance:{optic:1.6,id:'lance'
'@ @'
  lance:{optic:2.5,id:'lance'
'@

SubRx @'
function adsZf(){
'@ @'
// v25.xx (scopes2x), HIS ORDERS 2026-10-13: "no need for 1.25x scopes -- change to 2x minimum and adjust magnification-when-ADS accordingly",
// and "guns without a scope should still do a minor zoom (maybe 1.25x) when they are ADS'd". The smallest scope is 2x now (the Auto Rifle 2,
// the Meridian Lance 2.5, the Marksman Rifle 3, the Longshot 4; the Support MG and the Whisper, which had 1.15 and 1.1, carry none), and
// the camera while aiming a gun zooms ADS_ZMIN+(scope-1)*0.35: an unscoped gun 1.25, a 2x about 1.60, 2.5x 1.78, 3x 1.95, 4x 2.30, so
// each scope level is a clearly bigger punch-in. Fists and melee do not zoom. The base camera zoom (his answer 23) is untouched, the
// controller's steadying after a trigger pull still does not zoom, and the sight lane (VF, CH, AMBR) reads the same scope number.
var ADS_ZMIN=1.25;
function adsZf(){
'@

SubRx @'
tgt=(m>1&&!G.sim&&!G.over&&!(typeof PAD!=='undefined'&&PAD&&PAD.adsing&&!PAD.adsAim))?Math.max(1,1+(m-1)*k):1,
'@ @'
gun=!!(p.ads&&!p.downed&&!(p.roll>0)&&p.wep&&p.wep.mag>0), tgt=(gun&&!G.sim&&!G.over&&!(typeof PAD!=='undefined'&&PAD&&PAD.adsing&&!PAD.adsAim))?Math.max(1,ADS_ZMIN+(m-1)*k):1,
'@

SubRx @'
('  '+opticMag().toFixed(2).replace(/0$/,'')+'x SCOPE')
'@ @'
('  '+(+opticMag().toFixed(2))+'x SCOPE')
'@

SubRx @'
var k=clamp((mg-1)/1.0,0,1);
'@ @'
var k=clamp((mg-1)/3,0,1);   // v25.xx (scopes2x): the vignette now climbs from the 2x to the 4x
'@

SubRx @'
var VER='25.69';
'@ @'
var VER='25.70';
'@

$pat = "(?m)^  now:'v25\.69:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.70: Scopes now start at 2x, and aiming any gun without a scope gives a small 1.25x zoom. Check 25.70 fails on v25.69',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
