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

# THE LAST OPEN LINE OF THE 2026-09-06 IN-RAID AUDIT, and the piece v12.41 left
# behind on purpose because it is a different act.
#
# There are two things that say which grenade is in your hand and they are not
# the same thing. The belt highlight is one field; the throwable selector is
# another. Q is the key whose whole job is to choose a different grenade, and it
# writes the selector only. So pressing Q moves what you will throw and leaves
# the belt highlighting the cell you are no longer holding: the caption names
# one grenade, the highlight sits on its cell, and the trigger throws a
# different one.
#
# v12.41 closed the other half, where a USE key on an empty cell walked that
# same selector on without telling you. This is the deliberate half: choosing is
# fine, and the belt simply has to follow the choice.
SubRx @'
function cycleThrow(){
  for(var i=1;i<=3;i++){
    var n=(G.tsel+i)%3;
    if(G.pouch[THROWKEYS[n]]>0){ G.tsel=n; say(ITEMS[THROWKEYS[n]].name+' ready'); return; }
  }
  say('No throwables');
}
'@ @'
function cycleThrow(){
  for(var i=1;i<=3;i++){
    var n=(G.tsel+i)%3;
    if(G.pouch[THROWKEYS[n]]>0){
      G.tsel=n;
      // v12.56, 2026-09-06 in-raid audit: AND THE BELT FOLLOWS THE HAND. Which
      // grenade is in your hand and which cell the belt highlights are two
      // different fields, and this key wrote only the first, so choosing a
      // different grenade left the highlight and the caption on the cell you
      // were no longer holding while the trigger threw the new one. The
      // highlight now moves to the cell that actually holds what you chose,
      // whether that is the derived cell or one you dragged the grenade onto
      // yourself. Nothing else changes: Q still cycles, which is its job, and
      // v12.41 already stopped the USE keys doing it behind your back.
      var _cs=hotbarSlots(), _ck='throw:'+THROWKEYS[n], _ci, _cf=-1;
      for(_ci=0;_ci<_cs.length;_ci++){
        var _cc=_cs[_ci];
        if(!_cc) continue;
        if(_cc.k===_ck||_cc.itemKey===THROWKEYS[n]){ _cf=_ci; break; }
      }
      if(_cf>=0) G.hot=_cf;
      say(ITEMS[THROWKEYS[n]].name+' ready');
      return;
    }
  }
  say('No throwables');
}
'@

# NEW IN.
SubRx @'
  'AN IMPORTED GHOST FIGHTS AT HIS OWN GUN RANGE. He was handed the gun from the report he came out of but kept the engagement range of the body he arrived in, so he opened fire at a distance his rounds could not cross, or refused to open fire at one they could.',
'@ @'
  'AN IMPORTED GHOST FIGHTS AT HIS OWN GUN RANGE. He was handed the gun from the report he came out of but kept the engagement range of the body he arrived in, so he opened fire at a distance his rounds could not cross, or refused to open fire at one they could.',
  'Q MOVES THE BELT AS WELL AS YOUR HAND. Choosing a different grenade used to leave the tactical belt highlighting the cell you were no longer holding, so the caption named one grenade and the trigger threw another.',
'@

# STAMPS.
SubRx @'
var VER='12.55';
'@ @'
var VER='12.56';
'@
SubRx @'
var WHATSNEW_VER='12.55';
'@ @'
var WHATSNEW_VER='12.56';
'@
$cnt=([regex]::Matches($s,"now:'v12\.55:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.55 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.55:[^']*'",{ param($m) "now:'v12.56: the last open line of the 2026-09-06 in-raid audit, and the piece v12.41 deliberately left behind because it is a different act. Which grenade is in your hand and which cell the tactical belt highlights are two different fields. Q is the key whose whole job is to choose a different grenade and it wrote only the first, so pressing it moved what you would throw and left the belt highlighting the cell you were no longer holding: the caption named one grenade, the highlight sat on its cell, and the trigger threw another. v12.41 closed the other half of the same split, where a USE key on an empty cell walked that selector on without telling you; this is the deliberate half, where choosing is fine and the belt simply has to follow the choice. The highlight now moves to the cell that actually holds what was chosen, whether that is the derived cell or one he dragged the grenade onto himself, and nothing else changes. Check 12.56 gives him two kinds of grenade, points the belt at one, presses the real key, and requires the highlight, the caption and the selector all to name the same grenade afterwards, with a control that a man carrying only one kind is left exactly where he was; fails on v12.55.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
