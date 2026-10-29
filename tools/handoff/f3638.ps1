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

if ($s.Contains("  {v:'36.38',what:")) { throw "check 36.38 is in the fixture already" }

SubRx @'
  {v:'36.37',what:
'@ @'
  {v:'36.38',what:'each gun has one rarity: every Auto Rifle roll is purple, all gun sources and Wirt odds agree, and a saved Magnum keeps its cell, lock, belt, wear and Forge marks',
   run:function(){
     var snap=null, rng0=RNGS, seed0=RSEED, pend0=pendSeed, pool0=GAMBLE_POOL.slice(), sp0=saveProfile, rg0=renderGamble, rh0=renderHub;
     var bad=[], g, p, q, i, j, k, w, x, st, o, want, got, sum=0, el, h0, btn=document.getElementById('gamblebtn');
     var src=['smg','magnum','carbine','shotgun','rifle','lmg'], dmg=[15,77.5,21.25,20,28.75,20], val=[1350,1500,1650,1950,2250,2850], rar=['rare','elite','elite','elite','elite','gold'];
     function item(k){ var it=ITEMS[k]; if(it&&it.use==='gun'&&src.indexOf(it.gk)>=0&&dispR(k)!==rar[src.indexOf(it.gk)]) bad.push('lower gun item '+k); }
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       for(i=0;i<src.length;i++){
         k=src[i]; w=WEAPONS[k];
         if(!w||w.dmg!==dmg[i]||ITEMS['gun_'+k].val!==val[i]||gunRarity(k)!==rar[i]) bad.push('not the former higher '+k);
         if(WEAPONS[k+'_v']||ITEMS['gun_'+k+'_v']) bad.push('second live id for '+k);
       }
       srand(719); for(i=0;i<1000;i++){ w=rollFieldGun('rifle'); if(w.id!=='rifle'||gunRarity(w.id)!=='elite'||w.dmg!==28.75){ bad.push('Auto Rifle roll '+i+' is '+w.id+' / '+w.dmg); break; } }
       srand(73); rr(); x=RNGS; srand(73); rollFieldGun('rifle'); if(RNGS!==x) bad.push('field roll draw count changed');
       for(k in ITEMS) item(k);
       for(i=0;i<SHOP.length;i++) item(SHOP[i].kind==='wep'?'gun_'+SHOP[i].k:SHOP[i].k);
       for(i=0;i<PED_GUNS.length;i++) item(PED_GUNS[i]);
       for(i=0;i<ARCADE_GUNS2.length;i++) if(src.indexOf(ARCADE_GUNS2[i])>=0&&gunRarity(ARCADE_GUNS2[i])!==rar[src.indexOf(ARCADE_GUNS2[i])]) bad.push('lower arcade gun');
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state(); p=g&&g.player;
       if(!g||!p||g.over) return 'no raid for source checks';
       for(i=0;i<60;i++){
         st=mkPeddler(1000+i*31,1200+i*17,g.map).stock;
         for(j=0;j<st.length;j++) item(st[j].k);
         w=mkRaider(1000+i*7,1000,null,true).wep; if(w&&src.indexOf(w.id)>=0&&gunRarity(w.id)!==rar[src.indexOf(w.id)]) bad.push('lower pillager gun');
       }
       want={}; sum=0;
       for(i=0;i<GAMBLE_POOL.length;i++){ k=GAMBLE_POOL[i][0]; item(k); x=GAMBLE_POOL[i][1]; o=k==='KEY'?'rare':dispR(rvKey(k,0.99)); want[o]=(want[o]||0)+x; sum+=x; }
       got=gambleOdds(); for(i=0;i<got.length;i++) if(Math.abs(got[i][1]-(want[got[i][0]]||0)/sum)>1e-10) bad.push('Wirt odds disagree for '+got[i][0]);
       saveProfile=function(){}; renderGamble=function(){}; renderHub=function(){};
       for(i=0;i<src.length;i++){
         GAMBLE_POOL.length=0; GAMBLE_POOL.push(['gun_'+src[i],1]);
         q=__P(); q.stash=[]; q.credits=GAMBLE_PRICE*1100;
         for(j=0;j<30;j++) btn.onclick();
         if(q.stash.length!==30||q.stash.some(function(key){return key!=='gun_'+src[i]||dispR(key)!==rar[i];})) bad.push('Wirt produced a lower '+src[i]);
         o=gambleOdds(); if(o.length!==1||o[0][0]!==rar[i]||o[0][1]!==1) bad.push('Wirt has a lower odds row for '+src[i]);
         el=document.getElementById('gambleodds'); h0=el?el.innerHTML:null; gambleOddsDraw();
         if(el&&el.textContent.indexOf(rar[i])<0) bad.push('odds page omits '+rar[i]);
         if(el&&h0!==null) el.innerHTML=h0;
       }
       __endRaid('abandon'); __topClear();
       q=JSON.parse(JSON.stringify(__P())); q.beltV=5; q.hotbarV=10; q.mig945=1;
       q.stash=['scrap','gun_magnum','plate','gun_magnum_v']; q.weapons=['magnum','rifle_v']; q.equipped='magnum'; q.equippedSec='rifle_v';
       q.keep={gun_magnum:1,gun_magnum_v:1}; q.hotAssign={0:'gun_magnum',2:'gun_rifle_v'};
       q.kit=['gun_magnum','gun_rifle_v']; q.kitSaved={kit:['gun_magnum','gun_rifle_v'],hot:{0:'gun_magnum'}};
       q.wear={magnum:37,rifle_v:19}; q.forged={magnum:{fk:2,el:'shock'},rifle_v:{fk:1,el:''}};
       __applyLoaded(q); q=__P();
       if(q.stash.join(',')!=='scrap,gun_magnum,plate,gun_magnum'||dispR(q.stash[1])!=='elite') bad.push('saved Magnum lost its cell or higher rarity');
       if(!q.keep.gun_magnum||q.keep.gun_magnum_v||q.hotAssign[0]!=='gun_magnum'||q.hotAssign[2]!=='gun_rifle') bad.push('lock or belt assignment lost');
       if(q.kit[0]!=='gun_magnum'||q.kit[1]!=='gun_rifle'||q.kitSaved.kit[1]!=='gun_rifle') bad.push('kit migration lost a pick');
       if(q.wear.magnum!==37||q.wear.rifle!==19||!q.forged.magnum||q.forged.magnum.fk!==2||q.forged.magnum.el!=='shock'||!q.forged.rifle||q.forged.rifle.fk!==1) bad.push('wear or Forge marks lost');
       x=JSON.stringify(q); oneGunProfile(q); if(JSON.stringify(q)!==x) bad.push('migration is not idempotent');
       return bad.length?bad.slice(0,8).join('; '):null;
     } finally {
       saveProfile=sp0; renderGamble=rg0; renderHub=rh0;
       GAMBLE_POOL.length=0; for(i=0;i<pool0.length;i++) GAMBLE_POOL.push(pool0[i]);
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       if(snap) __applyLoaded(snap);
       RNGS=rng0; RSEED=seed0; pendSeed=pend0; __topClear();
     }
   }},
  {v:'36.37',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
