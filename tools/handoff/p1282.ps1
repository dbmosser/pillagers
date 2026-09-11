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

# FROM THE 2026-09-08 FIRST-HOUR AUDIT, confirmed by a skeptic and then by me
# reading all four sites: both places that take the freebie kit, the handoff in
# commitKit, and the restore at the end of a raid.
#
# His spec at v6.88 was that dying with the freebie kit puts his own loadout back
# rather than making him rebuild it. Both places that hand him the kit do the
# right thing: they keep a snapshot of ALL THREE parts of a loadout, the items,
# the tactical belt plan, and the gun slot. And the button that gives him his own
# gear back puts all three back, which is why that button works.
#
# The handoff in the middle takes only the items out of that snapshot and then
# throws the snapshot away. So the belt plan and the gun slot are gone from the
# moment he presses TAKE THE FREEBIE KIT, and the restore at the end of a raid
# has nothing left to put back but the item list.
#
# What that looks like: a new player takes the welcome pack, drags a Medkit onto
# key 1 and a Frag onto key 2, which is the gesture the game teaches, takes the
# freebie kit, dies in his first raid, and reads "2 items that you had in your
# loadout before choosing the freebie kit have been restored". The items are
# back. The two keys he bound are blank, and nothing said so.
#
# THE BELT PLAN IS FILTERED TO WHAT HE STILL OWNS, the same rule the item list
# already follows, because a key pointing at something he no longer has is not a
# restore, it is a dead key.
SubRx @'
    P.kitBeforeFree=((P.kitSaved&&P.kitSaved.kit)||P.kit||[]).slice(); P.kitSaved=null;
'@ @'
    // v12.82, 2026-09-08 first-hour audit: ALL THREE PARTS OF THE LOADOUT, not
    // just the items. The snapshot above holds the belt plan and the gun slot as
    // well, and the button that gives him his own gear back restores all three;
    // this handoff dropped two of them on the floor and then threw the snapshot
    // away, so a death restored his items into a backpack with every belt key he
    // had bound now blank, and told him he had been restored.
    // v12.82: AND COMMITTING TWICE NO LONGER WIPES IT. The first commit moves the
    // snapshot here and clears it, so a second commit found an empty snapshot and
    // an empty kit and overwrote the lot with nothing. Quick ascent commits and so
    // does the staging path, so taking the kit at the stash and then going up left
    // the death restore with no items, no belt keys and no gun slot at all.
    if(!(P.kitBeforeFree&&P.kitBeforeFree.length)){
      P.kitBeforeFree=((P.kitSaved&&P.kitSaved.kit)||P.kit||[]).slice();
      P.hotBeforeFree=(P.kitSaved&&P.kitSaved.hot)?P.kitSaved.hot:null;
      P.gunBeforeFree=(P.kitSaved&&P.kitSaved.gun)?P.kitSaved.gun:null;
    }
    P.kitSaved=null;
'@

SubRx @'
      P.kit=_kb;
      if(_kb.length) lines.push('<span style="color:var(--coolant)">'+_kb.length+' item'+(_kb.length===1?'':'s')+
        ' that you had in your loadout before choosing the freebie kit '+(_kb.length===1?'has':'have')+' been restored.</span>');
    }
    P.kitBeforeFree=null;
'@ @'
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
'@

# NEW IN.
SubRx @'
  'THE DOWNED SCREEN STOPS OFFERING A SURRENDER IT WILL NOT TAKE. With an extraction waiting on the point you are lying in, the space bar is refused on purpose so a resting hand cannot throw away a full backpack. It now says so instead of printing a dead prompt.',
'@ @'
  'THE DOWNED SCREEN STOPS OFFERING A SURRENDER IT WILL NOT TAKE. With an extraction waiting on the point you are lying in, the space bar is refused on purpose so a resting hand cannot throw away a full backpack. It now says so instead of printing a dead prompt.',
  'DYING WITH THE FREEBIE KIT GIVES YOUR TACTICAL BELT BACK TOO. It restored the items you had packed and quietly kept the belt keys you had bound, and the gun slot, which were thrown away the moment you took the kit. Keys pointing at something you no longer own are still dropped.',
'@

# STAMPS.
SubRx @'
var VER='12.81';
'@ @'
var VER='12.82';
'@
SubRx @'
var WHATSNEW_VER='12.81';
'@ @'
var WHATSNEW_VER='12.82';
'@
$cnt=([regex]::Matches($s,"now:'v12.81:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.81 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12.81:[^']*'",{ param($m) "now:'v12.82: from the 2026-09-08 first-hour audit, confirmed by a skeptic and then by me reading all four sites: both places that hand him the freebie kit, the handoff in the middle, and the restore at the end of a raid. His spec at v6.88 was that dying with the freebie kit puts his own loadout back rather than making him rebuild it. Both places that hand him the kit do the right thing and keep a snapshot of ALL THREE parts of a loadout, the items, the tactical belt plan and the gun slot, and the button that gives him his own gear back restores all three, which is why that button works. The handoff in the middle took only the items out of that snapshot and then threw the snapshot away, so the belt plan and the gun slot were gone from the moment he pressed TAKE THE FREEBIE KIT and the restore at the end of a raid had nothing left to put back but the item list. What that looks like: a new player takes the welcome pack, drags a Medkit onto key 1 and a Frag onto key 2, which is the gesture the game teaches him, takes the freebie kit, dies in his first raid, and reads that two items from the loadout he had before choosing the kit have been restored. The items are back. The two keys he bound are blank, and nothing said so. The belt plan is filtered to what he still owns, the same rule the item list already follows, because a key pointing at something he no longer has is a dead key and not a restore, and the line now says how many keys came back with the items. Check 12.82 binds two keys and a gun slot, takes the kit, dies, and requires the keys and the slot back with the items, with one control that a key bound to something he no longer owns is still dropped and another that a clean extraction restores nothing at all; fails on v12.81.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
