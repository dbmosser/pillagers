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

# HIS NOTE, 2026-09-06 (his 06:39 export, run 5, @255s): "it says i have
# support mg but it is firing like a pistol -- hotbar is wonky, why can't i
# drag items to diff keys??". Two faults, one note. A belt key holding a gun
# from the backpack showed the gun, said a hint nobody read, and left it in
# the bag, so the trigger fired what was in his hands: the key EQUIPS it now.
# And the derived cells (Medical, Armour Plate, the grenades) carried no item
# key, so only a cell he had already assigned could be picked up: a derived
# cell drags by the item it shows.
SubRx @'
  else if(s2.kind==='gun'&&!_inHands&&s2.itemKey){
    // v11.30: this sentence was overwritten by the slot label two lines down
    // in the same call, so nobody ever read it; the label yields to it now.
    say(s2.name+' is in your backpack. TAB, then ENTER to equip it.');
    _hinted=true;
  }
'@ @'
  else if(s2.kind==='gun'&&!_inHands&&s2.itemKey){
    // v11.30 said "TAB, then ENTER to equip it" here, and nobody read it.
    // v11.91, HIS NOTE: "it says i have support mg but it is firing like a
    // pistol". The key showed the gun and left it in the backpack, and the
    // trigger fired what was in his hands. The key EQUIPS it now, into the
    // hands (the equip path may route it to the free slot; it is swapped up),
    // the displaced gun goes to the bag, and the highlight follows it.
    var _bix=G.bag.indexOf(s2.itemKey);
    if(_bix<0) say(s2.name+' is not in your backpack.');
    else if(!equipFromBag(_bix,1)) say('Cannot equip '+s2.name+' right now.');
    else {
      var _gk=ITEMS[s2.itemKey]&&ITEMS[s2.itemKey].gk;
      if(_gk&&G.player.wep.id!==_gk&&G.player.sec&&G.player.sec.id===_gk) swapGuns();
      // The highlight stays on the pressed cell: once the gun is in hand the
      // derived gun cell is blanked by the dedupe, so pointing at it read EMPTY.
    }
    _hinted=true;
  }
'@
SubRx @'
        if(_hs2&&_hs2.kind!=='gun'&&_hs2.itemKey){
          G.drag={key:_hs2.itemKey,fromHot:_HC2.i};
          blip('pick');
        }
'@ @'
        // v11.91, HIS NOTE: "why can't i drag items to diff keys??" The derived
        // cells (Medical, Armour Plate, the grenades) carried no item key, so
        // only a cell he had already assigned could be picked up. A derived
        // cell drags by the item it shows.
        var _dk=_hs2?(_hs2.itemKey||((_hs2.kind==='heal'||_hs2.kind==='armor'||_hs2.kind==='throw')&&_hs2.icon&&ITEMS[_hs2.icon]&&(_hs2.kind!=='heal'||_hs2.count>0)?_hs2.icon:null)):null;   // an empty Medical cell shows a bandage it does not hold
        if(_hs2&&_hs2.kind!=='gun'&&_dk){
          G.drag={key:_dk,fromHot:_HC2.i};
          blip('pick');
        }
'@

# AND THE UNDERCROFT BELT, which had the same fault: only an assigned cell dragged.
SubRx @'
          var _sl=hotbarSlots()[_H.i];
          if(_sl&&_sl.itemKey){ G.drag={key:_sl.itemKey,fromHot:_H.i}; blip('pick'); }
'@ @'
          var _sl=hotbarSlots()[_H.i];
          // v11.91, HIS NOTE: the floor's belt drags derived cells by the item they show too.
          var _sdk=_sl?(_sl.itemKey||((_sl.kind==='heal'||_sl.kind==='armor'||_sl.kind==='throw')&&_sl.icon&&ITEMS[_sl.icon]&&(_sl.kind!=='heal'||_sl.count>0)?_sl.icon:null)):null;
          if(_sl&&_sl.kind!=='gun'&&_sdk){ G.drag={key:_sdk,fromHot:_H.i}; blip('pick'); }
'@

# STAMPS.
SubRx @'
var VER='11.90';
'@ @'
var VER='11.91';
'@
SubRx @'
var WHATSNEW_VER='11.90';
'@ @'
var WHATSNEW_VER='11.91';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'A BELT KEY HOLDING A GUN FROM YOUR BACKPACK NOW EQUIPS IT, and every belt cell can be dragged to another key.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.90:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.90 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.90:[^']*'",{ param($m) "now:'v11.91: HIS NOTE of 2026-09-06, the belt said Support MG but the pistol fired, and items could not be dragged to other keys. A belt key holding a gun from the backpack now equips it into the hands (swapped up if the equip path routed it to the free slot) and the highlight follows; and the derived cells (Medical, Armour Plate, grenades) drag by the item they show, so any cell can be moved to another key. Check 11.91 assigns a bagged SMG to key 4 and presses it, requiring the SMG in hand, and presses on the derived Medical cell through the real canvas mousedown requiring a drag carrying the bandage; fails on v11.90.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
