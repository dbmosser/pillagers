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
  {v:'15.82',what:
'@ @'
  {v:'15.83',what:'the sector map never sits over the open stall: beside the Peddler with nothing else claiming E, a fresh M with the stall shut opens the map and a second M shuts it, direct and through the page, a held E opens the stall and then a fresh M, direct and through the page, leaves the map shut and the stall open, a fresh ESC still shuts the stall, and with the map opened first a held E opens the stall and shuts the map in the same frame (trade audit finding)',
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
     // A fresh M as the keyboard listener hands it to the raid keys, or on the real path through window; the key is let go after.
     function mKey(viaPage){
       if(viaPage) window.dispatchEvent(new KeyboardEvent('keydown',{code:'KeyM',key:'m',repeat:false,bubbles:true,cancelable:true}));
       else raidKey('KeyM',false,null);
       keys['KeyM']=false;
     }
     // The stall shut, E let go for a frame, then held for one: the stall opens on the held key.
     function open(){ g.trade=null; clearKeys(); step(); if(g.pedLock) return false; keys['KeyE']=true; step(); return g.trade===pd; }
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
       // CONTROL: with the stall shut, M opens the map and a second M shuts it, on either build: the key path is live.
       mKey(false);
       if(!g.mapOpen) return 'SKIP: M with the stall shut did not open the map here, so the key path cannot be read';
       mKey(false);
       if(g.mapOpen) return 'SKIP: a second M with the stall shut did not shut the map here';
       var page=(typeof state!=='undefined'&&state==='raid');
       if(page){
         // CONTROL: the same through the page, which proves a page press reaches the raid keys.
         mKey(true);
         if(!g.mapOpen) page=false;
         else { mKey(true); if(g.mapOpen){ g.mapOpen=false; page=false; } }
       }
       // CONTROL: a held E beside the Peddler opens the stall, on either build.
       if(!open()) return 'SKIP: E held beside the Peddler did not open the stall here';
       // THE FIX, ONE: a fresh M at the open stall leaves the map shut and the stall open.
       mKey(false);
       if(g.mapOpen) bad.push('M at the open stall put the sector map over it, hiding the stall while its keys stay live');
       if(g.trade!==pd) bad.push('M at the open stall shut the stall');
       g.mapOpen=false;
       // THE FIX, TWO: on the path a real key takes through the page.
       if(page){
         if(!open()) return skip('the stall would not reopen for the page arm here');
         mKey(true);
         if(g.mapOpen) bad.push('M sent through the page at the open stall put the sector map over it');
         g.mapOpen=false;
       }
       // GUARD: a fresh ESC at the open stall still shuts it.
       if(!open()) return skip('the stall would not reopen for the ESC arm here');
       raidKey('Escape',false,null); keys['Escape']=false;
       if(g.trade) bad.push('a fresh ESC at the open stall no longer shuts it');
       // THE FIX, THREE: the other way in. The map open first, then a held E: the stall opens and the map shuts in the same frame.
       g.trade=null; clearKeys(); step();
       if(g.pedLock) return skip('E would not let go for the map-first arm here');
       g.mapOpen=true; keys['KeyE']=true; step();
       if(g.trade!==pd) bad.push('with the map open, a held E beside the Peddler did not open the stall');
       else if(g.mapOpen) bad.push('E with the map open opened the stall under the map, hidden, with its keys live');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ clearKeys(); }catch(_k){}
       try{ if(g){ g.trade=null; g.pedLock=0; g.mapOpen=false; g.nearPed=null; g.pedBlocked=0; g.searching=null; g.searchT=0; } }catch(_t){}
       try{ for(var sh=0;sh<shut.length;sh++) shut[sh].opened=false; }catch(_o){}
       try{ if(g&&keepEnts){ g.ents.length=0; for(var ke=0;ke<keepEnts.length;ke++) g.ents.push(keepEnts[ke]); } }catch(_n){}
       try{ if(p&&keep){ p.x=keep.x; p.y=keep.y; p.iv=keep.iv; } }catch(_p){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.82',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
