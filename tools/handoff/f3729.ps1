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

if ($s.Contains("  {v:'37.29',what:")) { throw "check 37.29 is in the fixture already" }

SubRx @'
  {v:'37.28',what:
'@ @'
  {v:'37.29',what:'cw-m2death, his rulings of 11-01 (round 5, answers 28 and 31, plan m2 the lineage): an extraction with a known haul and kills moves the living pillager by exactly one raid, one extract, its kills and the secured haul as best; a death puts it in the hall with how dead, map, zone, the KIA card killer, the value lost, the lost item keys most valuable first, a copy of the worn slots and the body look, and a new record with gen +1 is living; credits, stash, guns, lifetime earnings and rank after the death match the same death with no lineage; the floor line name is gone  pillager n shows once; a quit with shots fired ends it as quit; the free walk-back, a sim raid and the demo end and count nothing; an old save loads twice with nothing lost or moved',
   run:function(){
     if(!(window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile&&window.__deploy&&window.__endRaid&&window.__state)) return 'SKIP: this fixture cannot stage';
     if(typeof applyLoadedProfile!=='function'||typeof pilNow!=='function'||typeof pilEnd!=='function'||typeof pilBirth!=='function'||typeof lifeEarnNow!=='function') return 'SKIP: no loader or m0 account here';
     if(typeof pilRaidEnd!=='function'||typeof pilNoteShow!=='function') return 'no lineage in this build (pilRaidEnd, pilNoteShow)';
     var saved=P, cfg={}, k, oldStore=storeSet, oldSave=saveProfile, realPRE=pilRaidEnd, a0=(typeof ARCADE==='object'&&ARCADE)?ARCADE.on:undefined, bad=[], g, q0, h0, e, i, haul, snap, P0, A, B, s0, tst, r0, sorted;
     function need(ok,msg){ if(!ok) bad.push(msg); }
     function worth(L){ var s=0; for(var q=0;q<L.length;q++) s+=ival(L[q]); return s; }
     function J(o){ return JSON.stringify(o); }
     function up(bag){
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); var q=__state();
       if(!q||!q.player||q.over) throw new Error('no live raid');
       q.bag=bag.slice(); q.carriedIn=0; q.carriedKit=[]; q.issuedBandages=0; q.pedCarry=0; q.pedSold=0; q.strayPaid=0; q.goalRewards=null;
       q.player.downed=false; q.player.hp=100; q.ents.length=0; q.player.iv=99; q.tel.kills={};
       return q;
     }
     function done(){ if(typeof pendingRun!=='undefined'&&pendingRun&&!pendingRun._committed&&typeof commitRun==='function') commitRun(pendingRun); }
     function keep(){ return {c:P.credits, s:J(P.stash), w:J(P.weapons), eq:P.equipped+'/'+P.equippedSec, le:lifeEarnNow(), rk:(typeof rankNow==='function')?rankNow():0, an:P.acctName}; }
     for(k in CFG) cfg[k]=CFG[k];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       storeSet=function(){}; saveProfile=function(){};
       P.cond='day'; P.terms=[]; P.merc=''; CFG.safeSlots=0; P.pilNote=null;
       pilNow(); P.pil.best=0;
       // ONE: an extraction with a known haul and three kills
       haul=ival('core')+ival('titan');
       g=up(['core','titan']); g.tel.kills={raider:2,warden:1};
       q0=J(P.pil); q0=JSON.parse(q0); h0=P.hall.length;
       __endRaid('extract'); done();
       need(P.pil&&P.pil.gen===q0.gen&&P.hall.length===h0,'ONE: an extraction ended the pillager');
       need(P.pil&&P.pil.raids===q0.raids+1&&P.pil.ext===q0.ext+1,'ONE: raids '+(P.pil&&P.pil.raids)+' ext '+(P.pil&&P.pil.ext)+', not '+(q0.raids+1)+' and '+(q0.ext+1));
       need(P.pil&&P.pil.kills===q0.kills+3,'ONE: kills '+(P.pil&&P.pil.kills)+', not '+(q0.kills+3));
       need(P.pil&&P.pil.best===haul,'ONE: best '+(P.pil&&P.pil.best)+', not the secured haul '+haul);
       // TWO: a death, first with no lineage (the ledger alone), then for real from the same save
       P.cosHat='none'; P.cosSkin='tan'; P.cosFit='slate';
       P0=J(P);
       pilRaidEnd=function(){ return null; };
       g=up(['core','titan','scrap']); g.tel.kills={raider:1}; g.tel.deathKiller='warden'; g.tel.lastHitName=null;
       __endRaid('dead'); done();
       A=keep();
       pilRaidEnd=realPRE;
       P=JSON.parse(P0); storeSet=function(){}; saveProfile=function(){};
       q0=JSON.parse(J(P.pil)); h0=P.hall.length; r0=P.pil;
       g=up(['core','titan','scrap']); g.tel.kills={raider:1}; g.tel.deathKiller='warden'; g.tel.lastHitName=null;
       P.worn={head:(typeof wornMake==='function'&&wornMake('head',1,10,7))||{id:'g1',k:'head',r:1,pw:10,tr:[],pip:0,dye:'',rule:''}};
       __endRaid('dead'); done();
       B=keep();
       need(P.hall.length===h0+1,'TWO: the hall has '+P.hall.length+' after a death, not '+(h0+1));
       e=P.hall[P.hall.length-1]||{}; e.end=e.end||{};
       need(e.gen===q0.gen&&e.raids===q0.raids+1&&e.kills===q0.kills+1,'TWO: the hall record is not the pillager with this raid on it (gen '+e.gen+', raids '+e.raids+', kills '+e.kills+')');
       need(e.end.how==='dead'&&typeof e.end.at==='number','TWO: end.how '+e.end.how+', at '+e.end.at);
       need(e.end.map===FIXED_MAPS[0].id,'TWO: end.map '+e.end.map+', not '+FIXED_MAPS[0].id);
       need(typeof e.end.zone==='string','TWO: end.zone is '+typeof e.end.zone);
       need(e.end.by==='warden','TWO: end.by '+J(e.end.by)+', not the KIA card killer warden');
       need(Array.isArray(e.end.items)&&e.end.items.length<=7&&['core','titan','scrap'].every(function(q){ return e.end.items.indexOf(q)>=0; }),'TWO: end.items '+J(e.end.items)+' does not hold the lost bag');
       sorted=Array.isArray(e.end.items)?e.end.items.slice().sort(function(a,b){ return ival(b)-ival(a); }):[];
       need(Array.isArray(e.end.items)&&sorted.every(function(q,z){ return ival(q)===ival(e.end.items[z]); }),'TWO: end.items is not most valuable first');
       need(Array.isArray(e.end.items)&&e.end.lost===worth(e.end.items)&&e.end.lost>=worth(['core','titan','scrap']),'TWO: end.lost $'+e.end.lost+', not the $'+worth(e.end.items||[])+' its items are worth');
       need(J(e.end.worn)===J(P.worn)&&e.end.worn!==P.worn,'TWO: end.worn '+J(e.end.worn)+' is not a copy of '+J(P.worn));
       need(J(e.end.look)===J({hat:P.cosHat,cut:P.cosCut,skin:P.cosSkin,scheme:P.cosScheme,fit:P.cosFit,outfit:P.cosOutfit}),'TWO: end.look '+J(e.end.look));
       need(P.pil&&P.pil!==r0&&P.pil.gen===q0.gen+1&&P.pilGen===q0.gen+1&&P.pil.raids===0,'TWO: the living pillager is '+J(P.pil&&{gen:P.pil.gen,raids:P.pil.raids})+', not a new gen '+(q0.gen+1));
       need(J(A)===J(B),'TWO: the lineage moved the save: '+J(A)+' vs '+J(B));
       need(P.pilNote&&P.pilNote.t===String(q0.name).toLowerCase()+' is gone  pillager '+(q0.gen+1)&&!P.pilNote.shown,'TWO: the floor line is '+J(P.pilNote));
       // THREE: the floor line shows once
       showScreen('hub'); tst=document.getElementById('hubtoast');
       need(P.pilNote&&P.pilNote.shown===1&&tst&&String(tst.textContent).toLowerCase().indexOf('is gone  pillager '+(q0.gen+1))>=0,'THREE: the floor line reads '+(tst?J(tst.textContent):'nothing'));
       if(tst) tst.textContent='';
       showScreen('hub');
       need(!tst||String(tst.textContent).indexOf('is gone')<0,'THREE: the floor line showed twice');
       // FOUR: a quit with shots fired ends it as quit
       g=up(['core','scrap']); g.tel.shots=3; h0=P.hall.length; q0=JSON.parse(J(P.pil));
       __endRaid('abandon'); done();
       e=P.hall[P.hall.length-1]||{}; e.end=e.end||{};
       need(P.hall.length===h0+1&&e.end.how==='quit'&&e.gen===q0.gen&&e.raids===q0.raids+1,'FOUR: a quit with shots fired did not end the pillager as quit ('+P.hall.length+' vs '+h0+', '+e.end.how+')');
       need(e.end.lost===worth(['core','scrap'])&&J(e.end.items)===J(['core','scrap'].sort(function(a,b){ return ival(b)-ival(a); }))&&e.end.by==='','FOUR: the quit end is '+J(e.end));
       need(P.pil&&P.pil.gen===q0.gen+1,'FOUR: no new pillager after the quit');
       // FIVE: the free walk-back ends and counts nothing
       g=up([]); g.tel.shots=0; g.tel.containers=0; g.tel.distance=0; h0=P.hall.length; q0=J(P.pil); s0=P.runs;
       __endRaid('abandon'); done();
       need(P.runs===s0,'FIVE: control: that abandon was not the free walk-back');
       need(P.hall.length===h0&&J(P.pil)===q0,'FIVE: the free walk-back ended or counted something');
       // SIX: a sim raid ends and counts nothing
       g=up(['core']); g.sim=true; h0=P.hall.length; q0=J(P.pil);
       __endRaid('dead');
       need(P.hall.length===h0&&J(P.pil)===q0,'SIX: a sim raid ended or counted something');
       // SEVEN: a demo death ends nothing
       if(typeof ARCADE==='object'&&ARCADE){
         g=up(['core']); g.tel.shots=3; h0=P.hall.length; q0=J(P.pil);
         ARCADE.on=true;
         try{ __endRaid('dead'); done(); }catch(_de){} finally{ ARCADE.on=a0; }
         need(P.hall.length===h0&&J(P.pil)===q0,'SEVEN: a death with the demo on ended or counted something');
       }
       // EIGHT: an old save (no floor line field) loads twice with nothing lost or moved
       P.pilNote=null;
       snap=JSON.parse(J(P)); delete snap.pilNote; snap.cfg=JSON.parse(J(CFG)); snap.cfgv=18;
       A={c:snap.credits,s:J(snap.stash),w:J(snap.weapons),eq:snap.equipped,ct:J(snap.contracts),fg:J(snap.forged||{}),le:snap.lifeEarn,p:snap.pil.name+'/'+snap.pil.gen+'/'+snap.pil.raids,h:snap.hall.length,g:snap.pilGen};
       for(i=0;i<2;i++){
         applyLoadedProfile({value:J(i?snap:snap)});
         B={c:P.credits,s:J(P.stash),w:J(P.weapons),eq:P.equipped,ct:J(P.contracts),fg:J(P.forged||{}),le:P.lifeEarn,p:P.pil.name+'/'+P.pil.gen+'/'+P.pil.raids,h:P.hall.length,g:P.pilGen};
         need(J(A)===J(B),'EIGHT: load '+(i+1)+' moved the save: '+J(A)+' vs '+J(B));
         need(!P.pilNote||P.pilNote.shown,'EIGHT: an old save says a pillager is gone');
         snap=JSON.parse(J(P)); snap.cfg=JSON.parse(J(CFG)); snap.cfgv=18;
       }
     }catch(e2){ bad.push('threw: '+(e2&&e2.message||e2)); }
     finally{
       pilRaidEnd=realPRE;
       if(typeof ARCADE==='object'&&ARCADE) ARCADE.on=a0;
       try{ g=__state(); if(g&&!g.over){ g.player.downed=false; g.tel.shots=0; __endRaid('abandon'); } }catch(_e){}
       P=saved; storeSet=oldStore; saveProfile=oldSave;
       for(k in CFG) if(!(k in cfg)) delete CFG[k]; for(k in cfg) CFG[k]=cfg[k];
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'37.28',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
