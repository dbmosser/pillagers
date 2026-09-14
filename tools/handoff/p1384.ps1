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

# COMBAT AND PLAYER STATE AUDIT OF 2026-09-14, finding 5: BARE HANDS SWUNG ON TWO CLOCKS, AND F
# PUNCHED WITH A LIVE GRENADE IN THE HAND. The F strike (meleeStrike) keeps its own p.meleeAt
# stamp and the left click with Bare Hands keeps p.lastShot, and neither read the other, so
# alternating the two swung twice every 0.42 seconds. And meleeStrike had no cooking test, so
# with a pin pulled F still punched, which the trigger has refused since v13.62. The two swings
# now share one clock both ways, and F refuses while a grenade is cooking.
SubRx @'
  var gap=(WEAPONS.fists.rof||420)/1000;
  if(p.meleeAt!==undefined&&(G.t-p.meleeAt)<gap) return false;
  p.meleeAt=G.t;
'@ @'
  var gap=(WEAPONS.fists.rof||420)/1000;
  if(p.meleeAt!==undefined&&(G.t-p.meleeAt)<gap) return false;
  // v13.84, combat audit: not with a live grenade in the hand, and with bare hands up the F
  // strike and the left click are one swing on one clock.
  if(p.cooking) return false;
  var _bare=!!(p.wep&&p.wep.mag===0);
  if(_bare&&p.lastShot!==undefined&&(G.t*1000-p.lastShot)<=(WEAPONS.fists.rof||420)) return false;
  p.meleeAt=G.t;
  if(_bare) p.lastShot=G.t*1000;
'@
SubRx @'
    if(_mw.mag===0){
      if(_mw.auto||!p.fired){ p.lastShot=now; p.fired=true;
'@ @'
    if(_mw.mag===0){
      // v13.84, combat audit: the left-click swing waits on the F strike's clock too.
      if((_mw.auto||!p.fired)&&!(p.meleeAt!==undefined&&(G.t-p.meleeAt)<(WEAPONS.fists.rof||420)/1000)){ p.lastShot=now; p.fired=true; p.meleeAt=G.t;
'@
SubRx @'
var VER='13.83';
'@ @'
var VER='13.84';
'@

$pat = "(?m)^  now:'v13\.83:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.84: ONE SWING CLOCK FOR BARE HANDS, AND NO PUNCH WITH A LIVE GRENADE. Combat and player state audit of 2026-09-14, finding 5: the F strike kept p.meleeAt and the bare-hands left click kept p.lastShot, neither reading the other, so alternating them swung twice every 0.42 seconds, and meleeStrike had no cooking test so F punched with a pin pulled. The two now share one clock both ways and F refuses while a grenade cooks. Check 13.84 swings with the left click and then presses F in the same instant, requiring F refused, and pulls a pin and presses F, requiring it refused, with F on its own as the control; it fails on v13.83',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
