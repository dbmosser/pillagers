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

# HIS NOTE, 2026-09-06 (his 06:39 export, run 5, @264s): "not letting me put
# guns back into backpack -- GUNS SHOULD FUNCTION LIKE EVERY OTHER INVENTORY
# ITEM!!!!". The two gun cells were select-only since v7.21 ("Guns select
# only"), so a gun in your hands had no way into the bag. With the backpack
# open, a press on a gun cell picks the gun up and a release over the bag
# puts it there; the other gun comes up, or bare hands. Closed, a click on a
# gun cell still only selects, which is the combat rule.

# 1. THE VERB. Mirrors equipFromBag's displaced-gun rules: issued kit cannot
# be bagged, and a gun from your own armoury leaves the armoury for the raid
# (recorded on G.spliced so an abandoned raid puts it back), as v8.32 does.
SubRx @'
// pressing a number puts that specific gun up. `swapped` is the only new state.
function swapGuns(){
'@ @'
// pressing a number puts that specific gun up. `swapped` is the only new state.
// v11.89, HIS NOTE: a gun in your hands goes back into the backpack like any
// other item. slot is the derived cell it was dragged from; gunA is the gun you
// deployed with and gunB the other one, mapped through p.swapped the way
// hotbarSlots maps them. The gun in hand is always p.wep; if that is the one
// bagged, the other gun comes up and keeps its own numbered slot.
function bagHeldGun(slot){
  var p=G&&G.player; if(!p||p.downed||G.over) return false;
  var sw=!!p.swapped;
  var isHand=(slot==='gunA')?!sw:sw;
  var g=isHand?p.wep:p.sec, issued=isHand?p.wepIssued:p.secIssued, arm=isHand?p.wepFromArmory:p.secFromArmory;
  if(!g||g.id==='fists'||g.mag===0){ say('Nothing there to bag.'); return false; }
  if(issued){ say(g.name+' is issued kit; it stays in your hands.'); return false; }
  if(!ITEMS['gun_'+g.id]){ say(g.name+' has no place in a bag.'); return false; }
  G.bag.push('gun_'+g.id);
  if(!G.sim&&arm){ var oi=P.weapons.indexOf(g.id); if(oi>=0){ P.weapons.splice(oi,1); (G.spliced=G.spliced||[]).push(g.id); } }
  if(isHand){
    p.wep=p.sec||WEAPONS.fists; p.ammo=p.secAmmo||0; p.wepIssued=!!p.secIssued; p.wepFromArmory=!!p.secFromArmory; p.reloading=0;
    p.sec=WEAPONS.fists; p.secAmmo=0; p.secIssued=true; p.secFromArmory=false;
    p.swapped=!sw;   // the gun that came up keeps the numbered slot it had
  } else {
    p.sec=WEAPONS.fists; p.secAmmo=0; p.secIssued=true; p.secFromArmory=false;
  }
  G.tel.weapon=p.wep.name;
  say(g.name+' into the backpack.'); blip('pick');
  return true;
}
function swapGuns(){
'@

# 2. THE PRESS: a gun cell drags while the backpack is open.
SubRx @'
        setHot(_HC2.i);
        if(_hs2&&_hs2.kind!=='gun'&&_hs2.itemKey){
          G.drag={key:_hs2.itemKey,fromHot:_HC2.i};
          blip('pick');
        }
        return;
'@ @'
        setHot(_HC2.i);
        if(_hs2&&_hs2.kind!=='gun'&&_hs2.itemKey){
          G.drag={key:_hs2.itemKey,fromHot:_HC2.i};
          blip('pick');
        }
        // v11.89, HIS NOTE: "GUNS SHOULD FUNCTION LIKE EVERY OTHER INVENTORY
        // ITEM". With the backpack open, the gun in a hand cell can be picked
        // up and dropped into the bag. Closed, a click still only selects.
        else if(_hs2&&_hs2.kind==='gun'&&(_hs2.k==='gunA'||_hs2.k==='gunB')&&!_hs2.vacant&&G.bagOpen&&_hs2.icon&&_hs2.icon!=='fists'){
          G.drag={key:'gun_'+_hs2.icon,gunSlot:_hs2.k,fromHot:_HC2.i};
          blip('pick');
        }
        return;
'@

# 3. THE RELEASE: over the open backpack, the gun is bagged; anywhere else,
# nothing happens. The belt loop below is skipped for this drag (d.key is
# cleared), so a gun let go back on its own cell says nothing.
SubRx @'
  if(e.button===0&&G&&G.drag){
    var d=G.drag; G.drag=null;
    var dropped=false;
'@ @'
  if(e.button===0&&G&&G.drag){
    var d=G.drag; G.drag=null;
    var dropped=false;
    // v11.89, HIS NOTE: a gun dragged off a hand cell. Released over the open
    // backpack it goes in; released anywhere else it stays where it was.
    if(d.gunSlot){
      if(G.bagOpen&&G.bagPanel&&inRect(G.bagPanel,mouse.x,mouse.y)) bagHeldGun(d.gunSlot);
      d={key:null}; dropped=true;
    }
'@
SubRx @'
    if(G.hotCells) for(var hc=0;hc<G.hotCells.length;hc++){
      var HC=G.hotCells[hc];
'@ @'
    if(G.hotCells&&d.key) for(var hc=0;hc<G.hotCells.length;hc++){
      var HC=G.hotCells[hc];
'@

# STAMPS.
SubRx @'
var VER='11.88';
'@ @'
var VER='11.89';
'@
SubRx @'
var WHATSNEW_VER='11.88';
'@ @'
var WHATSNEW_VER='11.89';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'A GUN IN YOUR HANDS GOES BACK INTO THE BACKPACK: with the backpack open, drag it off its slot and drop it in.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.88:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.88 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.88:[^']*'",{ param($m) "now:'v11.89: HIS NOTE of 2026-09-06, guns should function like every other inventory item; a gun in his hands could not be put back in the backpack because the two gun cells were select-only. With the backpack open a press on a gun cell starts a drag and a release over the bag calls bagHeldGun, which puts the gun in the bag (issued kit refused, an armoury gun spliced and recorded as v8.32 does) and brings the other gun or bare hands up, keeping its numbered slot. Check 11.89 opens the bag, presses on slot 1 through the real canvas mousedown, releases over the bag panel through the real window mouseup, and requires the gun in the bag and bare hands up; fails on v11.88.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
