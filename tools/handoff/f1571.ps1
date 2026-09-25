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
  {v:'15.70',what:
'@ @'
  {v:'15.71',what:'with the freebie kit taken a controller cannot pack or unpack in the greyed out stash and backpack: on the Stash screen with one Medkit in the stash and nothing packed, A on a faked controller over TAKE THE FREEBIE KIT greys the stash and backpack out so the mouse cannot touch the Medkit, and then no greyed out control is in reach of the controller highlight, D-pad up from USE MY OWN GEAR does not walk into them, a highlight put on the Medkit moves off it and nothing is packed, while USE MY OWN GEAR and CLOSE stay in reach, and with no freebie kit taken the Medkit is in reach of the mouse and the controller as before (grid audit finding)',
   run:function(){
     if(typeof pollPad!=='function'||typeof padMenu!=='function'||typeof padSetFocus!=='function'||typeof padFocusables!=='function'||typeof padOpenModal!=='function'||typeof PAD==='undefined') return 'SKIP: no pad menu in this build';
     if(typeof renderHub!=='function'||typeof renderFreeKit!=='function'||typeof packedCount!=='function'||typeof ITEMS==='undefined'||!ITEMS.medkit) return 'SKIP: no Stash screen, freebie kit or Medkit in this build';
     if(!(window.__P&&window.__applyLoaded&&window.__hubEnter)) return 'SKIP: this fixture cannot reach the Stash screen and restore the profile';
     var hub=document.getElementById('hub'), sg=document.getElementById('stashgrid'), grid=hub?hub.querySelector('.hubgrid'):null, cl=document.getElementById('stashclose');
     if(!hub||!sg||!grid||!cl||!document.getElementById('hubfreekit')) return 'SKIP: no Stash screen with its grid, CLOSE and freebie kit in the page';
     if(G&&!G.over) return 'SKIP: a raid is running, and the freebie kit is taken in the Undercroft';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing can be reached';
     var NG=navigator.getGamepads;
     if(typeof NG!=='function') return 'SKIP: this browser has no pad interface to fake';
     var bad=[], stubbed=false, snap=null, keepPad=null, hubWas=hub.classList.contains('on'), nm=ITEMS.medkit.name+'  x';
     try{ navigator.getGamepads=function(){ return []; }; stubbed=(navigator.getGamepads!==NG); }catch(_s){}
     if(!stubbed){ try{ navigator.getGamepads=NG; }catch(_r0){} return 'SKIP: this browser will not let the pad be faked'; }
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     function padWith(down){
       var bts=[],i;
       for(i=0;i<17;i++) bts.push({pressed:(i===down),value:(i===down)?1:0,touched:(i===down)});
       var fake={connected:true,id:'probe pad',index:0,mapping:'standard',timestamp:1,axes:[0,0,0,0],buttons:bts};
       navigator.getGamepads=function(){ return [fake]; };
     }
     // One press of that button and its release, one poll each, the way a hand taps it.
     function tap(b){ padWith(b); pollPad(); padWith(-1); pollPad(); }
     function cell(){ return [].slice.call(sg.querySelectorAll('.cell')).filter(function(c){ return String(c.title||'').indexOf(nm)===0; })[0]||null; }
     // Whether the mouse lands on that cell at its centre: true, false, or null when it is not laid out.
     function mouseOn(c){
       var r=c.getBoundingClientRect(); if(!(r.width>0&&r.height>0)) return null;
       var t=document.elementFromPoint(r.left+r.width/2,r.top+r.height/2);
       return !!(t&&(t===c||c.contains(t)));
     }
     function inGrid(el){ return !!(el&&grid.contains(el)); }
     function label(){ var f=PAD.focus; if(!f) return 'nothing'; return '"'+(String(f.textContent||'').trim()||String(f.title||'').split('\n')[0]||f.id||'a control').slice(0,40)+'"'; }
     try{
       __topClear(); if(window.__resetCfg) __resetCfg(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       keepPad={aSpent:PAD.aSpent,announced:PAD.announced,ax:PAD.ax,mrep:PAD.mrep};
       try{ __hubEnter(); }catch(_h){}
       [].forEach.call(document.querySelectorAll('.modal.on'),function(m){ m.classList.remove('on'); });   // a fresh profile opens the welcome window
       // One Medkit in the stash, nothing packed, no belt key and no freebie kit taken, on the Stash screen.
       var q=__P(); q.stash=['medkit']; q.kit=[]; q.hotAssign={}; q.freeKit=0; q.kitSaved=null; q.stashTab='all';
       renderHub(); hub.classList.add('on');
       padWith(-1); pollPad();
       // CONTROL: the faked controller is seen and the Stash screen is the panel it works.
       if(!PAD.on||padOpenModal()!==hub) return 'SKIP: the faked controller does not work the Stash screen here';
       var c0=cell();
       if(!c0) return 'SKIP: the stash drew no Medkit stack here';
       // CONTROL: with no freebie kit taken the Medkit is under the mouse and in reach of the pad, on either build.
       if(hub.classList.contains('freekit')) return 'SKIP: the Stash screen is greyed out with no freebie kit taken here';
       if(mouseOn(c0)!==true) return 'SKIP: the Medkit in the stash is not on screen and on top for the mouse here';
       if(padFocusables(hub).indexOf(c0)<0) return 'SKIP: with no freebie kit taken the Medkit in the stash is not in reach of the pad here, so the reach cannot be compared';
       // TAKE THE FREEBIE KIT with A on the faked controller.
       var fb=hub.querySelector('#hubfreekit .fkbtn');
       if(!fb) return 'SKIP: the Stash screen drew no freebie kit button';
       padSetFocus(fb); pollPad();
       if(PAD.focus!==fb) return 'SKIP: the controller highlight would not stay on TAKE THE FREEBIE KIT here';
       tap(0);
       // CONTROL: the kit is taken, nothing is packed, and the stash is greyed out: the mouse cannot touch the Medkit.
       if(__P().freeKit!==1||!hub.classList.contains('freekit')) return 'SKIP: A on TAKE THE FREEBIE KIT did not take the freebie kit here';
       if(packedCount('medkit')!==0) return 'SKIP: taking the freebie kit left '+packedCount('medkit')+' Medkits packed here';
       var c1=cell();
       if(!c1) return 'SKIP: the stash drew no Medkit stack after the freebie kit was taken';
       var m1=mouseOn(c1);
       if(m1!==false) return 'SKIP: with the freebie kit taken the Medkit in the stash is '+(m1===null?'not laid out':'still under the mouse')+' here, so the stash is not greyed out for the mouse';
       // THE FIX, ONE: nothing greyed out is in reach of the controller highlight, and the two live controls still are.
       var L=padFocusables(hub), inG=0, i;
       for(i=0;i<L.length;i++) if(inGrid(L[i])) inG++;
       if(L.indexOf(c1)>=0) bad.push('with the freebie kit taken the greyed out Medkit in the stash, which the mouse cannot touch, is still in reach of the controller highlight ('+inG+' greyed out controls in reach in all)');
       else if(inG) bad.push('with the freebie kit taken '+inG+' greyed out controls in the stash and backpack are still in reach of the controller highlight');
       var fb1=hub.querySelector('#hubfreekit .fkbtn');
       if(!fb1||L.indexOf(fb1)<0) bad.push('with the freebie kit taken USE MY OWN GEAR is out of reach of the controller');
       if(L.indexOf(cl)<0) bad.push('with the freebie kit taken CLOSE is out of reach of the controller');
       // THE FIX, TWO: D-pad up from USE MY OWN GEAR, three times, never lands in the greyed out panel.
       if(fb1){
         padSetFocus(fb1); padWith(-1); pollPad();
         var walked=null;
         for(i=0;i<3&&!walked;i++){ tap(12); if(inGrid(PAD.focus)) walked=label(); }
         if(walked) bad.push('with the freebie kit taken D-pad up from USE MY OWN GEAR walks the controller highlight onto '+walked+' in the greyed out stash and backpack');
       }
       // THE FIX, THREE: a highlight put on the Medkit moves off it at the next poll, so no A can reach it. Where it stays in the
       // greyed out panel, the A a hand would press next is pressed, to show what it does there.
       var c2=cell();
       if(!c2) return skip('the stash drew no Medkit stack for the highlight');
       padSetFocus(c2); padWith(-1); pollPad();
       if(PAD.focus===c2||inGrid(PAD.focus)){
         var at=label(), k0=packedCount('medkit');
         tap(0);
         bad.push('with the freebie kit taken a controller highlight put on the greyed out Medkit in the stash stays in the greyed out panel on '+at+', and A there took the packed Medkits from '+k0+' to '+packedCount('medkit')+', in a backpack the freebie kit leaves behind');
       }
       if(!bad.length&&packedCount('medkit')!==0) bad.push('with the freebie kit taken '+packedCount('medkit')+' Medkits ended up packed');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ navigator.getGamepads=function(){ return []; }; pollPad(); }catch(_p0){}
       try{ padSetFocus(null); PAD.focus=null; PAD.focusIx=-1; PAD.focusMd=null; padRelease(); }catch(_pr){}
       try{ navigator.getGamepads=NG; }catch(_p){}
       try{ if(keepPad){ PAD.aSpent=keepPad.aSpent; PAD.announced=keepPad.announced; PAD.ax=keepPad.ax; PAD.mrep=keepPad.mrep; } }catch(_kp){}
       try{ var K3=__keysRef(); for(var k3 in K3) K3[k3]=false; }catch(_k){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ renderFreeKit(); }catch(_rf){}
       try{ if(typeof renderStage==='function') renderStage(); }catch(_st){}
       try{ if(hubWas){ renderHub(); hub.classList.add('on'); } else hub.classList.remove('on'); }catch(_hb){}
       try{ __topClear(); if(window.__resetCfg) __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.70',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
