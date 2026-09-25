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
  {v:'15.67',what:
'@ @'
  {v:'15.68',what:'dragging a backpack stack and letting go on its own cell moves nothing: on the Stash screen with two Medkits packed, a press on the Medkit stack in the backpack, a drag toward the stash and back, and a release and click on that same cell leave both packed and both in the stash, while a plain click on the stack leaves one behind, before the drag and after it (grid audit finding)',
   run:function(){
     if(typeof GRAB==='undefined'||typeof grabEnd!=='function'||typeof renderHub!=='function'||typeof packedCount!=='function') return 'SKIP: no pointer drag or backpack grid in this build';
     if(!(window.__P&&window.__applyLoaded&&window.__hubEnter)) return 'SKIP: this fixture cannot reach the Stash screen and restore the profile';
     if(typeof ITEMS==='undefined'||!ITEMS.medkit) return 'SKIP: no Medkit in this build';
     var hub=document.getElementById('hub'), kg=document.getElementById('kitgrid');
     if(!hub||!kg) return 'SKIP: no Stash screen or backpack grid in the page';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing can be pressed';
     var bad=[], snap=null, hubWas=hub.classList.contains('on'), nm=ITEMS.medkit.name;
     function held(){ var s=__P().stash||[], c=0; for(var i=0;i<s.length;i++) if(s[i]==='medkit') c++; return c; }
     function stage(){ var q=__P(); q.stash=['medkit','medkit']; q.kit=['medkit','medkit']; q.hotAssign={}; q.freeKit=0; renderHub(); hub.classList.add('on'); }
     // The Medkit stack in the backpack and its centre, only when that centre is on screen and the cell is what is there.
     function aim(){
       var c=kg.querySelector('.cell:not(.slotempty)');
       if(!c||String(c.title||'').indexOf(nm)!==0) return null;
       var r=c.getBoundingClientRect(); if(!(r.width>0&&r.height>0)) return null;
       var x=r.left+r.width/2, y=r.top+r.height/2, t=document.elementFromPoint(x,y);
       if(!(t&&t.closest&&t.closest('.cell')===c)) return null;
       return {c:c,x:x,y:y};
     }
     function ev(el,type,x,y){ el.dispatchEvent(new MouseEvent(type,{button:0,bubbles:true,cancelable:true,clientX:x,clientY:y,detail:(type==='mousemove'?0:1)})); }
     // A plain click, as a hand makes it: press, release and click on the same point with no movement.
     function press(a){ ev(a.c,'mousedown',a.x,a.y); ev(a.c,'mouseup',a.x,a.y); ev(a.c,'click',a.x,a.y); }
     try{
       __topClear(); if(window.__resetCfg) __resetCfg(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       try{ __hubEnter(); }catch(_h){}
       [].forEach.call(document.querySelectorAll('.modal.on'),function(m){ m.classList.remove('on'); });   // a fresh profile opens the welcome window
       stage();
       var a0=aim();
       if(!a0) return 'SKIP: the packed Medkit stack is not on screen and on top in the backpack here';
       // CONTROL: two packed and two held, and a plain click on the stack leaves one behind, on either build.
       if(packedCount('medkit')!==2||held()!==2) return 'SKIP: the staging did not take ('+packedCount('medkit')+' packed, '+held()+' held)';
       press(a0);
       if(packedCount('medkit')!==1) return 'SKIP: a plain click on the packed Medkit stack left '+packedCount('medkit')+' packed, not 1, so the click is not live here';
       // THE FINDING: press the stack, drag it toward the stash, bring it back and let go on its own cell.
       stage();
       var a1=aim();
       if(!a1) return 'SKIP: the packed Medkit stack is not on screen and on top after staging again';
       var sg=document.getElementById('stashgrid'), sr=sg?sg.getBoundingClientRect():null;
       var mx=(sr&&sr.width>0)?sr.left+sr.width/2:a1.x+120, my=(sr&&sr.height>0)?sr.top+Math.min(40,sr.height/2):a1.y+120;
       ev(a1.c,'mousedown',a1.x,a1.y);
       // CONTROL: the press started a drag.
       if(!GRAB) return 'SKIP: a press on the packed Medkit stack did not start a drag here';
       ev(document,'mousemove',mx,my);
       ev(document,'mousemove',a1.x,a1.y);
       ev(a1.c,'mouseup',a1.x,a1.y);
       // CONTROL: the release ended the drag, so nothing is left armed when the click arrives.
       if(GRAB) return 'SKIP: the release did not end the drag here';
       if(packedCount('medkit')!==2) return 'SKIP: the release itself moved a Medkit ('+packedCount('medkit')+' packed), so it did not land on the backpack here';
       ev(a1.c,'click',a1.x,a1.y);
       var n1=packedCount('medkit');
       if(n1!==2) bad.push('a Medkit stack pressed in the backpack, dragged toward the stash and let go on its own cell left '+n1+' packed, not 2: the click after the drag unpacked one with no word');
       if(held()!==2) bad.push('the drag and release on its own cell left '+held()+' Medkits in the stash, not 2');
       // AND THE NEXT REAL CLICK STILL WORKS: a plain click on the stack after that drag leaves one behind.
       if(!bad.length){
         var a2=aim();
         if(!a2) bad.push('after the drag the packed Medkit stack is no longer on screen and on top in the backpack');
         else {
           press(a2);
           if(packedCount('medkit')!==1) bad.push('after a drag let go on its own cell, a plain click on the stack left '+packedCount('medkit')+' packed, not 1');
         }
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(GRAB) grabEnd(); }catch(_g){}
       try{ if(typeof GRABSKIP!=='undefined') GRABSKIP=null; }catch(_gs){}
       try{ if(typeof mouse!=='undefined'&&mouse) mouse.down=false; }catch(_m){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ if(hubWas){ renderHub(); hub.classList.add('on'); } else hub.classList.remove('on'); }catch(_hb){}
       try{ __topClear(); if(window.__resetCfg) __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.67',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
