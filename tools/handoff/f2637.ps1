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

if ($s.Contains("  {v:'26.37',what:")) { throw "check 26.37 is in the fixture already" }

SubRx @'
  {v:'26.36',what:
'@ @'
  {v:'26.37',what:'gunkeys2, his order: the Stash screen has a GUN KEYS plate (a tile for each key 1 to 9, dragged onto another it swaps the two classes) and a WHEEL plate (the eight ring places, dragged onto another they swap), both kept on the profile; the next raid puts the Longshot on the key the stash gave the Sniper and the wheel reads the stash order; RESET puts his table and his order back; the tiles are controls for the pad',
   run:function(){
     if(!(window.__P&&window.__applyLoaded&&window.__hubEnter&&window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot reach the Stash screen and a raid';
     if(typeof kitSetupRender!=='function'||typeof wheelOrderOf!=='function') return 'this build has no stash setup';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live';
     var hub=document.getElementById('hub');
     if(!hub||!document.getElementById('kitsetup')) return 'this page has no stash setup plates';
     var bad=[], snap=null, hubWas=hub.classList.contains('on'), g=null, p=null, gk0=null, wo0=null, j, t, a, b, ws, pins;
     function tile(sel,ix){ return document.querySelector('#kitsetup '+sel+'="'+ix+'"]'); }
     function pin(k){ var y; for(y in g.hotAssign) if(g.hotAssign[y]===k) return +y; return -1; }
     function hubOn(){ P.freeKit=0; renderHub(); hub.classList.add('on'); }
     function raid(){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       if(gk0) P.gunKeys=gk0.slice(); if(wo0) P.wheelOrder=wo0.slice();
       __deploy({kit:['gun_sniper'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return false;
       p=g.player; p.iv=99; g.ents.length=0; g.paused=false; g.trade=null; g.bagOpen=false; g.mapOpen=false; g.wheel=null; p.hand=null; keys={}; mouse.down=false;
       return true;
     }
     function wheelKeys(){ var w; g.bag=['bandage','medkit','stim','plate']; g.pouch.frag=1; g.pouch.smoke=1; g.pouch.decoy=1; g.pouch.trip=1; g.wheel=null; if(!wheelOpen()||!g.wheel) return 'closed'; w=g.wheel.list.map(function(q){ return q.k; }).join(','); g.wheel=null; return w; }
     try{
       __topClear(); if(window.__resetCfg) __resetCfg(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(P));
       try{ __hubEnter(); }catch(_h){}
       [].forEach.call(document.querySelectorAll('.modal.on'),function(m){ m.classList.remove('on'); });
       // ONE: the plates stand at his table and his order
       delete P.gunKeys; delete P.wheelOrder; hubOn();
       if(document.querySelectorAll('#kitsetup [data-gk]').length!==9) bad.push('ONE: the GUN KEYS plate has '+document.querySelectorAll('#kitsetup [data-gk]').length+' tiles, not 9');
       if(document.querySelectorAll('#kitsetup [data-wh]').length!==8) bad.push('ONE: the WHEEL plate has '+document.querySelectorAll('#kitsetup [data-wh]').length+' tiles, not 8');
       a=tile('[data-gk',7); if(!a||!/SNIPER/.test(a.textContent||'')) bad.push('ONE: key 8 is not the Sniper tile ('+(a&&a.textContent)+')');
       a=tile('[data-wh',0); if(!a||!/MEDKIT/.test(a.textContent||'')) bad.push('ONE: the top place is not the Medkit tile ('+(a&&a.textContent)+')');
       // TWO: a drag of the Sniper tile onto key 2 swaps the classes, and the plate is drawn again
       a=tile('[data-gk',7); b=tile('[data-gk',1);
       if(!a||!b||typeof b.__grabDrop!=='function') return bad.concat(['TWO: the key tiles are not drag and drop']).join('; ');
       a.dispatchEvent(new MouseEvent('mousedown',{button:0,cancelable:true,clientX:5,clientY:5}));
       if(!GRAB||GRAB.from!=='gk:7') bad.push('TWO: pressing the key 8 tile started no drag ('+(GRAB&&GRAB.from)+')');
       b.__grabDrop(GRAB?GRAB.key:'gkc:sniper','gk:7'); try{ grabEnd(); }catch(_g){}
       if(!P.gunKeys||P.gunKeys[1]!=='sniper'||P.gunKeys[7]!=='smg') bad.push('TWO: after the drop the table reads '+JSON.stringify(P.gunKeys));
       b=tile('[data-gk',1); if(!b||!/SNIPER/.test(b.textContent||'')) bad.push('TWO: key 2 is not drawn as the Sniper after the swap');
       a=tile('[data-wh',7); b=tile('[data-wh',0);
       if(!a||!b||typeof b.__grabDrop!=='function') return bad.concat(['TWO: the wheel tiles are not drag and drop']).join('; ');
       b.__grabDrop('whl:stim','wh:7');
       if(!P.wheelOrder||P.wheelOrder[0]!=='stim'||P.wheelOrder[7]!=='medkit') bad.push('TWO: after the drop the order reads '+JSON.stringify(P.wheelOrder));
       gk0=P.gunKeys?P.gunKeys.slice():null; wo0=P.wheelOrder?P.wheelOrder.slice():null;
       // THREE: the tiles are controls for the pad
       if(typeof padFocusables==='function'&&(!window.__vpAlive||__vpAlive())){
         ws=padFocusables(hub); t=0; for(j=0;j<ws.length;j++) if(ws[j].classList&&ws[j].classList.contains('kst')) t++;
         if(t!==17) bad.push('THREE: the pad reaches '+t+' of the 17 setup tiles');
       }
       try{ __applyLoaded(snap); }catch(_r){}
       // FOUR: the next raid reads them: the Longshot on key 2, the wheel in the stash order; and the old behaviour in DEMO
       if(!raid()) return bad.concat(['SKIP: staging: no raid']).join('; ');
       if(pin('gun_sniper')!==1) bad.push('FOUR: a Longshot packed for the raid sits on key '+(pin('gun_sniper')+1)+', not 2 (keys '+JSON.stringify(g.hotAssign)+')');
       ws=wheelKeys(); if(ws!=='stim,smoke,frag,trip,plate,decoy,bandage,medkit') bad.push('FOUR: the raid wheel reads '+ws+', not the stash order');
       g.arcade=1; ws=wheelKeys(); g.arcade=0;
       if(ws!=='medkit,smoke,frag,trip,plate,decoy,bandage,stim') bad.push('FOUR: the DEMO wheel did not read his order ('+ws+')');
       try{ if(!g.over){ p.iv=0; __endRaid('abandon'); } }catch(_e1){}
       __topClear();
       // FIVE: RESET puts his table and his order back, and the raid follows
       try{ __applyLoaded(snap); }catch(_r2){}
       if(gk0) P.gunKeys=gk0.slice(); if(wo0) P.wheelOrder=wo0.slice(); hubOn();
       a=document.getElementById('gkreset'); b=document.getElementById('whreset');
       if(!a||!b) bad.push('FIVE: no RESET buttons');
       else {
         a.click(); b.click();
         if(P.gunKeys!==undefined||P.wheelOrder!==undefined) bad.push('FIVE: RESET left the profile with '+JSON.stringify(P.gunKeys)+' and '+JSON.stringify(P.wheelOrder));
         a=tile('[data-gk',7); if(!a||!/SNIPER/.test(a.textContent||'')) bad.push('FIVE: key 8 is not the Sniper tile again after RESET');
       }
       gk0=null; wo0=null;
       try{ __applyLoaded(snap); }catch(_r3){}
       if(!raid()) return bad.concat(['SKIP: staging: no raid']).join('; ');
       if(pin('gun_sniper')!==7) bad.push('FIVE: after RESET a Longshot sits on key '+(pin('gun_sniper')+1)+', not 8');
       ws=wheelKeys(); if(ws!=='medkit,smoke,frag,trip,plate,decoy,bandage,stim') bad.push('FIVE: after RESET the wheel reads '+ws);
       // SIX: a table or an order that is not whole is not read
       P.gunKeys=['sniper','sniper','rifle','carbine','lmg','shotgun','marksman','smg','energy']; P.wheelOrder=['stim','stim','frag','trip','plate','decoy','bandage','medkit'];
       if(gunKeyTable()[0]!=='pistol'||wheelOrderTable()[0]!=='medkit') bad.push('SIX: a table with a class twice or an order with an item twice was read');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(typeof GRAB!=='undefined'&&GRAB&&typeof grabEnd==='function') grabEnd(); }catch(_g){}
       try{ mouse.down=false; keys={}; if(g) g.arcade=0; var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; g2.wheel=null; __endRaid('abandon'); } }catch(_e){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ if(hubWas){ renderHub(); hub.classList.add('on'); } else hub.classList.remove('on'); }catch(_hb){}
       try{ __topClear(); if(window.__resetCfg) __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'26.36',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
