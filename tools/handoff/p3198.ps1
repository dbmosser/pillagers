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

# FLOOR BACKPACK ON A PAD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(state==='hub'){
    // This branch used to assign keys
'@ @'
  if(state==='hub'){
    // v28.xx (cw-cx-floorbag): J5: the floor backpack owns the pad, using the raid bag helpers and the floor mouse path.
    if(hubBagOpen&&hubBagG){
      padRelease(); PAD.mx=0; PAD.my=0;
      if(pressed(1)&&!PAD.prev[1]) backOut();
      else if(pressed(8)&&!PAD.prev[8]) floorPadTap('KeyI');
      else withHubBag(function(){
        var dirs={12:'ArrowUp',13:'ArrowDown',14:'ArrowLeft',15:'ArrowRight'};
        for(var d in dirs) if(pressed(+d)&&!PAD.prev[d]){ raidKey(dirs[d],false,null); keys[dirs[d]]=false; }
        if(pressed(0)&&!PAD.prev[0]) bagPadAct();
        if(pressed(3)&&!PAD.prev[3]) bagDropSel();
        if(G.drag&&G.drag.pad){ var c=bagPadCell(); if(c){ mouse.x=c.x+c.w/2; mouse.y=c.y+c.h/2; } }
      });
      if(pressed(9)&&!PAD.prev[9]) floorPadTap('KeyP');
      for(var hb=0;hb<bt.length;hb++) PAD.prev[hb]=pressed(hb);
      return;
    }
    // This branch used to assign keys
'@

SubRx @'
dk=dropItem(st.idxs[st.idxs.length-1]);
'@ @'
// v28.xx (cw-cx-floorbag): Y shares bagDropSel; a hub item uses the existing recoverable floor crate, never a raid container.
  if(G.hubFloor){
    dk=st.key;
    if(!HB||!HB.player||P.stash.indexOf(dk)<0) return false;
    P.kit=G.bag.slice(); P.hotAssign=G.hotAssign||{};
    if(unpackSome(dk,1)!==null) return false;
    if(!hubDropMake(dk)) return false;
    G.bag=P.kit.slice(); G.hotAssign=P.hotAssign||{}; G.drag=null;
    if(G.pouch&&G.pouch[dk]>0) G.pouch[dk]--;
    n=bagStacks().length; if(G.bagSel>=n) G.bagSel=Math.max(0,n-1);
    return true;
  }
  dk=dropItem(st.idxs[st.idxs.length-1]);
'@

SubRx @'
    ctx.fillText((state==='hub')?(padOn()?'':'drag to tactical belt')
'@ @'
    ctx.fillText((state==='hub')?(padOn()?padB('DPAD move   A pick up or place   Y drop   B close'):'drag to tactical belt') // v28.xx (cw-cx-floorbag): J5 controls in the existing hint row.
'@

SubRx @'
else cv.dispatchEvent(new MouseEvent('mousedown',{button:0}));
'@ @'
else {
      // v28.xx (cw-cx-floorbag): the player 2 mouse handler reads client coordinates, including pad-generated presses.
      var pr=cv.getBoundingClientRect();
      cv.dispatchEvent(new MouseEvent('mousedown',{button:0,clientX:pr.left+mouse.x,clientY:pr.top+mouse.y}));
    }
'@

SubRx @'
var VER='31.97';
'@ @'
var VER='31.98';
'@

$pat = "(?m)^  now:'v31\.97:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.98: D-pad moves, A picks up and places, Y drops on the floor, and B closes the Undercroft backpack. Check 31.98 fails on v31.97',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
