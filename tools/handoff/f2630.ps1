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

if ($s.Contains("  {v:'26.30',what:")) { throw "check 26.30 is in the fixture already" }

SubRx @'
  {v:'26.29',what:
'@ @'
  {v:'26.30',what:'his order (2026-10-14), the other ways a gun turns up: a pillager carries the twin one rarity up about one time in seven and his body drops it, an elite pillager about one in six, the Peddler stocks it at one stall in five, Wirt gamble gives it one gun in five, none of them draws a new number, and the stat card names the rarity (the same model at another rarity says which) and the hover damage row of a twin says its rarity and gain',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__topClear&&window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile&&window.__applyLoaded)||typeof mkRaider!=='function'||typeof mkPeddler!=='function'||typeof gunCardDraw!=='function'||typeof gunCompare!=='function'||typeof itemRows!=='function'||typeof rollTable!=='function') return 'SKIP: this fixture cannot build a pillager, a stall or a gun card';
     if(typeof RV_OF==='undefined'||typeof RV_BASE==='undefined'||typeof rvKey!=='function'||typeof RT_FRAC==='undefined') return 'the other gun sources have no rarity variants (rvKey, RT_FRAC)';
     var bad=[], P2=__P(), i, j, cnt, n, r, w, e, a, b, st, rows, txt, rec, snap=null, s0=RNGS, r0=RSEED, pend0=pendSeed, pct0=RV_PCT, er0=CFG.eliteRate, oFT=null, oRG=renderGamble, oRH=renderHub, oSP=saveProfile, gp0=GAMBLE_POOL.slice(), cr0=P2.credits, stash0=P2.stash.slice(), gl0=P2.gambleLog, gb=document.getElementById('gamblebtn'), g, p;
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player;
       if(!g||!p||g.over) return 'SKIP: no live raid';
       // ONE: pillagers. 300 built: the twin one time in about seven, the gun, the damage and the bag agree, and the draw count is the old one.
       srand(5150); cnt=0; n=300;
       for(i=0;i<n;i++){
         r=mkRaider(1000+i*7,1000,null,true); w=r.wep;
         if(w&&RV_BASE[w.id]){
           cnt++;
           if(r.dmg!==WEAPONS[w.id].dmg||w.dmg!==WEAPONS[RV_BASE[w.id]].dmg*VARIANT_DMG) bad.push('a pillager with the '+w.name+' twin has the wrong damage ('+r.dmg+')');
           if(r.elite!==1&&r.bag.indexOf('gun_'+w.id)<0) bad.push('a pillager with the '+w.name+' twin does not carry its twin to drop');
           if(r.elite===1&&!ITEMS['gun_'+w.id]) bad.push('an elite pillager with the '+w.name+' twin has no item for his body to drop');
         } else if(w&&w.id!=='tacker'&&w.id!=='smg'&&w.id!=='rifle'&&w.id!=='carbine'&&w.id!=='shotgun'&&r.elite!==1) bad.push('a pillager carries '+w.id);
       }
       if(cnt<15||cnt>80) bad.push('pillagers carried a twin '+cnt+' times in '+n+' (about 40 expected)');
       srand(11); mkRaider(500,500,null,true); a=RNGS; RV_PCT=0; srand(11); mkRaider(500,500,null,true); b=RNGS; RV_PCT=pct0;
       if(a!==b) bad.push('a pillager with the twins on draws a different count of numbers from one with them off');
       // TWO: elite pillagers (every one made one): the pool gun, its twin about one in six.
       CFG.eliteRate=2; srand(777); cnt=0; n=240; a=0;
       for(i=0;i<n;i++){
         r=mkRaider(2000+i*7,1000,null,true); w=r.wep;
         if(r.elite&&w){ a++; if(RV_BASE[w.id]) cnt++; }
       }
       CFG.eliteRate=er0;
       if(a<200) bad.push('control: only '+a+' of '+n+' pillagers came out elite with the rate pinned high');
       if(cnt<14||cnt>75) bad.push('elite pillagers carried a twin '+cnt+' times in '+n+' (about 40 expected)');
       // THREE: the Peddler. 400 stalls: the gun slot is the twin at about one stall in five, the stock and the price follow.
       srand(321); cnt=0; n=400;
       for(i=0;i<n;i++){
         st=mkPeddler(Math.floor(100+i*13.7),Math.floor(50+i*7.3),null); w=null;
         for(j=0;j<st.stock.length;j++) if(/^gun_/.test(st.stock[j].k)&&!st.stock[j].showpiece){ w=st.stock[j]; break; }
         if(!w){ bad.push('a stall had no gun in its gun slot'); break; }
         if(RV_BASE[ITEMS[w.k].gk]){ cnt++; if(w.price!==pedPrice(w.k)) bad.push('a twin on a stall is priced '+w.price+', not '+pedPrice(w.k)); }
       }
       if(cnt<40||cnt>130) bad.push('the Peddler stocked the twin at '+cnt+' of '+n+' stalls (about 80 expected)');
       srand(9); mkPeddler(300,200,null); a=RNGS; RV_PCT=0; srand(9); mkPeddler(300,200,null); b=RNGS; RV_PCT=pct0;
       if(a!==b) bad.push('a stall with the twins on draws a different count of numbers from one with them off');
       // FOUR: Wirt. A table of two guns only, 120 pulls: about one in five is a twin, each pull still draws one number.
       srand(4); rollTable([['gun_smg',1],['gun_dmr',1]]); a=RNGS; srand(4); rr(); b=RNGS;
       if(a!==b) bad.push('rollTable draws more or fewer than the one number it always drew');
       if(!gb||typeof gb.onclick!=='function') bad.push('SKIP: no gamble button here');
       else {
         renderGamble=function(){}; renderHub=function(){}; saveProfile=function(){};
         GAMBLE_POOL.length=0; GAMBLE_POOL.push(['gun_smg',1],['gun_dmr',1]);
         P2.stash=[]; P2.credits=1e12; srand(1999); cnt=0; n=120;
         for(i=0;i<n;i++) gb.onclick();
         a=0; for(i=0;i<P2.stash.length;i++){ if(P2.stash[i]==='gun_smg_v'||P2.stash[i]==='gun_dmr_v') cnt++; else if(P2.stash[i]==='gun_smg'||P2.stash[i]==='gun_dmr') a++; }
         if(a+cnt!==n) bad.push('120 gambles left '+(a+cnt)+' guns in the stash');
         if(cnt<8||cnt>45) bad.push('Wirt gave the twin '+cnt+' times in '+n+' gambles (about 24 expected)');
       }
       // FIVE: the words. The stat card of a twin names its rarity in its colour; against its own model it says which rarity it is against.
       rec=[]; oFT=ctx.fillText;
       ctx.fillText=function(t,x,y,mw){ rec.push(String(t)); return oFT.apply(this,arguments); };
       try{ gunCardDraw(gunCompare(WEAPONS.smg_v,WEAPONS.smg),700,500,1,''); } finally { delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }
       txt=rec.join('|');
       if(rec.indexOf('RARE')<0) bad.push('the blue Compact SMG card does not say RARE ('+txt.slice(0,100)+')');
       if(rec.indexOf('UPGRADE')<0) bad.push('the blue Compact SMG card against the green one does not say UPGRADE');
       if(rec.indexOf('VS COMPACT SMG UNCOMMON')<0) bad.push('the card does not say which rarity the same model is against ('+txt.slice(0,160)+')');
       if(rec.indexOf(String(WEAPONS.smg_v.dmg))<0) bad.push('the card does not show the damage number '+WEAPONS.smg_v.dmg);
       rows=itemRows('gun_smg_v'); a=null; for(i=0;i<rows.length;i++) if(rows[i][0]==='DAMAGE') a=String(rows[i][1]);
       if(a===null||a.indexOf('RARE')<0||a.indexOf('+25%')<0) bad.push('the damage row of the blue Compact SMG hover does not say its rarity and what it adds ('+a+')');
       b=itemRows('gun_smg'); a=null; for(i=0;i<b.length;i++) if(b[i][0]==='DAMAGE') a=String(b[i][1]);
       if(a===null||a.indexOf('+25%')>=0) bad.push('the damage row of the green Compact SMG hover claims a gain ('+a+')');
       if(rows.length!==b.length||rows.length>8) bad.push('the hover rows of the twin are '+rows.length+' against '+b.length+' for its model');
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       try{ if(oFT){ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; } }catch(_f){}
       try{ renderGamble=oRG; renderHub=oRH; saveProfile=oSP; }catch(_g){}
       try{ GAMBLE_POOL.length=0; for(i=0;i<gp0.length;i++) GAMBLE_POOL.push(gp0[i]); }catch(_p){}
       try{ RV_PCT=pct0; CFG.eliteRate=er0; }catch(_e2){}
       try{ var g2=__state(); if(g2){ g2.drag=null; if(g2.player){ g2.player.iv=0; g2.player.downed=false; } if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       try{ keys={}; }catch(_k){}
       try{ RNGS=s0; RSEED=r0; pendSeed=pend0; }catch(_s){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.slice(0,4).join('; '):null; }},
  {v:'26.29',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
