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
  {v:'15.62',what:
'@ @'
  {v:'15.63',what:'backing out of the loadout question returns to the sector page: at the lift with NIGHT picked on the sector page and ASCEND TO THIS SECTOR pressed, TAB, ESC and Not yet on What are you taking up each put the sector page back with NIGHT still picked and no other window open, the way TAB on the Hire nobody question puts the bench back, and MY LOADOUT and FREEBIE KIT still ascend with the sector page down over the raid (menus audit finding)',
   run:function(){
     if(!(window.__hubEnter&&window.__station&&window.__state&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot reach the lift and restore the profile';
     if(typeof askKit!=='function'||typeof askRestore!=='function'||typeof ascendNow!=='function'||typeof openTrader!=='function') return 'SKIP: no loadout question, window restore, ascent or bench in this build';
     if(typeof ASKBACK==='undefined'||typeof IDENTITIES==='undefined'||!IDENTITIES.length) return 'SKIP: no window restore or hires in this build';
     if(typeof keys==='undefined'||typeof state==='undefined'||typeof pauseOpen==='undefined') return 'SKIP: no keys, screen state or pause box in this build';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     var sm=document.getElementById('sectormodal'), am=document.getElementById('askmodal'), aq=document.getElementById('askq');
     var cn=document.getElementById('condnight'), dp=document.getElementById('sectordeploy');
     var ay=document.getElementById('askyes'), al=document.getElementById('askalt'), an=document.getElementById('askno');
     var tm=document.getElementById('tradermodal'), mc=document.getElementById('mercclear');
     if(!sm||!am||!aq||!cn||!dp||!ay||!al||!an||!tm||!mc) return 'SKIP: this build has no sector page, NIGHT button, loadout question with its three answers, bench or Hire nobody in the page';
     var bad=[], snap=null, why=null, keep={y:ASKYES,a:ASKALT,b:ASKBACK};
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     function on(el){ return !!(el&&el.classList.contains('on')); }
     // keys is replaced by a fresh object on the floor and on an instant quit, so it is looked up by name every time.
     function clearKeys(){ try{ for(var kk in keys) keys[kk]=false; }catch(_k){} }
     function shut(){ var mo=document.querySelectorAll('.modal.on'); for(var i=0;i<mo.length;i++) mo[i].classList.remove('on'); }
     function tab(){ window.dispatchEvent(new KeyboardEvent('keydown',{code:'Tab',key:'Tab',bubbles:true,cancelable:true})); clearKeys(); }
     // On the floor with every window shut (a fresh profile opens the welcome window) and the pause box down.
     function floor(){
       __topClear(); __hubEnter(); shut(); clearKeys();
       if(state!=='hub') return 'the Undercroft floor did not open';
       if(pauseOpen){ try{ togglePauseBox(false); }catch(_p){} }
       if(pauseOpen) return 'the pause box would not shut on the floor';
       return null;
     }
     // The lift, NIGHT on the sector page, then ASCEND TO THIS SECTOR: the question raised the way he raises it.
     function raise(){
       var w=floor(); if(w) return w;
       var r=__station('lift');
       if(!r||r.err) return 'the lift has no E act here';
       // CONTROL: the lift opened the sector page at DAY.
       if(!on(sm)||__P().cond!=='day') return 'the lift did not open the sector page at DAY here';
       cn.click();
       // CONTROL: NIGHT took.
       if(__P().cond!=='night') return 'NIGHT on the sector page did not take here';
       dp.click();
       // CONTROL: the loadout question is up and the sector page it was asked from is down.
       if(!on(am)||on(sm)) return 'ASCEND TO THIS SECTOR did not swap the sector page for the loadout question here';
       if(String(aq.textContent||'').indexOf('taking up')<0) return 'the question raised was not the loadout question here';
       return null;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       __P().autoExport=false;   // a check must not start a download
       // CONTROL A: TAB on the Hire nobody question puts the bench back, on either build, so the window restore and the TAB
       // path work here and only the loadout question went without them.
       why=floor(); if(why) return 'SKIP: '+why;
       __P().merc=IDENTITIES[0].id;
       openTrader('hire');
       if(!on(tm)) return 'SKIP: the bench would not open here';
       mc.click();
       if(!on(am)||on(tm)) return 'SKIP: Hire nobody did not swap the bench for its question here';
       tab();
       if(on(am)||!on(tm)) return 'SKIP: TAB on the Hire nobody question did not put the bench back here, so the window restore cannot be read here';
       __P().merc=snap.merc;
       // THE FINDING: each way of backing out of the loadout question, raised from the sector page with NIGHT picked.
       var OUT=[['TAB',tab],
                ['Not yet',function(){ an.click(); clearKeys(); }],
                ['ESC',function(){ document.body.dispatchEvent(new KeyboardEvent('keydown',{code:'Escape',key:'Escape',bubbles:true,cancelable:true})); clearKeys(); }]];
       for(var i=0;i<OUT.length;i++){
         why=raise(); if(why) return skip(why);
         OUT[i][1]();
         // CONTROL: the key or the button took the question down, on either build.
         if(on(am)) return skip(OUT[i][0]+' did not take the loadout question down here');
         if(!on(sm)){ bad.push(OUT[i][0]+' on the loadout question left him on the bare floor rather than on the sector page he asked it from, so getting the page back means the lift again, which puts his NIGHT back to DAY'); continue; }
         if(__P().cond!=='night') bad.push(OUT[i][0]+' put the sector page back at '+__P().cond+' rather than the NIGHT he picked');
         var mo=document.querySelectorAll('.modal.on');
         if(mo.length!==1) bad.push(OUT[i][0]+' put the sector page back with '+(mo.length-1)+' other windows open');
         if(ASKBACK!==null) bad.push(OUT[i][0]+' closed the question with '+ASKBACK+' still named to come back');
       }
       // CONTROL B: MY LOADOUT and FREEBIE KIT still ascend, and the sector page they put back first is down over the raid.
       var UP=[['MY LOADOUT',ay],['FREEBIE KIT',al]];
       for(var j=0;j<UP.length;j++){
         why=raise(); if(why) return skip(why);
         UP[j][1].click(); clearKeys();
         var g=__state();
         if(state!=='raid'||!g||g.over) bad.push(UP[j][0]+' on the loadout question did not ascend: the page is in '+state);
         else {
           if(on(sm)) bad.push(UP[j][0]+' ascended with the sector page still up over the raid');
           if(document.querySelectorAll('.modal.on').length) bad.push(UP[j][0]+' ascended with a window still open over the raid');
         }
         // Straight back down: an abandon with no time, distance, search or shot is thrown away with no card.
         try{ if(g&&!g.over) __endRaid('abandon'); }catch(_q){}
         clearKeys(); __topClear();
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       clearKeys();
       try{ var gl=__state(); if(gl&&!gl.over) __endRaid('abandon'); }catch(_e){}
       try{ if(pauseOpen) togglePauseBox(false); }catch(_pb){}
       try{ shut(); }catch(_m){}
       try{ ASKYES=keep.y; ASKALT=keep.a; ASKBACK=keep.b; }catch(_ak){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       clearKeys();
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.62',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
