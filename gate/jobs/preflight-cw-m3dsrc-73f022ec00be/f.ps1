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

if ($s.Contains("  {v:'37.60',what:")) { throw "check 37.60 is in the fixture already" }

SubRx @'
  {v:'37.59',what:
'@ @'
  {v:'37.60',what:'cw-m3dsrc, his rulings of 11-01 (season zero m3, answers 46, 57, 68): worn gear from machine wrecks, hostile pillagers and keycard rooms: over 800 seeds each machine kind drops at its row in WORN_SRC, a bigger machine more often and rarer than a crawler; staged kills of every machine kind and a pillager in a live __deploy raid put exactly the rolled pieces into the wreck or body the kill already leaves, with the normal loot, the container count, RNGS, FXS and the enemy stats the same with drops on and off, and the same seed and spawn giving the same piece; a pillager wears 0 to 2, more on a tough or elite one; a keycard room box always holds a piece a rarity step up and keeps the rest of its loot, and a plain box rolls the same piece it did; G.sim, the arcade, the demo, the switch, a hire and a linked window roll nothing; an old save reloads with nothing lost',
   run:function(){
     if(!(window.__runPrep&&window.__deploy&&window.__endRaid&&window.__state&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile&&window.__topClear)) return 'SKIP: this fixture cannot stage';
     if(typeof applyLoadedProfile!=='function'||typeof updateEnts!=='function'||typeof wornBoxRoll!=='function') return 'SKIP: no loader, enemy step or box roll here';
     if(typeof wornKillRoll!=='function'||typeof WORN_SRC!=='object'||typeof wornPieceKey!=='function') return 'no gear from wrecks, pillagers or keycard rooms in this build (wornKillRoll, WORN_SRC, wornPieceKey)';
     var saved=P, cfg={}, k, oOn=WORN_DROPS_ON, oStore=storeSet, oSave=saveProfile, bad=[], made=[], g, p, i, j, c, q, a, b, K, W, S, st={}, base, snap, oSeed, KS=['crawler','snitch','sentry','listener','bulwark','howler','choir','warden'], MK={crawler:'mkCrawler',snitch:'mkSnitch',sentry:'mkSentry',listener:'mkListener',bulwark:'mkBulwark',howler:'mkHowler',choir:'mkChoir',warden:'mkWarden'}, wsi0, keys0;
     function need(ok,msg){ if(!ok) bad.push(msg); }
     function same(x,y){ return JSON.stringify(x)===JSON.stringify(y); }
     function plain(l){ return (l||[]).filter(function(x){ return !wornKeyIs(x); }); }
     function gear(l){ return (l||[]).filter(wornKeyIs); }
     function roll(e){ var o=wornKillRoll({loot:[]},e); made=made.concat(o); return o; }
     function raid(sd){ __topClear(); __resetCfg(); __pinDefaults(0); __deploy({kit:[],safe:null,mapIx:0,seed:sd}); g=__state(); p=g&&g.player; if(!g||g.over||!p) throw new Error('seed '+sd+' built no live raid'); WORN_DROPS_ON=true; CFG.raiderDown=0; P.worn={}; P.gear=[]; p.iv=99; p.downed=false; }
     // a kill through the real death path; the new containers come back and are taken away again
     function kill(mk,on,sd,w){ var e, s0, n0, f, nw; WORN_DROPS_ON=on; g.ents.length=0; srand(sd); FXS=0x1234567;
       e=mk(); e.wsi=w; s0=JSON.stringify({hp:e.maxhp,spd:e.spd,dmg:e.dmg,rng:e.rng,cone:e.cone,w:e.wep&&e.wep.id,el:e.elite,rig:e.rig,st:e.state});
       g.ents.push(e); n0=g.containers.length; e.hp=0; e.byPlayer=true; e.downed=0;
       for(f=0;f<3&&!g.over;f++) updateEnts(0.016);
       nw=g.containers.slice(n0).map(function(x){ return x.loot.slice(); }); g.containers.length=n0; g.ents.length=0;
       return {nw:nw,r:RNGS,f:FXS,st:s0,dead:g.ents.indexOf(e)<0,e:e}; }
     for(k in CFG) cfg[k]=CFG[k];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       storeSet=function(){}; saveProfile=function(){};
       base=JSON.parse(JSON.stringify(P)); base.cfg=JSON.parse(JSON.stringify(CFG)); base.cfgv=18;
       raid(4242); oSeed=g.seed;
       // ONE: the table, over many seeds: each kind at its row, bigger machines more often and rarer
       for(i=0;i<KS.length;i++){ K=KS[i]; need(WORN_SRC[K]&&WORN_SRC[K].n&&WORN_SRC[K].o,'ONE: no row for '+K); if(!WORN_SRC[K]) continue;
         st[K]={hit:0,pcs:0,r:0};
         for(W=1;W<=1500;W++){ g.seed=7000+W*13; q=roll({kind:K,wsi:W}); if(q.length) st[K].hit++; st[K].pcs+=q.length; for(j=0;j<q.length;j++) st[K].r+=ITEMS[q[j]].pc.r; }
         st[K].p=st[K].hit/1500; st[K].mr=st[K].pcs?st[K].r/st[K].pcs:0;
         need(Math.abs(st[K].p-WORN_SRC[K].n[0])<0.06,'ONE: '+K+' dropped on '+st[K].p.toFixed(3)+' of kills, its row says '+WORN_SRC[K].n[0]);
       }
       g.seed=oSeed;
       need(st.sentry.p>st.crawler.p&&st.bulwark.p>st.sentry.p&&st.howler.p>st.sentry.p&&st.warden.p>st.bulwark.p,'ONE: a bigger machine does not drop more often: '+JSON.stringify(st));
       need(st.bulwark.mr>st.crawler.mr+0.25&&st.warden.mr>st.bulwark.mr&&st.sentry.mr>st.crawler.mr,'ONE: a bigger machine does not drop rarer: '+KS.map(function(x){ return x+' '+st[x].mr.toFixed(2); }).join(', '));
       // TWO: a pillager wears 0 to 2, more on a tough or elite one; the rarer the tougher
       a={}; [['pillager',{rig:'none'}],['tough',{rig:'heavy'}],['elite',{rig:'none',elite:1}]].forEach(function(T){ var n=0, mx=0, r=0, x, o, e;
         for(x=1;x<=800;x++){ g.seed=9000+x*7; e={kind:'raider',wsi:x,rig:T[1].rig,elite:T[1].elite}; o=roll(e); n+=o.length; if(o.length>mx) mx=o.length; for(j=0;j<o.length;j++) r+=ITEMS[o[j]].pc.r; }
         a[T[0]]={m:n/800,mx:mx,mr:n?r/n:0}; q=WORN_SRC[T[0]];
         need(q&&Math.abs(a[T[0]].m-(q.n[0]+q.n[0]*(q.n[1]||0)))<0.09,'TWO: a '+T[0]+' pillager wore '+a[T[0]].m.toFixed(3)+' pieces on average'); need(mx<=2,'TWO: a '+T[0]+' pillager wore '+mx); });
       g.seed=oSeed;
       need(a.elite.m>a.tough.m&&a.tough.m>a.pillager.m&&a.pillager.m>0.3&&a.elite.mr>a.pillager.mr,'TWO: tough and elite pillagers do not wear more and better: '+JSON.stringify(a));
       // THREE: staged kills of every machine kind in the live raid, drops on against off
       for(i=0;i<KS.length;i++){ K=KS[i]; if(typeof window[MK[K]]!=='function'){ bad.push('THREE: no '+MK[K]); continue; }
         for(W=1;W<300&&!roll({kind:K,wsi:W}).length;W++);
         for(S=11;S<60;S++){ a=kill(function(){ return window[MK[K]](p.x+320,p.y); },false,S,W); if(a.nw.length) break; }
         if(!a.nw.length){ bad.push('THREE: a staged '+K+' left nothing to search'); continue; }
         b=kill(function(){ return window[MK[K]](p.x+320,p.y); },true,S,W);
         q=gear([].concat.apply([],b.nw));
         need(a.dead&&b.dead,'THREE: the staged '+K+' did not die');
         need(b.nw.length===a.nw.length,'THREE: a '+K+' kill left '+b.nw.length+' containers with drops on, '+a.nw.length+' off');
         need(same(b.nw.map(plain),a.nw)&&!gear([].concat.apply([],a.nw)).length,'THREE: the '+K+' wreck loot differs: '+JSON.stringify(a.nw)+' / '+JSON.stringify(b.nw));
         need(a.r===b.r&&a.f===b.f,'THREE: a '+K+' kill moved a stream with drops on: '+[a.r,b.r,a.f,b.f].join());
         need(a.st===b.st,'THREE: the '+K+' stats differ with drops on: '+a.st+' / '+b.st);
         c=roll({kind:K,wsi:W,boss:b.e.boss,boss2:b.e.boss2,elite:b.e.elite});
         need(q.length>0&&same(q.slice().sort(),c.slice().sort()),'THREE: the '+K+' wreck holds '+JSON.stringify(q)+', its roll is '+JSON.stringify(c));
         a=kill(function(){ return window[MK[K]](p.x+320,p.y); },true,S,W); need(same(a.nw,b.nw),'THREE: the same '+K+' on the same seed gave '+JSON.stringify(a.nw)+' then '+JSON.stringify(b.nw));
       }
       // FOUR: a hostile pillager's body holds what he wore; the same seed, the same piece
       if(typeof mkRaider!=='function') bad.push('FOUR: no mkRaider');
       else {
         var mkP=function(){ return mkRaider(p.x+320,p.y); };
         // a spawn whose first die hits the plain row hits every pillager row (the seed is the kind and the spawn, not the row)
         for(W=1;W<300&&!roll({kind:'raider',wsi:W,rig:'none'}).length;W++);
         a=kill(mkP,false,31,W); b=kill(mkP,true,31,W);
         c=roll({kind:'raider',wsi:W,rig:b.e.rig,elite:b.e.elite});
         need(a.dead&&b.dead&&a.nw.length===1&&b.nw.length===1,'FOUR: the pillager left '+a.nw.length+' / '+b.nw.length+' bodies');
         need(same(b.nw.map(plain),a.nw)&&a.r===b.r&&a.f===b.f&&a.st===b.st,'FOUR: drops on moved his body, streams or stats: '+JSON.stringify(a.nw)+' / '+JSON.stringify(b.nw)+' '+[a.r,b.r,a.f,b.f].join());
         need(c.length>0&&same(gear(b.nw[0]||[]).sort(),c.slice().sort()),'FOUR: his body holds '+JSON.stringify(b.nw)+', he wore '+JSON.stringify(c));
         a=kill(mkP,true,31,W); need(same(a.nw,b.nw),'FOUR: the same pillager on the same seed gave '+JSON.stringify(a.nw)+' then '+JSON.stringify(b.nw));
         need(!Object.keys(b.e).some(function(x){ return /^w(orn|g)/i.test(x); }),'FOUR: something worn was written on the pillager: '+Object.keys(b.e).join());
       }
       // FIVE: keycard rooms: every box holds a piece a step up and keeps the rest; a plain box rolls what 00p-m3a rolled
       var oldRoll=function(ct){ var R=wornRand(wornBoxSeed(ct)), kinds, kk, n, r, s; if(R()>=WORN_BOX_CH) return null; kinds=Object.keys(WORN_KINDS); kk=kinds[Math.floor(R()*kinds.length)]; n=R()*100; for(r=0;r<3&&n>=WORN_RAR_ODDS[r];r++) n-=WORN_RAR_ODDS[r]; s=(R()*4294967296)>>>0; return wornKeyOf(kk,r,wornDropPw(kk,R),s); };
       a=0; b=0;
       [4242,4243,4244].forEach(function(sd){ raid(sd);
         for(i=0;i<g.containers.length;i++){ c=g.containers[i]; if(!(c&&c.d>=0&&c.type!=='botwreck'&&!c.dropped&&!c.opened&&Array.isArray(c.loot))) continue;
           var keep=c.loot.slice(), r0=RNGS, f0=FXS, want=c.inLocked?null:oldRoll(c); K=wornBoxRoll(c);
           if(RNGS!==r0||FXS!==f0) bad.push('FIVE: a box roll moved a stream');
           if(!same(plain(c.loot),keep)) bad.push('FIVE: box '+i+' lost or moved its normal loot');
           if(c.inLocked){ a++; if(!K||!(ITEMS[K].pc.r>=1)) bad.push('FIVE: keycard room box '+i+' on seed '+sd+' rolled '+K); }
           else { b++; if((K||null)!==(want||null)) bad.push('FIVE: plain box '+i+' on seed '+sd+' rolled '+K+', 00p-m3a rolled '+want); }
         } });
       need(a>=3&&b>=100,'FIVE: only '+a+' keycard room boxes and '+b+' plain boxes on three seeds');
       a={n:0,r:0}; b={n:0,r:0};
       for(i=1;i<=500;i++){ q={x:i*37,y:i*91,d:3,type:'cache',loot:[],inLocked:'cs_freezer'}; K=wornBoxRoll(q); if(K){ made.push(K); a.n++; a.r+=ITEMS[K].pc.r; if(ITEMS[K].pc.r<1) bad.push('FIVE: a keycard room box rolled scrap'); }
         q={x:i*37,y:i*91,d:3,type:'cache',loot:[]}; K=wornBoxRoll(q); if(K){ made.push(K); b.n++; b.r+=ITEMS[K].pc.r; } }
       need(a.n===500&&b.n<300&&a.r/a.n>b.r/b.n+0.8,'FIVE: keycard room boxes '+JSON.stringify(a)+' against plain boxes '+JSON.stringify(b));
       // SIX: the spawn index, fixed per build: the same machine on the same seed gives the same piece
       __topClear(); __resetCfg(); __pinDefaults(0); __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state(); WORN_DROPS_ON=true; P.worn={}; P.gear=[];
       var built=function(){ return g.ents.filter(function(e){ return e.wsi>0; }); }, ek=function(e){ return roll({kind:e.kind,wsi:e.wsi,rig:e.rig,elite:e.elite,merc:e.merc,friendlyPC:e.friendlyPC}); };
       wsi0=built().map(function(e){ return e.wsi; }); keys0=built().map(ek);
       need(wsi0.length>20&&wsi0.length>=g.ents.length*0.8&&wsi0.every(function(x,ix){ return x%1===0&&wsi0.indexOf(x)===ix; }),'SIX: the built enemies carry no distinct spawn index: '+wsi0.length+' of '+g.ents.length+' '+JSON.stringify(wsi0.slice(0,12)));
       need(keys0.some(function(x){ return x.length; }),'SIX: no enemy on seed 4242 would drop anything');
       __topClear(); __resetCfg(); __pinDefaults(0); __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state(); WORN_DROPS_ON=true; P.worn={}; P.gear=[];
       need(same(built().map(function(e){ return e.wsi; }),wsi0)&&same(built().map(ek),keys0),'SIX: seed 4242 built twice gives different spawn indexes or pieces');
       // SEVEN: nothing rolls in G.sim, the arcade, the demo, with the switch off, for a hire or a partner, or on a linked window
       q={kind:'warden',wsi:3}; for(W=1;W<300&&!roll({kind:'warden',wsi:W}).length;W++); q.wsi=W;
       var none=function(tag){ var ct={loot:['scrap']}; need(wornKillRoll(ct,q).length===0&&!ct.gearDone&&same(ct.loot,['scrap']),'SEVEN: '+tag+' rolled'); };
       g.sim=true; none('G.sim'); g.sim=false;
       g.arcade=1; none('an arcade raid'); g.arcade=0;
       if(typeof ARCADE==='object'&&ARCADE){ a=ARCADE.on; ARCADE.on=true; none('ARCADE.on'); ARCADE.on=a; }
       WORN_DROPS_ON=false; none('the switch off'); WORN_DROPS_ON=true;
       if(typeof NET==='object'&&NET){ a=NET.on; b=NET.role; NET.on=true; NET.role='join'; none('a linked window'); NET.on=a; NET.role=b; }
       q.merc=1; none('a hire'); delete q.merc; q.friendlyPC=1; none('a partner'); delete q.friendlyPC;
       need(roll(q).length>0,'SEVEN: the control warden rolled nothing');
       // EIGHT: an old save
       __topClear();
       snap=JSON.parse(JSON.stringify(base)); delete snap.gear; delete snap.worn; delete snap.gearN;
       snap.credits=4321; snap.stash=['scrap','core']; snap.weapons=['pistol','smg']; snap.equipped='smg';
       applyLoadedProfile({value:JSON.stringify(snap)});
       need(Array.isArray(P.gear)&&P.gear.length===0&&P.credits===4321&&same(P.stash,['scrap','core'])&&P.weapons.indexOf('smg')>=0&&P.equipped==='smg','EIGHT: the old save lost something (credits '+P.credits+', stash '+JSON.stringify(P.stash)+')');
       a=JSON.stringify({c:P.credits,s:P.stash,w:P.weapons,e:P.equipped,g:P.gear,pil:P.pil&&P.pil.name,h:(P.hall||[]).length});
       applyLoadedProfile({value:JSON.stringify(JSON.parse(JSON.stringify(P)))});
       need(a===JSON.stringify({c:P.credits,s:P.stash,w:P.weapons,e:P.equipped,g:P.gear,pil:P.pil&&P.pil.name,h:(P.hall||[]).length}),'EIGHT: a second load moved something');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)+' at '+String(e&&e.stack||'').split('\n').slice(1,3).join(' ')); }
     finally{
       for(i=0;i<made.length;i++) try{ delete ITEMS[made[i]]; }catch(_d){}
       P=saved; storeSet=oStore; saveProfile=oSave; WORN_DROPS_ON=oOn;
       for(k in CFG) if(!(k in cfg)) delete CFG[k]; for(k in cfg) CFG[k]=cfg[k];
       try{ var g2=__state(); if(g2&&g2.player) g2.player.iv=0; if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; ').slice(0,1800):null; }},
  {v:'37.59',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
