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

# HIS NOTES, 2026-09-06 about 13:40, three messages: "hotbar item dragging
# doesn't work in raid"; "i want to be able to drag items even without
# inventory open"; "i have an smg on my hotbar and i can't even move it to
# the backpack". Two faults. The gun in a hand cell could be picked up only
# with the backpack open and dropped only on its panel, so with it closed the
# drag never started and the gesture looked dead (the cursor ghost of v9.32
# had nothing to draw). And a belt key holding a gun (kind gun, not a hand
# cell) could not be picked up at all, in the raid or on the floor.
SubRx @'
        if(_hs2&&_hs2.kind!=='gun'&&_dk){
          G.drag={key:_dk,fromHot:_HC2.i};
          blip('pick');
        }
'@ @'
        // v11.97, HIS NOTE: a belt key holding a gun drags like any other key.
        if(_hs2&&_dk&&!(_hs2.k==='gunA'||_hs2.k==='gunB')){
          G.drag={key:_dk,fromHot:_HC2.i};
          blip('pick');
        }
'@
SubRx @'
        // ITEM". With the backpack open, the gun in a hand cell can be picked
        // up and dropped into the bag. Closed, a click still only selects.
        else if(_hs2&&_hs2.kind==='gun'&&(_hs2.k==='gunA'||_hs2.k==='gunB')&&!_hs2.vacant&&G.bagOpen&&_hs2.icon&&_hs2.icon!=='fists'){
'@ @'
        // ITEM". The gun in a hand cell can be picked up and dropped into the
        // bag. v11.97, HIS NOTE: open or closed; released anywhere off the
        // belt it goes into the backpack, and a click still only selects.
        else if(_hs2&&_hs2.kind==='gun'&&(_hs2.k==='gunA'||_hs2.k==='gunB')&&!_hs2.vacant&&_hs2.icon&&_hs2.icon!=='fists'){
'@
SubRx @'
    if(d.gunSlot){
      if(G.bagOpen&&G.bagPanel&&inRect(G.bagPanel,mouse.x,mouse.y)) bagHeldGun(d.gunSlot);
      d={key:null}; dropped=true;
    }
'@ @'
    if(d.gunSlot){
      // v11.97, HIS NOTE: released off the belt after a real drag, it goes into
      // the backpack, open or closed. A release within a few pixels of the
      // press is the click it always was; a release on another belt cell is
      // refused in words, because a silent drop reads as a missing feature.
      var _onCell=-1;
      if(G.hotCells) for(var _gc=0;_gc<G.hotCells.length;_gc++){ var _GC=G.hotCells[_gc]; if(mouse.x>=_GC.x&&mouse.x<=_GC.x+_GC.w&&mouse.y>=_GC.y&&mouse.y<=_GC.y+_GC.h){ _onCell=_GC.i; break; } }
      var _moved=(d.px===undefined)||(Math.hypot(mouse.x-d.px,mouse.y-d.py)>24);
      if(_onCell<0&&_moved) bagHeldGun(d.gunSlot);
      else if(_onCell>=0&&_onCell!==d.fromHot) say('Drop it off the belt to stow it in the backpack; its own key brings it up.');
      d={key:null}; dropped=true;
    }
'@
SubRx @'
          if(_sl&&_sl.kind!=='gun'&&_sdk){ G.drag={key:_sdk,fromHot:_H.i}; blip('pick'); }
'@ @'
          if(_sl&&_sdk&&!(_sl.k==='gunA'||_sl.k==='gunB')){ G.drag={key:_sdk,fromHot:_H.i}; blip('pick'); }   // v11.97: a key holding a gun drags on the floor too
'@
SubRx @'
          G.drag={key:'gun_'+_hs2.icon,gunSlot:_hs2.k,fromHot:_HC2.i};
'@ @'
          G.drag={key:'gun_'+_hs2.icon,gunSlot:_hs2.k,fromHot:_HC2.i,px:mouse.x,py:mouse.y};   // v11.97: the press point, so a click is not a stow
'@

# STAMPS.
SubRx @'
var VER='11.96';
'@ @'
var VER='11.97';
'@
SubRx @'
var WHATSNEW_VER='11.96';
'@ @'
var WHATSNEW_VER='11.97';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE TACTICAL BELT DRAGS WITH THE BACKPACK CLOSED: a gun in your hands dragged off the belt goes into the backpack, and a key holding a gun moves to another key like anything else, in a raid and on the floor.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.96:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.96 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.96:[^']*'",{ param($m) "now:'v11.97: HIS NOTES of 2026-09-06, belt drags looked dead: the gun in a hand cell dragged only with the backpack open and dropped only on its panel, so closed the drag never started, and a key holding a gun could not be picked up at all. A hand gun dragged and released off the belt goes into the backpack open or closed, a click on it still only selects, and a gun key drags like any key in the raid and on the floor. Check 11.97 clicks the hand cell (no stow), drags it off the belt (stowed), and drags a gun key to another key, through the real canvas press and release; fails on v11.96.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
