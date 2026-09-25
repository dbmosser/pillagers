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
  {v:'15.68',what:
'@ @'
  {v:'15.69',what:'a click on the Medical key of the Undercroft belt never binds a Bandage: on the floor with the backpack open and no keys set, where the Medical key shows a Bandage, a press and release on it binds nothing with two Medkits packed and binds nothing with a Bandage and a Medkit packed, a drag from it to key 9 with two Medkits packed binds nothing, and a Medkit on key 8 pressed and let go just off the top of the belt stays on key 8, while the Medkit tile dropped on key 8 still binds it and key 8 dragged well off the belt still lets it go (grid audit finding)',
   run:function(){
     if(!(window.__P&&window.__applyLoaded&&window.__hubEnter)) return 'SKIP: this fixture cannot reach the floor and restore the profile';
     if(typeof hubBagOpenSet!=='function'||typeof drawHubBag!=='function'||typeof withHubBag!=='function'||typeof hotbarSlots!=='function') return 'SKIP: no Undercroft backpack or belt in this build';
     if(typeof cv==='undefined'||!cv||typeof mouse==='undefined'||!mouse) return 'SKIP: no canvas or mouse state in this build';
     if(typeof ITEMS==='undefined'||!ITEMS.medkit||!ITEMS.bandage) return 'SKIP: no Medkit or Bandage in this build';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live, so the floor backpack cannot be driven';
     var bad=[], snap=null, mx0=mouse.x, my0=mouse.y, MK=['medkit','medkit'];
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     var show=function(o){ return JSON.stringify(o||{}); };
     // The floor backpack staged with the given kit and keys; hubBagG and the profile share one key map, as on the floor.
     function stage(bag,assign){ hubBagG.bag=bag.slice(); hubBagG.hotAssign=assign; __P().hotAssign=assign; hubBagG.drag=null; drawHubBag(); }
     function slots(){ var r=null; withHubBag(function(){ r=hotbarSlots(); }); return r||[]; }
     function cellAt(i){ var hc=hubBagG.hotCells||[]; for(var k=0;k<hc.length;k++) if(hc[k].i===i) return hc[k]; return null; }
     function onBelt(x,y){ var hc=hubBagG.hotCells||[]; for(var k=0;k<hc.length;k++){ var c=hc[k]; if(x>=c.x&&x<=c.x+c.w&&y>=c.y&&y<=c.y+c.h) return true; } return false; }
     // The mouse handlers read mouse.x and mouse.y, not the event, so the pointer is placed and the press and release dispatched
     // where the game listens: the press on the canvas, the release on the window.
     function press(x,y){ mouse.down=false; mouse.x=x; mouse.y=y; cv.dispatchEvent(new MouseEvent('mousedown',{button:0,bubbles:true,cancelable:true})); }
     function release(x,y){ mouse.x=x; mouse.y=y; window.dispatchEvent(new MouseEvent('mouseup',{button:0,bubbles:true,cancelable:true})); }
     function keysNow(){ return __P().hotAssign||{}; }
     function nKeys(o){ var c=0; for(var k in o) c++; return c; }
     try{
       __topClear(); if(window.__runPrep) __runPrep(); if(window.__resetCfg) __resetCfg(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       hubBagG=null; hubBagOpen=false;
       try{ __hubEnter(); }catch(_h){}
       if(state!=='hub') return 'SKIP: the fixture did not reach the Undercroft floor (state '+state+')';
       [].forEach.call(document.querySelectorAll('.modal.on'),function(m){ m.classList.remove('on'); });   // a fresh profile opens the welcome window
       var q=__P(); q.stash=['medkit','medkit','bandage']; q.kit=MK.slice(); q.hotAssign={};
       hubBagOpenSet(true);
       if(!hubBagOpen||!hubBagG) return 'SKIP: the Undercroft backpack did not open';
       stage(MK,{});
       var hc=hubBagG.hotCells||[], sl=slots();
       if(hc.length!==9||sl.length!==9) return 'SKIP: the floor belt drew '+hc.length+' keys here, not 9';
       var mi=-1;
       for(var i=0;i<sl.length;i++) if(sl[i]&&sl[i].k==='heal'){ mi=i; break; }
       if(mi<0) return 'SKIP: the floor belt shows no Medical key here';
       if(mi===7||mi===8||!sl[7]||sl[7].kind!=='empty'||!sl[8]||sl[8].kind!=='empty') return 'SKIP: keys 8 and 9 are not empty on the floor belt here';
       var M=cellAt(mi), K8=cellAt(7), K9=cellAt(8);
       if(!M||!K8||!K9||!(M.w>0&&M.h>0&&K8.w>0&&K8.h>0&&K9.w>0&&K9.h>0)) return 'SKIP: the floor belt drew no Medical, key 8 or key 9 cell to press';
       if(K8.h*4<=30) return 'SKIP: the belt keys are drawn too small here to tell a drag from a click';
       // THE STATE OF THE FINDING: the floor player is at full health, so Medical shows the Bandage fallback over two Medkits.
       if(sl[mi].icon!=='bandage'||hubBagG.bag.indexOf('bandage')>=0) return 'SKIP: the Medical key shows '+sl[mi].icon+' here rather than a Bandage he does not carry, so the finding cannot be staged';
       var tile=null, bc=hubBagG.bagCells||[];
       for(var b=0;b<bc.length;b++) if(bc[b]&&bc[b].key==='medkit'){ tile=bc[b]; break; }
       if(!tile) return 'SKIP: the Undercroft backpack drew no Medkit tile to drag';
       // CONTROL: the Medkit tile dropped on key 8 binds it, so the floor press and drop are live, on either build.
       press(tile.x+tile.w/2,tile.y+tile.h/2);
       if(!hubBagG.drag||hubBagG.drag.key!=='medkit') return 'SKIP: a press on the Medkit tile started no drag here';
       release(K8.x+K8.w/2,K8.y+K8.h/2);
       if(hubBagG.drag) return 'SKIP: the release did not reach the floor drop here';
       if(hubBagG.hotAssign[7]!=='medkit'||keysNow()[7]!=='medkit') return 'SKIP: the Medkit tile dropped on key 8 did not bind it here ('+show(keysNow())+')';
       // CONTROL: key 8 pressed and dragged well off the belt lets the Medkit go, so the off the belt release is live, on either build.
       stage(MK,{7:'medkit'}); K8=cellAt(7);
       var fx=K8.x+K8.w/2, fy=K8.y-4*K8.h;
       if(onBelt(fx,fy)) return 'SKIP: the point well above key 8 is on the belt here';
       press(K8.x+K8.w/2,K8.y+K8.h/2);
       if(!hubBagG.drag||hubBagG.drag.key!=='medkit'||hubBagG.drag.fromHot!==7) return 'SKIP: a press on key 8 holding a Medkit started no drag from it here';
       release(fx,fy);
       if(keysNow()[7]!==undefined) return 'SKIP: key 8 dragged well off the belt kept its Medkit here, so a kept key would prove nothing';
       // THE FINDING: a press and release on the Medical key, with two Medkits packed and no Bandage.
       stage(MK,{}); M=cellAt(mi);
       press(M.x+M.w/2,M.y+M.h/2);
       // CONTROL: the floor belt claimed the press, so it never reached the trigger (only an unclaimed press sets mouse.down).
       if(mouse.down) return 'SKIP: the press on the Medical key was not claimed by the floor belt here';
       release(M.x+M.w/2,M.y+M.h/2);
       var a1=keysNow();
       if(nKeys(a1)) bad.push('a click on the Medical key (key '+(mi+1)+') of the Undercroft belt, with two Medkits packed and no Bandage, bound and saved '+show(a1)+', so the key shows a Bandage he does not carry and Medical is gone');
       if(hubBagG.drag) bad.push('the click on the Medical key left a drag held');
       // A drag from the Medical key to the empty key 9.
       stage(MK,{}); M=cellAt(mi); K9=cellAt(8);
       press(M.x+M.w/2,M.y+M.h/2);
       release(K9.x+K9.w/2,K9.y+K9.h/2);
       var a2=keysNow();
       if(nKeys(a2)) bad.push('the Medical key dragged to key 9, with two Medkits packed and no Bandage, bound and saved '+show(a2)+', a Bandage he does not carry');
       // A click on key 8 holding a Medkit that slips 12 units, just off the top of the belt, keeps the Medkit on key 8.
       stage(MK,{7:'medkit'}); K8=cellAt(7);
       var sx=K8.x+K8.w/2, sy0=K8.y+3, sy1=K8.y-9;
       if(onBelt(sx,sy1)) return skip('the point just above key 8 is on the belt here, so the slip cannot be staged');
       press(sx,sy0);
       if(!hubBagG.drag||hubBagG.drag.fromHot!==7) return skip('a press near the top of key 8 started no drag from it here');
       release(sx,sy1);
       if(keysNow()[7]!=='medkit') bad.push('a click on key 8 that slipped 12 units off the top of the belt took the Medkit off key 8 ('+show(keysNow())+'), where the raid keeps it');
       // A click on the Medical key with a Bandage packed: the press picks the Bandage up on either build, so this measures the
       // release on its own key by itself.
       stage(['bandage','medkit'],{}); var sl4=slots(); M=cellAt(mi);
       if(!M||!sl4[mi]||sl4[mi].k!=='heal'||sl4[mi].icon!=='bandage') return skip('with a Bandage packed the Medical key is not on key '+(mi+1)+' showing a Bandage here');
       press(M.x+M.w/2,M.y+M.h/2);
       // CONTROL: the press armed a Bandage drag from the Medical key, so a key left unbound is the release doing nothing.
       if(!hubBagG.drag||hubBagG.drag.key!=='bandage'||hubBagG.drag.fromHot!==mi) return skip('with a Bandage packed a press on the Medical key started no Bandage drag here');
       release(M.x+M.w/2,M.y+M.h/2);
       var a4=keysNow();
       if(nKeys(a4)) bad.push('a click on the Medical key with a Bandage and a Medkit packed bound and saved '+show(a4)+', so Medical is gone from key '+(mi+1)+' and the Medkit has no key');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       // Shut without the commit, so the staged kit is never kept; the snapshot below puts the profile back.
       try{ if(hubBagG) hubBagG.drag=null; hubBagG=null; hubBagOpen=false; }catch(_hb){}
       try{ mouse.x=mx0; mouse.y=my0; mouse.down=false; }catch(_m){}
       try{ if(snap&&state==='hub'){ var mo=document.querySelectorAll('.modal.on'); for(var mj=0;mj<mo.length;mj++) mo[mj].classList.remove('on'); } }catch(_mo){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); if(window.__resetCfg) __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.68',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
