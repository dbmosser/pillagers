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

if ($s.Contains("  {v:'37.44',what:")) { throw "check 37.44 is in the fixture already" }

SubRx @'
  {v:'37.43',what:
'@ @'
  {v:'37.44',what:'cw-m3drops, his rulings of 11-01 (season zero m3): worn gear in loot boxes: over three seeds about one map box in three holds a piece, on its own dice (RNGS and FXS never move, with drops on and off a staged box gives the same normal items in the same order, the same search time and look), the same box on the same seed gives the same piece, a key rebuilt from nothing gives the identical piece, no loop over ITEMS sees a key, wornDropPw follows the best owned, worn and in the stash, with the step above about one in ten, G.sim and the demo roll nothing; the tip draws beside the search bar and in the backpack with better and worse; the new row carries the rarity colour, icon and one trait line; an extract banks exactly the piece into P.gear and nothing into P.stash, a death loses it, a dropped pile gives the same key back; an old save reloads with nothing lost',
   run:function(){
     if(!(window.__runPrep&&window.__startRaid&&window.__endRaid&&window.__state&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile&&window.__topClear)) return 'SKIP: this fixture cannot stage';
     if(typeof applyLoadedProfile!=='function'||typeof drawHUD!=='function') return 'SKIP: no loader or HUD here';
     if(typeof wornBoxRoll!=='function'||typeof wornItemEnsure!=='function'||typeof wornDropPw!=='function'||typeof wornPrice!=='function'||typeof wornTip!=='function'||typeof WORN_DROPS_ON==='undefined') return 'no worn drops in this build (wornBoxRoll, wornItemEnsure, wornDropPw, wornPrice, wornTip, WORN_DROPS_ON)';
     var saved=P, cfg={}, k, oOn=WORN_DROPS_ON, oSay=say, oStore=storeSet, oSave=saveProfile, oFill=null, PR=CanvasRenderingContext2D.prototype, drew=[], said=[], bad=[], oArc=null, seeds=[4242,4243,4244], si, g, p, i, j, c, n, K, map={}, boxes=0, got=0, rars=[0,0,0,0], kinds={}, r0, f0, keep, best, tm, q, a, b, pc, snap, base, L, before, oSafe;
     function need(ok,msg){ if(!ok) bad.push(msg); }
     function same(x,y){ return JSON.stringify(x)===JSON.stringify(y); }
     function plain(l){ return (l||[]).filter(function(x){ return !wornKeyIs(x); }); }
     function isBox(ct){ return ct&&ct.d>=0&&ct.type!=='botwreck'&&!ct.dropped&&!ct.mercSrc&&!ct.opened&&Array.isArray(ct.loot); }
     function raid(sd){ __topClear(); __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:sd}); g=__state(); p=g&&g.player; if(!g||g.over||!p) throw new Error('seed '+sd+' built no live raid'); g.ents.length=0; p.iv=99; p.downed=false; }
     function rec(fn){ drew=[]; PR.fillText=function(t){ drew.push({t:String(t),c:this.fillStyle}); return oFill.apply(this,arguments); }; try{ fn(); } finally { PR.fillText=oFill; } return drew; }
     function saw(txt){ for(var x=0;x<drew.length;x++) if(drew[x].t.toLowerCase()===String(txt).toLowerCase()) return drew[x]; return null; }
     function pull(ct){ var o=[], z; while(ct.loot.length){ z=ct.loot.shift(); ct.pulled=(ct.pulled||0)+1; openContainer(ct,[z]); ct.best=bestRarity(ct.loot); } openContainer(ct); return o; }
     for(k in CFG) cfg[k]=CFG[k];
     oFill=PR.fillText;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       WORN_DROPS_ON=true;
       storeSet=function(){}; saveProfile=function(){};
       base=JSON.parse(JSON.stringify(P)); base.cfg=JSON.parse(JSON.stringify(CFG)); base.cfgv=18;
       // ONE: the rate, the rarities, the kinds, and nothing else moves
       for(si=0;si<seeds.length;si++){
         raid(seeds[si]);
         for(i=0;i<g.containers.length;i++){ c=g.containers[i]; if(!isBox(c)) continue;
           keep=c.loot.slice(); best=c.best; tm=c.time; r0=RNGS; f0=FXS; boxes++;
           K=wornBoxRoll(c);
           if(RNGS!==r0||FXS!==f0) bad.push('ONE: the roll moved a stream on box '+i);
           if(c.best!==best||c.time!==tm) bad.push('ONE: the roll changed a box look or time on box '+i);
           if(!same(plain(c.loot),keep)) bad.push('ONE: the roll changed the normal items of box '+i);
           if(wornBoxRoll(c)!==null||c.loot.length!==keep.length+(K?1:0)) bad.push('ONE: a second roll on box '+i+' did something');
           if(K){ got++; a=ITEMS[K]; rars[a.pc.r]++; kinds[a.pc.k]=(kinds[a.pc.k]||0)+1; if(si===0) map[i]=K;
             for(j=1;j<c.loot.length;j++) if(ival(c.loot[j-1])>ival(c.loot[j])&&same(keep,keep.slice().sort(function(x,y){ return ival(x)-ival(y); }))) { bad.push('ONE: box '+i+' is out of value order '+JSON.stringify(c.loot)); break; } }
         }
         if(si===0){ for(k in ITEMS) if(wornKeyIs(k)) bad.push('ONE: for in over ITEMS saw '+k); if(Object.keys(ITEMS).some(wornKeyIs)) bad.push('ONE: Object.keys(ITEMS) holds a piece'); }
       }
       need(boxes>=150,'ONE: only '+boxes+' map boxes on three seeds');
       need(got/boxes>0.24&&got/boxes<0.44,'ONE: '+got+' pieces in '+boxes+' boxes, not about 34 percent');
       need(rars[0]/got>0.45&&rars[0]/got<0.75&&rars[1]/got>0.15&&rars[1]/got<0.42&&rars[3]/got<0.08&&rars[0]>rars[1]&&rars[1]>rars[2]&&rars[2]>=rars[3],'ONE: the rarities came out '+JSON.stringify(rars));
       need(Object.keys(kinds).length===8,'ONE: only these kinds came up '+JSON.stringify(kinds));
       // the same box on the same seed, a second raid: the same piece
       raid(4242);
       for(i=0;i<g.containers.length;i++){ c=g.containers[i]; if(!isBox(c)) continue; K=wornBoxRoll(c); if((K||null)!==(map[i]||null)) bad.push('ONE: box '+i+' on seed 4242 rolled '+K+' the second raid, '+map[i]+' the first'); }
       K=null; for(i in map){ K=map[i]; break; }
       need(!!K,'ONE: no piece on seed 4242');
       // TWO: the key spells itself out
       a=JSON.stringify(ITEMS[K].pc); b=ITEMS[K].name; n=ITEMS[K].val;
       delete ITEMS[K]; need(!ITEMS[K],'TWO: the piece would not unregister');
       q=wornItemEnsure(K);
       need(q&&JSON.stringify(q.pc)===a&&q.name===b&&q.val===n&&q.use==='wornpiece','TWO: the rebuilt key differs: '+JSON.stringify(q)+' / '+a);
       need(q&&q.r===['common','uncommon','rare','elite'][q.pc.r]&&q.val===wornPrice(q.pc)&&q.name===wornName(q.pc),'TWO: the item row reads '+JSON.stringify(q));
       need(!Object.getOwnPropertyDescriptor(ITEMS,K).enumerable,'TWO: the key is enumerable');
       ['wg_cloak_1_5_7','wg_boots_9_5_7','wg_boots_1_0_7','wg_boots_1_101_7','wg_boots_1_5_x','wg_boots_1_5','wg_boots_1_5_07','wg_boots_1.5_5_7'].forEach(function(x){ if(wornItemEnsure(x)||Object.prototype.hasOwnProperty.call(ITEMS,x)) bad.push('TWO: the bad key '+x+' made a piece'); });
       need(wornName({k:'armor',r:0,tr:[]})==='scrap scav vest'&&wornName({k:'armor',r:1,tr:[]})==='sound plated vest'&&wornName({k:'armor',r:2,tr:[]})==='rare breacher plate'&&wornName({k:'armor',r:3,tr:[]})==='relic breacher plate'&&wornName({k:'boots',r:1,tr:[]})==='sound boots','TWO: the armor names are wrong');
       need(wornPrice({r:2,pw:50,pip:1})===1100&&wornPrice({r:0,pw:50,pip:0})===150&&WORN_VAL.join()==='150,400,1000,2600','TWO: wornPrice is not the shared helper');
       // THREE: power follows the best owned
       function pws(kd){ var o={lo:999,hi:-999,up:0,n:0,base:0}, x, v; for(x=1;x<=1500;x++){ v=wornDropPw(kd,wornRand(x*7919)); if(v<o.lo) o.lo=v; if(v>o.hi) o.hi=v; o.n++; o.vals=o.vals||{}; o.vals[v]=(o.vals[v]||0)+1; } return o; }
       P.worn={}; P.gear=[]; q=pws('gloves');
       need(q.lo===15&&q.hi===20,'THREE: with nothing owned power runs '+q.lo+' to '+q.hi);
       P.gear=[{id:'a1',k:'gloves',r:0,pw:40,tr:[],pip:0}]; q=pws('gloves'); a=0; for(k in q.vals) if(+k>=43) a+=q.vals[k];
       need(q.lo===38&&q.hi===45&&!q.vals[42]&&a/q.n>0.06&&a/q.n<0.15,'THREE: stash best 40 gave '+JSON.stringify(q.vals));
       P.worn={gloves:{id:'a2',k:'gloves',r:0,pw:60,tr:[],pip:0}}; q=pws('gloves');
       need(q.lo===58&&q.hi===65,'THREE: worn best 60 over stash 40 ran '+q.lo+' to '+q.hi);
       q=pws('boots'); need(q.lo===53&&q.hi===60,'THREE: no boots with a best of 60 ran '+q.lo+' to '+q.hi+', not from 55');
       P.worn={}; P.gear=[{id:'a3',k:'ring',r:0,pw:99,tr:[],pip:0}]; q=pws('ring'); need(q.hi===WORN_PW_MAX,'THREE: the cap: '+q.hi);
       P.worn={}; P.gear=[];
       // FOUR: G.sim and the demo roll nothing
       raid(4242); c=null; for(i in map){ c=g.containers[i]; break; }
       g.sim=true; need(wornBoxRoll(c)===null&&!c.gearDone,'FOUR: G.sim rolled'); g.sim=false;
       g.arcade=1; need(wornBoxRoll(c)===null&&!c.gearDone,'FOUR: an arcade raid rolled'); g.arcade=0;
       if(typeof ARCADE==='object'&&ARCADE){ a=ARCADE.on; ARCADE.on=true; need(wornBoxRoll(c)===null&&!c.gearDone,'FOUR: ARCADE.on rolled'); ARCADE.on=a; }
       WORN_DROPS_ON=false; need(wornBoxRoll(c)===null&&!c.gearDone,'FOUR: the switch off rolled'); WORN_DROPS_ON=true;
       q={x:0,y:0,d:1,type:'crate',loot:[],dropped:1}; need(wornBoxRoll(q)===null,'FOUR: a dropped pile rolled');
       q={x:0,y:0,d:-1,type:'body',loot:[]}; need(wornBoxRoll(q)===null,'FOUR: a body with no map place rolled');
       q={x:0,y:0,d:1,type:'botwreck',loot:[]}; need(wornBoxRoll(q)===null,'FOUR: a wreck rolled');
       // FIVE: on against off, through the staged grant, on a box with no gun: same rows, same order, same streams
       raid(4242); c=null;
       for(i in map){ q=g.containers[i]; a=ITEMS[map[i]]; if(q.loot.length&&!q.loot.some(function(x){ return ITEMS[x]&&ITEMS[x].use==='gun'; })&&a&&a.pc.tr.length){ c=q; K=map[i]; break; } }
       need(!!c,'FIVE: no gun free box with a piece on seed 4242');
       if(c){
         keep=c.loot.slice(); tm=c.time; a=c.x; b=c.y;
         function stage(on){ WORN_DROPS_ON=on; c.loot=keep.slice(); c.best=bestRarity(keep); c.pulled=0; c.prog=0; c.opened=false; delete c.gearDone; g.bag=[]; g.pick=[]; srand(1234); FXS=0x1234567; said=[];
           wornBoxRoll(c); var had=c.loot.slice(), look=c.best; say=function(m,kd,o){ if(kd==='pick') said.push({m:m,item:o&&o.item,tag:(o&&o.tag)||''}); };
           pull(c); say=oSay; return {had:had,look:look,bag:g.bag.slice(),said:said.slice(),r:RNGS,f:FXS,t:c.time}; }
         a=stage(false); b=stage(true);
         need(a.had.indexOf(K)<0&&b.had.indexOf(K)>=0,'FIVE: the piece did not switch with the dial: '+JSON.stringify(a.had)+' / '+JSON.stringify(b.had));
         need(same(plain(b.bag),a.bag)&&b.bag.indexOf(K)>=0,'FIVE: the bag differs: '+JSON.stringify(a.bag)+' / '+JSON.stringify(b.bag));
         need(a.r===b.r&&a.f===b.f,'FIVE: the streams differ with drops on and off: '+[a.r,b.r,a.f,b.f].join());
         need(a.t===b.t&&a.look===b.look,'FIVE: time or look changed');
         q=b.said.filter(function(x){ return x.item!==K; }); need(same(q,a.said),'FIVE: the normal rows differ: '+JSON.stringify(a.said)+' / '+JSON.stringify(q));
         q=b.said.filter(function(x){ return x.item===K; }); pc=ITEMS[K].pc;
         need(q.length===1&&q[0].m===wornName(pc)&&q[0].tag===wornTraitTxt(pc,pc.tr[0]),'FIVE: the piece row reads '+JSON.stringify(q));
         // THE ROW itself: name in rarity colour, the trait line, the icon; a normal row beside it is as it was
         g.pick=[]; if(a.said[0]) pickSay(a.said[0].m,{item:a.said[0].item,tag:a.said[0].tag}); pickSay(wornName(pc),{item:K,tag:wornRowLine(pc)}); g.pick.forEach(function(x){ x.at=(g.t||0)-1; });
         rec(function(){ drawPickups(); });
         need(saw(wornName(pc))&&String(saw(wornName(pc)).c).toLowerCase()===String(WORN_RARS[pc.r].c).toLowerCase(),'FIVE: the row name is not in its rarity colour: '+JSON.stringify(saw(wornName(pc)))+' drew '+JSON.stringify(drew));
         need(!!saw(wornRowLine(pc)),'FIVE: the row has no trait line: '+JSON.stringify(drew));
         g.pick=[];
         // the first hold of E rolls it, and the search bar's real route shows the tip; let go and the piece stays
         WORN_DROPS_ON=true; c.loot=keep.slice(); c.best=bestRarity(keep); c.pulled=0; c.prog=0; c.opened=false; delete c.gearDone; g.bag=[]; g.searching=null; g.searchT=0;
         [[18,0],[-18,0],[0,18],[0,-18]].some(function(o){ p.x=c.x+o[0]; p.y=c.y+o[1]; keys={}; keys['KeyE']=true; updatePlayer(0.016); keys={}; return g.searching===c; });
         need(g.searching===c&&c.gearDone&&c.loot.indexOf(K)>=0,'FIVE: the first hold did not roll: searching '+(g.searching===c)+' loot '+JSON.stringify(c.loot));
         if(g.searching===c){
           g.searchT=c.time*0.2;
           P.worn={};
           rec(function(){ drawHUD(); });
           need(!!saw(wornName(pc))&&String(saw(wornName(pc)).c).toLowerCase()===String(WORN_RARS[pc.r].c).toLowerCase(),'FIVE: the tip has no name in rarity colour beside the search bar');
           for(i=0;i<pc.tr.length;i++) need(!!saw(wornTraitTxt(pc,pc.tr[i])),'FIVE: the tip has no trait '+wornTraitTxt(pc,pc.tr[i]));
           need(!!saw('better')&&!saw('worse'),'FIVE: nothing worn is not better in the tip');
           q=WORN_KINDS[pc.k].slots[0]; a={}; a[q]={id:'w1',k:pc.k,r:3,pw:100,pip:3,tr:pc.tr.map(function(t){ return {s:t.s,v:t.v*3}; })}; P.worn=a;
           rec(function(){ drawHUD(); }); need(!!saw('worse')&&!saw('better'),'FIVE: a far stronger piece worn is not worse in the tip');
           P.worn={};
           // a box with no piece: no tip
           q=c.loot; c.loot=plain(q); rec(function(){ drawHUD(); }); need(!saw('better')&&!saw('worse')&&!saw('even'),'FIVE: a box with no piece drew a tip'); c.loot=q;
           g.searching=null; g.searchT=0;
         }
         need(c.loot.indexOf(K)>=0,'FIVE: letting go took the piece');
       }
       // the shared tip: better, worse, even, and a ring against the weaker ring
       a=wornMake('gloves',1,50,99); P.worn={};
       need(wornTip(a,P)==='better','SIX: nothing worn is not better');
       P.worn={gloves:JSON.parse(JSON.stringify(a))}; need(wornTip(a,P)==='even','SIX: the same piece worn is not even');
       P.worn={gloves:wornMake('gloves',3,100,99)}; need(wornTip(wornMake('gloves',0,1,99),P)==='worse','SIX: a weak piece is not worse');
       P.worn={ring1:{id:'r1',k:'ring',r:1,pw:50,pip:0,tr:[{s:'reload',v:0.2}]},ring2:{id:'r2',k:'ring',r:0,pw:50,pip:0,tr:[{s:'quiet',v:0.01}]}};
       need(wornTip({k:'ring',r:0,pw:50,pip:0,tr:[{s:'quiet',v:0.03}]},P)==='better','SIX: a ring is not compared in place of the weaker ring');
       P.worn={};
       // SEVEN: the icons paint, and the backpack tip through its real route
       L=Object.keys(WORN_KINDS);
       for(i=0;i<L.length;i++){ q=document.createElement('canvas'); q.width=64; q.height=64; a=q.getContext('2d'); K=wornKeyOf(L[i],2,50,1000+i); wornItemEnsure(K); drawItemIconArt(a,K,32,32,56); b=a.getImageData(0,0,64,64).data; n=0; for(j=3;j<b.length;j+=4) if(b[j]>0) n++; need(n>200,'SEVEN: the '+L[i]+' icon painted '+n+' pixels'); }
       raid(4242); K=wornKeyOf('boots',2,40,4321); wornItemEnsure(K); pc=ITEMS[K].pc; g.bag=[K]; g.bagOpen=true; g.bagSel=0;
       need(autoBelt(K,1)===undefined&&beltClassOf(K)==='','SEVEN: the belt took a piece');
       need(itemRows(K).length===0,'SEVEN: the backpack row list says '+JSON.stringify(itemRows(K)));
       rec(function(){ drawBag(); });
       need(!!saw(wornTraitTxt(pc,pc.tr[0]))&&!!saw('better'),'SEVEN: no tip for the selected piece in the backpack');
       if(G.bagCells&&G.bagCells[0]&&!padOn()){ a=mouse.x; b=mouse.y; mouse.x=G.bagCells[0].x+2; mouse.y=G.bagCells[0].y+2; rec(function(){ drawBag(); }); need(!!saw(wornTraitTxt(pc,pc.tr[0])),'SEVEN: no tip hovering the piece'); mouse.x=a; mouse.y=b; }
       g.bagOpen=false;
       // EIGHT: drop and re-take, the same key
       a=g.containers.length; g.bag=[K]; dropItem(0); c=g.containers[g.containers.length-1];
       need(g.containers.length===a+1&&c.dropped&&same(c.loot,[K])&&g.bag.length===0,'EIGHT: the pile holds '+JSON.stringify(c&&c.loot));
       need(wornBoxRoll(c)===null&&same(c.loot,[K]),'EIGHT: a dropped pile rolled again');
       q=c.loot.shift(); c.pulled=1; openContainer(c,[q]); need(same(g.bag,[K]),'EIGHT: the re-take gave '+JSON.stringify(g.bag));
       // NINE: an extract banks exactly it, a death loses it
       g.bag=[]; a=P.stash.length; __endRaid('extract'); n=P.stash.length-a; raid(4242);   // what an extract adds with no piece
       before=P.stash.length; P.gear=[]; P.worn={};
       g.bag=[K]; __endRaid('extract');
       need(P.gear.length===1&&P.gear[0].k===pc.k&&P.gear[0].r===pc.r&&P.gear[0].pw===pc.pw&&same(P.gear[0].tr,pc.tr)&&!!P.gear[0].id,'NINE: the extract banked '+JSON.stringify(P.gear));
       need(P.stash.length-before===n&&!P.stash.some(wornKeyIs),'NINE: the piece went into P.stash: '+n+' added with none, now '+(P.stash.length-before)+': '+JSON.stringify(P.stash));
       a=P.log&&P.log[P.log.length-1]; need(a&&a.haul>=ival(K),'NINE: the haul '+(a&&a.haul)+' does not count '+ival(K));
       need(ITEMS[K].pc.id===''&&ITEMS[K].pc!==P.gear[0],'NINE: the banked piece is the key record itself');
       raid(4242); oSafe=CFG.safeSlots; CFG.safeSlots=0; g.bag=[K]; b=JSON.stringify(P.gear); before=P.stash.length; __endRaid('dead'); CFG.safeSlots=oSafe;
       need(JSON.stringify(P.gear)===b&&P.stash.length===before&&P.stash.indexOf(K)<0,'NINE: a death kept the piece: gear '+JSON.stringify(P.gear));
       __topClear();
       // TEN: an old save
       snap=JSON.parse(JSON.stringify(base)); delete snap.gear; delete snap.worn; delete snap.gearN;
       snap.credits=4321; snap.stash=['scrap','core']; snap.weapons=['pistol','smg']; snap.equipped='smg';
       applyLoadedProfile({value:JSON.stringify(snap)});
       need(Array.isArray(P.gear)&&P.gear.length===0&&P.credits===4321&&same(P.stash,['scrap','core'])&&P.weapons.indexOf('smg')>=0&&P.equipped==='smg','TEN: the old save lost something (credits '+P.credits+', stash '+JSON.stringify(P.stash)+')');
       wornAdd(P,JSON.parse(JSON.stringify(pc))); snap=JSON.parse(JSON.stringify(P)); applyLoadedProfile({value:JSON.stringify(snap)});
       need(P.gear.length===1&&same(P.gear[0].tr,pc.tr)&&P.gear[0].id===snap.gear[0].id&&P.credits===4321&&same(P.stash,['scrap','core']),'TEN: a banked piece did not survive a reload: '+JSON.stringify(P.gear));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)+' at '+String(e&&e.stack||'').split('\n').slice(1,3).join(' ')); }
     finally{
       PR.fillText=oFill; say=oSay; keys={};
       P=saved; storeSet=oStore; saveProfile=oSave; WORN_DROPS_ON=oOn;
       for(k in CFG) if(!(k in cfg)) delete CFG[k]; for(k in cfg) CFG[k]=cfg[k];
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; ').slice(0,1800):null; }},
  {v:'37.43',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
