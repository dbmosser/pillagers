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

# ============ HIS NOTE, 2026-09-03 about 21:25: "when i find a gun it should go
# ============ to the next open slot, not kick my scav pistol out of slot 1".
# ============
# ============ Reproduced before touching anything, on v10.61: a Scav Pistol in
# ============ hand, Bare Hands in the second slot, a found Auto Rifle in the
# ============ bag. Equipping the rifle put it in his hand and threw the pistol
# ============ into the bag, and the second slot was still empty afterwards. You
# ============ carry two guns and one of the two was standing empty while the
# ============ game turned out the one you were holding.
# ============
# ============ It goes to the empty one now. Only when the slot he asked for is
# ============ full and the other is free: with both full the slot he asked for
# ============ is replaced, because that is the only way to choose which of the
# ============ two goes, and that decision is his (his note of 2026-08-24, "you
# ============ should be able to carry all the guns you want but you only have 2
# ============ equipped").
SubRx @'
  var toSec=(slot===2);
  var oldW=toSec?p.sec:p.wep;
'@ @'
  var toSec=(slot===2);
  // v10.62, his note. Bare Hands is what an empty gun slot holds.
  function _slotFree(g){ return !g||g.id==='fists'||g.mag===0; }
  var _asked=toSec, _kept=null;
  if(!_slotFree(toSec?p.sec:p.wep)&&_slotFree(toSec?p.wep:p.sec)){
    toSec=!toSec;
    _kept=(_asked?p.sec:p.wep);   // the gun he is keeping, named in the line below
  }
  var oldW=toSec?p.sec:p.wep;
'@
SubRx @'
  say(g.name+(toSec?' to secondary':' equipped'));
'@ @'
  // v10.62: when it was routed to the free slot, say so and name what he kept,
  // or the gun appears to have gone somewhere he did not ask for.
  if(_kept) say(g.name+' to your empty slot. '+_kept.name+' stays in hand.');
  else say(g.name+(toSec?' to secondary':' equipped'));
'@

SubRx @'
var VER='10.61';
'@ @'
var VER='10.62';
'@
SubRx @'
  now:'v10.61: the Undercroft is darker and gloomier. The tune is no longer led by the bright square wave that made it sound like a toy, the room has slowed from a hundred beats a minute to seventy-six, the filter is closed further, the shimmer plays half as often, and the bass is held long enough to hum.',
'@ @'
  now:'v10.62: a gun you find goes into your empty slot instead of turning out the gun in your hand. You carry two; if both are full the one you picked is still the one replaced, because that is the only way to choose.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
