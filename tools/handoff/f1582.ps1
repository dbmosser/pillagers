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
  {v:'15.81',what:
'@ @'
  {v:'15.82',what:'holding E at the Peddler keeps the stall open: beside the Peddler with nothing else claiming E, one frame with E held opens the stall, the first key repeat of E as the keyboard listener hands it over, with the key still down, leaves the stall open and so does the frame after, a held repeat sent through the page leaves it open, while a fresh E sent through the page still closes it and holds the key, and a fresh ESC still closes it (trade audit finding)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy, end a raid and restore the profile';
     if(typeof updatePlayer!=='function'||typeof raidKey!=='function'||typeof mkPeddler!=='function'||typeof dist!=='function') return 'SKIP: no player update, raid keys, Peddler or distance in this build';
     if(typeof keys==='undefined'||typeof mouse==='undefined'||typeof KeyboardEvent==='undefined') return 'SKIP: no keys, mouse or keyboard events in this build';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     var bad=[], g=null, p=null, pd=null, snap=null, keep=null, keepEnts=null, shut=[];
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     function clearKeys(){ for(var kk in keys) keys[kk]=false; mouse.down=false; }
     function step(){ p.iv=99; updatePlayer(1/60); }
     // E as the keyboard listener hands it to the raid keys: rep marks a key repeat, and a page press takes the real path through window.
     function key(rep,viaPage){
       if(viaPage) window.dispatchEvent(new KeyboardEvent('keydown',{code:'KeyE',key:'e',repeat:!!rep,bubbles:true,cancelable:true}));
       else raidKey('KeyE',!!rep,null);
     }
     // E let go for a frame, then held for one: the stall opens on the held key and E stays down, the way he holds it.
     function open(){ clearKeys(); step(); if(g.pedLock) return false; keys['KeyE']=true; step(); return g.trade===pd; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       p=g.player;
       keep={x:p.x,y:p.y,iv:p.iv};
       clearKeys();
       p.downed=false; p.dying=false; p.roll=0;
       g.bagOpen=false; g.mapOpen=false; g.emoteBar=false; g.drag=null; g.trade=null; g.pedLock=0; g.searching=null; g.searchT=0;
       // Only the Peddler, 40 units to his right, and no unopened crate near enough to take E from the stall.
       keepEnts=g.ents.slice(); g.ents.length=0;
       for(var ci=0;ci<g.containers.length;ci++){ var CU=g.containers[ci]; if(!CU.opened&&dist(CU,p)<60){ CU.opened=true; shut.push(CU); } }
       pd=mkPeddler(p.x+40,p.y,g.map); g.ents.push(pd);
       // CONTROL: a frame with no key finds the Peddler and nothing else claims E.
       step();
       if(g.nearPed!==pd) return 'SKIP: the Peddler 40 units away was not found beside him here';
       if(g.pedBlocked||g.nearContainer) return 'SKIP: something at his feet already claims E here';
       // CONTROL: one frame with E held opens the stall, on either build.
       if(!open()) return 'SKIP: E held beside the Peddler did not open the stall here';
       // THE FIX, ONE: the first key repeat, E still down, as the listener hands it over.
       key(true,false);
       if(g.trade!==pd) bad.push('holding E at the Peddler, the first key repeat (about half a second in) shut the stall the held press had just opened');
       else { step(); if(g.trade!==pd) bad.push('a frame after the held E repeat, with E still down, the stall was shut'); }
       // THE FIX, TWO: on the path a real key takes through the page.
       if(typeof state!=='undefined'&&state==='raid'){
         if(!open()) return skip('the stall would not reopen for the page arm here');
         // GUARD: a fresh E sent through the page still closes the open stall and holds the key, which also proves the page path reaches the raid keys.
         key(false,true);
         if(g.trade) bad.push('a fresh E at the open stall no longer closes it');
         else if(g.pedLock!==1) bad.push('a fresh E that closed the stall did not hold the key, so the stall would reopen on the next frame');
         else {
           if(!open()) return skip('the stall would not reopen after the fresh press here');
           key(true,true);
           if(g.trade!==pd) bad.push('a held E repeat sent through the page shut the open stall');
         }
       }
       // GUARD: a fresh ESC still closes the stall.
       if(!open()) return skip('the stall would not reopen for the ESC arm here');
       raidKey('Escape',false,null);
       if(g.trade) bad.push('a fresh ESC at the open stall no longer closes it');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ clearKeys(); }catch(_k){}
       try{ if(g){ g.trade=null; g.pedLock=0; g.nearPed=null; g.pedBlocked=0; g.searching=null; g.searchT=0; } }catch(_t){}
       try{ for(var sh=0;sh<shut.length;sh++) shut[sh].opened=false; }catch(_o){}
       try{ if(g&&keepEnts){ g.ents.length=0; for(var ke=0;ke<keepEnts.length;ke++) g.ents.push(keepEnts[ke]); } }catch(_n){}
       try{ if(p&&keep){ p.x=keep.x; p.y=keep.y; p.iv=keep.iv; } }catch(_p){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.81',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
