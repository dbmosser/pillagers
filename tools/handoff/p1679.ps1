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

# PACK AND UNPACK ON A CONTROLLER (stability pass, 2026-09-27; drafted by a review agent, reviewed by a second).

SubRx @'
  if(G&&!G.over&&G.bagOpen&&G.bag.length&&bagStacks().length&&code.indexOf('Arrow')===0) keys[code]=false;
'@ @'
  // v16.79, his order: THE HIGHLIGHT WALKS ONTO THE TACTICAL BELT. With the backpack open, the v14.59 walk of up and down
  // through the stacks keeps every step but the one that wrapped it round: down past the last stack, or up before the first,
  // now lands on the belt row (an empty grid lands there at once), left and right walk along the belt, down from it starts
  // again at the first stack and up climbs back to the last. bagArrow keeps that state (G.bagBelt, G.bagBeltSel) and answers
  // true when it took the key, so the grid walk below never also moves. The pad sends the same four codes here.
  if(G&&!G.over&&G.bagOpen&&code.indexOf('Arrow')===0&&bagArrow(code)){ keys[code]=false; if(ev) ev.preventDefault(); return; }
  if(G&&!G.over&&G.bagOpen&&G.bag.length&&bagStacks().length&&code.indexOf('Arrow')===0) keys[code]=false;
'@

SubRx @'
    G.bagOpen=!G.bagOpen; G.bagSel=0; G.drag=null;   // v14.58: and B or I drops a held drag, as ESC, TAB and focus loss do
'@ @'
    G.bagOpen=!G.bagOpen; G.bagSel=0; G.drag=null;   // v14.58: and B or I drops a held drag, as ESC, TAB and focus loss do
    G.bagBelt=false;   // v16.79, his order: the highlight opens in the grid, not where it was left on the belt row
'@

SubRx @'
    PAD.prev[12]=dU; PAD.prev[13]=dD;
  } else { PAD.prev[12]=pressed(12); PAD.prev[13]=pressed(13); }
'@ @'
    PAD.prev[12]=dU; PAD.prev[13]=dD;
    // v16.79, his order: PACK AND UNPACK ON A CONTROLLER. With the backpack open D-LEFT and D-RIGHT walk along a row (the arrow
    // keys, as D-UP and D-DOWN above), A picks up the item under the highlight and A again places it, through the very mouse
    // press and release a drag uses (bagPadAct), so a belt key, a backpack cell and every rule of the mouse drop are the same.
    // While a pad drag is held the cursor sits on the highlight, so the ghost, the ringed drop target and the release land
    // where the mouse would be. These three buttons keep their own last state here: the tap loop above stamps PAD.prev for A,
    // so an edge read from it this late never fires. An A spent on a menu button (PAD.aSpent) is not a pick-up.
    var _dL=pressed(14),_dR=pressed(15),_aB=pressed(0),_bpb=PAD.bagBtn||{};
    if(_dL&&!_bpb.l){ raidKey('ArrowLeft',false,null); keys['ArrowLeft']=false; }
    if(_dR&&!_bpb.r){ raidKey('ArrowRight',false,null); keys['ArrowRight']=false; }
    if(_aB&&!_bpb.a&&!PAD.aSpent) bagPadAct();
    PAD.bagBtn={l:_dL,r:_dR,a:_aB};
    if(G.drag&&G.drag.pad){ var _bpc=bagPadCell(); if(_bpc){ mouse.x=_bpc.x+_bpc.w/2; mouse.y=_bpc.y+_bpc.h/2; } }
  } else { PAD.prev[12]=pressed(12); PAD.prev[13]=pressed(13); PAD.bagBtn={l:pressed(14),r:pressed(15),a:pressed(0)}; }
'@

