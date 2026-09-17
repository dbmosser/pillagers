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
  {v:'15.43',what:
'@ @'
  {v:'15.44',what:'a pillager who switches guns never leaves two copies of his old gun on his body: a Scav Pistol pillager carrying a Compact SMG swaps to it and his body holds one pistol and one SMG, with two SMGs carried it holds one pistol and both SMGs, an elite swapping his Marksman Rifle for a Longshot leaves all three guns once each, an elite carrying two Longshots leaves both of them, one who never swaps leaves his one pistol, and a swap by a man whose old gun has its copy in his pack never changes the pack length (bodies audit finding)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof mkRaider!=='function'||typeof raiderUseKit!=='function'||typeof updateEnts!=='function'||typeof IDENTITIES==='undefined'||!IDENTITIES.length) return 'SKIP: this build has no pillagers, pillager kit use or entity update';
     if(!(WEAPONS.pistol&&WEAPONS.dmr&&ITEMS.gun_pistol&&ITEMS.gun_pistol.gk==='pistol'&&ITEMS.gun_smg&&ITEMS.gun_smg.gk==='smg'&&ITEMS.gun_dmr&&ITEMS.gun_dmr.gk==='dmr'&&ITEMS.gun_sniper&&ITEMS.gun_sniper.gk==='sniper'&&ITEMS.scrap)) return 'SKIP: this build has no Scav Pistol, Compact SMG, Marksman Rifle, Longshot or scrap to stage';
     if(!((WTIER.smg||0)>(WTIER.pistol||0)&&(WTIER.sniper||0)>(WTIER.dmr||0))) return 'SKIP: the SMG does not outrank the Scav Pistol or the Longshot the Marksman Rifle here, so no swap would be offered';
     var bad=[], g=null, keepEnts=null, made=[];
     // Distinctive names, so only the bodies staged here are counted and removed.
     var TAG='QX BODY PROBE ';
     function count(list,k){ var c=0; for(var i=0;i<(list||[]).length;i++) if(list[i]===k) c++; return c; }
     function guns(list){ var o=[]; for(var i=0;i<(list||[]).length;i++) if(String(list[i]).indexOf('gun_')===0) o.push(list[i]); return o.length?o.join(', '):'no gun'; }
     function body(r){ var c=null; for(var i=0;i<g.containers.length;i++) if(g.containers[i]&&g.containers[i].fallen===r.name) c=g.containers[i]; return c; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over||!g.containers||!g.ents) return 'SKIP: no live raid';
       // CONTROL: the kit dial is on, so pillagers swap guns in this raid.
       if(CFG.raiderKit===0) return 'SKIP: pillager kit use is switched off here';
       keepEnts=g.ents.slice();
       var p=g.player;
       // A pillager holding wk with exactly this pack, full health, no heal queued and his swap test due now.
       function stage(tag,wk,elite,pack){
         var r=mkRaider(p.x+60+made.length*40,p.y+60,IDENTITIES[0],true);
         r.name=TAG+tag; r.elite=elite?1:0; r.ghost=0; r.downed=0; r.finished=0; r.byPlayer=false; r.paidRevive=0;
         r.wep=WEAPONS[wk]; r.dmg=r.wep.dmg; r.rng=Math.min(r.wep.rng*0.72,580);
         r.hp=r.maxhp; r.healQ=0; r.bag=pack.slice(); r.kitT=0;
         made.push(r); return r;
       }
       // A: the Scav Pistol with its spawn copy, and a Compact SMG. B: the same with a second SMG. C: an elite whose Marksman Rifle
       // was blessed, so it has no copy, carrying the spawn pistol and a Longshot. D: a pack with nothing better, so no swap.
       // E: the elite of C carrying two Longshots.
       var A=stage('ONE','pistol',false,['gun_pistol','gun_smg']);
       var B=stage('TWO','pistol',false,['gun_pistol','gun_smg','gun_smg']);
       var C=stage('THREE','dmr',true,['gun_pistol','gun_sniper']);
       var D=stage('FOUR','pistol',false,['gun_pistol','scrap']);
       var E=stage('FIVE','dmr',true,['gun_pistol','gun_sniper','gun_sniper']);
       var len0=[], k;
       for(k=0;k<made.length;k++){ len0.push(made[k].bag.length); raiderUseKit(made[k],0.016); }
       // CONTROL: the swap test ran for each: A and B took the SMG, C and E the Longshot, and D kept his pistol.
       if(!(A.wep&&A.wep.id==='smg'&&B.wep&&B.wep.id==='smg'&&C.wep&&C.wep.id==='sniper'&&D.wep&&D.wep.id==='pistol'&&E.wep&&E.wep.id==='sniper')) return 'SKIP: the staged swaps did not run here (held '+[A,B,C,D,E].map(function(x){ return x.wep&&x.wep.id; }).join(', ')+')';
       // KEPT: a man whose old gun has its copy in his pack (A, B), or who does not swap (D), has as many things in his pack as before.
       for(k=0;k<made.length;k++) if(made[k]!==C&&made[k]!==E&&made[k].bag.length!==len0[k]) bad.push(made[k].name+' had '+len0[k]+' things in his pack before the swap test and '+made[k].bag.length+' after');
       // All five killed in one frame down the ordinary death path: nobody else in the raid, not by the player, not a revive.
       for(k=0;k<made.length;k++){ made[k].hp=0; made[k].finished=1; made[k].downed=0; }
       g.ents.length=0; for(k=0;k<made.length;k++) g.ents.push(made[k]);
       updateEnts(0.016);
       var bA=body(A), bB=body(B), bC=body(C), bD=body(D), bE=body(E);
       // CONTROL: each of them died and left a named body to search.
       if(!(bA&&bB&&bC&&bD&&bE)) return 'SKIP: the staged kill did not leave all five bodies here ('+[bA,bB,bC,bD,bE].map(function(x){ return x?'body':'none'; }).join(', ')+')';
       // CONTROL: the ruler. The one who never swapped pays his held pistol once, as v8.44 made every body do.
       if(count(bD.loot,'gun_pistol')!==1) return 'SKIP: a pillager who never swapped left a body holding '+guns(bD.loot)+', not one Scav Pistol, so the body count cannot be read here';
       // THE FIX: one pistol in, one pistol out.
       if(count(bA.loot,'gun_pistol')!==1||count(bA.loot,'gun_smg')!==1) bad.push('a Scav Pistol pillager who swapped to the Compact SMG in his pack left a body holding '+guns(bA.loot)+', where he had one pistol and one SMG');
       // THE FIX, and what a fix that only skips the push misses: both SMGs still pay, the held one and the spare.
       if(count(bB.loot,'gun_pistol')!==1||count(bB.loot,'gun_smg')!==2) bad.push('a Scav Pistol pillager who swapped to one of the two Compact SMGs in his pack left a body holding '+guns(bB.loot)+', where he had one pistol and two SMGs');
       // KEPT: an elite blessed gun has no copy in the pack, so the swap still puts it away and all three guns pay once.
       if(count(bC.loot,'gun_pistol')!==1||count(bC.loot,'gun_dmr')!==1||count(bC.loot,'gun_sniper')!==1) bad.push('an elite who swapped his Marksman Rifle for the Longshot in his pack left a body holding '+guns(bC.loot)+', where he had one pistol, one Marksman Rifle and one Longshot');
       // THE FIX, and what a fix that still takes the new gun out of the pack misses: both Longshots pay, the held one and the spare.
       if(count(bE.loot,'gun_pistol')!==1||count(bE.loot,'gun_dmr')!==1||count(bE.loot,'gun_sniper')!==2) bad.push('an elite who swapped his Marksman Rifle for one of the two Longshots in his pack left a body holding '+guns(bE.loot)+', where he had one pistol, one Marksman Rifle and two Longshots');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(g&&keepEnts){ g.ents.length=0; for(var ke=0;ke<keepEnts.length;ke++) g.ents.push(keepEnts[ke]); } }catch(_n){}
       try{ if(g&&g.containers){ for(var ci=g.containers.length-1;ci>=0;ci--){ var cc=g.containers[ci]; if(cc&&typeof cc.fallen==='string'&&cc.fallen.indexOf(TAG)===0) g.containers.splice(ci,1); } } }catch(_b){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.43',what:
'@
SubRx @'
     var guns=function(x){
       var c=(x.wep&&x.wep.id!=='fists')?1:0;
       for(var i=0;i<(x.bag||[]).length;i++){ var it=ITEMS[x.bag[i]]; if(it&&it.use==='gun') c++; }
       return c;
     };
'@ @'
     // v15.44: the guns he has, each kind once, in his hands or his pack. A swap now leaves the new gun's copy in the pack beside
     // the old gun he put away, so counting every copy read three where the plain pillager still has two guns.
     var guns=function(x){
       var seen={}, c=0;
       if(x.wep&&x.wep.id&&x.wep.id!=='fists'){ seen[x.wep.id]=1; c++; }
       for(var i=0;i<(x.bag||[]).length;i++){ var it=ITEMS[x.bag[i]]; if(it&&it.use==='gun'&&it.gk&&!seen[it.gk]){ seen[it.gk]=1; c++; } }
       return c;
     };
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
