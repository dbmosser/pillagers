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

if ($s.Contains("  {v:'24.91',what:")) { throw "check 24.91 is in the fixture already" }

SubRx @'
  {v:'24.90',what:
'@ @'
  {v:'24.91',what:'his order: the Scav Pistol is spawn-only: in 30 raids no container, ground pile, Peddler stall or pillager (in hand or in his pack, which is what his body pays) holds one, nor does a hired man or an imported friend who favoured it; the loot, Peddler and gamble tables hold none; the free kit and the armoury pistol still put one in his hands',
   run:function(){
     if(!(window.__deploy&&window.__startRaid&&window.__state&&window.__endRaid&&window.__P&&window.__applyLoaded&&typeof buildRaid==='function'&&typeof commitKit==='function')) return 'SKIP: this fixture cannot build a raid';
     if(!(WEAPONS.pistol&&ITEMS.gun_pistol&&ITEMS.gun_pistol.gk==='pistol')) return 'SKIP: no Scav Pistol in this build';
     var bad=[], K='gun_pistol', W='pistol', P2=__P(), snap=null, oR=RNGS, oRS=RSEED, oPend=pendSeed, hits={}, nR=0, nC=0, nE=0, nM=0, i, j, s, g, e, c, tk, gh, p, out=[];
     function hit(w){ hits[w]=(hits[w]||0)+1; }
     function has(a){ return !!a&&a.indexOf(K)>=0; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(P2));
       for(tk in LOOT) if(LOOT[tk]&&LOOT[tk].length) for(j=0;j<LOOT[tk].length;j++) if(LOOT[tk][j][0]===K) hit('the LOOT.'+tk+' table');
       if(typeof PED_GUNS!=='undefined'&&has(PED_GUNS)) hit('the Peddler gun list');
       if(typeof GAMBLE_POOL!=='undefined') for(j=0;j<GAMBLE_POOL.length;j++) if(GAMBLE_POOL[j][0]===K) hit('the gamble table');
       // 30 live builds on COLD STORAGE, with a hired man along so his roll is read too
       if(typeof IDENTITIES!=='undefined'&&IDENTITIES.length) P2.merc=IDENTITIES[0].id;
       P2.mapIx=0;
       for(s=0;s<30;s++){
         pendSeed=(9100+s*7919)>>>0; G=null; g=buildRaid(false); G=null;
         if(!g||!g.containers||!g.ents) continue;
         nR++;
         for(i=0;i<g.containers.length;i++){ c=g.containers[i]; nC++; if(has(c.loot)) hit(c.dropped?'a ground pile':('a '+c.type)); }
         for(i=0;i<g.ents.length;i++){
           e=g.ents[i];
           if(e.kind==='raider'){
             nE++; if(e.merc) nM++;
             if(e.wep&&e.wep.id===W) hit(e.merc?'a hired man, in hand':'a pillager, in hand');
             if(has(e.bag)) hit(e.merc?'a hired man, in his pack':'a pillager, in his pack');
           }
           if(e.stock&&e.stock.length) for(j=0;j<e.stock.length;j++) if(e.stock[j]&&e.stock[j].k===K) hit('the Peddler stall');
         }
       }
       if(nR<25||nC<500||nE<30) return 'SKIP: the 30 builds made '+nR+' raids, '+nC+' containers and '+nE+' pillagers, too few to read';
       // an imported friend who favoured the Scav Pistol
       P2.merc=null;
       P2.ghost={tag:'QX_SSP_GHOST',wep:W,wepName:'Scav Pistol',runs:3,ext:1,rate:33,avgHaul:0};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); gh=null;
       if(g&&g.ents){
         for(i=0;i<g.ents.length;i++) if(g.ents[i].ghost){ gh=g.ents[i]; break; }
         if(!gh&&typeof applyGhost==='function'){ applyGhost(); for(i=0;i<g.ents.length;i++) if(g.ents[i].ghost){ gh=g.ents[i]; break; } }
       }
       if(gh){ if(gh.wep&&gh.wep.id===W) hit('an imported friend, in hand'); if(has(gh.bag)) hit('an imported friend, in his pack'); }
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_a){}
       P2.ghost=null;
       for(var w in hits) out.push(w+' x'+hits[w]);
       if(out.length) bad.push('the Scav Pistol can still be found ('+nR+' raids, '+nC+' containers, '+nE+' pillagers read): '+out.join(', '));
       // THE SPAWN PATHS THAT STAY. The free kit, the route the lift takes:
       __topClear(); __runPrep(); __cleanProfile();
       P2.stash=[]; P2.kit=[]; P2.safe=null; P2.weapons=[W]; P2.equipped='fists'; P2.equippedSec='none'; P2.freeKit=1; P2.kitChosen=0; P2.ghost=null; P2.merc=null; saveProfile();
       commitKit(); __startRaid({mapIx:0,seed:4242});
       g=__state(); p=g&&g.player;
       if(!g||!g.freeKit) bad.push('the raid did not take the free kit');
       else if(!p||!p.wep||p.wep.id!==W) bad.push('the free kit did not put the Scav Pistol in his hands (holding '+(p&&p.wep&&p.wep.id)+')');
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_b){}
       // and the armoury pistol every save starts with, taken up with an empty kit
       __topClear(); __runPrep(); __cleanProfile();
       P2.weapons=[W]; P2.equipped=W; P2.equippedSec='none'; P2.freeKit=0; P2.kitSaved=null; P2.kitBeforeFree=null; saveProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player;
       if(!p||!p.wep||p.wep.id!==W) bad.push('an empty kit with the armoury Scav Pistol did not deploy holding it (holding '+(p&&p.wep&&p.wep.id)+')');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ var gl=__state(); if(gl&&!gl.over) __endRaid('abandon'); }catch(_e){}
       try{ RNGS=oR; RSEED=oRS; pendSeed=oPend; }catch(_s){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'24.90',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
