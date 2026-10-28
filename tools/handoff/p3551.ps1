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

# pad trigger keeps steady spread without focus aim (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(PAD.adsT>0||PAD.adsAim){ G.player.ads=true; PAD.adsing=1; }
'@ @'
  // v28.xx (cw-cx-rtsteady): his 10-20 aim order names right mouse and LT; RT settles spread only.
  if(PAD.adsAim){ G.player.ads=true; PAD.adsing=1; }
'@

SubRx @'
  PAD.rtHeld=false; PAD.ltHeld=false;
'@ @'
  PAD.rtHeld=false; PAD.ltHeld=false; PAD.adsT=0; // v28.xx (cw-cx-rtsteady): a released pad cannot leave a spread bonus behind.
'@

SubRx @'
function bloomTick(p,dt){
'@ @'
// v28.xx (cw-cx-rtsteady): the existing 0.35 second pad settle changes accuracy without entering focus aim.
function shotSteady(p){ return !!(p&&(p.ads||(G&&p===G.player&&PAD.on&&PAD.adsT>0))); }
function bloomTick(p,dt){
'@

SubRx @'
  if(p.ads) base*=0.4;
'@ @'
  if(shotSteady(p)) base*=0.4; // v28.xx (cw-cx-rtsteady): retain the movement bloom bonus on RT.
'@

SubRx @'
  return t.cone*Math.max(0,Math.min(1,p.bloomK||0))*(p.ads?0.5:1);
'@ @'
  return t.cone*Math.max(0,Math.min(1,p.bloomK||0))*(shotSteady(p)?0.5:1); // v28.xx (cw-cx-rtsteady): RT retains the same bloom cone.
'@

SubRx @'
var spx=wep.spread*(((fromPlayer&&G.player.ads)||(!fromPlayer&&sh&&sh.steady))?0.4:1)*(fromPlayer?bloomMul(G.player):1)+(fromPlayer?bloomCone(G.player,wep):0);
'@ @'
var spx=wep.spread*(((fromPlayer&&shotSteady(G.player))||(!fromPlayer&&sh&&sh.steady))?0.4:1)*(fromPlayer?bloomMul(G.player):1)+(fromPlayer?bloomCone(G.player,wep):0);
'@

SubRx @'
var VER='35.50';
'@ @'
var VER='35.51';
'@

$pat = "(?m)^  now:'v35\.50:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.51: pad trigger fire keeps its steady spread without cutting sprint or pulsing a scoped view. lt and right mouse still aim. Check 35.51 fails on v35.50',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
