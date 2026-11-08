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
  {v:'37.60',what:'cw-m3death, his rulings of 11-01 (season zero m3, plan worn gear, answers 60 and 61): a death with three pieces worn empties P.worn, leaves P.gear as it was, the hall copy holds the three, the KIA card lists each and its $ gone and the hall value lost include them at wornPrice, and cash, stash, guns, lifetime earnings and rank match the same death with nothing worn; a quit with shots fired does the same; the free walk-back takes nothing and adds no pip; an extract gives each worn piece one pip (3 stays 3), a bag piece none, one card line per piece that gained (at most 4 then +n), and wornMods rises by a third of each trait per pip; a bag piece is never saved by safe slots; the demo and a sim raid touch nothing and the demo body carries nothing; an old save loads twice with nothing lost or moved',
   run:function(){
     if(!(window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile&&window.__deploy&&window.__endRaid&&window.__state)) return 'SKIP: this fixture cannot stage';
     if(typeof applyLoadedProfile!=='function'||typeof pilNow!=='function'||typeof pilRaidEnd!=='function'||typeof wornMake!=='function'||typeof wornAdd!=='function'||typeof wornWear!=='function'||typeof wornPrice!=='function'||typeof wornKeyOf!=='function'||typeof wornItemEnsure!=='function') return 'SKIP: no lineage or worn gear here';
     var saved=P, cfg={}, k, oldStore=storeSet, oldSave=saveProfile, a0=(typeof ARCADE==='object'&&ARCADE)?ARCADE.on:undefined, bad=[], g, e, eB, i, j, A, B, P0, G0, W0, L, sumV, man, wm0, wm1, exp, K, Kr, h0, s0, snap, pc;
     function need(ok,msg){ if(!ok) bad.push(msg); }
     function J(o){ return JSON.stringify(o); }
     function kindFor(s){ for(var q in WORN_KINDS) if(Object.prototype.hasOwnProperty.call(WORN_KINDS,q)&&WORN_KINDS[q].slots.indexOf(s)>=0) return q; return null; }
     function live(){ if(!P.pil){ P.hall=[]; P.pil=null; P.pilGen=0; P.pilNote=null; acctEnsure(P); } }
     function dress(slots,rs,pips){ var q, x; P.worn={}; P.gear=[];
       for(q=0;q<slots.length;q++){ x=wornAdd(P,wornMake(kindFor(slots[q]),rs[q],10,31+q)); x.pip=pips[q]; if(!wornWear(P,x.id,slots[q])) throw new Error('could not wear '+slots[q]); }
       x=wornAdd(P,wornMake(kindFor('head'),2,12,77));   // one stash piece, never worn
       return x; }
     function up(bag){
       live();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); var q=__state();
       if(!q||!q.player||q.over) throw new Error('no live raid');
       q.bag=bag.slice(); q.carriedIn=0; q.carriedKit=[]; q.issuedBandages=0; q.pedCarry=0; q.pedSold=0; q.strayPaid=0; q.goalRewards=null;
       q.player.downed=false; q.player.hp=100; q.ents.length=0; q.player.iv=99; q.tel.kills={}; q.tel.shots=3;
       return q;
     }
     function done(){ if(typeof pendingRun!=='undefined'&&pendingRun&&!pendingRun._committed&&typeof commitRun==='function') commitRun(pendingRun); }
     function keep(){ return {c:P.credits, s:J(P.stash), w:J(P.weapons), eq:P.equipped+'/'+P.equippedSec, le:lifeEarnNow(), rk:(typeof rankNow==='function')?rankNow():0, an:P.acctName}; }
     function card(){ var m=document.getElementById('oc_manifest'); return m?String(m.innerHTML).toLowerCase():''; }
     function wornList(){ var o=[], q; for(q=0;q<WORN_SLOTS.length;q++) if(P.worn[WORN_SLOTS[q]]) o.push(P.worn[WORN_SLOTS[q]]); return o; }
     function sameWorn(H,list){ var q, x, n=0; if(!H||typeof H!=='object') return false; for(q in H) if(Object.prototype.hasOwnProperty.call(H,q)) n++; if(n!==list.length) return false;
       for(q=0;q<list.length;q++){ x=H[list[q].s]; if(!x||x.k!==list[q].k||x.r!==list[q].r||x.pw!==list[q].pw||(x.pip|0)!==(list[q].pip|0)) return false; } return true; }
     function shape(){ var o=[], q, s; for(q=0;q<WORN_SLOTS.length;q++){ s=WORN_SLOTS[q]; if(P.worn[s]) o.push({s:s,k:P.worn[s].k,r:P.worn[s].r,pw:P.worn[s].pw,pip:P.worn[s].pip|0,n:wornName(P.worn[s])}); } return o; }
     for(k in CFG) cfg[k]=CFG[k];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       storeSet=function(){}; saveProfile=function(){};
       P.cond='day'; P.terms=[]; P.merc=''; CFG.safeSlots=0; P.pilNote=null;
       // ONE: a death with three pieces worn, then the same death with nothing worn
       live(); dress(['head','boots','gloves'],[1,2,0],[0,1,3]);
       W0=shape(); G0=J(P.gear); sumV=0; L=wornList(); for(i=0;i<L.length;i++) sumV+=Math.round(wornPrice(L[i])*CFG.lootMult);
       P0=J(P);
       g=up(['core','titan']); h0=P.hall.length;
       __endRaid('dead'); done();
       A=keep(); man=card(); e=P.hall[P.hall.length-1]||{}; e.end=e.end||{};
       need(P.hall.length===h0+1,'ONE: the death did not end the pillager');
       need(P.worn&&typeof P.worn==='object'&&Object.keys(P.worn).length===0,'ONE: still worn after a death: '+J(shape()));
       need(J(P.gear)===G0,'ONE: the stash pieces moved: '+J(P.gear)+' vs '+G0);
       need(sameWorn(e.end.worn,W0),'ONE: the hall copy end.worn is '+J(e.end.worn)+', not the three worn');
       for(i=0;i<W0.length;i++) need(man.indexOf('>'+W0[i].n+'</span><span style="color:var(--rust)">  lost')>=0,'ONE: the KIA card does not list '+W0[i].n+' as lost');
       need(man.indexOf('3 worn pieces')>=0||(typeof OC_LG!=='undefined'&&!!OC_LG),'ONE: the KIA card count does not say 3 worn pieces');
       P=JSON.parse(P0); storeSet=function(){}; saveProfile=function(){}; P.worn={};
       g=up(['core','titan']);
       __endRaid('dead'); done();
       B=keep(); eB=P.hall[P.hall.length-1]||{}; eB.end=eB.end||{};
       need(J(A)===J(B),'ONE: losing the worn pieces moved cash, stash, guns, lifetime earnings or rank: '+J(A)+' vs '+J(B));
       need(e.end.lost===eB.end.lost+sumV,'ONE: the hall value lost $'+e.end.lost+', not $'+eB.end.lost+' plus the pieces $'+sumV);
       need(man.indexOf((eB.end.lost+sumV).toLocaleString())>=0||man.indexOf('data-to="'+(eB.end.lost+sumV)+'"')>=0,'ONE: the KIA card $ gone does not include the pieces ($'+(eB.end.lost+sumV)+')');
       // TWO: a quit with shots fired does the same
       live(); dress(['head','boots','gloves'],[1,2,0],[0,1,3]); W0=shape(); G0=J(P.gear);
       g=up(['core']); h0=P.hall.length;
       __endRaid('abandon'); done(); man=card(); e=P.hall[P.hall.length-1]||{}; e.end=e.end||{};
       need(P.hall.length===h0+1&&e.end.how==='quit','TWO: the quit did not end the pillager');
       need(Object.keys(P.worn).length===0,'TWO: still worn after a quit: '+J(shape()));
       need(J(P.gear)===G0,'TWO: the stash pieces moved after a quit');
       need(sameWorn(e.end.worn,W0),'TWO: the hall copy after a quit is '+J(e.end.worn));
       for(i=0;i<W0.length;i++) need(man.indexOf('>'+W0[i].n+'</span>')>=0,'TWO: the quit card does not list '+W0[i].n);
       // THREE: the free walk-back takes nothing and adds no pip
       live(); dress(['head','boots','gloves'],[1,2,0],[0,1,3]); W0=J(P.worn); G0=J(P.gear);
       g=up([]); g.tel.shots=0; g.tel.containers=0; g.tel.distance=0; s0=P.runs;
       __endRaid('abandon'); done();
       need(P.runs===s0,'THREE: control: that abandon was not the free walk-back');
       need(J(P.worn)===W0&&J(P.gear)===G0,'THREE: the free walk-back moved the worn pieces: '+J(shape()));
       // FOUR: an extract gives each worn piece one pip, 3 stays 3, a bag piece none
       live(); dress(['head','boots','gloves'],[1,2,0],[0,1,3]);
       L=wornList(); wm0=wornMods(P.worn); exp={};
       for(i=0;i<L.length;i++) if((L[i].pip|0)<3) for(j=0;j<L[i].tr.length;j++) exp[L[i].tr[j].s]=(exp[L[i].tr[j].s]||0)+L[i].tr[j].v/3;
       W0=shape(); G0=P.gear.length;
       K=wornKeyOf(kindFor('pants'),1,10,991); need(!!wornItemEnsure(K),'FOUR: control: no bag piece key');
       g=up([K,'core']);
       __endRaid('extract'); done(); man=card();
       need(Object.keys(P.worn).length===3,'FOUR: an extract changed what is worn: '+J(shape()));
       for(i=0;i<W0.length;i++){ pc=P.worn[W0[i].s];
         need(pc&&(pc.pip|0)===Math.min(3,W0[i].pip+1),'FOUR: '+W0[i].n+' pip '+(pc&&pc.pip)+', not '+Math.min(3,W0[i].pip+1));
         if(W0[i].pip<3) need(man.indexOf('>'+W0[i].n+' pip '+(W0[i].pip+1)+'</span>')>=0,'FOUR: the extract card has no line '+W0[i].n+' pip '+(W0[i].pip+1));
         else need(man.indexOf('>'+W0[i].n+' pip ')<0,'FOUR: a piece at 3 got a line'); }
       need(P.gear.length===G0+1&&(P.gear[P.gear.length-1].pip|0)===0&&P.gear[P.gear.length-1].k===kindFor('pants'),'FOUR: the bag piece did not bank with no pip: '+J(P.gear[P.gear.length-1]));
       wm1=wornMods(P.worn);
       for(k in WORN_STATS) if(Object.prototype.hasOwnProperty.call(WORN_STATS,k)) need(Math.abs((wm1[k]-wm0[k])-(exp[k]||0))<0.0003,'FOUR: wornMods '+k+' rose '+(wm1[k]-wm0[k])+', not '+(exp[k]||0));
       // FIVE: six pieces gain, the card shows 4 lines then +2
       live(); dress(['head','amulet','armor','pants','boots','gloves'],[0,1,2,3,0,1],[0,0,0,0,0,0]); W0=shape();
       g=up(['core']);
       __endRaid('extract'); done(); man=card();
       for(i=0,j=0;i<W0.length;i++) if(man.indexOf('>'+W0[i].n+' pip 1</span>')>=0) j++;
       need(j===4&&man.indexOf('>+2</span>')>=0,'FIVE: '+j+' pip lines and '+(man.indexOf('>+2</span>')>=0?'':'no ')+'+2, not 4 lines then +2');
       // SIX: a piece in the bag is never saved by safe slots
       live(); P.worn={}; P.gear=[]; CFG.safeSlots=2; G0=P.gear.length;
       Kr=wornKeyOf(kindFor('boots'),3,60,4321); need(!!wornItemEnsure(Kr),'SIX: control: no relic key');
       g=up([Kr,'scrap']); s0=P.stash.length;
       __endRaid('dead'); done(); man=card(); CFG.safeSlots=0;
       need(P.gear.length===G0,'SIX: a safe slot saved the bag piece: '+J(P.gear));
       need(P.stash.length===s0+1&&P.stash[P.stash.length-1]==='scrap','SIX: the other thing was not saved by the pocket: '+J(P.stash.slice(s0)));
       need(man.indexOf(ITEMS[Kr].name)>=0,'SIX: the KIA card does not list the bag piece');
       // SEVEN: the demo touches nothing and its body carries nothing
       if(typeof ARCADE==='object'&&ARCADE){
         live(); dress(['head','boots','gloves'],[1,2,0],[0,1,3]); W0=J(P.worn); G0=J(P.gear);
         g=up(['core']); ARCADE.on=true;
         try{ need(raidWornMods()===null,'SEVEN: the demo body carries worn stats'); __endRaid('dead'); done(); }catch(_de){} finally{ ARCADE.on=a0; }
         need(J(P.worn)===W0&&J(P.gear)===G0,'SEVEN: a demo death moved the worn pieces');
         g=up(['core']); ARCADE.on=true;
         try{ __endRaid('extract'); done(); }catch(_dx){} finally{ ARCADE.on=a0; }
         need(J(P.worn)===W0&&J(P.gear)===G0,'SEVEN: a demo extract moved the worn pieces');
       }
       // EIGHT: a sim raid touches nothing
       live(); dress(['head','boots','gloves'],[1,2,0],[0,1,3]); W0=J(P.worn); G0=J(P.gear);
       g=up(['core']); g.sim=true; __endRaid('dead');
       g=up(['core']); g.sim=true; __endRaid('extract');
       need(J(P.worn)===W0&&J(P.gear)===G0,'EIGHT: a sim raid moved the worn pieces');
       // NINE: an old save loads twice with nothing lost or moved
       live(); dress(['head','boots','gloves'],[1,2,0],[2,1,3]);
       snap=JSON.parse(J(P)); snap.cfg=JSON.parse(J(CFG)); snap.cfgv=18;
       A={c:snap.credits,s:J(snap.stash),w:J(snap.weapons),eq:snap.equipped,ct:J(snap.contracts),fg:J(snap.forged||{}),le:snap.lifeEarn,wn:J(snap.worn),gr:J(snap.gear),p:snap.pil.name+'/'+snap.pil.gen,h:snap.hall.length};
       for(i=0;i<2;i++){
         applyLoadedProfile({value:J(snap)});
         B={c:P.credits,s:J(P.stash),w:J(P.weapons),eq:P.equipped,ct:J(P.contracts),fg:J(P.forged||{}),le:P.lifeEarn,wn:J(P.worn),gr:J(P.gear),p:P.pil.name+'/'+P.pil.gen,h:P.hall.length};
         need(J(A)===J(B),'NINE: load '+(i+1)+' moved the save: '+J(A)+' vs '+J(B));
         snap=JSON.parse(J(P)); snap.cfg=JSON.parse(J(CFG)); snap.cfgv=18;
       }
     }catch(e2){ bad.push('threw: '+(e2&&e2.message||e2)); }
     finally{
       if(typeof ARCADE==='object'&&ARCADE) ARCADE.on=a0;
       try{ g=__state(); if(g&&!g.over){ g.sim=false; g.player.downed=false; g.tel.shots=0; g.tel.containers=0; g.tel.distance=0; __endRaid('abandon'); } }catch(_e){}
       P=saved; storeSet=oldStore; saveProfile=oldSave;
       for(k in CFG) if(!(k in cfg)) delete CFG[k]; for(k in cfg) CFG[k]=cfg[k];
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'37.59',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
