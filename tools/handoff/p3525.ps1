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

# HOTBAR ITEMS WORK LIKE THE WHEEL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
beltInstant(dn-1); else setHot(dn-1);   // cw-hotitems: an item key uses its item at once
'@ @'
beltEquip(dn-1); else setHot(dn-1);   // cw-hotitems; cw-beltwheel (his order of 10-27): an item key takes its item out as a wheel pick does, and the trigger uses it
'@

SubRx @'
// A click on a grenade or medical key picks it, as U and J do (it used to put the highlight there, so the trigger cooked it); a gun key draws.
function beltPickCell(i){
  var sl, c, ti;
  if(!G||G.hubFloor||G.sim||i<0||i>=HOTBAR_N) return false;   // cw-hotitems: any key may hold an item
  sl=hotbarSlots(); c=sl[i];
  if(!c) return false;
  if(c.kind==='throw'&&c.icon&&(c.count|0)>0){
    ti=THROWKEYS.indexOf(c.icon); if(ti<0) return false;
    G.tsel=ti; say((c.name+' ready').toUpperCase()); return true;
  }
  if((c.kind==='heal'||c.kind==='stim')&&(c.count|0)>0&&c.itemKey&&ITEMS[c.itemKey]){
    G.msel=c.itemKey; say((c.name+' ready').toUpperCase()); return true;
  }
  return false;
}
'@ @'
// cw-beltwheel, HIS ORDER (2026-10-27): "if its on the hotbar, then it should work like the wheel... e.g you click the number to equip, then you
// still gotta click the mouse to use it". THE KEY OF AN ITEM TAKES IT OUT, the wheel pick (handTake): the gun goes away, the item readies, and a
// fresh pull of the trigger uses it, one item, then the gun comes back. The same key again puts it away with no use. It used to use the item at
// once with the gun still up (beltInstant, the cw-hotitems build of the same day), which no key calls any more. slot is the key it came from, so
// the belt lights that key while the item is out.
function beltEquip(i){
  var p=G&&G.player, sl, c, k;
  if(!G||G.sim||G.over||G.paused||G.trade||G.hubFloor||!p||i<0||i>=HOTBAR_N) return false;
  if(p.downed){ say('NOT WHILE DOWN'); return false; }
  if(p.dying||p.specOut) return false;
  sl=hotbarSlots(); c=sl[i];
  if(!c||!/^(throw|heal|stim|armor)$/.test(c.kind)) return false;
  k=c.itemKey||c.icon;
  if(!k||!ITEMS[k]) return false;
  if(p.hand&&p.hand.k===k){ handCancel(p); return true; }
  if(wheelHave(k)<=0){ say(('NO '+ITEMS[k].name).toUpperCase()); return false; }
  if(p.hand) handCancel(p);
  if(!handTake(k)) return false;
  p.hand.slot=i;
  return true;
}
// A click on an item key is its number key (cw-beltwheel: it takes the item out); a gun key draws.
function beltPickCell(i){
  var sl, c;
  if(!G||G.hubFloor||G.sim||i<0||i>=HOTBAR_N) return false;   // cw-hotitems: any key may hold an item
  sl=hotbarSlots(); c=sl[i];
  if(!c) return false;
  if(/^(throw|heal|stim|armor)$/.test(c.kind)) return beltEquip(i);
  return false;
}
'@

SubRx @'
var sl=hotbarSlots(),sel=hotSel();
'@ @'
var sl=hotbarSlots(),sel=hotSel(), _hhd=(!G.hubFloor&&G.player)?G.player.hand:null;
    if(_hhd&&_hhd.slot!==undefined&&sl[_hhd.slot]&&(sl[_hhd.slot].itemKey||sl[_hhd.slot].icon)===_hhd.k) sel=_hhd.slot;   // cw-beltwheel: the key of the item in hand is lit
'@

SubRx @'
if(G&&G.mapFirst&&!G.over){ if(e.button===0) mapFirstGo('click'); return; }
'@ @'
if(G&&G.mapFirst&&!G.over){ if(e.button===0) mapFirstGo('click'); return; }
  // cw-beltwheel, HIS ORDER (2026-10-27): "i should be able to drag items from the wheel to the hotbar". With the wheel open (hold Q), a press
  // picks up the item under the aim, the drag the backpack uses; let go over a belt key and it is bound there as a backpack drag binds it. A
  // press with the wheel open never reaches anything else (the trigger is dead there already).
  if(e.button===0&&G&&!G.over&&G.wheel&&!G.wheel.pad){
    var _wd=G.wheel, _wk=(!G.drag&&_wd.sel>=0&&_wd.list&&_wd.list[_wd.sel])?_wd.list[_wd.sel].k:null;
    if(_wk&&ITEMS[_wk]&&wheelHave(_wk)>0){ G.drag={key:_wk,fromWheel:1,px:mouse.x,py:mouse.y}; blip('pick'); }
    return;
  }
'@

SubRx @'
  w.list=wheelList(); m=w.list.length;
  if(!m){ G.wheel=null; return; }
'@ @'
  w.list=wheelList(); m=w.list.length;
  if(!m){ G.wheel=null; return; }
  if(G.drag&&G.drag.fromWheel){ p.trigYield=1; return; }   // cw-beltwheel: an item picked up off the wheel keeps its segment lit until it is dropped
'@

SubRx @'
  G.wheel=null;
  if(w.sel<0||!w.list||!w.list[w.sel]) return false;
'@ @'
  G.wheel=null;
  if(G.drag&&G.drag.fromWheel) return false;   // cw-beltwheel: Q let go with an item from the wheel held: nothing comes out, the drop still binds it
  if(w.sel<0||!w.list||!w.list[w.sel]) return false;
'@

SubRx @'
  if(e.button===0&&G&&G.drag&&!G.over){
    var d=G.drag; G.drag=null;
    var dropped=false;
'@ @'
  if(e.button===0&&G&&G.drag&&!G.over){
    var d=G.drag; G.drag=null;
    var dropped=false;
    if(d.fromWheel) G.wheel=null;   // cw-beltwheel: a drop off the wheel closes it, so letting go of Q after it takes nothing out
'@

SubRx @'
if(!dropped&&G&&!G.over&&d&&d.key&&!netEntsPeer()){
'@ @'
if(!dropped&&G&&!G.over&&d&&d.key&&!d.fromWheel&&!netEntsPeer()){   // cw-beltwheel: a wheel drag only binds a key
'@

SubRx @'
var VER='35.24';
'@ @'
var VER='35.25';
'@

$pat = "(?m)^  now:'v35\.24:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.25: a belt key or a click takes the item out and the trigger uses it, the key again puts it away; drag an item off the wheel onto a belt key Check 35.25 fails on v35.24',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
