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

if ($s.Contains("  {v:'37.38',what:")) { throw "check 37.38 is in the fixture already" }

SubRx @'
  {v:'37.37',what:
'@ @'
  {v:'37.38',what:'cw-m2retire: a level 3 pillager wearing two pieces retired by the hold pays exactly $750, adds $750 to lifetime earnings, moves both pieces to P.gear, goes in the hall as retire, rolls three heirs and opens the birth card; a short hold, a mouse click and a raidless pillager pay nothing; pad and keys go through a confirm card; retire and rename are refused in a raid and in the demo; a rename shows in the hall tab and in the raid word, over the head and on the run card; the account name shows in the lobby and the stash and not over the head; a restore code carries the lineage exactly; an old code and an old save lose nothing',
   run:function(){
     if(!(window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile&&window.__deploy&&window.__endRaid&&window.__state)) return 'SKIP: this fixture cannot stage';
     if(typeof pilRetire!=='function'||typeof pilRename!=='function'||typeof pilHeadName!=='function'||typeof acctNameSet!=='function') return 'no retire, rename or account name in this build';
     var saved=P, snap0=JSON.stringify(P), cfg={}, k, oldStore=storeSet, oldSave=saveProfile, oldFast=netSendFast, arcOn=ARCADE.on, bad=[], q, b, r, i, le0, c0, pcA, pcB, sent, tx, oldFill, o, o2, A, B, snap, seed;
     var netWas={on:NET.on,role:NET.role,seat:NET.seat,peers:NET.peers,roster:NET.roster,up:NET.up,upSeed:NET.upSeed,name:NET.name,pn:NET.pn,pnSent:NET.pnSent,upAcc:NET.upAcc};
     function need(ok,msg){ if(!ok) bad.push(msg); }
     function E(id){ return document.getElementById(id); }
     function J(x){ return JSON.stringify(x); }
     function on(id){ return E(id).classList.contains('on'); }
     function kindFor(slot){ var n; for(n in WORN_KINDS) if(WORN_KINDS[n].slots.indexOf(slot)>=0) return n; return null; }
     function live(lvl,raids){ P.pil=pilMake('brakka',P.hall.length+1,[],pilNum(P,'brakka')); P.pil.lvl=lvl; P.pil.raids=raids; P.pilGen=P.pil.gen; delete P.heirs; BIRTH=null; }
     function arrive(q){ q.bag=[]; q.carriedIn=0; q.carriedKit=[]; q.issuedBandages=0; q.pedCarry=0; q.pedSold=0; q.strayPaid=0; q.goalRewards=null; q.player.downed=false; q.player.hp=100; q.ents.length=0; q.player.iv=99; q.tel.kills={}; q.tel.deathKiller='warden'; q.tel.lastHitName=null; }
     for(k in CFG) cfg[k]=CFG[k];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       storeSet=function(){}; saveProfile=function(){};
       P.cond='day'; P.terms=[]; P.merc=''; CFG.safeSlots=0; P.pilNote=null; P.birthKit=null; P.freeKit=0; P.kitPick='mine'; P.gear=[]; P.worn={}; P.hall=[]; P.sellDay=null;
       showScreen('hub');
       // ONE: the hold retires a level 3 pillager wearing two pieces
       P.credits=1000; P.lifeEarn=100; live(3,2);
       pcA=wornAdd(P,wornMake(kindFor('head'),1,10,11)); pcB=wornAdd(P,wornMake(kindFor('boots'),1,10,12));
       need(pcA&&pcB&&wornWear(P,pcA.id)&&wornWear(P,pcB.id)&&Object.keys(P.worn).length===2,'ONE: the two pieces are not worn '+J(P.worn));
       le0=lifeEarnNow();
       openOps('hall');
       b=E('hallretire');
       need(on('opmodal')&&E('hallme').style.display!=='none'&&b.offsetParent,'ONE: the retire row does not show');
       need(b.textContent==='retire brakka  +$750','ONE: the row reads '+J(b.textContent));
       need(E('hallname').value==='brakka','ONE: the name box reads '+J(E('hallname').value));
       // a short hold cancels and a mouse click spends nothing
       b.onmousedown({button:0}); craftHoldStep(0.5); window.dispatchEvent(new MouseEvent('mouseup'));
       craftHoldStep(1); need(P.pil&&P.credits===1000,'ONE: a short hold retired');
       b.dispatchEvent(new MouseEvent('click',{detail:1,bubbles:true}));
       need(P.pil&&P.credits===1000&&!on('askmodal'),'ONE: a mouse click retired');
       b.onmousedown({button:0}); craftHoldStep(0.5); need(!!P.pil,'ONE: half a hold retired'); craftHoldStep(0.6);
       need(P.credits===1750,'ONE: paid to '+P.credits+', not 1750');
       need(lifeEarnNow()===le0+750,'ONE: lifetime earnings '+lifeEarnNow()+', not '+(le0+750));
       need(Object.keys(P.worn).length===0,'ONE: still worn '+J(P.worn));
       need(P.gear.some(function(g){ return g.id===pcA.id; })&&P.gear.some(function(g){ return g.id===pcB.id; }),'ONE: the pieces are not in P.gear '+J(P.gear));
       r=P.hall[P.hall.length-1];
       need(P.hall.length===1&&r.end&&r.end.how==='retire'&&r.end.look&&r.end.worn&&Object.keys(r.end.worn).length===2&&r.lvl===3,'ONE: the hall record is '+J(r));
       need(P.pil===null&&Array.isArray(P.heirs)&&P.heirs.length===3&&P.heirs[0].gen===2,'ONE: pil '+J(P.pil)+' heirs '+J(P.heirs));
       need(on('birthmodal')&&!on('opmodal'),'ONE: the birth card is '+on('birthmodal')+', the Mainframe '+on('opmodal'));
       birthFinish(false);
       need(P.pil&&P.pil.gen===2,'ONE: the birth card did not birth after a retire');
       // a pillager with no raids yet cannot retire: birth, retire, birth would print money
       openOps('hall'); b=E('hallretire');
       need(b.disabled&&b.textContent==='retire after one raid','TWO: a raidless pillager reads '+J(b.textContent));
       c0=P.credits; need(pilRetire()===null&&P.credits===c0&&!!P.pil,'TWO: a raidless pillager retired');
       // keys and pad press with no hold, so they ask first
       P.pil.raids=1; P.pil.lvl=1; hallMeDraw(); c0=P.credits;
       need(b.textContent.indexOf('retire ')===0&&b.textContent.indexOf('+$250')>0&&!b.disabled,'TWO: level 1 reads '+J(b.textContent));
       b.click();
       need(on('askmodal')&&!!P.pil&&P.credits===c0,'TWO: a key or pad press did not ask first');
       E('askno').click();
       need(!!P.pil&&P.credits===c0&&!on('askmodal')&&on('opmodal'),'TWO: not yet did not go back');
       b.click(); E('askyes').click();
       need(!P.pil&&P.credits===c0+250&&on('birthmodal')&&!on('opmodal'),'TWO: yes did not retire: credits '+P.credits+' birth '+on('birthmodal'));
       birthFinish(false);
       // THREE: refused in the demo
       P.pil.raids=2; c0=P.credits; ARCADE.on=1;
       need(pilRetire()===null&&pilRename(P,'demoname')===null&&P.credits===c0&&!!P.pil&&P.pil.name!=='demoname','THREE: the demo retired or renamed');
       hallMeDraw(); need(E('hallme').style.display==='none','THREE: the row shows in the demo');
       ARCADE.on=arcOn;
       // FOUR: a rename, in the hall tab; the numeral counts the lineage
       openOps('hall'); r=E('hallname');
       r.value='Rusk'; r.dispatchEvent(new Event('input',{bubbles:true}));
       need(P.pil.name==='rusk'&&r.value==='rusk','FOUR: typed Rusk, name '+J(P.pil.name)+' box '+J(r.value));
       need(document.querySelector('#halllist .hname').textContent==='rusk','FOUR: the tab shows '+document.querySelector('#halllist .hname').textContent);
       need(E('hallretire').textContent.indexOf('retire rusk')===0,'FOUR: the row reads '+E('hallretire').textContent);
       r.value='brakka'; r.dispatchEvent(new Event('input',{bubbles:true}));
       need(pilName(P.pil)==='brakka ii'&&document.querySelector('#halllist .hname').textContent==='brakka ii','FOUR: the second brakka is '+pilName(P.pil));
       r.value='rusk'; r.dispatchEvent(new Event('input',{bubbles:true}));
       r.value=''; r.dispatchEvent(new Event('input',{bubbles:true}));
       need(P.pil.name==='rusk','FOUR: an empty box renamed to '+J(P.pil.name));
       r.dispatchEvent(new Event('blur')); need(r.value==='rusk','FOUR: an empty box stayed empty');
       // typing in the box leaves the Mainframe alone, and the pad letter picker writes it
       r.focus(); window.dispatchEvent(new KeyboardEvent('keydown',{code:'KeyE',key:'e',bubbles:true,cancelable:true})); window.dispatchEvent(new KeyboardEvent('keydown',{code:'KeyR',key:'r',bubbles:true,cancelable:true}));
       need(on('opmodal')&&E('opane_hall').style.display!=='none','FOUR: typing E and R moved the Mainframe');
       r.blur();
       need(padNameStart(r)===true&&PADNAME&&PADNAME.input===r,'FOUR: the pad letter picker did not open');
       if(PADNAME){ padNamePoll(function(){ return false; }); need(!!PADNAME,'FOUR: the picker shut over the Mainframe'); if(PADNAME){ PADNAME.l=('vosk'+'                ').slice(0,16).split(''); padNameClose(true); } }
       need(P.pil.name==='vosk','FOUR: the picker wrote '+J(P.pil.name));
       padSetFocus(null); PAD.focus=null;
       E('closeop').click();
       // FIVE: the account name and the pillager's name
       P.pil.name='rusk'; P.pil.num=1; P.runs=3; P.pil.raids=2;
       E('pnamein').value='ozzy'; E('pnamesave').onclick();
       need(P.acctName==='ozzy'&&P.pname==='ozzy'&&P.pil.name==='rusk','FIVE: the title name set account '+J(P.acctName)+' pname '+J(P.pname)+' pillager '+J(P.pil.name));
       renderHub(); need(E('stashname').textContent==='ozzy','FIVE: the stash shows '+E('stashname').textContent);
       netMe(); need(NET.name==='ozzy','FIVE: the link name is '+NET.name);
       need(pilHeadName()==='rusk','FIVE: over the head is '+pilHeadName());
       // the next raid: refused up there, and the word carries the pillager's name
       P.pil.lvl=2; c0=P.credits; A=J(P.hall);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); q=__state(); arrive(q); seed=q.seed>>>0;
       need(state==='raid','SIX: the raid state is '+state);
       need(pilRetire()===null&&pilRename(P,'upthere')===null&&P.credits===c0&&!!P.pil&&P.pil.name==='rusk'&&J(P.hall)===A,'SIX: retired or renamed in a raid');
       NET.on=true; NET.role='join'; NET.seat=1; NET.peers=[{state:'in',seat:0}]; NET.up=[]; NET.upSeed=seed; NET.upAcc=1; NET.pn={}; NET.pnSent='';
       NET.roster=[{seat:0,pid:'aa',name:'hostacct',host:true},{seat:1,pid:'bb',name:'ozzy',host:false}];
       sent=[]; netSendFast=function(p,m){ sent.push(m); return true; };
       netUpTick(0.2);
       need(sent.length>0&&sent[0].pn==='rusk','SIX: the raid word carries '+J(sent[0]&&sent[0].pn));
       need(J(sent[0]).indexOf('ozzy')<0,'SIX: the raid word carries the account name');
       need(netOnState({state:'in',seat:0},{t:'st',k:'r',s:0,sd:seed,x:q.player.x+50,y:q.player.y,f:0,m:0,r:0})==='state'&&netSeatName(0)==='hostacct','SIX: an old window with no pn reads '+netSeatName(0));
       need(netOnState({state:'in',seat:0},{t:'st',k:'r',s:0,sd:seed,x:q.player.x+50,y:q.player.y,f:0,m:0,r:0,pn:'brakka ii'})==='state'&&netSeatName(0)==='brakka ii','SIX: the partner reads '+netSeatName(0));
       tx=[]; oldFill=wc.fillText; wc.fillText=function(t){ tx.push(String(t)); };
       try{ netUpTags(); }finally{ wc.fillText=oldFill; }
       need(tx.indexOf('brakka ii')>=0&&tx.indexOf('hostacct')<0,'SIX: over his head drew '+J(tx));
       renderParty(); o=E('partyroster').textContent;
       need(o.indexOf('hostacct')>=0&&o.indexOf('ozzy')>=0&&o.indexOf('brakka ii')<0&&o.indexOf('rusk')<0,'SIX: the lobby reads '+J(o));
       netSendFast=oldFast; NET.on=false; NET.role=null; NET.peers=[]; NET.roster=[]; NET.up=[]; NET.upSeed=0; NET.pn={};
       __endRaid('extract');
       need(E('oc_pil').textContent==='rusk'&&E('oc_pil').style.display!=='none','SIX: the run card reads '+J(E('oc_pil').textContent));
       __topClear(); showScreen('hub');
       // the demo keeps its own name
       ARCADE.on=1; P.pname='PLAYER 1'; need(pilHeadName()==='PLAYER 1','SIX: the demo head name is '+pilHeadName()); ARCADE.on=arcOn; P.pname='ozzy';
       // a save that has not played: the first pillager takes the typed name
       P.hall=[]; P.pilGen=1; P.pil=pilMake('PILLAGER',1); P.runs=0; acctNameSet('kell');
       need(P.acctName==='kell'&&P.pil.name==='kell','SEVEN: a new save has account '+P.acctName+' pillager '+P.pil.name);
       // EIGHT: a restore code carries the lineage and restores it exactly
       P.acctName='ozzy'; P.pname='ozzy'; P.pilGen=4; P.pil=pilMake('vosk',4,['lightstep'],2); P.pil.raids=7; P.pil.lvl=5;
       P.hall=[{name:'vosk',gen:1,num:1,traits:[],lvl:2,raids:3,kills:1,best:50,end:{at:5,how:'dead',by:'warden'}},{name:'rusk',gen:2,num:1,traits:[],lvl:3,raids:4,kills:2,best:60,end:{at:6,how:'retire',worn:{},look:{}}},{name:'kell',gen:3,num:1,traits:[],lvl:1,raids:2,kills:0,best:0,end:{at:7,how:'quit'}}];
       A={a:'ozzy',p:J(P.pil),h:J(P.hall),g:P.pilGen};
       o=restoreRead(restoreCode());
       need(o&&o.pl&&o.n==='ozzy','EIGHT: the code carries '+J(o&&o.pl));
       P.acctName='other'; P.pname='other'; P.pil=pilMake('someone',9); P.hall=[{name:'notmine',gen:1,end:{how:'dead'}}]; P.pilGen=9;
       need(restoreApply(o)===true,'EIGHT: the code did not apply');
       B={a:P.acctName,p:J(P.pil),h:J(P.hall),g:P.pilGen};
       need(J(A)===J(B)&&P.pname==='ozzy','EIGHT: restored '+J(B)+' not '+J(A));
       // nobody living, three heirs waiting
       P.pil=null; delete P.heirs; pilHeirs(P); A=J(P.heirs); o=restoreRead(restoreCode());
       P.pil=pilMake('someone',9); P.heirs=undefined; P.pilNote={t:'someone is gone',shown:0}; P.birthKit='basic';
       restoreApply(o);
       need(P.pil===null&&J(P.heirs)===A&&!P.pilNote&&!P.birthKit,'EIGHT: nobody living came back as '+J(P.pil)+' heirs '+J(P.heirs)+' note '+J(P.pilNote)+' kit '+P.birthKit);
       need(birthNeed(),'EIGHT: the birth card is not owed');
       // NINE: an old code, made the way v37.27 made it, restores with nothing lost
       P.acctName='ozzy'; P.pname='ozzy'; P.pilGen=1; P.hall=[]; P.pil=pilMake('ozzy',1); P.credits=4321; P.stash=['scrap','core']; P.lifeEarn=7000; P.runs=9; P.ext=4; P.best=800;
       o=JSON.parse(J(restoreMake())); delete o.pl;
       P.acctName='other'; P.pname='other'; P.pil=pilMake('someone',9); P.hall=[{name:'notmine',gen:1,end:{how:'dead'}}]; P.pilGen=9; P.credits=1; P.stash=[]; P.lifeEarn=1; P.heirs=undefined;
       need(restoreApply(o)===true,'NINE: the old code did not apply');
       need(P.acctName==='ozzy'&&P.pname==='ozzy','NINE: the old code named '+P.acctName);
       need(P.pil&&P.pil.gen===1&&P.pil.name==='ozzy'&&P.hall.length===0&&P.pilGen===1&&P.heirs===undefined,'NINE: the lineage is '+J(P.pil)+' hall '+J(P.hall)+' gen '+P.pilGen);
       need(P.pil.raids===9&&P.pil.ext===4&&P.pil.best===800,'NINE: generation one lost its record '+J(P.pil));
       need(P.credits===4321&&P.stash.length===2&&P.lifeEarn===7000,'NINE: credits '+P.credits+' stash '+J(P.stash)+' lifetime '+P.lifeEarn);
       // TEN: an old save reloads twice with nothing lost; the name typed since m0 wins once
       P.pilGen=4; P.pil=pilMake('live',4); P.hall=[{name:'oldtimer',gen:1,end:{how:'dead'}}]; P.lifeEarn=7000; P.credits=4321;
       for(i=0;i<2;i++){
         snap=JSON.parse(J(P)); snap.cfg=JSON.parse(J(CFG)); snap.cfgv=18;
         if(i===0){ delete snap.mig2n; snap.acctName='stale'; snap.pname='typedlater'; }
         A={c:snap.credits,s:J(snap.stash),w:J(snap.weapons),eq:snap.equipped,ct:J(snap.contracts),fg:J(snap.forged||{}),le:snap.lifeEarn,p:J(snap.pil),h:J(snap.hall),g:snap.pilGen,gr:J(snap.gear),wn:J(snap.worn)};
         applyLoadedProfile({value:J(snap)});
         B={c:P.credits,s:J(P.stash),w:J(P.weapons),eq:P.equipped,ct:J(P.contracts),fg:J(P.forged||{}),le:P.lifeEarn,p:J(P.pil),h:J(P.hall),g:P.pilGen,gr:J(P.gear),wn:J(P.worn)};
         need(J(A)===J(B),'TEN: load '+(i+1)+' moved the save: '+J(A)+' vs '+J(B));
         need(P.mig2n===1&&P.acctName==='typedlater'&&P.pname==='typedlater','TEN: load '+(i+1)+' account '+P.acctName+' pname '+P.pname+' stamp '+P.mig2n);
       }
       P.acctName='keptname'; snap=JSON.parse(J(P)); snap.cfg=JSON.parse(J(CFG)); snap.cfgv=18;
       applyLoadedProfile({value:J(snap)});
       need(P.acctName==='keptname','TEN: a stamped save lost its account name: '+P.acctName);
     }catch(e2){ bad.push('threw: '+(e2&&e2.message||e2)); }
     finally{
       netSendFast=oldFast; ARCADE.on=arcOn;
       for(k in netWas) NET[k]=netWas[k];
       try{ if(state==='raid'){ __endRaid('extract'); } }catch(_e){}
       try{ if(PADNAME) padNameClose(false); padSetFocus(null); PAD.focus=null; }catch(_p){}
       try{ craftHoldCancel(); }catch(_h){}
       try{ E('birthmodal').classList.remove('on'); E('askmodal').classList.remove('on'); E('opmodal').classList.remove('on'); }catch(_m){}
       BIRTH=null;
       P=saved;
       (function(){ var n, s=JSON.parse(snap0); for(n in P) if(Object.prototype.hasOwnProperty.call(P,n)) delete P[n]; for(n in s) P[n]=s[n]; })();
       storeSet=oldStore; saveProfile=oldSave;
       for(k in cfg) CFG[k]=cfg[k];
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'37.37',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
