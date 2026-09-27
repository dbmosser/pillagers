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

if ($s.Contains("  {v:'16.85',what:")) { throw "check 16.85 is in the fixture already" }

SubRx @'
  {v:'16.84',what:
'@ @'
  {v:'16.85',what:'a controller builds the tactical belt on the Stash screen: with a Bandage and a Medkit packed and every belt key free, A on a faked controller over the Bandage in the backpack picks it up and moves nothing, D-pad down walks the highlight onto a belt key, A there puts the Bandage on that key, with the Medkit picked up B lets it go, moves nothing and leaves the Stash screen open, and a Medkit picked up when the Stash screen closes under it is let go at the next poll with its ghost hidden',
   run:function(){
     if(typeof pollPad!=='function'||typeof padMenu!=='function'||typeof padSetFocus!=='function'||typeof padFocusables!=='function'||typeof padOpenModal!=='function'||typeof padRelease!=='function'||typeof PAD==='undefined') return 'SKIP: no pad menu in this build';
     if(typeof renderHub!=='function'||typeof ITEMS==='undefined'||!ITEMS.bandage||!ITEMS.medkit) return 'SKIP: no Stash screen, Bandage or Medkit in this build';
     if(!(window.__P&&window.__applyLoaded&&window.__hubEnter)) return 'SKIP: this fixture cannot reach the Stash screen and restore the profile';
     var hub=document.getElementById('hub'), kg=document.getElementById('kitgrid'), hpw=document.getElementById('hotplanwrap');
     if(!hub||!kg||!hpw) return 'SKIP: no Stash screen with its backpack grid and belt plan in the page';
     if(G&&!G.over) return 'SKIP: a raid is running';
     if(typeof NET!=='undefined'&&NET&&NET.same) return 'SKIP: a same machine party is on, and its controller comes from the hand-over';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing can be reached';
     var NG=navigator.getGamepads;
     if(typeof NG!=='function') return 'SKIP: this browser has no pad interface to fake';
     var bad=[], stubbed=false, snap=null, keepPad=null, hubWas=hub.classList.contains('on');
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
     function held(){ return (typeof GRAB!=='undefined')&&!!GRAB; }
     function ghostShown(){ var g=document.getElementById('grabghost'); return !!(g&&g.style.display!=='none'); }
     // The first line of a backpack cell title is the item name, then two spaces and x and the count on a stack.
     function packed(nm){ return [].slice.call(kg.querySelectorAll('.cell')).filter(function(c){ return String(c.title||'').split('\n')[0].split('  x')[0]===nm; })[0]||null; }
     function keyOf(el){ return (el&&el.getAttribute&&hpw.contains(el)&&el.getAttribute('data-plan')!==null)?+el.getAttribute('data-plan'):-1; }
     function label(){ var f=PAD.focus; if(!f) return 'nothing'; return (String(f.textContent||'').trim()||String(f.title||'').split('\n')[0]||f.id||'a control').slice(0,40); }
     function bound(){ var h=__P().hotAssign||{}, out=[]; for(var k in h) if(h[k]) out.push('key '+(+k+1)+': '+h[k]); return out.join(', ')||'none'; }
     try{
       __topClear(); if(window.__resetCfg) __resetCfg(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       keepPad={aSpent:PAD.aSpent,announced:PAD.announced,ax:PAD.ax,mrep:PAD.mrep};
       try{ __hubEnter(); }catch(_h){}
       [].forEach.call(document.querySelectorAll('.modal.on'),function(m){ m.classList.remove('on'); });   // a fresh profile opens the welcome window
       // A Bandage and a Medkit in the stash and both packed, no belt key, no freebie kit taken, on the Stash screen.
       var q=__P(); q.stash=['bandage','medkit']; q.kit=['bandage','medkit']; q.hotAssign={}; q.freeKit=0; q.kitSaved=null; q.stashTab='all';
       renderHub(); hub.classList.add('on');
       padWith(-1); pollPad();
       // CONTROL: the faked controller is seen and the Stash screen is the panel it works.
       if(!PAD.on||padOpenModal()!==hub) return 'SKIP: the faked controller does not work the Stash screen here';
       if(hub.classList.contains('freekit')) return 'SKIP: the Stash screen is greyed out here';
       if(!hpw.querySelector('[data-plan]')) return 'SKIP: the Stash screen drew no belt keys';
       var c0=packed(ITEMS.bandage.name);
       if(!c0) return 'SKIP: the backpack drew no Bandage here';
       if(padFocusables(hub).indexOf(c0)<0) return 'SKIP: the Bandage in the backpack is not in reach of the pad here';
       padSetFocus(c0); padWith(-1); pollPad();
       if(PAD.focus!==c0) return 'SKIP: the controller highlight would not stay on the Bandage here';
       // THE FIX, ONE: A on the Bandage in the backpack picks it up and moves nothing.
       tap(0);
       var k1=(__P().kit||[]).length;
       if(k1!==2) bad.push('A on the Bandage in the backpack moved it (2 packed became '+k1+') instead of picking it up');
       if(!held()) bad.push('A on the Bandage in the backpack picked nothing up');
       // THE FIX, TWO: D-pad down walks the highlight onto a belt key, and A there puts the Bandage on that key.
       var ix=-1, steps=0;
       while(ix<0&&steps<16){ tap(13); steps++; ix=keyOf(PAD.focus); }
       if(ix<0) bad.push('D-pad down from the backpack never reached a belt key in '+steps+' steps, and ended on '+label());
       else{
         if(!held()) bad.push('the Bandage was let go on the way to belt key '+(ix+1));
         tap(0);
         if((__P().hotAssign||{})[ix]!=='bandage') bad.push('A on belt key '+(ix+1)+' with the Bandage picked up did not put it there ('+bound()+')');
         if(held()) bad.push('the Bandage is still picked up after A placed it');
       }
       // THE FIX, THREE: B lets a picked up Medkit go, moves nothing and closes nothing.
       var c2=packed(ITEMS.medkit.name);
       if(!c2) bad.push('the backpack drew no Medkit for the B test ('+(__P().kit||[]).join(',')+' packed)');
       else{
         padSetFocus(c2); padWith(-1); pollPad();
         if(PAD.focus!==c2) bad.push('the controller highlight would not stay on the Medkit for the B test');
         else{
           tap(0);
           if(!held()) bad.push('A on the Medkit in the backpack picked nothing up');
           else{
             tap(1);
             if(held()) bad.push('B did not let the picked up Medkit go');
             if(!hub.classList.contains('on')) bad.push('B on a picked up Medkit closed the Stash screen');
             if((__P().kit||[]).length!==2) bad.push('B on a picked up Medkit moved it ('+(__P().kit||[]).length+' packed)');
             // THE FIX, FOUR: a Medkit picked up when the Stash screen closes under it is let go at the next poll, ghost and all.
             if(hub.classList.contains('on')&&PAD.focus===c2){
               tap(0);
               if(!held()) bad.push('A on the Medkit after B picked nothing up');
               else{
                 hub.classList.remove('on'); padWith(-1); pollPad();
                 if(held()) bad.push('the picked up Medkit outlived the Stash screen');
                 if(ghostShown()) bad.push('the ghost of the picked up Medkit stayed on screen after the Stash screen closed');
                 hub.classList.add('on');
               }
             }
           }
         }
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
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
  {v:'16.84',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
