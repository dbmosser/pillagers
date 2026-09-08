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

# CLOSES THE "Not verified:" LINE ON v12.08, and the 2026-09-07 audit confirmed
# it. v12.08 stopped an empty throwable cell from owning the MOUSE trigger. The
# G key and the pad reach the throw by a different door, through useHot into
# doThrow, and that door still cycled: an empty selected cell walked the hidden
# selector on to the next grenade you DID have and threw that one instead, while
# the belt highlight and the caption still named the cell you chose. Same for
# the cook. The two use verbs now do exactly what the mouse branch does: name
# what is missing, put the gun up, and spend nothing.
SubRx @'
function doThrow(){
  var p=G.player;
  if(p.downed||p.roll>0) return;
  var tk=THROWKEYS[G.tsel];
  if(G.pouch[tk]<=0){ cycleThrow(); if(G.pouch[THROWKEYS[G.tsel]]<=0) return; tk=THROWKEYS[G.tsel]; }
'@ @'
// v12.41, 2026-09-07 audit: AN EMPTY CELL SPENDS NOTHING FROM ANOTHER CELL.
// Both use verbs below used to call cycleThrow when the selected cell was
// empty, which walks the hidden selector on to the next kind you are carrying
// and throws or cooks THAT one, while the belt highlight and the caption still
// name the cell you pressed. v12.08 closed this on the mouse trigger and its
// DESIGN entry recorded the key and the pad as not verified; this is that line.
// Q still cycles on purpose. A use key never does.
function emptyThrowCell(tk){
  setHot(gunCell());
  if(!G.sim) say('No '+((ITEMS[tk]&&ITEMS[tk].name)||'throwable')+' left. '+((G.player.wep&&G.player.wep.name)||'Your gun')+' up.');
}
function doThrow(){
  var p=G.player;
  if(p.downed||p.roll>0) return;
  var tk=THROWKEYS[G.tsel];
  if(G.pouch[tk]<=0){ emptyThrowCell(tk); return; }
'@

SubRx @'
  if(G.pouch[tk]<=0){ cycleThrow(); if(G.pouch[THROWKEYS[G.tsel]]<=0) return false; tk=THROWKEYS[G.tsel]; }
'@ @'
  // v12.41: the cook takes the same rule as the throw. See emptyThrowCell above.
  if(G.pouch[tk]<=0){ emptyThrowCell(tk); return false; }
'@

# NEW IN.
SubRx @'
  'THE MAN YOU HIRED STOPS PICKING UP THE MEN SHOOTING AT YOU. A crew number is not a side: your hire shares one with about half the map, so a downed hostile carrying that number used to be worth breaking off your job for. He still picks up anyone who has thrown in with you.',
'@ @'
  'THE MAN YOU HIRED STOPS PICKING UP THE MEN SHOOTING AT YOU. A crew number is not a side: your hire shares one with about half the map, so a downed hostile carrying that number used to be worth breaking off your job for. He still picks up anyone who has thrown in with you.',
  'AN EMPTY CELL SPENDS NOTHING FROM ANOTHER CELL. The G key on a cell you had nothing in used to quietly walk to the next grenade you did have and throw that one, while the belt still named the cell you pressed. It names what is missing and puts your gun up. Q still cycles.',
'@

# STAMPS.
SubRx @'
var VER='12.40';
'@ @'
var VER='12.41';
'@
SubRx @'
var WHATSNEW_VER='12.40';
'@ @'
var WHATSNEW_VER='12.41';
'@
$cnt=([regex]::Matches($s,"now:'v12\.40:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.40 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.40:[^']*'",{ param($m) "now:'v12.41: closes the not-verified line on v12.08, confirmed by the 2026-09-07 audit. v12.08 stopped an empty throwable cell from owning the MOUSE trigger. The G key and the pad reach the throw through a different door, useHot into doThrow, and that door still cycled: an empty selected cell walked the hidden selector on to the next grenade you did have and threw that one instead, while the belt highlight and the caption still named the cell you pressed. The cook did the same. One shared refusal now serves both use verbs and does exactly what the mouse branch does: it names what is missing, puts the gun in your hands up, and spends nothing. Q, the dedicated cycle key, still cycles, because choosing another grenade on purpose is not the same act as using the one you chose. Check 12.41 deploys with two Smoke and nothing else, points the belt at the Frag cell, presses the key through the real use path, and requires the pouch, the throw list and the selector all unmoved with a toast that names the Frag; it then drives the assigned-cell route and the cook the same way, and a control requires a cell that DOES hold a grenade to still throw it; fails on v12.40.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
