$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# HIS NOTE, 2026-09-06 about 14:30: "howler shouldn't be able to bomb from
# outside a building to the inside of the building". Both mortar sites aimed
# at a point and never asked whether a roof was over it. A shell aimed at a
# point under a roof the Howler is not itself under is refused; the machine
# keeps its clock and fires when the target is in the open, or once it has
# followed you inside.
SubRx @'
function buildingAtPt(map,x,y){
'@ @'
// v12.20, HIS NOTE: no shells through a roof. True when the target point is
// under a building the Howler is not itself in.
function mortarRoofed(e,tx,ty){
  var bt=buildingAtPt(G.map,tx,ty); if(!bt) return false;
  return buildingAtPt(G.map,e.x,e.y)!==bt;
}
function buildingAtPt(map,x,y){
'@
SubRx @'
        if(_hd<e.rng&&_hd>140){
          // Wider scatter than the aimed shot: it is shooting at a report, not
'@ @'
        if(_hd<e.rng&&_hd>140&&!mortarRoofed(e,e.heardX,e.heardY)){   // v12.20: not through a roof
          // Wider scatter than the aimed shot: it is shooting at a report, not
'@
SubRx @'
        if(e.cd<=0&&d<e.rng&&d>140&&!p.downed&&(_hSee||e.alert>1.2)){
'@ @'
        if(e.cd<=0&&d<e.rng&&d>140&&!p.downed&&(_hSee||e.alert>1.2)&&!mortarRoofed(e,_htx,_hty)){   // v12.20: not through a roof
'@

# STAMPS.
SubRx @'
var VER='12.19';
'@ @'
var VER='12.20';
'@
SubRx @'
var WHATSNEW_VER='12.19';
'@ @'
var WHATSNEW_VER='12.20';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE HOWLER DOES NOT SHELL THROUGH A ROOF: inside a building you are out of its reach until it comes in after you.',
'@
$cnt=([regex]::Matches($s,"now:'v12\.19:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.19 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.19:[^']*'",{ param($m) "now:'v12.20: HIS NOTE of 2026-09-06, the Howler bombed from outside a building to the inside. Both mortar sites refuse a target under a roof the Howler is not itself under; the machine keeps its clock and fires in the open or once inside. Check 12.20 stages a Howler outside and the player inside a building and requires no shell, then both in the open and requires one; fails on v12.19.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
