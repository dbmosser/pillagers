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

# PLAYER 2 SEES HIS KILLING SHOT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
                dmgNum(en.x+fxn(-5,5),en.y-Math.round(en.r*1.1),_dn,_dc,en.hp<=0);   // v8.35
                if(NET.on) netFxDmg(en.x,en.y-Math.round(en.r*1.1),_dn,_dc,en.hp<=0);
'@ @'
                dmgNum(en.x+fxn(-5,5),en.y-Math.round(en.r*1.1),_dn,_dc,hitKills(en,edmg));   // v8.35; v23.18: the kill style on player 2 too
                if(NET.on) netFxDmg(en.x,en.y-Math.round(en.r*1.1),_dn,_dc,hitKills(en,edmg));
'@

SubRx @'
function dmgNum(x,y,amount,col,kill){
'@ @'
// v23.18, parked by the raid text audit of 2026-10-09: PLAYER 2 SEES HIS KILLING SHOT. On a linked window the host runs the body, so the
// round only asks the host for the damage and the mirrored health has not dropped yet when the number is drawn: the shot that killed
// showed as a plain number, never the larger kill number with its mark. There it is worked out from the damage the round sends (the
// host takes off exactly that); on the host and solo the health has already been taken off, as before.
function hitKills(en,dmg){
  if(!en) return false;
  if(typeof NET==='object'&&NET&&NET.on&&typeof netEntsPeer==='function'&&netEntsPeer()) return ((+en.hp||0)-(+dmg||0))<=0;
  return en.hp<=0;
}
function dmgNum(x,y,amount,col,kill){
'@

SubRx @'
var VER='23.17';
'@ @'
var VER='23.18';
'@

$pat = "(?m)^  now:'v23\.17:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.18: In co-op, the second player killing shot now shows the larger kill number, as the host already did. Check 23.18 fails on v23.17',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
