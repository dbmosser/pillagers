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

# HIS NOTE, 2026-09-11, VERBATIM: "when a player comes back to the undercroft
# after dying in a raid or leaving/abandoning a raid, there should be nothing in
# their loadout. This increases the feeling of loss. So, if they had stuff in
# their loadout and took the free kit, then that old loadout should move to their
# stash, so they spawn in the undercroft with nothing. There may be instructions
# that need to change related to this."
#
# THIS REVERSES v6.88 AND v12.82. Both were built to his earlier spec, which said
# a death should re-equip the loadout he had before the freebie, and v12.82 added
# the tactical belt plan and the gun slot to it. He has changed his mind. That is
# his call, and a later reader must not read the missing restore as a regression.
#
# THE ITEMS ARE ALREADY IN THE STASH, so "move to their stash" is a matter of not
# putting them back. Taking the freebie kit commits nothing, so his own packing
# never left the stash; this block re-selecting it was the only reason it was in
# his loadout when he got back down.
SubRx @'
  // v6.88, his spec: "if they die, then their current loadout (before the freebie) should
  // be re-equipped". commitKit stashed it before the free gear wiped it; put it back on
  // anything that is not a clean extraction, and clear it either way.
  if(P.kitBeforeFree&&P.kitBeforeFree.length){
    if(how!=='extract'){
      // Only the pieces he still owns: anything spent, sold or lost since is not his to
      // re-arm, and P.kit is a SELECTION out of the stash rather than a move.
      var _kb=[],_have={};
      for(var _ks=0;_ks<P.stash.length;_ks++) _have[P.stash[_ks]]=(_have[P.stash[_ks]]||0)+1;
      for(var _kf=0;_kf<P.kitBeforeFree.length;_kf++){
        var _kk=P.kitBeforeFree[_kf];
        if((_have[_kk]||0)>0){ _have[_kk]--; _kb.push(_kk); }
      }
      P.kit=_kb;
      // v12.82: the tactical belt plan and the gun slot come back with the
      // items. The plan is filtered to what he still owns, the same rule the
      // list above follows, because a key pointing at something he no longer has
      // is a dead key rather than a restore.
      var _hk=0;
      if(P.hotBeforeFree){
        var _pool={},_q,_hi,_hv,_hb={};
        for(_q=0;_q<_kb.length;_q++) _pool[_kb[_q]]=(_pool[_kb[_q]]||0)+1;
        for(_hi in P.hotBeforeFree){
          _hv=P.hotBeforeFree[_hi];
          if(_hv&&(_pool[_hv]||0)>0){ _hb[_hi]=_hv; _pool[_hv]--; _hk++; }
        }
        P.hotAssign=_hb;
      }
      if(P.gunBeforeFree) P._gunSlot=P.gunBeforeFree;
      if(_kb.length) lines.push('<span style="color:var(--coolant)">'+_kb.length+' item'+(_kb.length===1?'':'s')+
        ' that you had in your loadout before choosing the freebie kit '+(_kb.length===1?'has':'have')+' been restored'+
        (_hk?(', and '+_hk+' tactical belt key'+(_hk===1?'':'s')+' with '+(_hk===1?'it':'them')):'')+'.</span>');
    }
    P.kitBeforeFree=null; P.hotBeforeFree=null; P.gunBeforeFree=null;
  }
