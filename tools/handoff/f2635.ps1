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

if ($s.Contains("  {v:'26.35',what:")) { throw "check 26.35 is in the fixture already" }

SubRx @'
  {v:'26.34',what:
'@ @'
  {v:'26.35',what:'his order (2026-10-14): the four starter guns are gone: no weapon, rank, draw time, gear sound, held sprite or icon family for the Tacker, Sputter, Chatter or Scuttle, no starter list, no pillager or hired man holds one in 30 seeded raids, the DEMO kit never deals one, pillagers carry real lootable guns, and the gun a sidearm-row pillager spawns with leaves no copy on his body, so the share who drop a gun is what it was',
   run:function(){
     if(!(window.__deploy&&window.__startRaid&&window.__state&&window.__endRaid&&window.__P&&window.__applyLoaded&&window.__topClear&&window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile)||typeof buildRaid!=='function'||typeof mkRaider!=='function'||typeof updateEnts!=='function'||typeof arcadeDeploy!=='function'||typeof arcadeKitApply!=='function'||typeof ARCADE!=='object'||typeof IDENTITIES==='undefined'||!IDENTITIES.length) return 'SKIP: this fixture cannot build a raid, a pillager or a DEMO kit';
     var NM=['tac'+'ker','sput'+'ter','chat'+'ter','scut'+'tle'], bad=[], P2=__P(), snap=null, oR=RNGS, oRS=RSEED, oPend=pendSeed, TAG='QX NOSTART ';
     var i, j, k, s, g, p, e, r, w, h, c, nR=0, nE=0, nM=0, tot=0, lootable=0, drops=0, side=0, made=[], keepEnts=null, gh, A, B, C, bA, bB, bC, ids, why;
     function isS(id){ return NM.indexOf(String(id))>=0; }
     function holds(ent){ var o=[], z; if(ent&&ent.wep&&ent.wep.id) o.push(String(ent.wep.id)); for(z=0;z<((ent&&ent.bag)||[]).length;z++) o.push(String(ent.bag[z]).replace(/^gun_/,'')); return o; }
     function count(list,key){ var q=0, z; for(z=0;z<(list||[]).length;z++) if(list[z]===key) q++; return q; }
     function body(ent){ var q=null, z; for(z=0;z<g.containers.length;z++) if(g.containers[z]&&g.containers[z].fallen===ent.name) q=g.containers[z]; return q; }
     function findGhost(){ var z, q=null; if(g&&g.ents){ for(z=0;z<g.ents.length;z++) if(g.ents[z].ghost){ q=g.ents[z]; break; } if(!q&&typeof applyGhost==='function'){ applyGhost(); for(z=0;z<g.ents.length;z++) if(g.ents[z].ghost){ q=g.ents[z]; break; } } } return q; }
     // ONE: no table names them.
     for(i=0;i<NM.length;i++){
       k=NM[i];
       if(WEAPONS[k]) bad.push('the weapon table still has '+k);
       if(WTIER[k]!==undefined) bad.push('the rank table still ranks '+k);
       if(typeof GUN_FAMILY==='object'&&GUN_FAMILY[k]!==undefined) bad.push('the icon families still draw '+k);
       if(typeof DRAWT==='object'&&DRAWT[k]!==undefined) bad.push('the draw times still time '+k);
       if(typeof GEAR_LIGHT==='object'&&GEAR_LIGHT[k]!==undefined) bad.push('the gear sounds still name '+k);
       if(typeof GUNDEF==='object'&&GUNDEF[k]!==undefined) bad.push('the held gun sprites still draw '+k);
     }
     if(typeof STARTERS!=='undefined') bad.push('the starter list is still there');
     for(k in WEAPONS) if(WEAPONS[k]&&WEAPONS[k].starter) bad.push(k+' is still flagged a starter');
     // TWO: the DEMO kit deals lootable guns, and never one of the four.
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       if(!ARCADE.on&&typeof ARCADE_GUNS1!=='undefined'&&typeof ARCADE_GUNS2!=='undefined'){
         ids=ARCADE_GUNS1.concat(ARCADE_GUNS2);
         for(i=0;i<ids.length;i++){
           if(isS(ids[i])) bad.push('the DEMO gun lists still deal '+ids[i]);
           else if(!WEAPONS[ids[i]]||!ITEMS['gun_'+ids[i]]) bad.push('the DEMO gun lists deal '+ids[i]+', which is not a lootable gun');
         }
         if(arcadeDeploy({mapIx:0,seed:4242})){
           g=__state(); p=g&&g.player;
           if(g&&p){
             for(i=0;i<60;i++){
               arcadeKitApply(p,g,'zq');
               if(isS(p.wep&&p.wep.id)||isS(p.sec&&p.sec.id)){ bad.push('the DEMO kit dealt '+(p.wep&&p.wep.id)+' / '+(p.sec&&p.sec.id)); break; }
               if(!(p.wep&&ITEMS['gun_'+p.wep.id])||!(p.sec&&ITEMS['gun_'+p.sec.id])){ bad.push('the DEMO kit dealt a gun that is not lootable ('+(p.wep&&p.wep.id)+' / '+(p.sec&&p.sec.id)+')'); break; }
             }
           }
         }
       }
     }catch(x1){ bad.push('threw in the DEMO kit: '+(x1&&x1.message||x1)); }
     finally{
       try{ if(ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ var gA=__state(); if(gA&&!gA.over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     // THREE: pillagers, hired men, the drop rate, the body and the imported friend.
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(P2));
       // 30 builds with a hired man along: nobody holds one, in hand or in the pack.
       P2.merc=IDENTITIES[0].id; P2.mapIx=0;
       for(s=0;s<30;s++){
         pendSeed=(9100+s*7919)>>>0; G=null; g=buildRaid(false); G=null;
         if(!g||!g.ents) continue;
         nR++;
         for(i=0;i<g.ents.length;i++){
           e=g.ents[i]; if(e.kind!=='raider') continue;
           nE++; if(e.merc) nM++;
           h=holds(e);
           for(j=0;j<h.length;j++) if(isS(h[j])) bad.push('seed '+s+': '+(e.merc?'a hired man':'a pillager')+' holds '+h[j]);
         }
       }
       if(nR<25||nE<30) return bad.length?bad.slice(0,4).join('; '):'SKIP: the 30 builds made '+nR+' raids and '+nE+' pillagers, too few to read';
       if(!nM) bad.push('no hired man came along in 30 builds, so none was read');
       // 600 made one by one: each carries a real lootable gun, and the share whose gun leaves a copy for his body is the old six rows in nine.
       srand(5150);
       for(i=0;i<600;i++){
         r=mkRaider(1000+i*7,1000,null,true); w=r.wep;
         if(!w||r.elite===1) continue;
         tot++;
         if(isS(w.id)) bad.push('a pillager was built holding '+w.id);
         if(ITEMS['gun_'+w.id]) lootable++;
         if(r.bag.indexOf('gun_'+w.id)>=0) drops++;
         if(r.noGunDrop) side++;
       }
       if(lootable!==tot) bad.push('only '+lootable+' of '+tot+' pillagers carry a gun that can be looted');
       if(drops/tot<0.58||drops/tot>0.76) bad.push('the share of pillagers whose gun drops is '+(drops/tot).toFixed(2)+', not about 0.67 as it was');
       if(side/tot<0.26||side/tot>0.42) bad.push('the share of sidearm-row pillagers is '+(side/tot).toFixed(2)+', not about 0.33');
       // the body: the sidearm-row gun leaves none, a pack copy leaves one, a held gun with no flag still pays one.
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player;
       if(!g||g.over||!p||!g.ents||!g.containers) return bad.length?bad.slice(0,4).join('; '):'SKIP: staging: no live raid';
       keepEnts=g.ents.slice();
       function stage(tag,id,flag,pack){
         var q=mkRaider(p.x+60+made.length*40,p.y+60,IDENTITIES[0],true);
         q.name=TAG+tag; q.elite=0; q.ghost=0; q.downed=0; q.finished=0; q.byPlayer=false; q.paidRevive=0;
         q.wep=WEAPONS[id]; q.dmg=q.wep.dmg; q.rng=Math.min(q.wep.rng*0.72,580);
         q.hp=q.maxhp; q.noGunDrop=flag?id:null; q.bag=pack.slice();
         made.push(q); return q;
       }
       A=stage('ONE','magnum',true,['scrap']); B=stage('TWO','magnum',false,['gun_magnum','scrap']); C=stage('THREE','smg',false,['scrap']);
       for(k=0;k<made.length;k++){ made[k].hp=0; made[k].finished=1; made[k].downed=0; }
       g.ents.length=0; for(k=0;k<made.length;k++) g.ents.push(made[k]);
       var bb0=(typeof bodyBonus==='function')?bodyBonus:null;
       if(bb0) bodyBonus=function(){ return []; };
       try{ updateEnts(0.016); } finally { if(bb0) bodyBonus=bb0; }
       bA=body(A); bB=body(B); bC=body(C);
       if(!(bA&&bB&&bC)) return bad.length?bad.slice(0,4).join('; '):'SKIP: the staged kill did not leave all three bodies here';
       if(count(bB.loot,'gun_magnum')!==1) bad.push('control: a pillager with a Magnum in his pack left '+count(bB.loot,'gun_magnum')+' Magnums on his body, not one');
       if(count(bC.loot,'gun_smg')!==1) bad.push('control: a pillager holding a Compact SMG with no flag and no copy left '+count(bC.loot,'gun_smg')+' on his body, not one');
       if(count(bA.loot,'gun_magnum')!==0) bad.push('a sidearm-row pillager holding a Magnum left '+count(bA.loot,'gun_magnum')+' on his body, not none');
       g.ents.length=0; for(k=0;k<keepEnts.length;k++) g.ents.push(keepEnts[k]);
       for(k=g.containers.length-1;k>=0;k--){ c=g.containers[k]; if(c&&typeof c.fallen==='string'&&c.fallen.indexOf(TAG)===0) g.containers.splice(k,1); }
       try{ if(!g.over) __endRaid('abandon'); }catch(_a){}
       // an imported friend who favoured the Scav Pistol walks in with a lootable gun that is not one of the four, and so does one whose
       // file names a gun that is gone.
       why=[['pistol','QX_NS_GHOST_A'],[NM[0],'QX_NS_GHOST_B']];
       for(k=0;k<why.length;k++){
         __topClear(); __runPrep(); __cleanProfile();
         P2.merc=null;
         P2.ghost={tag:why[k][1],wep:why[k][0],wepName:'Scav Pistol',runs:3,ext:1,rate:33,avgHaul:0};
         __deploy({kit:[],safe:null,mapIx:0,seed:4242});
         g=__state(); gh=findGhost();
         if(!gh) bad.push('no imported friend came up in the raid (his file named '+why[k][0]+')');
         else {
           h=holds(gh);
           for(j=0;j<h.length;j++) if(isS(h[j])) bad.push('an imported friend holds '+h[j]);
           if(!(gh.wep&&ITEMS['gun_'+gh.wep.id])) bad.push('an imported friend (file named '+why[k][0]+') holds '+(gh.wep&&gh.wep.id)+', which is not a lootable gun');
         }
         try{ if(g&&!g.over) __endRaid('abandon'); }catch(_b){}
         P2.ghost=null;
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ var gl=__state(); if(gl&&!gl.over) __endRaid('abandon'); }catch(_e){}
       try{ RNGS=oR; RSEED=oRS; pendSeed=oPend; }catch(_s){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       __topClear();
     }
     return bad.length?bad.slice(0,5).join('; '):null; }},
  {v:'26.34',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
