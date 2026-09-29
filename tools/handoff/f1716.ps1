$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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

if ($s.Contains("  {v:'17.16',what:")) { throw "check 17.16 is in the fixture already" }

SubRx @'
  {v:'17.15',what:
'@ @'
  {v:'17.16',what:'a controller puts an armoury gun in a hand on the Stash screen: with gun A in gun 1 and gun B spare, A on gun B and A again in place opens the gun menu a right-click opens, the pad works that menu, A on its first row makes gun B gun 1 and it stays in the armoury, and on the menu opened again B shuts it, changes nothing, keeps the Stash screen open and puts the highlight back on gun B (stash hunt finding)',
   run:function(){
     if(typeof pollPad!=='function'||typeof padMenu!=='function'||typeof padSetFocus!=='function'||typeof padFocusables!=='function'||typeof padOpenModal!=='function'||typeof padRelease!=='function'||typeof stashPadAct!=='function'||typeof PAD==='undefined') return 'SKIP: no pad menu or pad grab in this build';
     if(typeof openGunMenu!=='function'||typeof renderHub!=='function'||typeof WEAPONS==='undefined') return 'SKIP: no armoury gun menu in this build';
     if(!(window.__P&&window.__applyLoaded&&window.__hubEnter)) return 'SKIP: this fixture cannot reach the Stash screen and restore the profile';
     var hub=document.getElementById('hub'), sg=document.getElementById('stashgrid');
     if(!hub||!sg) return 'SKIP: no Stash screen with its stash grid in the page';
     if(G&&!G.over) return 'SKIP: a raid is running';
     if(typeof NET!=='undefined'&&NET&&NET.same) return 'SKIP: a same machine party is on, and its controller comes from the hand-over';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing can be reached';
     var gA=null, gB=null, k;
     for(k in WEAPONS){ if(k==='fists'||!ITEMS['gun_'+k]) continue; if(!gA) gA=k; else if(!gB){ gB=k; break; } }
     if(!gA||!gB) return 'SKIP: fewer than two guns with an item form to stage';
     var NG=navigator.getGamepads;
     if(typeof NG!=='function') return 'SKIP: this browser has no pad interface to fake';
     var nm=WEAPONS[gB].name, bad=[], stubbed=false, snap=null, keepPad=null, hubWas=hub.classList.contains('on');
     try{ navigator.getGamepads=function(){ return []; }; stubbed=(navigator.getGamepads!==NG); }catch(_s){}
     if(!stubbed){ try{ navigator.getGamepads=NG; }catch(_r0){} return 'SKIP: this browser will not let the pad be faked'; }
     function padWith(down){
       var bts=[],i;
       for(i=0;i<17;i++) bts.push({pressed:(i===down),value:(i===down)?1:0,touched:(i===down)});
       var fake={connected:true,id:'probe pad',index:0,mapping:'standard',timestamp:1,axes:[0,0,0,0],buttons:bts};
       navigator.getGamepads=function(){ return [fake]; };
     }
     // One press of that button and its release, one poll each, the way a hand taps it.
     function tap(b){ padWith(b); pollPad(); padWith(-1); pollPad(); }
     function menu(){ return document.querySelector('.imenu'); }
     function held(){ return (typeof GRAB!=='undefined')&&!!GRAB; }
     function gunCell(){
       var cs=[].slice.call(sg.querySelectorAll('.cell'));
       for(var i=0;i<cs.length;i++) if(cs[i].style.cursor==='grab'&&String(cs[i].title||'').split('\n')[0]===nm) return cs[i];
       return null;
     }
     function label(){ var f=PAD.focus; if(!f) return 'nothing'; return (String(f.textContent||'').trim()||String(f.title||'').split('\n')[0]||f.id||'a control').slice(0,40); }
     function home(){ var q=__P(); return (q.weapons||[]).indexOf(gB)>=0&&(q.stash||[]).indexOf('gun_'+gB)<0; }
     try{
       __topClear(); if(window.__resetCfg) __resetCfg(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       keepPad={aSpent:PAD.aSpent,announced:PAD.announced,ax:PAD.ax,mrep:PAD.mrep};
       try{ __hubEnter(); }catch(_h){}
       [].forEach.call(document.querySelectorAll('.modal.on'),function(m){ m.classList.remove('on'); });   // a fresh profile opens the welcome window
       // Gun A in gun 1, gun B a spare in the armoury, gun 2 empty, nothing in the stash, the GUNS tab, no freebie kit.
       var q=__P(); q.weapons=[gA,gB]; q.equipped=gA; q.equippedSec='none'; q.stash=[]; q.kit=[]; q.hotAssign={}; q.freeKit=0; q.kitSaved=null; q.stashTab='gun';
       renderHub(); hub.classList.add('on');
       padWith(-1); pollPad();
       // CONTROL: the faked controller is seen and the Stash screen is the panel it works.
       if(!PAD.on||padOpenModal()!==hub) return 'SKIP: the faked controller does not work the Stash screen here';
       if(hub.classList.contains('freekit')) return 'SKIP: the Stash screen is greyed out here';
       var c0=gunCell();
       if(!c0) return 'SKIP: the armoury drew no cell for the '+nm;
       if(padFocusables(hub).indexOf(c0)<0) return 'SKIP: the armoury '+nm+' is not in reach of the pad here';
       padSetFocus(c0); padWith(-1); pollPad();
       if(PAD.focus!==c0) return 'SKIP: the controller highlight would not stay on the armoury '+nm+' here';
       // CONTROL: A on the armoury gun picks it up.
       tap(0);
       if(!(held()&&GRAB.from==='rack')) bad.push('control: A on the armoury '+nm+' picked nothing up');
       else{
         // THE FIX, ONE: A again in place opens the gun menu, and the pad works it.
         tap(0);
         var m=menu();
         if(held()) bad.push('A again in place left the '+nm+' picked up');
         if(!m) bad.push('A and A again in place on the armoury '+nm+' opened no gun menu, so a controller cannot put it in gun 1 or gun 2');
         else{
           if(padOpenModal()!==m) bad.push('the open gun menu is not the panel the pad works');
           if(!(PAD.focus&&m.contains(PAD.focus))) bad.push('with the gun menu open the pad highlight is on '+label()+', not on a row of the menu');
           else{
             // THE FIX, TWO: A on the first live row puts gun B in gun 1.
             tap(0);
             if(menu()) bad.push('A on the first row of the gun menu left the menu open');
             if(__P().equipped!==gB) bad.push('A on the first row of the gun menu did not put the '+nm+' in gun 1 (gun 1 is '+__P().equipped+')');
           }
         }
       }
       if(!home()) bad.push('the '+nm+' left the armoury');
       // THE FIX, THREE: on the menu opened again, B shuts it, changes nothing and gives the highlight back to the gun.
       if(!bad.length){
         var c1=gunCell();
         if(!c1) bad.push('the armoury drew no cell for the '+nm+' once it was in gun 1');
         else{
           padSetFocus(c1); padWith(-1); pollPad();
           tap(0); tap(0);
           if(!menu()) bad.push('A and A again in place on the '+nm+' in gun 1 opened no gun menu');
           else{
             tap(1);
             if(menu()) bad.push('B did not shut the gun menu');
             if(!hub.classList.contains('on')) bad.push('B on the gun menu closed the Stash screen');
             padWith(-1); pollPad();
             if(PAD.focus!==gunCell()) bad.push('after B shut the gun menu the pad highlight is on '+label()+', not back on the '+nm);
             if(__P().equipped!==gB||(__P().equippedSec||'none')!=='none') bad.push('B on the gun menu changed the guns in hand to '+__P().equipped+' and '+__P().equippedSec);
             if(!home()) bad.push('B on the gun menu moved the '+nm+' out of the armoury');
           }
         }
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(typeof closeItemMenu==='function') closeItemMenu(); }catch(_cm){}
       try{ if(typeof grabEnd==='function') grabEnd(); }catch(_g){}
       try{ navigator.getGamepads=function(){ return []; }; pollPad(); }catch(_p0){}
       try{ padSetFocus(null); PAD.focus=null; PAD.focusIx=-1; PAD.focusMd=null; padRelease(); }catch(_pr){}
       try{ navigator.getGamepads=NG; }catch(_p){}
       try{ if(keepPad){ PAD.aSpent=keepPad.aSpent; PAD.announced=keepPad.announced; PAD.ax=keepPad.ax; PAD.mrep=keepPad.mrep; } }catch(_kp){}
       try{ if(window.__keysRef){ var K3=__keysRef(); for(var k3 in K3) K3[k3]=false; } }catch(_k){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ if(typeof renderStage==='function') renderStage(); }catch(_st){}
       try{ if(hubWas){ renderHub(); hub.classList.add('on'); } else hub.classList.remove('on'); }catch(_hb){}
       try{ __topClear(); if(window.__resetCfg) __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.15',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
