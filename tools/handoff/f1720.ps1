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

if ($s.Contains("  {v:'17.20',what:")) { throw "check 17.20 is in the fixture already" }

SubRx @'
  {v:'17.19',what:
'@ @'
  {v:'17.20',what:'a held ESC or TAB shuts one window once: at the lift with NIGHT picked, a fresh ESC or TAB on the loadout question puts the sector page back and the key repeats after it leave the sector page up with NIGHT still picked, a held ESC on the Hire nobody question leaves the bench it put back up, and a fresh ESC still shuts the sector page (menus finding 5)',
   run:function(){
     if(!(window.__hubEnter&&window.__station&&window.__state&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot reach the lift and restore the profile';
     if(typeof askKit!=='function'||typeof askRestore!=='function'||typeof openTrader!=='function') return 'SKIP: no loadout question, window restore or bench in this build';
     if(typeof ASKBACK==='undefined'||typeof IDENTITIES==='undefined'||!IDENTITIES.length) return 'SKIP: no window restore or hires in this build';
     if(typeof keys==='undefined'||typeof state==='undefined'||typeof pauseOpen==='undefined'||typeof KeyboardEvent==='undefined') return 'SKIP: no keys, screen state, pause box or keyboard events in this build';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     var sm=document.getElementById('sectormodal'), am=document.getElementById('askmodal'), aq=document.getElementById('askq');
     var cn=document.getElementById('condnight'), dp=document.getElementById('sectordeploy');
     var tm=document.getElementById('tradermodal'), mc=document.getElementById('mercclear');
     if(!sm||!am||!aq||!cn||!dp||!tm||!mc||!document.body) return 'SKIP: this build has no sector page, NIGHT button, loadout question, bench or Hire nobody in the page';
     var bad=[], snap=null, why=null, keep={y:ASKYES,a:ASKALT,b:ASKBACK,r:(typeof ASKRAND!=='undefined')?ASKRAND:null,t:(typeof ASKTOP!=='undefined')?ASKTOP:null}, codes=['Escape','Tab'], i, c;
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     function on(el){ return !!(el&&el.classList.contains('on')); }
     // keys is replaced by a fresh object on the floor, so it is looked up by name every time.
     function clearKeys(){ try{ for(var kk in keys) keys[kk]=false; }catch(_k){} }
     function shut(){ var mo=document.querySelectorAll('.modal.on'); for(var j=0;j<mo.length;j++) mo[j].classList.remove('on'); }
     // A real key lands on the body; rep marks a key repeat, the way the browser sends a held key.
     function press(code,rep){ document.body.dispatchEvent(new KeyboardEvent('keydown',{code:code,key:code,repeat:!!rep,bubbles:true,cancelable:true})); clearKeys(); }
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
       if(!on(sm)||__P().cond!=='day') return 'the lift did not open the sector page at DAY here';
       cn.click();
       if(__P().cond!=='night') return 'NIGHT on the sector page did not take here';
       dp.click();
       if(!on(am)||on(sm)) return 'ASCEND TO THIS SECTOR did not swap the sector page for the loadout question here';
       if(String(aq.textContent||'').indexOf('taking up')<0) return 'the question raised was not the loadout question here';
       return null;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       __P().autoExport=false;   // a check must not start a download
       // THE FINDING: a held ESC or TAB on the loadout question.
       for(i=0;i<codes.length;i++){
         c=codes[i];
         why=raise(); if(why) return skip(why);
         press(c,false);
         // CONTROL: the fresh key put the sector page back, on either build (v15.63).
         if(on(am)||!on(sm)) return skip('a fresh '+c+' on the loadout question did not put the sector page back here');
         press(c,true); press(c,true);
         if(!on(sm)) bad.push('holding '+c+' on the loadout question, the key repeat after it shut the sector page it had just put back, so he lands on the bare floor and the lift puts NIGHT back to DAY');
         else if(__P().cond!=='night') bad.push('holding '+c+' on the loadout question left the sector page at '+__P().cond+' rather than NIGHT');
       }
       // Hire nobody: the bench it puts back stays up under a held ESC.
       why=floor(); if(why) return skip(why);
       __P().merc=IDENTITIES[0].id;
       openTrader('hire');
       if(!on(tm)) return skip('the bench would not open here');
       mc.click();
       if(!on(am)||on(tm)) return skip('Hire nobody did not swap the bench for its question here');
       press('Escape',false);
       if(on(am)||!on(tm)) return skip('a fresh ESC on the Hire nobody question did not put the bench back here');
       press('Escape',true);
       if(!on(tm)) bad.push('holding ESC on the Hire nobody question, the key repeat shut the bench it had just put back');
       __P().merc=snap.merc;
       // CONTROL: a fresh ESC still shuts the sector page once the question is gone.
       why=raise(); if(why) return skip(why);
       press('Escape',false);
       if(!on(sm)) return skip('a fresh ESC on the loadout question did not put the sector page back for the last control here');
       press('Escape',false);
       if(on(sm)) bad.push('a fresh ESC on the sector page no longer shuts it');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       clearKeys();
       try{ var gl=__state(); if(gl&&!gl.over) __endRaid('abandon'); }catch(_e){}
       try{ if(pauseOpen) togglePauseBox(false); }catch(_pb){}
       try{ shut(); }catch(_m){}
       try{ if(typeof kitExtraHide==='function') kitExtraHide(); }catch(_kx){}
       try{ ASKYES=keep.y; ASKALT=keep.a; ASKBACK=keep.b; if(typeof ASKRAND!=='undefined'){ ASKRAND=keep.r; ASKTOP=keep.t; } }catch(_ak){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       clearKeys();
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.19',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