SubRx @'
function backOut(){
'@ @'
// v16.79, his order: PACK AND UNPACK ON A CONTROLLER. Three helpers, all written against what the mouse already does. bagArrow
// walks the highlight between the backpack grid and the tactical belt row (G.bagBelt, G.bagBeltSel); bagPadCell is the cell
// under the highlight, in the rectangles the belt and drawBag recorded this frame; bagPadAct is pad A: with nothing held it is
// the mouse press that starts a drag from that cell, with something held it is the mouse release that drops it there, so a
// belt key, a backpack cell, the swap, the click-in-place, the unbind and every word said are the mouse rules, not a copy.
function bagArrow(code){
  var HC=G.hotCells||[], hn=HC.length, sn=bagStacks().length, bc=G.bagCols||5;
  if(!hn) return false;   // no belt drawn yet: the grid walk in raidKey keeps the key
  if(G.bagBelt){
    var bs=clamp(G.bagBeltSel||0,0,hn-1);
    if(code==='ArrowLeft'){ G.bagBeltSel=(bs-1+hn)%hn; return true; }
    if(code==='ArrowRight'){ G.bagBeltSel=(bs+1)%hn; return true; }
    if(code!=='ArrowUp'&&code!=='ArrowDown') return false;
    // the belt row sits between the last stack and the first: down starts the walk again, up climbs back to its end
    G.bagBelt=false; G.bagSel=(code==='ArrowUp'&&sn)?sn-1:0;
    return true;
  }
  if(code!=='ArrowUp'&&code!=='ArrowDown') return false;
  var sel=clamp(G.bagSel||0,0,Math.max(0,sn-1));
  // the v14.59 column walk keeps every step but the one that wrapped it round (down past the last stack, up before the
  // first); that step, or up or down in an empty grid, lands on the belt, on the key the highlight last held there
  var wrap=!sn||(code==='ArrowDown'?(sel+bc>=sn&&(sel%bc)+1>=Math.min(bc,sn)):(sel===0));
  if(!wrap) return false;
  G.bagBelt=true; G.bagBeltSel=clamp(G.bagBeltSel||0,0,hn-1);
  return true;
}
function bagPadCell(){
  if(!G||!G.bagOpen) return null;
  var HC=G.hotCells||[];
  if(G.bagBelt&&HC.length) return HC[clamp(G.bagBeltSel||0,0,HC.length-1)];
  var BC=G.bagCells||[], sel=G.bagSel||0;
  for(var i=0;i<BC.length;i++) if(BC[i].stackIx===sel) return BC[i];
  return G.bagPanel||null;   // an empty grid: the panel itself, off the belt, so a held belt item still comes off its key
}
function bagPadAct(){
  if(!G||G.over||!G.bagOpen||G.mapOpen||G.trade||(G.player&&(G.player.downed||G.player.dying))) return false;
  var C=bagPadCell();
  if(!C) return false;
  mouse.x=C.x+C.w/2; mouse.y=C.y+C.h/2;
  var had=!!G.drag;
  try{
    if(had) window.dispatchEvent(new MouseEvent('mouseup',{button:0}));
    else cv.dispatchEvent(new MouseEvent('mousedown',{button:0}));
  }catch(_pe){}
  if(!had&&G.drag) G.drag.pad=1;
  return true;
}
function backOut(){
'@

SubRx @'
      var dragOver=(G.drag&&mouse.x>=bx&&mouse.x<=bx+bw&&mouse.y>=hy&&mouse.y<=hy+bw);
'@ @'
      var dragOver=(G.drag&&mouse.x>=bx&&mouse.x<=bx+bw&&mouse.y>=hy&&mouse.y<=hy+bw)
        ||(!!G.bagOpen&&!!G.bagBelt&&q===clamp(G.bagBeltSel||0,0,sl.length-1));   // v16.79, his order: the backpack highlight on the belt row rings its key
'@

SubRx @'
      ctx.strokeStyle=(si===sel)?'#ffc04a':(RCOL[it?dispR(stacks[si].key):null]||'rgba(90,102,116,.6)');
'@ @'
      ctx.strokeStyle=(si===sel&&!G.bagBelt)?'#ffc04a':(RCOL[it?dispR(stacks[si].key):null]||'rgba(90,102,116,.6)');   // v16.79, his order: the gold ring is on the belt row while the highlight is there
'@

SubRx @'
  ctx.fillText((PAD&&PAD.on)?'VIEW to close':'B or I to close',x+PW-11,cy); ctx.textAlign='left';
'@ @'
  ctx.fillText((PAD&&PAD.on)?((state==='hub')?'VIEW to close':'A pick up or place   B close'):'B or I to close',x+PW-11,cy); ctx.textAlign='left';   // v16.79, his order: in a raid a pad packs with A and backs out on B; on the floor A does nothing to the backpack and VIEW still closes it
'@

SubRx @'
      :(PAD&&PAD.on)?'DPAD select   DPAD L drop'
'@ @'
      :(PAD&&PAD.on)?'DPAD move, past the ends to the tactical belt   A pick up or place   B close'   // v16.79, his order: D-LEFT no longer drops on a pad
'@

SubRx @'
var VER='16.78';
'@ @'
var VER='16.79';
'@

$pat = "(?m)^  now:'v16\.78:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.79: PACK AND UNPACK ON A CONTROLLER. His order: with the backpack open, A picks up the item under the highlight, D-pad down walks the stacks and past the last one lands on the tactical belt row, D-pad left and right walk the belt keys, and A places the item there or back in the backpack, exactly as a mouse drag does. B still closes the backpack. Check 16.79 fails on v16.78',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
