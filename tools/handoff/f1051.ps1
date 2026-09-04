$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'10.50',what:'freckles, scar, mud and every beard sit clear of the eyes on the painted figure, and a boot colour paints the foot and collar, not the leg',
'@ @'
  {v:'10.51',what:'behind the terminal plinth the Undercroft shows the operator through the wall, and pinned against it he does not run in place',
   run:function(){
     var bad=[];
     if(!(window.__hubEnter&&typeof updateHubWorld==='function'&&typeof drawHubWorld==='function')) return 'SKIP: this build cannot step the floor';
     if(!(W>0&&H>0)) return 'SKIP: the pane is 0x0';
     __hubEnter(); if(!HB||!HB.player) return 'the Undercroft did not build';
     var p=HB.player, wall=null;
     for(var i=0;i<HB.walls.length;i++){ var w=HB.walls[i]; if(w.x===300&&w.y===385&&w.w===100) wall=w; }
     if(!wall) return 'the terminal plinth is not at 300,385 any more; the check needs re-aiming';
     for(var k in keys) keys[k]=false;
     // In corpus order an earlier check can leave a window open, and the floor does not simulate under one.
     var _open=[]; Array.prototype.forEach.call(document.querySelectorAll('.modal.on,#hub.on,#pausebox.on,#outcome.on'),function(el){ _open.push(el); el.classList.remove('on'); });
     var keep={x:p.x,y:p.y,face:p.face,roll:p.rollT,mov:p.moving,see:CFG.seeThrough};
     try{
       // 1. Pinned behind the plinth, walking down: he covers no ground, so he must not be walking.
       p.x=350; p.y=wall.y-p.r-0.5; p.rollT=0; p.face=1.5708;
       keys['KeyS']=true; var y0=p.y;
       for(var f=0;f<12;f++) updateHubWorld(0.016);
       keys['KeyS']=false;
       var pinnedDy=p.y-y0, pinnedMoving=p.moving;
       // 2. The open floor, walking down: he must cover ground and be walking.
       p.x=350; p.y=250; keys['KeyS']=true;
       for(f=0;f<12;f++) updateHubWorld(0.016);
       keys['KeyS']=false;
       var freeDy=p.y-250, freeMoving=p.moving;
       // 3. The see-through pass: the frame differs with the pass on and off only where a wall covers him.
       function snap(){ drawHubWorld(0); return wc.getImageData(0,0,wc.canvas.width,wc.canvas.height).data; }
       function differ(a,b){ var d=0; for(var j=0;j<a.length;j+=4) if(a[j]!==b[j]||a[j+1]!==b[j+1]||a[j+2]!==b[j+2]) d++; return d; }
       p.x=350; p.y=wall.y-p.r-0.5; p.moving=false;
       CFG.seeThrough=0; var a1=snap(); CFG.seeThrough=1; var b1=snap();
       var hidDiff=differ(a1,b1);
       p.x=350; p.y=250;
       CFG.seeThrough=0; var a2=snap(); CFG.seeThrough=1; var b2=snap();
       var openDiff=differ(a2,b2);
       if(Math.abs(pinnedDy)>0.5) bad.push('pinned behind the plinth he still moved '+pinnedDy.toFixed(1)+' units');
       if(pinnedMoving) bad.push('pinned against the plinth he runs in place: moving is true with no ground covered');
       if(freeDy<5||!freeMoving) bad.push('on the open floor he did not walk (moved '+freeDy.toFixed(1)+', moving '+freeMoving+')');
       if(hidDiff<150) bad.push('behind the plinth the see-through pass changes '+hidDiff+' pixels; he vanishes into the drawn wall top');
       if(openDiff>0) bad.push('on the open floor the see-through pass drew '+openDiff+' pixels where nothing covers him');
     } finally {
       p.x=keep.x; p.y=keep.y; p.face=keep.face; p.rollT=keep.roll; p.moving=keep.mov;
       if(keep.see===undefined) delete CFG.seeThrough; else CFG.seeThrough=keep.see;
       for(var k2 in keys) keys[k2]=false;
       for(var _o=0;_o<_open.length;_o++) _open[_o].classList.add('on');
     }
     return bad.length?bad.join('; '):null; }},
  {v:'10.50',what:'freckles, scar, mud and every beard sit clear of the eyes on the painted figure, and a boot colour paints the foot and collar, not the leg',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
