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

# AN ITEM BOUND TO BELT KEY 1 NO LONGER BURIES THE GUN FOR THE WHOLE RAID (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(G.hotAssign) for(var ai in G.hotAssign){
'@ @'
  var _dGun=[out[0],out[1]];   // v17.17, belt hunt 2026-09-28: the two gun cells as derived, before any key covers them
  if(G.hotAssign) for(var ai in G.hotAssign){
'@

SubRx @'
  // v6.70, his note that moving a belt item does not work: the bar is DERIVED and an
'@ @'
  // v17.17, belt hunt 2026-09-28: AN ITEM ON KEY 1 OR 2 NO LONGER BURIES A GUN. Any item goes on any key (v6.61), so a Medkit
  // bound to key 1 in the Undercroft covered the gun cell for the whole raid and nothing showed the gun anywhere else: the raid
  // started on the Medkit, no cell fired the gun, and key 2 (Bare Hands) stowed it where no key reached it again. A gun cell a
  // key covers now moves to the last free key, where the automatic pins already yield to, unless a key he bound already shows
  // that gun. It keeps its gunA or gunB name, so the swap, the raid start and the weapon slot drop rule all find it. Stowed Bare
  // Hands need no key.
  for(var _dg=0;_dg<2;_dg++){
    var _gc=_dGun[_dg];
    if(!_gc||_gc.vacant||out[_dg]===_gc) continue;
    if(!_gc.inHand&&_gc.icon==='fists') continue;
    var _gShown=false;
    for(var _gj=0;_gj<out.length;_gj++) if(out[_gj]&&out[_gj].kind==='gun'&&out[_gj].equipped&&!!out[_gj].inHand===!!_gc.inHand) _gShown=true;
    if(_gShown) continue;
    for(var _gn=out.length-1;_gn>=2;_gn--)
      if(out[_gn]&&out[_gn].kind==='empty'&&!(G.hotAssign&&G.hotAssign[_gn]!==undefined)){ out[_gn]=_gc; break; }
  }
  // v6.70, his note that moving a belt item does not work: the bar is DERIVED and an
'@

SubRx @'
var VER='17.16';
'@ @'
var VER='17.17';
'@

$pat = "(?m)^  now:'v17\.16:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.17: Belt key 1 or 2 covering the gun cell. v6.61 lets any item go on any key, and hotbarSlots let an assignment on index 0 or 1 overwrite the derived gunA or gunB cell with nothing moving the gun cell it covered. With a Medkit on key 1, heldGunCell found no cell holding the gun in hand, so the raid started on the Medkit (gunCell falls back to 0), the trigger fired from no cell, and key 2 or RB swapped to Bare Hands and left the carried gun under the Medkit for the rest of the raid, while gunKeyLine still said Press 1 for your gun. hotbarSlots now keeps the two derived gun cells and, after the assignment loop, moves a covered one (still keyed gunA or gunB, so setHot, swapGuns, heldGunCell, the raid start and the weapon slot drop rule all find it) onto the highest empty key with no assignment, the same place the automatic pins yield to. It stays put when a key he bound already shows that gun, and stowed Bare Hands get no key. Check 17.17 fails on v17.16',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