'@ @'
  // v12.87, HIS NOTE 2026-09-11, verbatim: "when a player comes back to the
  // undercroft after dying in a raid or leaving/abandoning a raid, there should
  // be nothing in their loadout. This increases the feeling of loss. So, if they
  // had stuff in their loadout and took the free kit, then that old loadout
  // should move to their stash, so they spawn in the undercroft with nothing."
  // And, the same day: "aka nothing in tactical belt or backpack".
  //
  // THIS REVERSES v6.88 AND v12.82, both built to his earlier spec that a death
  // should re-equip the loadout he had before the freebie, and v12.82 added the
  // belt plan and the gun slot to it. He has changed his mind. Do not read the
  // missing restore as a regression and do not put it back.
  //
  // THE ITEMS ARE ALREADY IN THE STASH. Taking the freebie kit commits nothing,
  // so his own packing never left the stash, and this block re-selecting it was
  // the only reason it was in his loadout when he got back down. Moving it to
  // the stash is a matter of not putting it back, and the line he reads says
  // where his gear is rather than claiming it was restored to him.
  if(how!=='extract'){
    var _kbn=0;
    if(P.kitBeforeFree&&P.kitBeforeFree.length){
      var _have={},_ks,_kf,_kk;
      for(_ks=0;_ks<P.stash.length;_ks++) _have[P.stash[_ks]]=(_have[P.stash[_ks]]||0)+1;
      for(_kf=0;_kf<P.kitBeforeFree.length;_kf++){
        _kk=P.kitBeforeFree[_kf];
        if((_have[_kk]||0)>0){ _have[_kk]--; _kbn++; }
      }
    }
    // Nothing in the loadout, whichever way it ended badly and whether or not the
    // freebie kit was taken. HIS CLARIFICATION, same day: "aka nothing in
    // tactical belt or backpack". The Undercroft backpack and belt ARE P.kit and
    // P.hotAssign, read through hubBagState and written back when the bag closes,
    // so both are the loadout and both go. The gun slot goes with them: a slot
    // pointing at a gun he is not carrying is the v5.72 fault.
    P.kit=[]; P.hotAssign={}; P._gunSlot=null;
    // A bag left open in memory writes its old contents straight back over those
    // two the moment it closes, so the live one is dropped and rebuilt from the
    // profile that has just been emptied.
    hubBagG=null;
    if(_kbn) lines.push('<span style="color:var(--coolant)">The '+_kbn+' item'+(_kbn===1?'':'s')+
      ' you had packed before choosing the freebie kit '+(_kbn===1?'is':'are')+
      ' in your stash. You come back down with an empty backpack and belt.</span>');
  }
  P.kitBeforeFree=null; P.hotBeforeFree=null; P.gunBeforeFree=null;
'@

# NEW IN.
SubRx @'
  'RESTORING FROM A FILE REBUILDS THE SCREEN INSTEAD OF HALF OF IT.
'@ @'
  'YOU COME BACK DOWN WITH AN EMPTY BACKPACK AND BELT. Die or walk out and your backpack, your tactical belt and your gun slot are all empty by the time you reach the Undercroft, so the next raid is packed on purpose rather than carried over. If you took the freebie kit, the gear you had packed before it is waiting in your stash, not back on your back.',
  'RESTORING FROM A FILE REBUILDS THE SCREEN INSTEAD OF HALF OF IT.
'@

# STAMPS.
SubRx @'
var VER='12.86';
'@ @'
var VER='12.87';
'@
SubRx @'
var WHATSNEW_VER='12.86';
'@ @'
var WHATSNEW_VER='12.87';
'@
$cnt=([regex]::Matches($s,"now:'v12\.86:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.86 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.86:[^']*'",{ param($m) "now:'v12.87: his note of 2026-09-11, verbatim: when a player comes back to the undercroft after dying in a raid or leaving/abandoning a raid, there should be nothing in their loadout, this increases the feeling of loss, so if they had stuff in their loadout and took the free kit then that old loadout should move to their stash, so they spawn in the undercroft with nothing. This REVERSES v6.88 and v12.82, both built to his earlier spec that a death should re-equip the loadout he had before the freebie, with v12.82 adding the belt plan and the gun slot to it; he has changed his mind, and a later reader must not read the missing restore as a regression. The items are already in the stash: taking the freebie kit commits nothing, so his own packing never left the stash, and the block re-selecting it was the only reason it was in his loadout when he got back down, so moving it to the stash is a matter of not putting it back and the line he reads says where his gear is rather than claiming it was restored. His clarification the same day was aka nothing in tactical belt or backpack, and the Undercroft backpack and belt ARE P.kit and P.hotAssign read through hubBagState, so both are emptied and the live bag is dropped rather than left to write its old contents back when it closes. The loadout is emptied on dead and on abandon, freebie or not, and the gun slot goes with it because a slot pointing at a gun he is not carrying is the v5.72 fault; extracting is untouched. Check 12.87 packs two items and binds two belt keys, takes the freebie kit the way the stash button leaves it, commits, runs a raid and ends it dead, then requires an empty backpack, an empty belt and both items still in the stash, and does the same for abandon; the arms fail on v12.86 where the loadout comes back full. NOT CHANGED AND FLAGGED TO HIM: the ascent check still auto-fills a standard loadout when it is opened with nothing packed, which is the next screen rather than the Undercroft, and his baked text edit for the old restored line is now a dead key rather than being rewritten for him.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
