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

if ($s.Contains("  {v:'37.33',what:")) { throw "check 37.33 is in the fixture already" }

SubRx @'
  {v:'37.32',what:
'@ @'
  {v:'37.33',what:'cw-m2birth, his rulings of 11-01 (plan m2 the lineage): a death leaves nobody living and three heirs; the first arrival in the Undercroft opens the birth card; heir 2 named vosk with the basic kit becomes the living pillager with its traits and the next gen, $300 exactly gone, lifetime earnings unchanged, and the next raid goes up with the kit; a kit he cannot afford is refused; close and esc birth heir 1; ascend and the quick ascent are refused with nobody living; the look is random once and his edits stay; a free walk-back gives the kit back and a death takes it off the ledger; the demo sees no card; an old save with a living pillager sees no card and loads twice unmoved; a save waiting on the card loads twice and still waits',
   run:function(){
     if(!(window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile&&window.__deploy&&window.__endRaid&&window.__state)) return 'SKIP: this fixture cannot stage';
     if(typeof applyLoadedProfile!=='function'||typeof pilRaidEnd!=='function'||typeof pilHeirs!=='function') return 'SKIP: no loader or lineage here';
     if(typeof birthOpen!=='function'||typeof birthBorn!=='function'||typeof birthNeed!=='function'||!document.getElementById('birthmodal')) return 'no birth card in this build (birthOpen, birthBorn, #birthmodal)';
     var saved=P, cfg={}, k, oldStore=storeSet, oldSave=saveProfile, a0=(typeof ARCADE==='object'&&ARCADE)?ARCADE.on:undefined, bad=[], g, g0, h, h0, c0, le0, i, n, A, B, snap, st, L;
     function need(ok,msg){ if(!ok) bad.push(msg); }
     function J(o){ return JSON.stringify(o); }
     function el(id){ return document.getElementById(id); }
     function on(id){ var m=el(id); return !!(m&&m.classList.contains('on')); }
     function done(){ if(typeof pendingRun!=='undefined'&&pendingRun&&!pendingRun._committed&&typeof commitRun==='function') commitRun(pendingRun); }
     function strip(q){ q.bag=[]; q.carriedIn=0; q.carriedKit=[]; q.issuedBandages=0; q.pedCarry=0; q.pedSold=0; q.strayPaid=0; q.goalRewards=null; q.player.downed=false; q.player.hp=100; q.ents.length=0; q.player.iv=99; q.tel.kills={}; q.tel.deathKiller='warden'; q.tel.lastHitName=null; return q; }
     function die(){ __deploy({kit:[],safe:null,mapIx:0,seed:4242}); var q=__state(); if(!q||!q.player||q.over) throw new Error('no live raid'); strip(q); __endRaid('dead'); done(); }
     function shut(){ var m=el('birthmodal'); if(m) m.classList.remove('on'); }
     for(k in CFG) cfg[k]=CFG[k];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       storeSet=function(){}; saveProfile=function(){};
       P.cond='day'; P.terms=[]; P.merc=''; CFG.safeSlots=0; P.pilNote=null; P.credits=2000; P.birthKit=null; P.freeKit=0; P.birthLook=0;
       pilNow(); BIRTH=null; shut();
       // ONE: a death leaves nobody living and three heirs
       die();
       need(P.pil===null&&Array.isArray(P.heirs)&&P.heirs.length===3&&P.hall.length===1&&P.pilGen===1,'ONE: after a death pil '+J(P.pil)+' heirs '+J(P.heirs)+' hall '+P.hall.length+' gen '+P.pilGen);
       need(birthNeed()===true,'ONE: birthNeed is not true with nobody living');
       need(!on('birthmodal'),'ONE: the card opened before the Undercroft');
       h=JSON.parse(J(P.heirs));
       // TWO: the Undercroft opens the card through its real route, with what the plan says on it
       P.cosSkin='tan'; A=J(lookSnap());
       showScreen('hub');
       need(on('birthmodal'),'TWO: the Undercroft did not open the birth card');
       L=document.querySelectorAll('#birthheirs .bhcard');
       need(L.length===3,'TWO: '+L.length+' heir cards, not 3');
       for(i=0;i<3&&i<L.length;i++) need(L[i].textContent.indexOf(pilName(h[i]))===0,'TWO: card '+i+' reads '+J(L[i].textContent)+', not '+pilName(h[i]));
       need(el('birthhead').textContent==='your 2nd pillager','TWO: the head reads '+J(el('birthhead').textContent));
       need(el('birthgo').textContent==='ascend as '+pilName(h[0]),'TWO: the default button reads '+J(el('birthgo').textContent));
       need(document.querySelectorAll('#birthkits .bkit').length===3,'TWO: the kit row has '+document.querySelectorAll('#birthkits .bkit').length+' kits');
       need(P.pilNote&&P.pilNote.shown===1,'TWO: the floor line did not stay: '+J(P.pilNote));
       need(P.birthLook===2,'TWO: the look was not rolled for this birth (birthLook '+P.birthLook+')');
       for(i=0;i<L.length;i++) (function(c){ var T=pilTraitList(h[i]), q=c.querySelectorAll('i'), j; need(q.length===T.length,'TWO: card '+i+' shows '+q.length+' traits, not '+T.length); for(j=0;j<q.length&&j<T.length;j++) need(q[j].textContent===T[j].n&&q[j].getAttribute('style').indexOf(pilTraitGood(T[j])?'--ok':'--danger')>=0,'TWO: card '+i+' trait '+j+' reads '+q[j].outerHTML); })(L[i]);
       // the pad reaches every control and never a kit he cannot pay for
       st=padFocusables(el('birthmodal'));
       need(st.indexOf(el('birthname'))>=0&&st.indexOf(el('birthgo'))>=0&&st.indexOf(el('closebirth'))>=0&&st.indexOf(el('birthlook'))>=0&&st.indexOf(L[1])>=0,'TWO: the pad cannot reach a control on the card');
       // THREE: the look: his edit is kept through the editor and through opening the card again
       P.cosSkin='tan'; B=J(lookSnap());
       el('birthlook').click();
       need(on('appearmodal')&&!on('birthmodal')&&P.pil===null,'THREE: edit look did not open the editor over a waiting card');
       el('closeappear').click();
       need(on('birthmodal')&&!on('appearmodal')&&P.pil===null,'THREE: closing the editor did not come back to the card');
       showScreen('hub');
       need(J(lookSnap())===B,'THREE: the look moved after his edit');
       // FOUR: nothing ascends with nobody living
       g0=__state();
       need(ascendNow()===false&&__state()===g0&&P.pil===null&&on('birthmodal'),'FOUR: ascendNow went through with nobody living');
       if(!HB) HB=buildHub();
       n=0; for(i=0;i<HB.stations.length;i++){ st=HB.stations[i]; if(st.acts&&st.acts.KeyR&&/quick ascent/.test(st.acts.KeyR[0])){ n++; st.acts.KeyR[1](); } }
       need(n>0,'FOUR: no quick ascent found to refuse');
       need(__state()===g0&&P.pil===null&&on('birthmodal'),'FOUR: the quick ascent went through with nobody living');
       // FIVE: heir 2, named vosk, the basic kit, through the card
       c0=P.credits; le0=lifeEarnNow();
       document.querySelector('#birthheirs [data-heir="1"]').click();
       el('birthname').value='VOSK'; el('birthname').dispatchEvent(new Event('input',{bubbles:true}));
       need(el('birthname').value==='vosk','FIVE: the name box holds '+J(el('birthname').value));
       document.querySelector('#birthkits [data-bkit="basic"]').click();
       need(P.credits===c0&&P.pil===null,'FIVE: picking a kit charged or birthed before the button');
       el('birthgo').click();
       need(P.pil&&P.pil.name==='vosk'&&P.pil.gen===2&&P.pilGen===2&&J(P.pil.traits)===J(h[1].traits)&&P.heirs===undefined,'FIVE: the living pillager is '+J(P.pil)+' gen '+P.pilGen+', not vosk gen 2 with '+J(h[1].traits));
       need(P.pil&&P.pil.num===pilNum({hall:P.hall},'vosk'),'FIVE: vosk carries numeral '+(P.pil&&P.pil.num));
       need(P.credits===c0-300,'FIVE: credits '+P.credits+', not exactly '+(c0-300));
       need(lifeEarnNow()===le0,'FIVE: lifetime earnings moved from '+le0+' to '+lifeEarnNow());
       need(P.birthKit==='basic'&&P.freeKit===1,'FIVE: the kit is not waiting: birthKit '+P.birthKit+' freeKit '+P.freeKit);
       need(!on('birthmodal')&&on('sectormodal'),'FIVE: the default button did not end on the map page');
       st=document.querySelector('#sectorkitpick .kitb[data-kit="free"]');
       need(st&&/basic kit/i.test(st.textContent),'FIVE: the kit tile reads '+(st?J(st.textContent):'nothing'));
       // the raid goes up with the kit, on the real door
       P.kit=[]; c0=P.credits;
       ascendNow(); g=__state();
       need(g&&g!==g0&&g.freeKit===1&&g.player.wep&&g.player.wep.id==='smg','FIVE: the raid went up with '+(g&&g.player.wep&&g.player.wep.id)+', not the kit gun');
       n=0; for(i=0;g&&i<g.bag.length;i++) if(g.bag[i]==='bandage') n++;
       need(n>=3,'FIVE: the raid went up with '+n+' bandages');
       need(P.birthKit===null&&P.credits===c0,'FIVE: going up left birthKit '+P.birthKit+' and credits '+P.credits);
       // SIX: a free walk-back gives the kit back; a death takes it off the ledger
       g.tel.shots=0; g.tel.containers=0; g.tel.distance=0; g.bag=[]; n=P.runs;
       __endRaid('abandon'); done();
       need(P.runs===n,'SIX: control: that abandon was not the free walk-back');
       need(P.birthKit==='basic'&&P.freeKit===1,'SIX: the free walk-back lost the kit: '+P.birthKit+' '+P.freeKit);
       shut();
       ascendNow(); g=__state(); strip(g);
       need(g.player.wep&&g.player.wep.id==='smg','SIX: second raid is not on the kit gun');
       n=P.hall.length;
       __endRaid('dead'); done();
       need(P.pil===null&&P.hall.length===n+1,'SIX: the death did not end vosk');
       st=P.hall[P.hall.length-1]||{end:{}};
       need((st.end.items||[]).indexOf('gun_smg')<0&&P.weapons.indexOf('smg')<0,'SIX: the kit gun is on the ledger or the rack: '+J(st.end.items)+' '+J(P.weapons));
       // SEVEN: a kit he cannot afford is refused and greyed, and close births heir 1
       P.credits=100; h=JSON.parse(J(P.heirs));
       showScreen('hub');
       st=document.querySelector('#birthkits [data-bkit="basic"]');
       need(on('birthmodal')&&st&&st.disabled,'SEVEN: the basic kit is not greyed with $100');
       need(padFocusables(el('birthmodal')).indexOf(st)<0,'SEVEN: the pad can reach a kit he cannot pay for');
       need(birthBorn(0,'','basic')===null&&P.pil===null&&P.credits===100&&!P.birthKit,'SEVEN: birthBorn took a kit he cannot pay for: '+J(P.pil)+' $'+P.credits);
       need(birthBorn(1,'','priv')===null&&P.pil===null,'SEVEN: birthBorn took the privileged kit with $100');
       el('closebirth').click();
       need(P.pil&&P.pil.name===h[0].name&&J(P.pil.traits)===J(h[0].traits)&&P.pil.gen===3&&!on('birthmodal')&&P.credits===100,'SEVEN: close gave '+J(P.pil)+', not heir 1 '+J(h[0]));
       // EIGHT: esc births heir 1 through the same door
       die(); h=JSON.parse(J(P.heirs)); showScreen('hub');
       need(on('birthmodal'),'EIGHT: the card did not open');
       escCloseTopModal();
       need(P.pil&&P.pil.name===h[0].name&&P.pil.gen===4&&!on('birthmodal'),'EIGHT: esc gave '+J(P.pil));
       // NINE: the host goes up while the card is open: heir 1 goes up, no kit
       die(); h=JSON.parse(J(P.heirs)); showScreen('hub');
       birthAuto();
       need(P.pil&&P.pil.name===h[0].name&&!on('birthmodal'),'NINE: birthAuto gave '+J(P.pil));
       // TEN: the demo sees no card
       if(typeof ARCADE==='object'&&ARCADE){
         die(); n=P.pil;
         ARCADE.on=true;
         try{ showScreen('hub'); need(!on('birthmodal')&&birthNeed()===false&&birthOpen()===false,'TEN: the demo opened the card'); }finally{ ARCADE.on=a0; }
       }
       // ELEVEN: a save waiting on the card loads twice and still waits, with the same three heirs
       shut(); if(P.pil) { BIRTH=null; birthBorn(0,'','none'); die(); }
       h0=J(P.heirs); snap=JSON.parse(J(P)); snap.cfg=JSON.parse(J(CFG)); snap.cfgv=18;
       for(i=0;i<2;i++){
         applyLoadedProfile({value:J(snap)});
         need(P.pil===null&&J(P.heirs)===h0&&birthNeed()===true,'ELEVEN: load '+(i+1)+' gave pil '+J(P.pil)+' heirs '+J(P.heirs));
         snap=JSON.parse(J(P)); snap.cfg=JSON.parse(J(CFG)); snap.cfgv=18;
       }
       // TWELVE: an old save has a living pillager: no card, and nothing lost or moved
       BIRTH=null; birthBorn(0,'','none'); shut();
       snap=JSON.parse(J(P)); delete snap.birthLook; delete snap.birthKit; delete snap.heirs; delete snap.pilNote; snap.cfg=JSON.parse(J(CFG)); snap.cfgv=18;
       A={c:snap.credits,s:J(snap.stash),w:J(snap.weapons),eq:snap.equipped,ct:J(snap.contracts),fg:J(snap.forged||{}),le:snap.lifeEarn,p:snap.pil.name+'/'+snap.pil.gen+'/'+snap.pil.raids,h:snap.hall.length,g:snap.pilGen};
       for(i=0;i<2;i++){
         applyLoadedProfile({value:J(snap)});
         B={c:P.credits,s:J(P.stash),w:J(P.weapons),eq:P.equipped,ct:J(P.contracts),fg:J(P.forged||{}),le:P.lifeEarn,p:P.pil.name+'/'+P.pil.gen+'/'+P.pil.raids,h:P.hall.length,g:P.pilGen};
         need(J(A)===J(B),'TWELVE: load '+(i+1)+' moved the save: '+J(A)+' vs '+J(B));
         need(birthNeed()===false,'TWELVE: an old save with a living pillager needs a birth');
         snap=JSON.parse(J(P)); snap.cfg=JSON.parse(J(CFG)); snap.cfgv=18;
       }
       showScreen('hub');
       need(!on('birthmodal'),'TWELVE: an old save opened the card');
     }catch(e2){ bad.push('threw: '+(e2&&e2.message||e2)); }
     finally{
       if(typeof ARCADE==='object'&&ARCADE) ARCADE.on=a0;
       try{ g=__state(); if(g&&!g.over){ g.player.downed=false; g.tel.shots=0; __endRaid('abandon'); } }catch(_e){}
       shut(); BIRTH=null;
       P=saved; storeSet=oldStore; saveProfile=oldSave;
       for(k in CFG) if(!(k in cfg)) delete CFG[k]; for(k in cfg) CFG[k]=cfg[k];
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'37.32',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
