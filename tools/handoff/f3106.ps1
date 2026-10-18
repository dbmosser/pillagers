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

if ($s.Contains("  {v:'31.06',what:")) { throw "check 31.06 is in the fixture already" }

SubRx @'
  {v:'31.05',what:
'@ @'
  {v:'31.06',what:'cw-barrels3, his note (2026-10-18): "add other exploding barrels, e.g. electricity, toxic waste, dry ice": three new kinds beside the red one, laid by a pure hash of the seed and the spot (all four in a few raids, the same kinds on the same seed, the seed 4242 fingerprint unchanged), each with its own blast on the Forge effects (shock stuns and arcs, acid eats armour and leaves a pool, cryo freezes and leaves a fog, a frozen crawler shatters), its own sound, drawn in a real frame, lit in a chain by a real round, never hurting a teammate in co-op',
   run:function(){
     if(typeof brlKindAt!=='function'||typeof BRLK!=='object') return 'the barrels have only the red kind in this build (no brlKindAt)';
     var bad=[], g=null, p=null, p0=null, L=null, i, k, tot=0, kinds={red:0,shock:0,acid:0,cryo:0}, sds=[4242,9071,31337,2024,777,5150], si, sig1='', sig2='', fp={}, heard=[], hits=[], drawn={}, A, B, C, D, c1, c2, c3, r, hp0, ar0, a0, a1, tk, NK0=null;
     var oSfx=sfx, oDmg=damagePlayer, oDK=brlDrawK, oPD=brlPoolDraw, oUp=netUpShared;
     function sigOf(q){ return q.brl.map(function(b){ return Math.round(b.x)+','+Math.round(b.y)+','+b.k; }).join(';'); }
     function cnt(nm){ return heard.filter(function(s){ return s===nm; }).length; }
     function nhit(s){ return hits.filter(function(h){ return h.indexOf(s)===0; }).length; }
     function lane(){
       var bi, q, a, ca, sa, b, ok, o;
       for(bi=0;bi<g.brl.length;bi++){
         b=g.brl[bi];
         for(q=0;q<16;q++){
           a=q*0.3927; ca=Math.cos(a); sa=Math.sin(a); ok=true;
           for(o=-1;o<=1&&ok;o++) if(!losClear(b.x-sa*18*o,b.y+ca*18*o,b.x+ca*340-sa*18*o,b.y+sa*340+ca*18*o,g.map.segs)) ok=false;
           if(ok) return {x:b.x,y:b.y,ux:ca,uy:sa};
         }
       }
       return null;
     }
     function mkb(kd,d,id,by){ return {id:id,x:L.x+L.ux*d,y:L.y+L.uy*d,hp:BRL_HP,fuse:-1,by:(by===undefined?-1:by),gone:0,k:kd}; }
     function crawl(d,hp){ var e=mkCrawler(L.x+L.ux*d,L.y+L.uy*d); e.hp=e.maxhp=hp||900; e.state='patrol'; e.alert=0; g.ents.push(e); return e; }
     function reset(){
       g.brl.length=0; g.ents.length=0; g.bfire=[]; g.arcs=[]; heard.length=0; hits.length=0;
       p.x=L.x+L.ux*40; p.y=L.y+L.uy*40; p.hp=100; p.armor=0; p.iv=0; p.downed=false; p.dying=false; p.specOut=false; g.deathBeat=null;
     }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       // ONE: the kinds. All four in a few raids, about the mix, the same on the same seed, and the seed 4242 fingerprint where it was
       for(si=0;si<sds.length;si++){
         __deploy({kit:[],safe:null,mapIx:0,seed:sds[si]});
         g=__state(); p=g&&g.player; if(!g||g.over||!p) return 'SKIP: no live raid';
         if(!Array.isArray(g.brl)||g.brl.length<8){ bad.push('ONE: seed '+sds[si]+' has '+(g.brl&&g.brl.length)+' barrels'); __endRaid('abandon'); __topClear(); continue; }
         for(i=0;i<g.brl.length;i++){
           k=g.brl[i].k;
           if(!(k in kinds)){ bad.push('ONE: seed '+sds[si]+' barrel '+i+' has the kind '+k); continue; }
           kinds[k]++; tot++;
           if(brlKindAt(g.seed,g.brl[i].x,g.brl[i].y)!==k) bad.push('ONE: seed '+sds[si]+' barrel '+i+' is not the kind its place hashes to');
         }
         if(si===0) sig1=sigOf(g);
         __endRaid('abandon'); __topClear();
       }
       for(k in kinds) if(!kinds[k]) bad.push('ONE: no '+k+' barrel in '+sds.length+' raids');
       if(tot&&!(kinds.red/tot>0.35&&kinds.red/tot<0.75)) bad.push('ONE: red is '+Math.round(100*kinds.red/tot)+' percent of '+tot+' barrels, not about 55');
       __deploy({kit:[],safe:null,mapIx:0,seed:sds[0]});
       g=__state(); p=g.player; p0={x:p.x,y:p.y}; sig2=sigOf(g);
       if(sig1!==sig2) bad.push('ONE: the same seed laid different kinds the second time');
       p.x=140; p.y=140; brlPlace(g);
       if(sigOf(g)!==sig1) bad.push('ONE: laying the barrels again with the player somewhere else changed a spot or a kind (a second window would see another set)');
       p.x=p0.x; p.y=p0.y;
       [0,1].forEach(function(mi){ __resetCfg(); __pinDefaults(mi); __startRaid({mapIx:mi,seed:4242}); var q=__state(); fp[mi]=q.ents.length+'/'+q.containers.length; try{ __endRaid('abandon'); }catch(_f){} __topClear(); });
       if(fp[0]!=='85/165'||fp[1]!=='374/593') bad.push('ONE: the seed 4242 fingerprint moved: '+fp[0]+' and '+fp[1]+', not 85/165 and 374/593');
       __resetCfg(); __pinDefaults(0); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; if(!g||g.over||!p) return 'SKIP: no live raid';
       p0={x:p.x,y:p.y}; g.mapOpen=false; g.mapCur=null;
       // TWO: all four kinds are drawn in a real frame, and a pool and a fog too
       if(typeof __vpAlive!=='function'||__vpAlive()){
         g.brl.length=0; g.ents.length=0; g.bfire=[]; p.iv=99;
         ['red','shock','acid','cryo'].forEach(function(kd,q){ g.brl.push({id:q,x:p0.x-90+q*60,y:p0.y-60,hp:BRL_HP,fuse:-1,by:-1,gone:0,k:kd}); });
         g.brl.push({id:4,x:p0.x-20,y:p0.y+70,hp:BRL_HP,fuse:0.5,by:-1,gone:0,k:'shock'});
         g.bfire.push({x:p0.x-80,y:p0.y+60,r:72,t:1,life:6,by:-1,bt:0,k:'acid'},{x:p0.x+80,y:p0.y+60,r:96,t:1,life:5,by:-1,bt:0,k:'cryo'});
         brlDrawK=function(Q){ drawn[Q.k]=(drawn[Q.k]||0)+1; return oDK.apply(this,arguments); };
         brlPoolDraw=function(Q){ drawn['pool_'+Q.k]=(drawn['pool_'+Q.k]||0)+1; return oPD.apply(this,arguments); };
         try{ __frame(0.016); __frame(0.016); __frame(0.016); }
         catch(fe){ bad.push('TWO: a frame with all four barrels and a pool and a fog threw: '+(fe&&fe.message||fe)); }
         brlDrawK=oDK; brlPoolDraw=oPD;
         ['shock','acid','cryo','pool_acid','pool_cryo'].forEach(function(kd){ if(!drawn[kd]) bad.push('TWO: a frame drew no '+kd); });
         p.iv=0;
       }
       // THREE: a clear lane for the blasts, and the stub of the sound and the damage
       L=lane(); if(!L) return 'SKIP: staging: no clear lane near a barrel on this seed';
       sfx=function(nm){ heard.push(String(nm)); };
       damagePlayer=function(am,sr,nm){ hits.push(String(sr)+':'+String(nm)); return oDmg.apply(this,arguments); };
       // SHOCK: stuns what it strikes, the arc chains on past the blast's reach, the player is hurt, its own sound
       reset(); A=mkb('shock',0,0); g.brl.push(A); c1=crawl(100); c2=crawl(190);
       brlBlast(A);
       if(!A.gone) bad.push('SHOCK: the barrel did not go off');
       if(cnt('barrelShock')!==1||cnt('barrelBlast')) bad.push('SHOCK: the blast made '+heard.join(',')+', not one barrelShock');
       if(!(c1.stunT>0.5)) bad.push('SHOCK: a machine 100 from the blast is not stunned ('+c1.stunT+')');
       if(!(c1.hp<900)) bad.push('SHOCK: a machine 100 from the blast took nothing');
       if(!(c2.hp<900)) bad.push('SHOCK: the arc did not chain on to the machine 90 past the first (190 from the barrel, outside its reach)');
       if(!(c2.stunT>0)) bad.push('SHOCK: the machine the arc reached is not stunned');
       if(!(g.arcs&&g.arcs.length>=2)) bad.push('SHOCK: no arcs were drawn ('+(g.arcs&&g.arcs.length)+')');
       if(!(p.hp<100)||nhit('barrel:SHOCK')!==1) bad.push('SHOCK: the player 40 away was hurt '+nhit('barrel:SHOCK')+' times (hp '+p.hp+')');
       if(g.bfire.length) bad.push('SHOCK: a shock barrel left a pool');
       // ACID: eats armour, corrodes, a smaller blast, leaves a pool that hurts and goes on eating, then goes out
       reset(); A=mkb('acid',0,0); g.brl.push(A); r=mkRaider(L.x+L.ux*60,L.y+L.uy*60,IDENTITIES[0],false); r.rig='heavy'; r.armor=120; r.hp=r.maxhp=900; g.ents.push(r); c1=crawl(100,900); p.armor=50;
       brlBlast(A);
       if(cnt('barrelAcid')!==1||cnt('barrelBlast')) bad.push('ACID: the blast made '+heard.join(',')+', not one barrelAcid');
       if(!(r.armor<120)) bad.push('ACID: the plate of a pillager 60 away was not eaten ('+r.armor+' of 120)');
       if(!(r.corrT>0)) bad.push('ACID: the pillager is not corroded');
       if(!(r.hp<900)) bad.push('ACID: the pillager took nothing');
       if(c1.hp<900&&!(c1.corrT>0)) bad.push('ACID: the machine the blast hurt is not corroded');
       if(g.bfire.length!==1||g.bfire[0].k!=='acid') bad.push('ACID: the blast left '+g.bfire.length+' pools, the first a '+(g.bfire[0]&&g.bfire[0].k));
       if(!(p.hp<100)||nhit('barrel:ACID')!==1) bad.push('ACID: the player was hurt '+nhit('barrel:ACID')+' times (hp '+p.hp+')');
       a0=r.armor; ar0=p.armor; hp0=r.hp; tk=nhit('acid:');
       for(i=0;i<8;i++) brlTick(0.3);
       if(!(r.armor<a0)) bad.push('ACID: the pool did not go on eating the plate ('+a0+' to '+r.armor+')');
       if(!(r.hp<hp0)) bad.push('ACID: the pool did not hurt the pillager standing in it');
       if(nhit('acid:')<=tk) bad.push('ACID: the pool did not hurt the player standing in it');
       if(!(p.armor<ar0)) bad.push('ACID: the pool did not eat the plate of the player standing in it ('+ar0+' to '+p.armor+')');
       brlTick(30);
       if(g.bfire.length) bad.push('ACID: the pool never went out ('+g.bfire.length+')');
       // CRYO: the middle freezes, the rim is slowed, the fog goes on chilling until it freezes, and a frozen crawler shatters (by a second cryo barrel, and by a red one)
       reset(); A=mkb('cryo',0,0); g.brl.push(A); c1=crawl(50); c2=crawl(100); c3=crawl(60);
       brlBlast(A);
       if(cnt('barrelCryo')!==1||cnt('barrelBlast')) bad.push('CRYO: the blast made '+heard.join(',')+', not one barrelCryo');
       if(!(c1.frozenT>0)) bad.push('CRYO: a machine 50 from the blast is not frozen');
       if(!(c2.chillT>0)||c2.frozenT>0) bad.push('CRYO: a machine 100 from the blast should be slowed and not frozen (chill '+c2.chillT+', frozen '+c2.frozenT+')');
       if(g.bfire.length!==1||g.bfire[0].k!=='cryo') bad.push('CRYO: the blast left '+g.bfire.length+' fogs, the first a '+(g.bfire[0]&&g.bfire[0].k));
       if(nhit('barrel:CRYO')!==1) bad.push('CRYO: the player was hurt '+nhit('barrel:CRYO')+' times by the blast');
       for(i=0;i<8;i++) brlTick(0.3);
       if(!(c2.frozenT>0)) bad.push('CRYO: a machine that stays in the fog was never frozen by it');
       if(nhit('cold:')<1) bad.push('CRYO: the fog did not hurt the player standing in it');
       c3.frozenT=2; B=mkb('red',40,1); g.brl.push(B); heard.length=0; brlBlast(B);
       if(!(c3.hp<=0)) bad.push('CRYO: a red blast did not shatter a frozen crawler (hp '+c3.hp+' of 900)');
       if(cnt('elFreeze')<1) bad.push('CRYO: the shatter made no crack');
       c1.frozenT=2; C=mkb('cryo',20,2); g.brl.push(C); brlBlast(C);
       if(!(c1.hp<=0)) bad.push('CRYO: a second cryo blast did not shatter the frozen crawler (hp '+c1.hp+' of 900)');
       brlTick(30);
       if(g.bfire.length) bad.push('CRYO: the fog never cleared ('+g.bfire.length+')');
       // CHAIN: a real round into a shock barrel lights the acid barrel beside it and the cryo barrel beside that
       reset(); p.iv=99; A=mkb('shock',72,0); B=mkb('acid',36,1); C=mkb('cryo',0,2); g.brl.push(A,B,C);
       g.bullets.length=0;
       g.bullets.push({x:L.x+L.ux*130,y:L.y+L.uy*130,vx:-1180*L.ux,vy:-1180*L.uy,dmg:200,life:1,player:true,owner:p,tint:'#ffd48a',thru:0});
       for(i=0;i<10;i++) updateBullets(0.016);
       if(!(A.fuse>=0||A.gone)) bad.push('CHAIN: a round into the shock barrel did not set it off');
       for(i=0;i<60;i++) brlTick(0.02);
       if(!(A.gone&&B.gone&&C.gone)) bad.push('CHAIN: the barrels did not go up in a chain (shock '+A.gone+', acid '+B.gone+', cryo '+C.gone+')');
       if(cnt('barrelShock')!==1||cnt('barrelAcid')!==1||cnt('barrelCryo')!==1) bad.push('CHAIN: the chain made '+heard.join(',')+', not one of each blast');
       if(!g.bfire.some(function(q){ return q.k==='acid'; })||!g.bfire.some(function(q){ return q.k==='cryo'; })) bad.push('CHAIN: the acid and the cryo blast of the chain left no pool and no fog');
       // TWO WINDOWS: as player 2 (seat 1) of a party, never hurt by a barrel a teammate lit, hurt by one I lit; the bodies are the host window, which shows the shards
       NK0={on:NET.on,role:NET.role,seat:NET.seat,upSeed:NET.upSeed};
       NET.on=true; NET.role='join'; NET.seat=1; NET.upSeed=g.seed>>>0; netUpShared=function(){ return false; };
       if(!netEntsPeer()) bad.push('WINDOWS: the staging did not make this a linked window');
       else {
         reset(); A=mkb('shock',0,0,0); c1=crawl(60); g.brl.push(A); brlBlast(A);
         if(!(p.hp===100)||hits.length) bad.push('WINDOWS: a shock barrel the other player lit hurt me ('+hits.join(',')+', hp '+p.hp+')');
         if(c1.hp!==900||c1.stunT>0) bad.push('WINDOWS: a linked window ran a body of its own (hp '+c1.hp+', stun '+c1.stunT+')');
         reset(); B=mkb('acid',0,0,1); g.brl.push(B); brlBlast(B);
         if(!(p.hp<100)||nhit('barrel:ACID')!==1) bad.push('WINDOWS: an acid barrel I lit did not hurt me');
         if(g.bfire.length!==1||g.bfire[0].k!=='acid') bad.push('WINDOWS: the linked window laid no pool of its own');
         reset(); B=mkb('acid',0,0,0); g.brl.push(B); brlBlast(B); hits.length=0; p.hp=100;
         for(i=0;i<8;i++) brlTick(0.3);
         if(!(p.hp===100)||hits.length) bad.push('WINDOWS: an acid pool the other player lit hurt me ('+hits.join(',')+')');
         reset(); D=mkb('red',0,0,0); c1=crawl(60); c1.frozenT=0.3; g.brl.push(D); heard.length=0; brlBlast(D);
         if(cnt('elFreeze')<1) bad.push('WINDOWS: the linked window showed no shards for a frozen crawler');
         if(c1.hp!==900) bad.push('WINDOWS: the linked window broke a crawler itself');
       }
       return bad.length?bad.slice(0,10).join('; '):null;
     }catch(e){ bad.push('threw: '+(e&&e.stack||e)); return bad.slice(0,10).join('; '); }
     finally{
       sfx=oSfx; damagePlayer=oDmg; brlDrawK=oDK; brlPoolDraw=oPD; netUpShared=oUp;
       if(NK0){ NET.on=NK0.on; NET.role=NK0.role; NET.seat=NK0.seat; NET.upSeed=NK0.upSeed; }
       try{ var g2=__state(); if(g2&&g2.player){ g2.player.iv=0; g2.player.hp=100; g2.player.downed=false; g2.player.dying=false; g2.deathBeat=null; } }catch(_p){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'31.05',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
