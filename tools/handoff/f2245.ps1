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

if ($s.Contains("  {v:'22.45',what:")) { throw "check 22.45 is in the fixture already" }

SubRx @'
  {v:'22.44',what:
'@ @'
  {v:'22.45',what:'the Undercroft belt edits all four gun keys (the four-gun belt, build 4): on the floor gun 1 dragged from key 1 onto key 6 is bound there and the Medkit on key 6 goes to key 1; gun 2 dragged onto key 3 is bound there and leaves key 2, and the raid starts on the keys the floor showed; the Stash screen belt shows the guns on unbound keys 1 to 3; and after an extraction the gun on key 1, in the backpack, is gun 1 at home and the gun on key 2 is gun 2 (decision D3)',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__state||!window.__P||!window.__applyLoaded||!window.__hubEnter) return 'SKIP: this fixture cannot deploy a raid or reach the floor';
     if(typeof hotbarSlots!=='function'||typeof GUNKEYS==='undefined'||GUNKEYS<4||typeof hubBagOpenSet!=='function'||typeof drawHubBag!=='function'||typeof withHubBag!=='function'||typeof hubBagState!=='function'||typeof hotPlanHTML!=='function'||typeof setHot!=='function') return 'SKIP: no four gun keys or floor belt here';
     if(!WEAPONS.rifle||!WEAPONS.smg||!WEAPONS.shotgun||!ITEMS.gun_rifle||!ITEMS.gun_smg||!ITEMS.gun_shotgun||!ITEMS.medkit) return 'SKIP: no rifle, smg, shotgun or medkit here';
     if(typeof cv==='undefined'||!cv||typeof mouse==='undefined'||!mouse) return 'SKIP: no canvas or mouse in this build';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live';
     var bad=[], snap=null, snap2=null, mx0=mouse.x, my0=mouse.y, md0=mouse.down, g=null, p=null, i, sl, q, ha, fl4=null, rd4, d, rl;
     function gid(c){ return (c&&!c.vacant)?String(c.icon||'').replace(/^gun_/,''):''; }
     function desc(c){ if(!c) return 'nothing'; var n=(c.itemKey&&!/^gun_/.test(c.itemKey))?c.itemKey:(gid(c)||'nothing'); return n+(c.vacant?' (vacant)':(c.inHand?' in hand':'')); }
     function fslots(){ var r=null; withHubBag(function(){ r=hotbarSlots(); }); return r||[]; }
     function cellAt(ix){ var hc=hubBagG.hotCells||[]; for(var j=0;j<hc.length;j++) if(hc[j].i===ix) return hc[j]; return null; }
     function press(x,y){ mouse.down=false; mouse.x=x; mouse.y=y; cv.dispatchEvent(new MouseEvent('mousedown',{button:0,bubbles:true,cancelable:true})); }
     function release(x,y){ mouse.x=x; mouse.y=y; window.dispatchEvent(new MouseEvent('mouseup',{button:0,bubbles:true,cancelable:true})); }
     function drag(a,b){
       drawHubBag(); var A=cellAt(a), B=cellAt(b);
       if(!A||!B||!(A.w>0&&A.h>0&&B.w>0&&B.h>0)) return 'the floor belt drew no key '+(a+1)+' or key '+(b+1);
       press(A.x+A.w/2,A.y+A.h/2);
       var ok=!!(hubBagG.drag&&hubBagG.drag.gunSlot);
       release(B.x+B.w/2,B.y+B.h/2); if(hubBagG) hubBagG.drag=null;
       return ok?null:'a press on key '+(a+1)+' of the floor belt picked up no gun';
     }
     function plan(o){ q=__P(); q.hotAssign=o; if(hubBagG){ hubBagG.hotAssign=q.hotAssign; hubBagG.player=hubBagState().player; hubBagG.drag=null; } }
     // 1. THE FLOOR: the rifle is gun 1, the SMG gun 2, a Medkit and a shotgun packed.
     try{
       __topClear(); if(window.__runPrep) __runPrep(); if(window.__resetCfg) __resetCfg(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       hubBagG=null; hubBagOpen=false;
       try{ __hubEnter(); }catch(_h){}
       if(state!=='hub') return 'SKIP: the fixture did not reach the Undercroft floor (state '+state+')';
       [].forEach.call(document.querySelectorAll('.modal.on'),function(m){ m.classList.remove('on'); });
       q=__P(); q.weapons=['rifle','smg']; q.equipped='rifle'; q.equippedSec='smg'; q.stash=['medkit','gun_shotgun']; q.kit=['medkit','gun_shotgun']; q.hotAssign={5:'medkit'};
       hubBagOpenSet(true);
       if(!hubBagOpen||!hubBagG) return 'SKIP: the Undercroft backpack did not open';
       plan({5:'medkit'}); sl=fslots();
       if(!(gid(sl[0])==='rifle'&&gid(sl[1])==='smg'&&gid(sl[2])==='shotgun'&&sl[5]&&sl[5].itemKey==='medkit')) return 'SKIP: staging: the floor belt is not rifle, SMG, shotgun on keys 1 to 3 and the Medkit on key 6 ('+desc(sl[0])+' / '+desc(sl[1])+' / '+desc(sl[2])+' / '+desc(sl[5])+')';
       // ONE: gun 1 from key 1 onto key 6, where the Medkit is.
       rl=drag(0,5); if(rl) return 'SKIP: '+rl;
       ha=__P().hotAssign||{};
       if(ha[5]!=='gun_rifle') bad.push('gun 1 dragged from key 1 onto key 6 of the floor belt was not bound there (plan '+JSON.stringify(ha)+')');
       if(ha[0]!=='medkit') bad.push('the Medkit that was on key 6 did not go to key 1, where gun 1 came from (plan '+JSON.stringify(ha)+')');
       sl=fslots();
       if(gid(sl[5])!=='rifle') bad.push('after that drag key 6 of the floor belt shows '+desc(sl[5])+', not gun 1');
       // TWO: gun 2 from key 2 onto key 3, where the packed shotgun shows.
       plan({}); sl=fslots();
       if(!(gid(sl[1])==='smg'&&gid(sl[2])==='shotgun')) return bad.length?bad.join('; '):'SKIP: staging: with no plan keys 2 and 3 are not the SMG and the shotgun';
       rl=drag(1,2); if(rl) return bad.length?bad.join('; '):('SKIP: '+rl);
       ha=__P().hotAssign||{};
       if(ha[2]!=='gun_smg') bad.push('gun 2 dragged from key 2 onto key 3 of the floor belt was not bound there (plan '+JSON.stringify(ha)+')');
       sl=fslots(); fl4=[gid(sl[0]),gid(sl[1]),gid(sl[2]),gid(sl[3])];
       if(gid(sl[2])!=='smg') bad.push('after that drag key 3 of the floor belt shows '+desc(sl[2])+', not gun 2');
       if(gid(sl[1])==='smg') bad.push('gun 2 moved to key 3 and the floor belt still shows it on key 2 as well');
       if(gid(sl[0])!=='rifle') bad.push('gun 2 moved to key 3 and key 1 of the floor belt shows '+desc(sl[0])+', not gun 1');
       if(gid(sl[3])!=='shotgun') bad.push('gun 2 moved to key 3 and the packed shotgun is not on key 4 of the floor belt ('+desc(sl[3])+')');
       // THREE: the Stash screen belt with no plan shows the guns on keys 1 to 3.
       plan({});
       d=document.createElement('div'); d.innerHTML=hotPlanHTML();
       var exp=[WEAPONS.rifle.name,WEAPONS.smg.name,ITEMS.gun_shotgun.name];
       for(i=0;i<3;i++){
         var pc=d.querySelector('[data-plan="'+i+'"]'), tt=pc?(pc.getAttribute('title')||''):'';
         if(!pc) bad.push('the Stash screen belt drew no key '+(i+1));
         else if(tt.indexOf(exp[i])<0||!pc.querySelector('img')) bad.push('key '+(i+1)+' of the Stash screen belt, with no plan, reads '+JSON.stringify(tt)+', not the '+exp[i]+' the floor belt shows there');
       }
     }catch(e){ bad.push('floor threw: '+(e&&e.message||e)); }
     finally{
       try{ if(hubBagG) hubBagG.drag=null; hubBagG=null; hubBagOpen=false; }catch(_hb){}
       try{ mouse.x=mx0; mouse.y=my0; mouse.down=false; }catch(_m){}
       try{ if(snap&&state==='hub'){ var mo=document.querySelectorAll('.modal.on'); for(var mj=0;mj<mo.length;mj++) mo[mj].classList.remove('on'); } }catch(_mo){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); if(window.__resetCfg) __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     // 2. THE RAID with the plan the floor made (the SMG on key 3), then D3 at the extraction.
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap2=JSON.parse(JSON.stringify(__P()));
       P.weapons=['rifle','smg']; P.equipped='rifle'; P.equippedSec='smg'; P.hotAssign={2:'gun_smg'};
       __deploy({kit:['gun_shotgun'],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p) return bad.length?bad.join('; '):'SKIP: no live raid';
       if(!(p.wep&&p.wep.id==='rifle'&&p.sec&&p.sec.id==='smg'&&g.bag.indexOf('gun_shotgun')>=0)) return bad.length?bad.join('; '):'SKIP: staging: did not deploy with the rifle up, the SMG stowed and the shotgun packed';
       g.ents.length=0; p.iv=99; p.roll=0; p.downed=false; p.dying=false; g.paused=false; g.drag=null; keys={};
       sl=hotbarSlots(); rd4=[gid(sl[0]),gid(sl[1]),gid(sl[2]),gid(sl[3])];
       if(fl4&&rd4.join(',')!==fl4.join(',')) bad.push('the raid started on keys 1 to 4 '+JSON.stringify(rd4)+', not the '+JSON.stringify(fl4)+' the floor belt showed');
       var ks=-1; for(i=0;i<4;i++) if(gid(sl[i])==='shotgun'&&!sl[i].inHand) ks=i;
       if(ks<0) return bad.length?bad.join('; '):'SKIP: staging: no gun key shows the packed shotgun at the raid start';
       // FOUR: the shotgun drawn from its key; the rifle goes to the backpack and keeps key 1.
       setHot(ks);
       sl=hotbarSlots();
       if(!(p.wep&&p.wep.id==='shotgun'&&g.bag.indexOf('gun_rifle')>=0&&gid(sl[0])==='rifle'&&!sl[0].inHand)) return bad.length?bad.join('; '):('SKIP: staging: the shotgun drawn from key '+(ks+1)+' did not leave the rifle in the backpack on key 1 (in hand '+(p.wep&&p.wep.id)+', key 1 '+desc(sl[0])+')');
       // The shotgun goes to key 2 as his own key, so keys 1 and 2 are the rifle (backpack) and the shotgun (in hand).
       for(i in g.hotAssign) if(g.hotAssign[i]==='gun_shotgun'){ delete g.hotAssign[i]; if(g.hotAuto) delete g.hotAuto[i]; }
       g.hotAssign[1]='gun_shotgun'; if(g.hotAuto) delete g.hotAuto[1];
       sl=hotbarSlots();
       if(!(gid(sl[0])==='rifle'&&gid(sl[1])==='shotgun')) return bad.length?bad.join('; '):('SKIP: staging: keys 1 and 2 are not the rifle and the shotgun ('+desc(sl[0])+' / '+desc(sl[1])+')');
       p.downed=false; __endRaid('extract');
       q=__P();
       if(q.equipped!=='rifle') bad.push('after an extraction with the rifle on key 1 in the backpack, gun 1 at home is '+q.equipped+', not the rifle (decision D3)');
       if(q.equippedSec!=='shotgun') bad.push('after an extraction with the shotgun on key 2, gun 2 at home is '+q.equippedSec+', not the shotgun (decision D3)');
       if((q.weapons||[]).indexOf('smg')<0) bad.push('the SMG carried on key 3 did not go home to the armoury');
     }catch(e){ bad.push('raid threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2){ g2.drag=null; g2.bagOpen=false; if(g2.player){ g2.player.iv=0; g2.player.downed=false; } if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       try{ mouse.x=mx0; mouse.y=my0; mouse.down=md0; keys={}; }catch(_m2){}
       try{ if(snap2) __applyLoaded(snap2); }catch(_r2){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c2){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.44',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
