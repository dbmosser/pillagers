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

# ============ THE LOADOUT NUMBER DID NOT COUNT WHAT WAS GOING UP.
# ============
# ============ The ascent panel is headed LOADOUT with "Xc going up" beside it,
# ============ which is the number he reads before deciding what to risk. It was
# ============ computed from the BACKPACK GRID rather than from the loadout, and
# ============ the grid is deliberately not the whole loadout: since v6.60 a copy
# ============ claimed by a tactical belt key is removed from it, because an item
# ============ is in the backpack or on the belt and never both, which is his own
# ============ rule and correct.
# ============
# ============ So the number fell every time he put something on a key, and the
# ============ safe pocket was never in it at all. Both still go up with him.
# ============
# ============ REPRODUCED on v10.69 in the Undercroft, with a medkit, a plate and
# ============ a servo packed: the header reads 860c. Put the medkit on key 3,
# ============ which moves nothing out of the loadout, and it reads 650c. The
# ============ medkit is worth 210 and it went up either way. Put a bandage worth
# ============ 60 in the safe pocket and the number does not move at all.
# ============
# ============ It counts the loadout now: the whole backpack including the copies
# ============ that live on keys, plus the safe pocket. The three labels under it
# ============ are unchanged and still split it up, because "Backpack N packed"
# ============ is about the grid and is right as it stands.
SubRx @'
  var K=stageKitLive();
'@ @'
  var K=stageKitLive();
  // v10.70: what actually goes up the lift, taken BEFORE the belt copies are
  // removed below. The grid and the loadout are two different things and the
  // header is about the second one.
  var _goingUp=K.slice();
'@

SubRx @'
  var kvEl=document.getElementById('kitval');
  if(kvEl){ var kv=0; for(var _kq=0;_kq<K.length;_kq++) kv+=ival(K[_kq]);
    kvEl.textContent=kv.toLocaleString(); }
'@ @'
  // v10.70: THE LOADOUT, not the grid. This read K, which has had one copy per
  // tactical belt key taken out of it, so the number fell every time he put
  // something on a key even though the item still goes up; and the safe pocket
  // was never counted at all. Measured on v10.69: a medkit, a plate and a servo
  // read 860c, the same three with the medkit on key 3 read 650c, and a bandage
  // worth 60 in the safe pocket moved it not at all.
  var kvEl=document.getElementById('kitval');
  if(kvEl){ var kv=0; for(var _kq=0;_kq<_goingUp.length;_kq++) kv+=ival(_goingUp[_kq]);
    var _sk=safeKey(); if(_sk) kv+=ival(_sk);
    kvEl.textContent=kv.toLocaleString(); }
'@

SubRx @'
var VER='10.69';
'@ @'
var VER='10.70';
'@
SubRx @'
  now:'v10.69: FIRST TIME OUT tells you how much of it you have not read. Most of the briefing was under the fold behind a five pixel scrollbar, so a new player finished it without ever seeing the Bulwark, the Pillbox or the Mainframe.',
'@ @'
  now:'v10.70: the LOADOUT number counts everything going up with you. It was reading the backpack grid, so putting an item on a tactical belt key made its value disappear from the total, and the safe pocket was never counted at all.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
