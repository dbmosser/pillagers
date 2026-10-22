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

# RARITY READS WITHOUT COLOUR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawItemIcon(c,key,cx,cy,S){
'@ @'
// v28.xx (cw-cx-raritypips), his 2.79 a: every colour cue has a backup, always, no switch needed.
// One to five cream pips follow the displayed rank, including gun variants. The same painter feeds menu, bag, belt and loot icons.
function rarityPips(c,key,cx,cy,S){
  var r=ITEMS[key]?dispR(key):((WEAPONS[key]&&key!=='fists')?gunRarity(key):null);
  var n={common:1,uncommon:2,rare:3,elite:4,gold:5}[r]||0;
  if(!n||!(S>0)) return 0;
  c.save();
  c.fillStyle='#0b0c0d'; c.fillRect(cx-S*.4,cy+S*.39,S*.8,S*.18);
  c.fillStyle='#efe9dc';
  for(var i=0;i<n;i++) c.fillRect(cx-S*.34+i*S*.145,cy+S*.43,S*.1,S*.1);
  c.restore();
  return n;
}
function drawItemIcon(c,key,cx,cy,S){
  var result=drawItemIconArt(c,key,cx,cy,S);
  rarityPips(c,key,cx,cy,S);
  return result;
}
function drawItemIconArt(c,key,cx,cy,S){
'@

SubRx @'
var VER='34.00';
'@ @'
var VER='34.01';
'@

$pat = "(?m)^  now:'v34\.00:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.01: Item icons carry one to five cream rarity pips, from common through gold, in every colour mode. Check 34.01 fails on v34.00',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
