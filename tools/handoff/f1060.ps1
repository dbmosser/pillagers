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
  {v:'10.59',what:'seen through a wall in a raid, the operator is painted in his own colours, faded, and not as a light-blue cutout',
'@ @'
  {v:'10.60',what:'walls are opaque by default, and over a minute of the Undercroft no body and not the operator ever stands inside the rectangle a wall paints',
   run:function(){
     var bad=[];
     if(!(window.__hubEnter&&window.__hubStep&&window.__hub)) return 'SKIP: this build cannot step the floor';
     if(typeof CFG==='undefined') return 'SKIP: no config';
     // 1. The dial that paints a see-through copy of you is off out of the box.
     __resetCfg();
     if(CFG.seeThrough!==0) bad.push('walls still go transparent by default (seeThrough is '+CFG.seeThrough+')');
     __hubEnter();
     var H=__hub(); if(!H||!H.crowd||!H.walls) return 'the Undercroft did not build';
     if(!H.dwalls||H.dwalls.length!==H.walls.length) bad.push('the room does not know what its walls paint');
     var _open=[]; Array.prototype.forEach.call(document.querySelectorAll('.modal.on,#hub.on,#pausebox.on,#outcome.on'),function(el){ _open.push(el); el.classList.remove('on'); });
     for(var k in keys) keys[k]=false;
     // 2. The painted rectangle of every wall, worked out here from the collider
     //    and the same lift the renderer uses, so this cannot inherit a mistake
     //    from the list the game builds.
     var PIC=[];
     for(var i=0;i<H.walls.length;i++){ var w=H.walls[i], L=(w.w<=60&&w.h<=60)?14:26; PIC.push({x:w.x,y:w.y-L,w:w.w,h:w.h+L,src:w}); }
     function inPicture(b){
       var r=(b.r||12)*0.5;
       for(var j=0;j<PIC.length;j++){ var q=PIC[j];
         var cx=Math.max(q.x,Math.min(b.x,q.x+q.w)), cy=Math.max(q.y,Math.min(b.y,q.y+q.h));
         if(Math.hypot(b.x-cx,b.y-cy)<r) return q; }
       return null;
     }
     var hits=0, first=null, whom={}, p=H.player, pHits=0;
     try{
       for(var s=0;s<1200;s++){
         __hubStep(0.05);
         for(i=0;i<H.crowd.length;i++){
           var c=H.crowd[i]; if(c.away>0) continue;
           var q2=inPicture(c);
           if(q2){ hits++; whom[i]=1;
             if(!first) first='body '+i+(c.post?' (a post holder)':'')+' at '+Math.round(c.x)+','+Math.round(c.y)+' inside the picture of the wall at '+q2.src.x+','+q2.src.y+' '+q2.src.w+'x'+q2.src.h+', at step '+s; }
         }
         if(inPicture(p)) pHits++;
       }
     } finally { for(var o=0;o<_open.length;o++) _open[o].classList.add('on'); }
     if(hits) bad.push('over 1200 steps of the room, people stood inside a wall picture '+hits+' times ('+Object.keys(whom).length+' of '+H.crowd.length+' bodies); first: '+first);
     if(pHits) bad.push('the operator stood inside a wall picture '+pHits+' times');
     return bad.length?bad.join('; '):null; }},
  {v:'10.59',what:'seen through a wall in a raid, the operator is painted in his own colours, faded, and not as a light-blue cutout',
'@

# v10.51 was written when the operator could stand inside the plinth's picture
# and was shown through it. He has asked for opaque walls, so the see-through
# half of that check is gone and the pin moves to the edge of the PICTURE, which
# is where he is stopped now. The running-in-place half is untouched.
SubRx @'
  {v:'10.51',what:'behind the terminal plinth the Undercroft shows the operator through the wall, and pinned against it he does not run in place',
'@ @'
  {v:'10.51',what:'pinned against the terminal plinth the operator covers no ground and does not run in place, and on the open floor he walks',
'@
SubRx @'
       // 1. Pinned behind the plinth, walking down: he covers no ground, so he must not be walking.
       p.x=350; p.y=wall.y-p.r-0.5; p.rollT=0; p.face=1.5708;
'@ @'
       // 1. Pinned behind the plinth, walking down: he covers no ground, so he must not be walking.
       // v10.60: against the edge of what the plinth PAINTS, which is where he stops now.
       var _L51=(wall.w<=60&&wall.h<=60)?14:26;
       p.x=350; p.y=wall.y-_L51-p.r-0.5; p.rollT=0; p.face=1.5708;
'@
SubRx @'
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
'@ @'
       if(Math.abs(pinnedDy)>0.5) bad.push('pinned behind the plinth he still moved '+pinnedDy.toFixed(1)+' units');
'@
SubRx @'
       if(freeDy<5||!freeMoving) bad.push('on the open floor he did not walk (moved '+freeDy.toFixed(1)+', moving '+freeMoving+')');
       if(hidDiff<150) bad.push('behind the plinth the see-through pass changes '+hidDiff+' pixels; he vanishes into the drawn wall top');
       if(openDiff>0) bad.push('on the open floor the see-through pass drew '+openDiff+' pixels where nothing covers him');
'@ @'
       if(freeDy<5||!freeMoving) bad.push('on the open floor he did not walk (moved '+freeDy.toFixed(1)+', moving '+freeMoving+')');
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
