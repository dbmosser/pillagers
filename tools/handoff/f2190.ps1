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

if ($s.Contains("  {v:'21.90',what:")) { throw "check 21.90 is in the fixture already" }

SubRx @'
  {v:'21.89',what:
'@ @'
  {v:'21.90',what:'the gun keys after the review of 21.83: on the Undercroft floor with a Medkit on key 1, gun 2 stays on key 2 and gun 1 on a later key, and dragging gun 1 onto key 1 moves the Medkit off (v18.91); with no gun 1 the floor shows Bare Hands on key 1 and gun 2 on key 2; the raid starts on the same keys, and a gun drawn into the stowed slot takes the key of the gun it pushed out, not the gun in his hands; a backpack gun dropped on the key of an issued loaner replaces the loaner, so his own gun 2 stays in his hands and no line says the loaner has no key',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__state||!window.__P||!window.__applyLoaded||!window.__hubEnter) return 'SKIP: this fixture cannot deploy a raid or reach the floor';
     if(typeof hotbarSlots!=='function'||typeof gunKeysSettle!=='function'||typeof equipFromBag!=='function'||typeof gunCell!=='function'||typeof hubBagOpenSet!=='function'||typeof drawHubBag!=='function'||typeof withHubBag!=='function'||typeof hubBagState!=='function') return 'SKIP: no gun keys or floor belt here';
     if(!WEAPONS.rifle||!WEAPONS.smg||!WEAPONS.shotgun||!ITEMS.gun_rifle||!ITEMS.gun_smg||!ITEMS.gun_shotgun||!ITEMS.medkit||!WEAPONS.fists) return 'SKIP: no rifle, smg, shotgun or medkit here';
     if(typeof cv==='undefined'||!cv||typeof mouse==='undefined'||!mouse) return 'SKIP: no canvas or mouse in this build';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live';
     var bad=[], snap=null, snap2=null, mx0=mouse.x, my0=mouse.y, md0=mouse.down, s0=say, said=[], g=null, p=null, i, sl, q;
     function gid(c){ return String((c&&c.icon)||'').replace(/^gun_/,''); }
     function desc(c){ if(!c) return 'nothing'; var n=(c.itemKey&&!/^gun_/.test(c.itemKey))?c.itemKey:(gid(c)||'nothing'); return n+(c.vacant?' (vacant)':(c.inHand?' in hand':'')); }
     function held(id){ return !!((p.wep&&p.wep.id===id)||(p.sec&&p.sec.id===id)); }
     function fslots(){ var r=null; withHubBag(function(){ r=hotbarSlots(); }); return r||[]; }
     function cellAt(ix){ var hc=hubBagG.hotCells||[]; for(var j=0;j<hc.length;j++) if(hc[j].i===ix) return hc[j]; return null; }
     function press(x,y){ mouse.down=false; mouse.x=x; mouse.y=y; cv.dispatchEvent(new MouseEvent('mousedown',{button:0,bubbles:true,cancelable:true})); }
     function release(x,y){ mouse.x=x; mouse.y=y; window.dispatchEvent(new MouseEvent('mouseup',{button:0,bubbles:true,cancelable:true})); }
     // 1. THE FLOOR: a Medkit on key 1.
     try{
       __topClear(); if(window.__runPrep) __runPrep(); if(window.__resetCfg) __resetCfg(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       hubBagG=null; hubBagOpen=false;
       try{ __hubEnter(); }catch(_h){}
       if(state!=='hub') return 'SKIP: the fixture did not reach the Undercroft floor (state '+state+')';
       [].forEach.call(document.querySelectorAll('.modal.on'),function(m){ m.classList.remove('on'); });
       q=__P(); q.weapons=['rifle','smg']; q.equipped='rifle'; q.equippedSec='smg'; q.stash=['medkit']; q.kit=['medkit']; q.hotAssign={0:'medkit'};
       hubBagOpenSet(true);
       if(!hubBagOpen||!hubBagG) return 'SKIP: the Undercroft backpack did not open';
       hubBagG.drag=null; drawHubBag();
       sl=fslots();
       if(!(sl[0]&&sl[0].itemKey==='medkit')) return 'SKIP: staging: the Medkit is not on key 1 of the floor belt ('+desc(sl[0])+')';
       var ga=-1; for(i=2;i<sl.length;i++) if(sl[i]&&sl[i].kind==='gun'&&gid(sl[i])==='rifle'){ ga=i; break; }
       if(!(sl[1]&&gid(sl[1])==='smg')) bad.push('with a Medkit on key 1 the floor belt shows '+desc(sl[1])+' on key 2, not gun 2 (the SMG) as before');
       if(ga<0) bad.push('with a Medkit on key 1 no later key of the floor belt shows gun 1 (the rifle)');
       else {
         var K1=cellAt(0), KG=cellAt(ga);
         if(!K1||!KG||!(K1.w>0&&K1.h>0&&KG.w>0&&KG.h>0)) return 'SKIP: the floor belt drew no key 1 or key '+(ga+1)+' to press';
         press(KG.x+KG.w/2,KG.y+KG.h/2);
         if(!hubBagG.drag||!hubBagG.drag.gunSlot) bad.push('a press on gun 1 on key '+(ga+1)+' of the floor belt picked up no gun');
         release(K1.x+K1.w/2,K1.y+K1.h/2);
         if(hubBagG) hubBagG.drag=null;
         var ha=__P().hotAssign||{};
         sl=fslots();
         if(ha[0]!==undefined||!(sl[0]&&gid(sl[0])==='rifle')) bad.push('gun 1 dragged from key '+(ga+1)+' onto key 1 of the floor belt did not go there (key 1 shows '+desc(sl[0])+')');
         if(ha[ga]!=='medkit') bad.push('the Medkit did not go to key '+(ga+1)+', where gun 1 came from');
       }
       // With no gun 1 the floor shows Bare Hands on key 1 and gun 2 on key 2, as before.
       q=__P(); q.hotAssign={}; q.equipped=''; hubBagG.hotAssign=q.hotAssign; hubBagG.player=hubBagState().player;
       sl=fslots();
       if(!(sl[0]&&gid(sl[0])==='fists'&&sl[1]&&gid(sl[1])==='smg')) bad.push('with no gun 1 the floor belt shows '+desc(sl[0])+' on key 1 and '+desc(sl[1])+' on key 2, not Bare Hands and the SMG');
     }catch(e){ bad.push('floor threw: '+(e&&e.message||e)); }
     finally{
       try{ if(hubBagG) hubBagG.drag=null; hubBagG=null; hubBagOpen=false; }catch(_hb){}
       try{ mouse.x=mx0; mouse.y=my0; mouse.down=false; }catch(_m){}
       try{ if(snap&&state==='hub'){ var mo=document.querySelectorAll('.modal.on'); for(var mj=0;mj<mo.length;mj++) mo[mj].classList.remove('on'); } }catch(_mo){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); if(window.__resetCfg) __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     // 2. THE RAID START with a Medkit on key 1, then a gun drawn into the stowed slot. 3. A loaner on key 1.
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap2=JSON.parse(JSON.stringify(__P()));
       P.weapons=['rifle','smg']; P.equipped='rifle'; P.equippedSec='smg'; P.hotAssign={0:'medkit'};
       __deploy({kit:['medkit'],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p) return 'SKIP: no live raid';
       if(!(p.wep&&p.wep.id==='rifle'&&p.sec&&p.sec.id==='smg')) return 'SKIP: staging: did not deploy with the rifle up and the SMG stowed';
       g.ents.length=0; p.iv=99; p.roll=0; p.downed=false; p.dying=false; g.paused=false; g.drag=null;
       if(!(g.hotAssign&&g.hotAssign[0]==='medkit')){ g.hotAssign={0:'medkit'}; g.hotAuto={}; if(g.bag.indexOf('medkit')<0) g.bag.push('medkit'); gunKeysSettle({deploy:1}); g.hot=gunCell(); }
       sl=hotbarSlots();
       if(!(sl[0]&&sl[0].itemKey==='medkit')) return 'SKIP: staging: the Medkit did not take key 1 in the raid';
       var ra=-1; for(i=2;i<sl.length;i++) if(sl[i]&&sl[i].kind==='gun'&&gid(sl[i])==='rifle'&&sl[i].inHand){ ra=i; break; }
       if(!(sl[1]&&gid(sl[1])==='smg'&&!sl[1].inHand)) bad.push('with a Medkit on key 1 the raid started with key 2 showing '+desc(sl[1])+', not the stowed SMG the floor belt showed there');
       if(ra<0) bad.push('with a Medkit on key 1 no later key shows the rifle in his hands at the raid start');
       else if(g.hot!==ra) bad.push('the raid started on key '+(g.hot+1)+', not on key '+(ra+1)+' with the rifle in his hands');
       p.wepFromArmory=false; p.secFromArmory=false;
       g.bag=g.bag.filter(function(k){ return !/^gun_/.test(k); }); g.bag.push('gun_shotgun');
       if(!equipFromBag(g.bag.lastIndexOf('gun_shotgun'),2)) return 'SKIP: the shotgun could not be drawn into the stowed slot';
       if(!(p.sec&&p.sec.id==='shotgun'&&p.wep&&p.wep.id==='rifle')) return 'SKIP: staging: the shotgun did not go into the stowed slot beside the rifle';
       sl=hotbarSlots();
       if(gid(sl[1])!=='shotgun') bad.push('the shotgun drawn into the stowed slot in place of the SMG on key 2 did not take key 2, which shows '+desc(sl[1]));
       __endRaid('abandon'); __topClear();
       // 3. Gun 1 not his, so a loaner is issued; his SMG is gun 2.
       P.weapons=['smg']; P.equipped='rifle'; P.equippedSec='smg'; P.hotAssign={};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p) return 'SKIP: no live raid for the loaner';
       if(!(p.wepIssued&&p.wep&&p.wep.id!=='fists'&&p.wep.id!=='smg'&&p.wep.id!=='shotgun'&&p.sec&&p.sec.id==='smg'&&!p.secIssued)) return 'SKIP: staging: did not deploy with an issued loaner up and his SMG stowed';
       var lo=p.wep.id;
       g.ents.length=0; p.iv=99; p.roll=0; p.downed=false; p.dying=false; p.swapped=false; p.wepFromArmory=false; p.secFromArmory=false;
       g.bag=g.bag.filter(function(k){ return !/^gun_/.test(k); }); g.bag.push('gun_shotgun');
       sl=hotbarSlots();
       if(!(gid(sl[0])===lo&&sl[0].inHand&&gid(sl[1])==='smg')) return 'SKIP: staging: keys 1 and 2 are not the loaner and the SMG ('+desc(sl[0])+' / '+desc(sl[1])+')';
       var R1={x:100,y:700,w:40,h:40,i:0}, R2={x:150,y:700,w:40,h:40,i:1};
       g.paused=false; g.bagOpen=true; g.bagCells=[]; g.bagPanel=null; g.mapOpen=false; g.trade=null; g.hotCells=[R1,R2];
       say=function(t){ said.push(String(t)); try{ s0(t); }catch(_s){} };
       g.drag={key:'gun_shotgun',bagIx:g.bag.lastIndexOf('gun_shotgun')};
       mouse.x=R1.x+20; mouse.y=R1.y+20; window.dispatchEvent(new MouseEvent('mouseup',{button:0}));
       say=s0;
       if(!(p.wep&&p.wep.id==='shotgun')) bad.push('the shotgun dropped on the key of the loaner did not come up (in hand: '+(p.wep&&p.wep.id)+')');
       if(!held('smg')) bad.push('the shotgun dropped on the key of the issued '+lo+' put his own SMG into the backpack'+((g.bag.indexOf('gun_smg')>=0)?'':' (not even there)')+' and kept the loaner');
       sl=hotbarSlots();
       if(gid(sl[1])!=='smg') bad.push('after the drop key 2 shows '+desc(sl[1])+', not his SMG');
       if(gid(sl[0])!=='shotgun') bad.push('after the drop key 1 shows '+desc(sl[0])+', not the shotgun');
       for(i=0;i<said.length;i++) if(/NO KEY/.test(said[i])) bad.push('the drop said: '+said[i]);
     }catch(e){ bad.push('raid threw: '+(e&&e.message||e)); }
     finally{
       say=s0;
       try{ var g2=__state(); if(g2){ g2.drag=null; g2.bagOpen=false; g2.hotCells=null; if(g2.player){ g2.player.iv=0; g2.player.downed=false; } if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       try{ mouse.x=mx0; mouse.y=my0; mouse.down=md0; }catch(_m2){}
       try{ if(snap2) __applyLoaded(snap2); }catch(_r2){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c2){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'21.89',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
