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

if ($s.Contains("  {v:'26.26',what:")) { throw "check 26.26 is in the fixture already" }

SubRx @'
  {v:'26.25',what:
'@ @'
  {v:'26.26',what:'his order (2026-10-14): a green, blue or purple gun is found one rarity up about one time in five (the Compact SMG as a blue one, the Magnum, Burst Carbine, Riot Scattergun and Auto Rifle as purple ones, the Support MG, Marksman Rifle and Whisper as gold ones) with 1.25 times the damage and nothing else changed, worth 1.5 times, never two steps up and never the Scav Pistol, Longshot or Lance; the twin stays itself through a pickup, a drop, the belt rank, an extraction and the next deploy, and a roll still draws exactly one number',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__topClear&&window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile&&window.__applyLoaded)||typeof rollFieldGun!=='function'||typeof openContainer!=='function'||typeof dropItem!=='function'||typeof drawGun!=='function'||typeof gunCompare!=='function'||typeof beltGunLow!=='function') return 'SKIP: this fixture cannot deploy, roll, drop and equip a gun';
     if(typeof RV_OF==='undefined'||typeof VARIANT_DMG==='undefined'||typeof gunBase!=='function') return 'guns have no rarity variants (RV_OF, VARIANT_DMG, gunBase)';
     var bad=[], RN=['common','uncommon','rare','elite','gold'], SRC=['smg','magnum','carbine','shotgun','rifle','lmg','dmr','whisper'], NONE=['pistol','sniper','lance','tacker'];
     var SAME=['rof','reload','mag','spread','rng','noise','pellets','burst','auto','optic','tint','name'];
     var P2=__P(), i, j, k, b, v, vi, ib, iv, cnt, hi, mm, nb, nv, nx, n, g, p, q, ct, o, ok, ix, snap=null, s0=RNGS, r0=RSEED, pend0=pendSeed;
     function gunsHeld(){
       var out=[], z;
       if(p.wep&&p.wep.id&&p.wep.id!=='fists'&&p.wep.mag!==0) out.push(p.wep.id);
       if(p.sec&&p.sec.id&&p.sec.id!=='fists'&&p.sec.mag!==0) out.push(p.sec.id);
       for(z=0;z<g.bag.length;z++) if(ITEMS[g.bag[z]]&&ITEMS[g.bag[z]].use==='gun') out.push(ITEMS[g.bag[z]].gk);
       return out; }
     function stage(){ g.bag=[]; g.stowQ={}; g.stowAmmo={}; g.hotAssign={}; g.hotAuto={}; p.wep=WEAPONS.fists; p.sec=WEAPONS.fists; p.wepIssued=false; p.secIssued=false; p.wepFromArmory=false; p.secFromArmory=false; p.reloading=0; }
     function find(key){ stage(); var box=setLoot(mkContainer(p.x+6,p.y+6,'crate'),[key]); g.containers.push(box); openContainer(box,[key]); return gunsHeld(); }
     function base0(){
       q=__P(); q.autoExport=false;
       q.weapons=['pistol']; q.equipped='pistol'; q.equippedSec='none'; q.forged={};
       q.stash=[]; q.kit=[]; q.hotAssign={}; q.safe=null; q.dropKit=[]; q.kitChosen=0; q.devKit=0;
       q.kitSaved=null; q.kitBeforeFree=null; q.hotBeforeFree=null; q.gunBeforeFree=null; q.freeKit=0; delete q.raidSpliced; q.gunPiled=[];
     }
     function up(){ __topClear(); __runPrep(); __resetCfg(); __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state(); p=g&&g.player; return !!(g&&!g.over&&p); }
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       // ONE: the table. Each twin is the model with only the damage changed, one rarity up, worth more.
       if(!(VARIANT_DMG>=1.2&&VARIANT_DMG<=1.4)) bad.push('VARIANT_DMG is '+VARIANT_DMG+', outside his 1.2 to 1.4');
       for(i=0;i<SRC.length;i++){
         b=WEAPONS[SRC[i]]; vi=RV_OF[SRC[i]]; v=vi?WEAPONS[vi]:null;
         if(!b||!v){ bad.push((b?b.name:SRC[i])+' has no rarity variant'); continue; }
         if(v.dmg!==b.dmg*VARIANT_DMG) bad.push(b.name+' variant does '+v.dmg+' damage, not '+(b.dmg*VARIANT_DMG));
         for(j=0;j<SAME.length;j++) if(String(v[SAME[j]])!==String(b[SAME[j]])) bad.push(b.name+' variant changed '+SAME[j]+' ('+b[SAME[j]]+' to '+v[SAME[j]]+')');
         if(WTIER[vi]!==WTIER[SRC[i]]) bad.push(b.name+' variant ranks '+WTIER[vi]+' against '+WTIER[SRC[i]]);
         if(RN.indexOf(gunRarity(vi))!==RN.indexOf(gunRarity(SRC[i]))+1) bad.push(b.name+' variant reads '+gunRarity(vi)+', not one step above '+gunRarity(SRC[i]));
         if(RV_OF[vi]) bad.push(b.name+' variant has a variant of its own');
         ib=ITEMS['gun_'+SRC[i]]; iv=ITEMS['gun_'+vi];
         if(!iv||iv.gk!==vi||iv.use!=='gun') bad.push(b.name+' variant has no gun item');
         else if(iv.val!==Math.round(ib.val*VARIANT_VAL)||ival('gun_'+vi)<=ival('gun_'+SRC[i])) bad.push(b.name+' variant is worth '+iv.val+', not '+Math.round(ib.val*VARIANT_VAL));
       }
       for(i=0;i<NONE.length;i++) if(RV_OF[NONE[i]]) bad.push((WEAPONS[NONE[i]]?WEAPONS[NONE[i]].name:NONE[i])+' has a rarity variant');
       if(gunRarity('smg')!=='uncommon'||gunRarity(RV_OF.smg)!=='rare') bad.push('the Compact SMG is not green with a blue twin ('+gunRarity('smg')+', '+gunRarity(RV_OF.smg)+')');
       if(gunRarity('magnum')!=='rare'||gunRarity(RV_OF.magnum)!=='elite') bad.push('the Magnum is not blue with a purple twin');
       if(gunRarity('dmr')!=='elite'||gunRarity(RV_OF.dmr)!=='gold') bad.push('the Marksman Rifle is not purple with a gold twin');
       // TWO: the roll. 400 finds of each model: about one in five is the twin, none is two steps up, a twin is the model with 1.25 times the damage.
       srand(424242);
       for(i=0;i<SRC.length;i++){
         cnt=0; hi=0; mm=0; b=WEAPONS[SRC[i]];
         for(j=0;j<400;j++){
           g=rollFieldGun(SRC[i]);
           if(g.id===RV_OF[SRC[i]]){ cnt++; if(g.dmg!==b.dmg*VARIANT_DMG||g.reload!==b.reload||g.rof!==b.rof||g.mag!==b.mag||g.spread!==b.spread||g.name!==b.name) mm++; }
           else if(g.id!==SRC[i]) hi++;
           else if(g.dmg!==b.dmg) mm++;
         }
         if(hi) bad.push(b.name+' came as something else '+hi+' times in 400 finds');
         if(mm) bad.push(b.name+' came with the wrong numbers '+mm+' times in 400 finds');
         if(cnt<40||cnt>120) bad.push(b.name+' came as the variant '+cnt+' times in 400 finds (about 80 expected)');
       }
       for(i=0;i<NONE.length;i++){
         for(j=0;j<400;j++){ g=rollFieldGun(NONE[i]); if(g.id!==NONE[i]){ bad.push((WEAPONS[NONE[i]]?WEAPONS[NONE[i]].name:NONE[i])+' was found as '+g.id); break; } }
       }
       for(i=0;i<SRC.length;i++){
         vi=RV_OF[SRC[i]]; if(!vi) continue;
         for(j=0;j<60;j++){ g=rollFieldGun(vi); if(g.id!==vi||g.dmg!==WEAPONS[vi].dmg){ bad.push('the '+WEAPONS[vi].name+' variant was found as '+g.id+' doing '+g.dmg); break; } }
       }
       srand(7); rr(); o=RNGS; srand(7); rollFieldGun('smg');
       if(RNGS!==o) bad.push('a gun roll draws more or fewer than the one number it always drew');
       // THREE: the real pickup. Staged finds of a Compact SMG out of a box.
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player;
       if(!g||!p||g.over) return bad.length?bad.join('; '):'SKIP: no live raid';
       g.ents.length=0; g.hotZone=null; g.trade=null; p.downed=false; p.iv=99;
       nb=0; nv=0; nx=0;
       for(i=0;i<300;i++){
         o=find('gun_smg');
         if(o.length===1&&o[0]==='smg') nb++; else if(o.length===1&&o[0]==='smg_v') nv++; else nx++;
       }
       if(nx) bad.push(nx+' of 300 staged finds of a Compact SMG did not leave exactly one Compact SMG or its variant');
       if(nv<25||nv>105) bad.push('the pickup path made the variant '+nv+' times in 300 finds (about 60 expected)');
       if(nb<150) bad.push('control: the plain Compact SMG came only '+nb+' times in 300 finds');
       nv=0; for(i=0;i<300&&!nv;i++){ o=find('gun_smg'); if(o.length===1&&o[0]==='smg_v') nv=1; }
       if(!nv) return bad.concat(['no variant came out of 300 more finds']).slice(0,4).join('; ');
       if(g.bag.indexOf('gun_smg_v')>=0){
         if(g.bag.indexOf('gun_smg')>=0) bad.push('a variant find also left a plain Compact SMG key in the backpack');
         if(!gunQPeek('smg_v')||gunQPeek('smg_v').dmg!==WEAPONS.smg.dmg*VARIANT_DMG) bad.push('the variant in the backpack lost its damage in the kept copy');
       } else if(!((p.wep&&p.wep.id==='smg_v')||(p.sec&&p.sec.id==='smg_v'))) bad.push('a variant find went neither to the backpack nor to a hand');
       // FOUR: a drop and a pickup, then the hand.
       stage(); g.bag.push('gun_smg_v'); gunQPush(WEAPONS.smg_v);
       dropItem(0); ct=g.containers[g.containers.length-1];
       if(!ct||!ct.dropped||!ct.loot||ct.loot.indexOf('gun_smg_v')<0) bad.push('a variant dropped did not make a pile of itself ('+(ct&&ct.loot)+')');
       else {
         openContainer(ct); o=gunsHeld();
         if(o.length!==1||o[0]!=='smg_v') bad.push('a variant dropped and searched back up came back as '+o.join(','));
       }
       stage(); g.bag.push('gun_smg_v'); gunQPush(WEAPONS.smg_v);
       ok=drawGun(0);
       if(!ok||!p.wep||p.wep.id!=='smg_v') bad.push('a variant in the backpack did not come up in the hand ('+(p.wep&&p.wep.id)+')');
       else if(p.wep.dmg!==WEAPONS.smg.dmg*VARIANT_DMG||p.wep.reload!==WEAPONS.smg.reload||p.wep.rof!==WEAPONS.smg.rof||p.wep.mag!==WEAPONS.smg.mag||p.wep.spread!==WEAPONS.smg.spread) bad.push('the variant in the hand has numbers other than the model with 1.25 times the damage');
       // FIVE: the belt rank. Tier first, then the damage a second: the twin outranks its model and still sits under a higher tier.
       if(!beltGunLow(WEAPONS.smg,WEAPONS.smg_v)||beltGunLow(WEAPONS.smg_v,WEAPONS.smg)) bad.push('the belt does not rank the variant Compact SMG above the plain one');
       if(!beltGunLow(WEAPONS.smg_v,WEAPONS.rifle)) bad.push('the belt ranks a variant Compact SMG above a plain Auto Rifle, a higher tier');
       if(gunStats(WEAPONS.smg_v).dmg!==gunStats(WEAPONS.smg).dmg*VARIANT_DMG) bad.push('the stat card does not read 1.25 times the damage for the variant');
       if(gunCompare(WEAPONS.smg_v,WEAPONS.smg).verdict!=='UPGRADE') bad.push('the stat card does not call the variant an UPGRADE over its model');
       // SIX: an extraction. In a hand, in the backpack, already owned (stash), and the next deploy.
       base0(); saveProfile();
       if(!up()) return bad.length?bad.join('; '):'SKIP: no second raid';
       o={}; for(k in WEAPONS.smg_v) o[k]=WEAPONS.smg_v[k];
       p.sec=o; p.secAmmo=10; p.secIssued=false; p.secFromArmory=false; p.downed=false; p.hp=100;
       __endRaid('extract');
       q=__P();
       if(q.weapons.indexOf('smg_v')<0) bad.push('a variant carried out in a hand did not reach the armoury ('+q.weapons.join(',')+')');
       base0(); saveProfile();
       if(!up()) return bad.length?bad.join('; '):'SKIP: no third raid';
       g.bag.push('gun_smg_v'); gunQPush(WEAPONS.smg_v); p.downed=false; p.hp=100;
       __endRaid('extract');
       q=__P();
       if(q.weapons.indexOf('smg_v')<0) bad.push('a variant carried out in the backpack did not reach the armoury ('+q.weapons.join(',')+')');
       if(q.weapons.indexOf('smg')>=0) bad.push('a variant carried out put the plain Compact SMG in the armoury too');
       base0(); q.weapons=['pistol','smg_v']; saveProfile();
       if(!up()) return bad.length?bad.join('; '):'SKIP: no fourth raid';
       g.bag.push('gun_smg_v'); gunQPush(WEAPONS.smg_v); p.downed=false; p.hp=100;
       __endRaid('extract');
       q=__P();
       if(q.stash.indexOf('gun_smg_v')<0) bad.push('a second variant carried out did not go to the stash as a variant ('+q.stash.join(',')+')');
       if(q.stash.indexOf('gun_smg')>=0) bad.push('a second variant carried out became a plain Compact SMG in the stash');
       base0(); q.weapons=['pistol','smg_v']; q.equipped='smg_v'; saveProfile();
       if(!up()) return bad.length?bad.join('; '):'SKIP: no fifth raid';
       if(!p.wep||p.wep.id!=='smg_v'||p.wep.dmg!==WEAPONS.smg.dmg*VARIANT_DMG||!p.wepFromArmory) bad.push('the variant in the armoury did not come up as gun 1 on the next deploy ('+(p.wep&&p.wep.id)+')');
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       try{ var g2=__state(); if(g2){ g2.drag=null; if(g2.player){ g2.player.iv=0; g2.player.downed=false; } if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       try{ keys={}; }catch(_k){}
       try{ RNGS=s0; RSEED=r0; pendSeed=pend0; }catch(_s){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.slice(0,4).join('; '):null; }},
  {v:'26.25',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
