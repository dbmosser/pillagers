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
  {v:'15.69',what:
'@ @'
  {v:'15.70',what:'a key dragged onto a filled key on the Stash screen belt swaps the two keys, and a key on the gun in his hands can be moved like any other: on the tactical belt of the Stash screen, Medkit on key 3 dragged onto Frag Charge on key 4 leaves the Frag Charge on key 3 and the Medkit on key 4 with both still packed, the key on the Compact SMG in his hands dragged from key 5 to key 7 moves there and packs nothing, and with a spare field SMG in the stash it still moves and the spare stays unpacked, while Medkit on key 3 dragged onto an empty key 7 just moves there (grid audit finding)',
   run:function(){
     if(typeof GRAB==='undefined'||typeof grabEnd!=='function'||typeof renderHub!=='function'||typeof planPut!=='function'||typeof rackPut!=='function'||typeof packedCount!=='function') return 'SKIP: no pointer drag, belt plan or backpack count in this build';
     if(!(window.__P&&window.__applyLoaded&&window.__hubEnter)) return 'SKIP: this fixture cannot reach the Stash screen and restore the profile';
     if(typeof ITEMS==='undefined'||!ITEMS.medkit||!ITEMS.frag||!ITEMS.gun_smg||typeof WEAPONS==='undefined'||!WEAPONS.smg||!WEAPONS.pistol) return 'SKIP: no Medkit, Frag Charge or Compact SMG in this build';
     if(typeof say2!=='function') return 'SKIP: no say2 in this build';
     var hub=document.getElementById('hub');
     if(!hub||!document.getElementById('hotplanwrap')) return 'SKIP: no Stash screen or tactical belt in the page';
     var bad=[], snap=null, hubWas=hub.classList.contains('on'), s2Was=say2, said=[];
     function plan(){ return JSON.stringify(__P().hotAssign||{}); }
     function stage(o){
       var q=__P(); q.stash=o.stash.slice(); q.kit=o.kit.slice(); q.hotAssign=JSON.parse(JSON.stringify(o.hot)); q.freeKit=0;
       q.weapons=['pistol','smg']; q.equipped=o.eq||'pistol'; q.equippedSec='none';
       renderHub(); hub.classList.add('on'); said.length=0;
     }
     function cell(ix){ return document.querySelector('#hotplanwrap [data-plan="'+ix+'"]'); }
     // The centre of a belt key, only when that key is what is on top there.
     function mid(c){
       var r=c.getBoundingClientRect(); if(!(r.width>0&&r.height>0)) return null;
       var x=r.left+r.width/2, y=r.top+r.height/2, t=document.elementFromPoint(x,y);
       return (t&&t.closest&&t.closest('[data-plan]')===c)?{x:x,y:y}:null;
     }
     function ev(el,type,x,y){ el.dispatchEvent(new MouseEvent(type,{button:0,bubbles:true,cancelable:true,clientX:x,clientY:y})); }
     // A press on key fi, a move to key ti and a release there, as a hand makes it, when both keys are on screen and on top;
     // otherwise the drop on key ti is handed the item and the plan: label that the press on key fi carries. Returns why it
     // could not drag, or null.
     function drag(fi,ti){
       var a=cell(fi), b=cell(ti);
       if(!a||!b||typeof b.__grabDrop!=='function') return 'belt key '+(ti+1)+' is not a drop target';
       if(a.style.cursor!=='grab') return 'belt key '+(fi+1)+' is not a drag source';
       var pa=mid(a), pb=mid(b);
       if(pa&&pb){
         ev(a,'mousedown',pa.x,pa.y);
         if(!GRAB||GRAB.from!=='plan:'+fi) return 'a press on belt key '+(fi+1)+' did not start a drag from it';
         ev(document,'mousemove',pb.x,pb.y); ev(document,'mouseup',pb.x,pb.y);
         if(GRAB) return 'the release on belt key '+(ti+1)+' did not end the drag';
       } else b.__grabDrop(__P().hotAssign[fi],'plan:'+fi);
       return null;
     }
     try{
       __topClear(); if(window.__resetCfg) __resetCfg(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       try{ __hubEnter(); }catch(_h){}
       [].forEach.call(document.querySelectorAll('.modal.on'),function(m){ m.classList.remove('on'); });   // a fresh profile opens the welcome window
       say2=function(t){ said.push(String(t)); };
       var A={stash:['medkit','frag'],kit:['medkit','frag'],hot:{2:'medkit',3:'frag'}};
       // CONTROL: Medkit on key 3 dragged onto the empty key 7 moves there and the Frag Charge keeps key 4, on either build.
       stage(A);
       if(plan()!=='{"2":"medkit","3":"frag"}'||packedCount('medkit')!==1||packedCount('frag')!==1) return 'SKIP: the staging did not take (plan '+plan()+', '+packedCount('medkit')+' Medkit and '+packedCount('frag')+' Frag Charge packed)';
       var w0=drag(2,6);
       if(w0) return 'SKIP: '+w0+' here';
       if(plan()!=='{"3":"frag","6":"medkit"}') return 'SKIP: Medkit on key 3 dragged onto the empty key 7 gave the plan '+plan()+(said.length?(' and said "'+said.join(' | ')+'"'):'')+', so a drag between belt keys is not live here';
       // THE FINDING, case A: Medkit on key 3 dragged onto the Frag Charge on key 4 swaps the two keys, and both stay packed.
       stage(A);
       var w1=drag(2,3);
       if(w1) bad.push('the drag onto a filled key could not be driven: '+w1);
       else {
         if(plan()!=='{"2":"frag","3":"medkit"}') bad.push('Medkit on key 3 dragged onto the Frag Charge on key 4 gave the plan '+plan()+', not the Frag Charge on key 3 and the Medkit on key 4: the Frag Charge lost its key');
         if(packedCount('medkit')!==1||packedCount('frag')!==1) bad.push('the drag onto a filled key left '+packedCount('medkit')+' Medkit and '+packedCount('frag')+' Frag Charge packed, not one of each');
       }
       // THE FINDING, case B: the key on the Compact SMG in his hands, dragged from key 5 to key 7, moves and packs nothing.
       stage({stash:[],kit:[],hot:{4:'gun_smg'},eq:'smg'});
       if(plan()!=='{"4":"gun_smg"}') bad.push('control: the key on the SMG in his hands did not stay on key 5 when the Stash screen was drawn (plan '+plan()+')');
       else {
         var w2=drag(4,6);
         if(w2) bad.push('the key on the gun in his hands could not be driven: '+w2);
         else {
           if(plan()!=='{"6":"gun_smg"}') bad.push('the key on the SMG in his hands dragged from key 5 to key 7 left the plan '+plan()+(said.length?(' and said "'+said.join(' | ')+'"'):'')+', where it should have moved to key 7');
           if((__P().kit||[]).length) bad.push('moving the key on the SMG in his hands packed '+__P().kit.join(', '));
           if(__P().equipped!=='smg'||(__P().weapons||[]).indexOf('smg')<0) bad.push('moving the key took the SMG out of his hands');
         }
       }
       // THE FINDING, case B with a spare field SMG in the stash: the key moves and the spare stays unpacked.
       stage({stash:['gun_smg'],kit:[],hot:{4:'gun_smg'},eq:'smg'});
       if(plan()!=='{"4":"gun_smg"}') bad.push('control: with a spare SMG in the stash the key on the SMG in his hands did not stay on key 5 (plan '+plan()+')');
       else {
         var w3=drag(4,6);
         if(w3) bad.push('the key on the gun in his hands, with a spare in the stash, could not be driven: '+w3);
         else {
           if(plan()!=='{"6":"gun_smg"}') bad.push('with a spare SMG in the stash, the key on the SMG in his hands dragged from key 5 to key 7 left the plan '+plan());
           if(packedCount('gun_smg')) bad.push('moving the key on the SMG in his hands packed '+packedCount('gun_smg')+' spare field SMG from the stash, which would go up the lift unasked');
           if((__P().stash||[]).indexOf('gun_smg')<0||(__P().weapons||[]).indexOf('smg')<0||__P().equipped!=='smg') bad.push('moving the key moved the spare SMG or the SMG in his hands');
         }
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ say2=s2Was; }catch(_s){}
       try{ if(GRAB) grabEnd(); }catch(_g){}
       try{ if(typeof GRABSKIP!=='undefined') GRABSKIP=null; }catch(_gs){}
       try{ if(typeof mouse!=='undefined'&&mouse) mouse.down=false; }catch(_m){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ if(hubWas){ renderHub(); hub.classList.add('on'); } else hub.classList.remove('on'); }catch(_hb){}
       try{ __topClear(); if(window.__resetCfg) __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.69',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
