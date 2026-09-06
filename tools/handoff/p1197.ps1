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
# the backpack". Three faults. A drag drew nothing but a highlight on the
# cell under the cursor, so with the backpack closed it looked like nothing
# happened. The gun in a hand cell could be picked up only with the backpack
# open and dropped only on its panel. And a belt key holding a gun (kind gun,
# not a hand cell) could not be picked up at all.
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
      // v11.97, HIS NOTE: released anywhere that is not a belt cell, it goes into
      // the backpack, open or closed. A release on its own cell is a click.
      var _onCell=false;
      if(G.hotCells) for(var _gc=0;_gc<G.hotCells.length;_gc++){ var _GC=G.hotCells[_gc]; if(mouse.x>=_GC.x&&mouse.x<=_GC.x+_GC.w&&mouse.y>=_GC.y&&mouse.y<=_GC.y+_GC.h){ _onCell=true; break; } }
      if(!_onCell) bagHeldGun(d.gunSlot);
      d={key:null}; dropped=true;
    }
'@
SubRx @'
    ctx.fillText(sl[sel].name+'   [FIRE] use    [V] signal',W/2,hy-LH(6));
    ctx.textAlign='left';
  }
'@ @'
    ctx.fillText(sl[sel].name+'   [FIRE] use    [V] signal',W/2,hy-LH(6));
    ctx.textAlign='left';
    // v11.97, HIS NOTE: THE GHOST. A drag drew nothing but a highlight on the cell
    // under the cursor, so with the backpack closed it looked like nothing had
    // happened. The item rides the cursor now, open or closed.
    if(G&&G.drag&&G.drag.key&&ITEMS[G.drag.key]){ ctx.globalAlpha=.85; drawItemIcon(ctx,G.drag.key,mouse.x+LH(10),mouse.y+LH(10),LH(26)); ctx.globalAlpha=1; }
  }
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
  'THE TACTICAL BELT DRAGS WITH THE BACKPACK CLOSED: the item rides the cursor, a gun in your hands dragged off the belt goes into the backpack, and a key holding a gun moves to another key like anything else.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.96:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.96 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.96:[^']*'",{ param($m) "now:'v11.97: HIS NOTES of 2026-09-06, belt drags in a raid looked dead: no ghost was drawn, the gun in a hand cell dragged only with the backpack open and dropped only on its panel, and a key holding a gun could not be picked up. The dragged item rides the cursor, a hand gun released anywhere off the belt goes into the backpack open or closed, and a gun key drags like any key. Check 11.97 presses the hand cell with the backpack closed and releases off the belt, then drags an assigned gun key to another key, through the real canvas press and release; fails on v11.96.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
