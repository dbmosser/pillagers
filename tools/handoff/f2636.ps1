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

if ($s.Contains("  {v:'26.36',what:")) { throw "check 26.36 is in the fixture already" }

SubRx @'
  {v:'26.35',what:
'@ @'
  {v:'26.36',what:'gunkeys1, his order: a gun always goes to the key of its class (1 pistol, 2 SMG, 3 rifle, 4 carbine, 5 LMG, 6 shotgun, 7 marksman, 8 sniper, 9 energy): a Longshot picked up takes key 8 and a Magnum key 1; a better rarity of the same gun swaps in at once, keeps the rounds in the magazine and sends the old one to the backpack; a Whisper takes key 7 from a weaker Marksman Rifle and goes to the backpack against a stronger one; the table is read from the profile and a drag to another key still works',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: no raid or frame here';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing can be drawn';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live';
     if(typeof gunClassOf!=='function'||typeof gunClassPlace!=='function'||typeof gunKeyFor!=='function') return 'this build has no class keys';
     if(!WEAPONS.smg_v||!WEAPONS.rifle_v||!ITEMS.gun_smg_v||!ITEMS.gun_rifle_v) return 'SKIP: no rarity twins here';
     var bad=[], g=null, p=null, had=(P.gunKeys!==undefined), keep=P.gunKeys, ar0, j, x, c0, c5, wk, TAB=[['magnum',0],['smg',1],['carbine',3],['lmg',4],['shotgun',5],['dmr',6],['sniper',7],['lance',8]];
     function stage(w,wa,s,sa,bag){
       p.swapped=false; p.wep=w; p.ammo=wa; p.sec=s||WEAPONS.fists; p.secAmmo=sa||0; p.wepIssued=false; p.secIssued=false; p.wepFromArmory=false; p.secFromArmory=false; p.reloading=0; p.hand=null;
       g.bag=(bag||[]).slice(); g.stowAmmo={}; g.stowQ={}; g.hotAssign={}; g.hotAuto={}; g.hotPruned={}; g.bagOpen=false; g.drag=null;
       gunKeysSettle({deploy:1}); g.hot=gunCell();
     }
     function pick(id){ var f=beltGunField(id), k='gun_'+id; g.bag.push(k); gunQPush(f); BELTAT=-1; BELTDISP=null; autoBelt(k,1,{found:f}); BELTDISP=null; return k; }
     function pin(k){ var y; for(y in g.hotAssign) if(g.hotAssign[y]===k) return +y; return -1; }
     function has(k){ return g.bag.indexOf(k)>=0; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       delete P.gunKeys;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       p=g.player; p.iv=99; g.ents.length=0; g.paused=false; g.trade=null; keys={}; mouse.down=false; ar0=g.arcade;
       // ONE: his table, every class on its own key
       stage(beltGunField('rifle'),20,null,0,[]);
       if(pin('gun_rifle')!==2) bad.push('ONE: the Auto Rifle in his hands sits on key '+(pin('gun_rifle')+1)+', not 3');
       for(j=0;j<TAB.length;j++){ pick(TAB[j][0]); if(pin('gun_'+TAB[j][0])!==TAB[j][1]) bad.push('ONE: a picked up '+TAB[j][0]+' went to key '+(pin('gun_'+TAB[j][0])+1)+', not '+(TAB[j][1]+1)); }
       pick('pistol');
       if(pin('gun_pistol')!==-1||!has('gun_pistol')||pin('gun_magnum')!==0) bad.push('ONE: a Scav Pistol picked up with a Magnum on key 1 did not go to the backpack and leave the Magnum on its key (keys '+JSON.stringify(g.hotAssign)+')');
       // TWO: a better rarity swaps in at once, in his hands, with the rounds
       stage(beltGunField('smg'),17,null,0,[]);
       if(pin('gun_smg')!==1) bad.push('TWO: the SMG in his hands sits on key '+(pin('gun_smg')+1)+', not 2');
       pick('smg_v');
       if(!p.wep||p.wep.id!=='smg_v') bad.push('TWO: the blue SMG did not come into his hands (in hand '+(p.wep&&p.wep.id)+')');
       else if(p.ammo!==17) bad.push('TWO: the rounds did not come with it ('+p.ammo+', not 17)');
       if(!has('gun_smg')||has('gun_smg_v')) bad.push('TWO: the green SMG is not the gun in the backpack (backpack '+g.bag.join(',')+')');
       if(pin('gun_smg_v')!==1||pin('gun_smg')!==-1) bad.push('TWO: key 2 does not name the blue SMG alone (keys '+JSON.stringify(g.hotAssign)+')');
       stage(beltGunField('smg'),40,null,0,[]); pick('smg_v');
       if(!p.wep||p.ammo!==WEAPONS.smg_v.mag) bad.push('TWO: the rounds were not held to the new magazine ('+p.ammo+', not '+WEAPONS.smg_v.mag+')');
       if(!(g.stowAmmo.smg&&g.stowAmmo.smg[0]===40-WEAPONS.smg_v.mag)) bad.push('TWO: the rounds that did not fit did not stay with the old gun ('+JSON.stringify(g.stowAmmo)+')');
       // THREE: a stowed gun is swapped the same way, and a worse find goes to the backpack
       stage(beltGunField('pistol'),9,beltGunField('rifle'),13,[]); pick('rifle_v');
       if(!p.sec||p.sec.id!=='rifle_v'||p.secAmmo!==13||!p.wep||p.wep.id!=='pistol') bad.push('THREE: the better rifle did not take the stowed slot with its 13 rounds (hand '+(p.wep&&p.wep.id)+', stowed '+(p.sec&&p.sec.id)+' '+p.secAmmo+')');
       if(!has('gun_rifle')||pin('gun_rifle_v')!==2) bad.push('THREE: the old rifle is not in the backpack with key 3 on the better one (keys '+JSON.stringify(g.hotAssign)+', backpack '+g.bag.join(',')+')');
       stage(beltGunField('smg_v'),17,null,0,[]); pick('smg');
       if(!p.wep||p.wep.id!=='smg_v'||pin('gun_smg')!==-1||!has('gun_smg')||BELTAT!==-2) bad.push('THREE: a green SMG picked up against a blue one in hand did not go to the backpack and leave the blue one alone');
       // FOUR: two models of one class, the better by the stat card keeps the key
       wk=beltGunField('dmr'); wk.dmg=10;
       stage(beltGunField('rifle'),20,wk,5,[]);
       if(pin('gun_dmr')!==6) bad.push('FOUR: the stowed Marksman Rifle sits on key '+(pin('gun_dmr')+1)+', not 7');
       pick('whisper');
       if(!p.sec||p.sec.id!=='whisper'||pin('gun_whisper')!==6||!has('gun_dmr')) bad.push('FOUR: a Whisper did not replace a weaker Marksman Rifle on key 7 (stowed '+(p.sec&&p.sec.id)+', keys '+JSON.stringify(g.hotAssign)+')');
       stage(beltGunField('rifle'),20,beltGunField('dmr'),5,[]); pick('whisper');
       if(!p.sec||p.sec.id!=='dmr'||!has('gun_whisper')||pin('gun_whisper')!==-1) bad.push('FOUR: a Whisper picked up against a stronger Marksman Rifle did not go to the backpack (stowed '+(p.sec&&p.sec.id)+', keys '+JSON.stringify(g.hotAssign)+')');
       // FIVE: the table the stash set is the one the raid reads, and a bad one is not
       P.gunKeys=['pistol','sniper','rifle','carbine','lmg','shotgun','marksman','smg','energy'];
       stage(beltGunField('rifle'),20,null,0,[]); pick('sniper'); pick('smg');
       if(pin('gun_sniper')!==1||pin('gun_smg')!==7) bad.push('FIVE: with the Sniper set on key 2 a Longshot went to key '+(pin('gun_sniper')+1)+' and the SMG to key '+(pin('gun_smg')+1));
       g.arcade=1; stage(beltGunField('rifle'),20,null,0,[]); pick('sniper'); g.arcade=ar0;
       if(pin('gun_sniper')!==7) bad.push('FIVE: the DEMO read the stash table (Longshot on key '+(pin('gun_sniper')+1)+')');
       P.gunKeys=['pistol','pistol','rifle','carbine','lmg','shotgun','marksman','sniper','energy'];
       stage(beltGunField('rifle'),20,null,0,[]); pick('sniper');
       if(pin('gun_sniper')!==7) bad.push('FIVE: a table with a class twice was read (Longshot on key '+(pin('gun_sniper')+1)+')');
       delete P.gunKeys;
       // SIX: a drag to another key still works, for this raid, and writes no plan
       if(typeof cv==='undefined'||typeof mouse==='undefined') return bad.length?bad.join('; '):'SKIP: no canvas or mouse here';
       stage(beltGunField('rifle'),20,null,0,['gun_pistol']);
       if(pin('gun_pistol')!==0) bad.push('SIX: the packed pistol is not on key 1 before the drag (keys '+JSON.stringify(g.hotAssign)+')');
       __frame(0.016); __frame(0.016);
       c0=g.hotCells&&g.hotCells[0]; c5=g.hotCells&&g.hotCells[5];
       if(!c0||!c5) bad.push('SIX: the bar drew no cells 1 and 6 to drag between');
       else {
         mouse.x=c0.x+c0.w/2; mouse.y=c0.y+c0.h/2;
         cv.dispatchEvent(new MouseEvent('mousedown',{button:0,bubbles:true}));
         if(!g.drag||g.drag.key!=='gun_pistol') bad.push('SIX: pressing the pistol key started no drag');
         mouse.x=c5.x+c5.w/2; mouse.y=c5.y+c5.h/2;
         window.dispatchEvent(new MouseEvent('mouseup',{button:0,bubbles:true}));
         if(pin('gun_pistol')!==5) bad.push('SIX: the pistol dragged to key 6 sits on key '+(pin('gun_pistol')+1)+' (keys '+JSON.stringify(g.hotAssign)+')');
         for(x in (P.hotAssign||{})) if(P.hotAssign[x]==='gun_pistol') bad.push('SIX: the drag was written to the saved plan');
         if(gunClassKey('pistol')!==0) bad.push('SIX: the drag changed the table (pistol on key '+(gunClassKey('pistol')+1)+')');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ mouse.down=false; keys={}; if(g){ g.drag=null; g.arcade=ar0; } if(had) P.gunKeys=keep; else delete P.gunKeys; var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'26.35',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
