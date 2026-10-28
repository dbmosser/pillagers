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

# WALL HITS MAKE A SMALL NOISE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function updateBullets(dt){
'@ @'
// v28.xx (cw-cx-wallnoise), his 10-28 yes: a distant player round hitting solid cover makes a small noise at the impact.
const IMPACT_NOISE=200;
function impactNoise(x,y,sx,sy){
  if(!G||!isFinite(sx)||!isFinite(sy)||Math.hypot(x-sx,y-sy)<=220) return;
  if(typeof G.impNzT==='number'&&G.t<G.impNzT) return;
  G.impNzT=G.t+0.2;
  ping(x,y,IMPACT_NOISE*CFG.noiseMult*wx().noise,false,false,'player','move',null,1);
}
function updateBullets(dt){
'@

SubRx @'
        if(_pf&&(b._pen||0)<PEN_MAX&&b.dmg*_pf.dmg>=PEN_FLOOR){
'@ @'
        if(_pf&&(b._pen||0)<PEN_MAX&&b.dmg*_pf.dmg>=PEN_FLOOR){
          // v28.xx (cw-cx-wallnoise): sound starts at the entry face, before the round steps out through cover.
          if(b.player&&!b.rkt&&matOf(_struck)!=='glass') impactNoise(b.x,b.y,b.sx,b.sy);
'@

SubRx @'
        } else {
          spark(b.x,b.y,'#ffd9a0',5,150);
'@ @'
        } else {
          // v28.xx (cw-cx-wallnoise): a stopped or bouncing player round uses the same impact noise budget.
          if(b.player&&!b.rkt&&matOf(_struck)!=='glass') impactNoise(b.x,b.y,b.sx,b.sy);
          spark(b.x,b.y,'#ffd9a0',5,150);
'@

SubRx @'
var VER='35.89';
'@ @'
var VER='35.90';
'@

$pat = "(?m)^  now:'v35\.89:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.90: far wall hits make a small noise that machines investigate. Check 35.90 fails on v35.89',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
