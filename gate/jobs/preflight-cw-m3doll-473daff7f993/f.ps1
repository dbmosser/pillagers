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

if ($s.Contains("  {v:'37.42',what:")) { throw "check 37.42 is in the fixture already" }

SubRx @'
  {v:'37.41',what:
'@ @'
  {v:'37.42',what:'cw-m3doll: the doll opens from the stash row with nine named slots and the figure; a click on a piece wears it, a second swaps, a ring takes the empty ring and with both full the weaker, a click on a filled slot takes it off; 50 random clicks lose and double nothing; the sum shown equals wornMods with a cap mark; the tip says better, worse and even on hover and on the highlight; an outfit saved, undressed and tapped dresses exactly, and with a piece gone leaves that slot and shows 1 missing; 200 pieces draw and scroll with nothing out of the window; keys and pad reach every control and B never wears a backpack; the pre-raid worn line opens it and comes back; demo and raid refuse it; an old save reloads with nothing lost',
   run:function(){
     if(!(window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile&&window.__deploy&&window.__endRaid&&window.__state)) return 'SKIP: this fixture cannot stage';
     if(typeof gearOpen!=='function'||typeof wornOutfitDress!=='function'||typeof wornTip!=='function') return 'no doll in this build';
     var saved=P, snap0=JSON.stringify(P), cfg={}, k, oldStore=storeSet, oldSave=saveProfile, arcOn=ARCADE.on, bad=[], i, a, b, c, d, r1, r2, r3, L, s, t, o, snap, A, B, n0, seed, pcs, q, keys;
     function need(ok,msg){ if(!ok) bad.push(msg); }
     function E(id){ return document.getElementById(id); }
     function J(x){ return JSON.stringify(x); }
     function on(id){ return E(id).classList.contains('on'); }
     function rowOf(id){ return document.querySelector('#gearlist [data-gp="'+id+'"]'); }
     function slotOf(sl){ return document.querySelector('#gearslots [data-gs="'+sl+'"]'); }
     function mk(kind,st,v,r){ var pc=wornAdd(P,wornMake(kind,r===undefined?1:r,50,7)); pc.tr=[{s:st,v:v}]; return pc; }
     function wid(sl){ return P.worn[sl]?P.worn[sl].id:''; }
     function allIds(){ var x=[], u; P.gear.forEach(function(g){ x.push(g.id); }); for(u in P.worn) x.push(P.worn[u].id); return x.sort(); }
     function uniq(x){ var u={}, j; for(j=0;j<x.length;j++){ if(u[x[j]]) return false; u[x[j]]=1; } return true; }
     function fresh(){ P.gear=[]; P.worn={}; P.outfits=[]; GEAR.lit=''; GEAR.tip=''; gearDraw(); }
     function hover(el){ el.dispatchEvent(new MouseEvent('mouseover',{bubbles:true})); }
     function press(code){ window.dispatchEvent(new KeyboardEvent('keydown',{code:code,key:code,bubbles:true,cancelable:true})); }
     function sumOk(tag){
       var m=wornMods(P.worn), u, x, shown=document.querySelectorAll('#gearsum [data-st]'), want=0;
       for(u in m) if(m[u]){ want++; x=document.querySelector('#gearsum [data-st="'+u+'"]');
         need(!!x&&x.textContent.indexOf(WORN_STATS[u].n+' +'+Math.round(m[u]*100)+'%')===0,tag+': '+u+' shows '+(x?J(x.textContent):'nothing')+', wornMods '+m[u]);
         need(!!x&&(!!x.querySelector('em'))===(m[u]>=WORN_STATS[u].cap),tag+': the cap mark on '+u+' at '+m[u]); }
       need(shown.length===want,tag+': '+shown.length+' stats shown, wornMods has '+want);
     }
     for(k in CFG) cfg[k]=CFG[k];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       storeSet=function(){}; saveProfile=function(){};
       P.cond='day'; P.terms=[]; P.merc=''; P.pilNote=null; P.birthKit=null; P.freeKit=0; P.kitPick='mine'; P.gear=[]; P.worn={}; P.outfits=[]; P.hall=[];
       showScreen('hub'); renderHub();
       // ONE: the real route from the stash row, nine named slots and the figure
       need(!!E('gearbtn')&&E('gearbtn').textContent.replace(/\s+/g,' ')==='GEAR 0/9','ONE: the stash row reads '+(E('gearbtn')?J(E('gearbtn').textContent):'nothing'));
       E('gearbtn').click();
       need(on('gearmodal'),'ONE: the gear button did not open the window');
       L=document.querySelectorAll('#gearslots [data-gs]');
       need(L.length===9,'ONE: '+L.length+' slots');
       WORN_SLOTS.forEach(function(sl){ var e=slotOf(sl); need(!!e&&e.offsetHeight>0&&e.textContent===WORN_KINDS[gearKindOf(sl)].n,'ONE: slot '+sl+' reads '+(e?J(e.textContent):'nothing')); });
       need(E('gearwn').textContent==='worn 0 of 9','ONE: the head reads '+E('gearwn').textContent);
       (function(){ var cv=E('gearcv'), px=cv.getContext('2d').getImageData(0,0,cv.width,cv.height).data, j, any=0; for(j=3;j<px.length;j+=4) if(px[j]){ any=1; break; } need(any,'ONE: the figure did not draw'); })();
       // TWO: a click wears, a second swaps, a filled slot shows its name, colour and icon, a click takes off
       a=wornAdd(P,wornMake('boots',1,40,11)); b=wornAdd(P,wornMake('boots',2,44,12)); gearDraw();
       need(!!rowOf(a.id)&&rowOf(a.id).textContent.indexOf('sound boots')>=0&&rowOf(a.id).textContent.indexOf('power 40')>=0,'TWO: the row reads '+(rowOf(a.id)?J(rowOf(a.id).textContent):'nothing'));
       need(rowOf(a.id).textContent.indexOf(WORN_STATS[a.tr[0].s].n+' +'+Math.round(wornTraitV(a,a.tr[0])*100)+'%')>=0,'TWO: the row has not its trait: '+J(rowOf(a.id).textContent));
       rowOf(a.id).click();
       need(wid('boots')===a.id&&!P.gear.some(function(g){ return g.id===a.id; }),'TWO: the click did not wear it: '+wid('boots'));
       need(!rowOf(a.id),'TWO: a worn piece stays in the list');
       need(slotOf('boots').textContent.indexOf('sound boots')>=0&&!!slotOf('boots').querySelector('svg')&&slotOf('boots').getAttribute('style').indexOf(WORN_RARS[1].c)>=0,'TWO: the filled slot is '+slotOf('boots').outerHTML);
       need(E('gearwn').textContent==='worn 1 of 9','TWO: the head reads '+E('gearwn').textContent);
       rowOf(b.id).click();
       need(wid('boots')===b.id&&P.gear.length===1&&P.gear[0].id===a.id,'TWO: the second did not swap: '+wid('boots')+' gear '+J(P.gear));
       slotOf('boots').click();
       need(!P.worn.boots&&P.gear.length===2,'TWO: the slot did not take off: '+J(P.worn));
       need(GEAR.lit==='boots'&&document.querySelectorAll('#gearlist .grow').length===2,'TWO: taking off did not light the slot');
       // a lit slot filters, all lets go
       c=wornAdd(P,wornMake('head',0,20,13)); gearDraw();
       need(!rowOf(c.id)&&!!E('gearall'),'TWO: the lit slot does not filter');
       E('gearall').click();
       need(GEAR.lit===''&&!!rowOf(c.id),'TWO: all did not let go');
       slotOf('amulet').click();
       need(GEAR.lit==='amulet'&&document.querySelectorAll('#gearlist .grow').length===0&&document.querySelector('#gearlist .gnone').textContent==='no amulet','TWO: an empty slot lit reads '+E('gearlist').textContent);
       slotOf('amulet').click();
       need(GEAR.lit==='','TWO: a lit empty slot did not let go');
       // THREE: rings: the empty ring first, with both full the weaker
       fresh();
       r1=mk('ring','reload',0.10); r2=mk('ring','quiet',0.02); r3=mk('ring','quiet',0.05); gearDraw();
       rowOf(r1.id).click(); need(wid('ring1')===r1.id,'THREE: the first ring went to '+J(P.worn));
       rowOf(r2.id).click(); need(wid('ring2')===r2.id&&wid('ring1')===r1.id,'THREE: the second ring went to '+J(P.worn));
       slotOf('ring1').click(); GEAR.lit=''; gearDraw();
       rowOf(r3.id).click(); need(wid('ring1')===r3.id&&wid('ring2')===r2.id,'THREE: the empty ring was not filled first: '+J(P.worn));
       rowOf(r1.id).click(); need(wid('ring2')===r1.id&&wid('ring1')===r3.id,'THREE: with both full the weaker ring did not go: '+J(P.worn));
       need(wornTip(mk('ring','reload',0.01),P)==='worse','THREE: the tip against the weaker ring');
       // FOUR: 50 random clicks lose and double nothing
       fresh(); pcs=Object.keys(WORN_KINDS); seed=4242;
       for(i=0;i<36;i++) wornAdd(P,wornMake(pcs[i%pcs.length],i%4,10+i,1000+i));
       gearDraw(); n0=allIds().length; a=J(allIds());
       for(i=0;i<50;i++){
         seed=(seed*1103515245+12345)&0x7fffffff;
         if(E('gearall')) E('gearall').click();
         L=document.querySelectorAll('#gearlist .grow');
         if((seed>>8)%3!==0&&L.length) L[(seed>>10)%L.length].click();
         else { L=document.querySelectorAll('#gearslots .gslot.full'); if(L.length) L[(seed>>10)%L.length].click(); }
         need(J(allIds())===a&&uniq(allIds()),'FOUR: step '+i+' moved the pieces: '+allIds().length+' of '+n0);
         for(s in P.worn) need(WORN_KINDS[P.worn[s].k].slots.indexOf(s)>=0,'FOUR: step '+i+': '+P.worn[s].k+' in '+s);
       }
       sumOk('FOUR');
       // FIVE: the sum with a cap mark, the tip on hover and on the highlight
       fresh();
       a=mk('armor','tough',0.12); b=mk('head','tough',0.12); c=mk('boots','quiet',0.05); gearDraw();
       rowOf(a.id).click(); rowOf(b.id).click(); rowOf(c.id).click();
       need(wornMods(P.worn).tough===WORN_STATS.tough.cap,'FIVE: the staged cap is '+wornMods(P.worn).tough);
       sumOk('FIVE');
       need(document.querySelector('#gearsum [data-st="tough"]').textContent==='tough +15%cap','FIVE: the capped stat reads '+document.querySelector('#gearsum [data-st="tough"]').textContent);
       r1=mk('boots','quiet',0.10); r2=mk('boots','quiet',0.02); r3=mk('boots','quiet',0.05); gearDraw();
       [[r1,'better'],[r2,'worse'],[r3,'even']].forEach(function(T){
         need(wornTip(T[0],P)===T[1],'FIVE: wornTip says '+wornTip(T[0],P)+' for '+T[1]);
         hover(rowOf(T[0].id));
         t=E('geartip').textContent;
         need(t.indexOf(T[1])>=0&&t.indexOf('quiet +')>=0&&t.indexOf('against sound boots')>=0,'FIVE: on hover the '+T[1]+' tip reads '+J(t));
         need(rowOf(T[0].id).querySelector('em').textContent===T[1],'FIVE: the row word on '+T[1]);
       });
       E('geartip').innerHTML=''; padSetFocus(rowOf(r2.id));
       need(E('geartip').textContent.indexOf('worse')>=0,'FIVE: the tip does not follow the highlight: '+J(E('geartip').textContent));
       padSetFocus(slotOf('boots')); need(E('geartip').textContent.indexOf('worn')>=0,'FIVE: a worn slot tips '+J(E('geartip').textContent));
       padSetFocus(slotOf('amulet')); need(E('geartip').textContent.indexOf('empty')>=0,'FIVE: an empty slot tips '+J(E('geartip').textContent));
       padSetFocus(null); PAD.focus=null;
       // SIX: an outfit saved, undressed and tapped dresses exactly; a piece gone leaves its slot
       fresh();
       a=mk('head','hide',0.03); b=mk('ring','reload',0.05); c=mk('ring','quiet',0.05); d=mk('boots','quiet',0.03); r1=mk('boots','hide',0.03); r2=mk('amulet','grit',0.05); gearDraw();
       rowOf(a.id).click(); rowOf(b.id).click(); rowOf(c.id).click(); rowOf(d.id).click();
       E('gearname').value='Quiet Run'; E('gearname').dispatchEvent(new Event('input',{bubbles:true}));
       E('gearsavebtn').click();
       A=J({head:a.id,ring1:b.id,ring2:c.id,boots:d.id});
       need(P.outfits.length===1&&P.outfits[0].n==='quiet run'&&J(P.outfits[0].s)===A,'SIX: saved '+J(P.outfits));
       need(E('gearname').value===''&&E('gearoutn').textContent==='outfits 1 of 5','SIX: after a save the box reads '+J(E('gearname').value)+', the head '+E('gearoutn').textContent);
       function dressed(){ var x={}, j, u; for(j=0;j<WORN_SLOTS.length;j++){ u=WORN_SLOTS[j]; if(P.worn[u]) x[u]=P.worn[u].id; } return x; }
       need(document.querySelector('[data-gof="0"]').textContent==='quiet run4 pieces'&&document.querySelector('[data-gof="0"]').classList.contains('on'),'SIX: the row reads '+document.querySelector('[data-gof="0"]').textContent);
       ['head','ring1','ring2','boots'].forEach(function(u){ slotOf(u).click(); });
       need(gearWornN()===0&&P.gear.length===6,'SIX: not undressed: '+J(P.worn));
       document.querySelector('[data-gof="0"]').click();
       need(J(dressed())===A,'SIX: one tap dressed '+J(dressed()));
       // rings the wrong way round, and a piece the outfit does not have, come right
       wornOff(P,'ring1'); wornOff(P,'ring2'); wornWear(P,c.id,'ring1'); wornWear(P,b.id,'ring2'); wornWear(P,r2.id,'amulet'); wornOff(P,'boots'); wornWear(P,r1.id,'boots'); gearDraw();
       document.querySelector('[data-gof="0"]').click();
       need(J(dressed())===A&&uniq(allIds())&&allIds().length===6,'SIX: from another dress one tap gave '+J(dressed()));
       // a piece gone: the others go on, its slot stays as it is, the row counts it
       ['head','ring1','ring2','boots'].forEach(function(u){ wornOff(P,u); });
       wornWear(P,r1.id,'boots');
       P.gear=P.gear.filter(function(g){ return g.id!==d.id; }); gearDraw();
       need(document.querySelector('[data-gof="0"] i').textContent==='1 missing','SIX: the row reads '+document.querySelector('[data-gof="0"]').textContent);
       document.querySelector('[data-gof="0"]').click();
       need(wid('boots')===r1.id&&wid('head')===a.id&&wid('ring1')===b.id&&wid('ring2')===c.id&&uniq(allIds())&&allIds().length===5,'SIX: with one gone '+J(dressed()));
       need(document.querySelector('[data-gof="0"] i').textContent==='1 missing','SIX: after the tap the row reads '+document.querySelector('[data-gof="0"]').textContent);
       // about 5 rows: a sixth is refused, a name there is saved over, a blank name gets one, x removes
       ['b','c','d','e'].forEach(function(u){ E('gearname').value=u; E('gearsavebtn').click(); });
       need(P.outfits.length===5,'SIX: '+P.outfits.length+' rows');
       E('gearname').value='six'; E('gearname').dispatchEvent(new Event('input',{bubbles:true}));
       need(E('gearsavebtn').disabled,'SIX: a sixth row can be saved');
       E('gearname').value='B'; E('gearname').dispatchEvent(new Event('input',{bubbles:true}));
       need(!E('gearsavebtn').disabled,'SIX: a name there cannot be saved over');
       E('gearsavebtn').click(); need(P.outfits.length===5,'SIX: saving over made '+P.outfits.length+' rows');
       document.querySelector('[data-gofx="4"]').click();
       need(P.outfits.length===4&&!P.outfits.some(function(x){ return x.n==='e'; }),'SIX: x left '+J(P.outfits));
       E('gearname').value=''; E('gearname').dispatchEvent(new Event('input',{bubbles:true})); E('gearsavebtn').click();
       need(P.outfits.length===5&&P.outfits[4].n==='outfit 1','SIX: a blank name made '+J(P.outfits[4]));
       // SEVEN: keys and pad reach every control; A wears, B closes and never wears a backpack
       fresh();
       for(i=0;i<12;i++) wornAdd(P,wornMake(pcs[i%pcs.length],i%4,10+i,2000+i));
       a=mk('head','hide',0.03); gearDraw(); rowOf(a.id).click();
       E('gearname').value='x'; E('gearsavebtn').click(); E('gearname').value='';
       L=padFocusables(E('gearmodal'));
       (function(){ var seen=[L[0]], q2=[L[0]], cur, j, mv=[[0,-1],[0,1],[-1,0],[1,0]], nx;
         while(q2.length){ cur=q2.shift(); for(j=0;j<4;j++){ nx=padStep(L,cur,mv[j][0],mv[j][1]); if(nx&&seen.indexOf(nx)<0){ seen.push(nx); q2.push(nx); } } }
         L.forEach(function(el){ if(seen.indexOf(el)<0) bad.push('SEVEN: the arrows and the d-pad never reach '+(el.id||el.getAttribute('data-gk'))); });
         WORN_SLOTS.forEach(function(sl){ if(L.indexOf(slotOf(sl))<0) bad.push('SEVEN: slot '+sl+' is not a control'); });
         need(document.querySelectorAll('#gearlist .grow').length===P.gear.length,'SEVEN: rows');
         [].forEach.call(document.querySelectorAll('#gearlist .grow'),function(el){ if(L.indexOf(el)<0) bad.push('SEVEN: a row is not a control'); });
         need(L.indexOf(E('gearname'))>=0&&L.indexOf(E('gearsavebtn'))>=0&&L.indexOf(document.querySelector('[data-gof="0"]'))>=0&&L.indexOf(document.querySelector('[data-gofx="0"]'))>=0&&L.indexOf(E('closegear'))>=0,'SEVEN: the outfit controls or close are not controls');
       })();
       padSetFocus(slotOf('head')); press('ArrowDown');
       need(PAD.focus===slotOf('armor'),'SEVEN: arrow down from head went to '+(PAD.focus&&PAD.focus.getAttribute('data-gk')));
       press('Enter'); need(GEAR.lit==='armor','SEVEN: enter on an empty slot lit '+J(GEAR.lit));
       need(PAD.focus===slotOf('armor'),'SEVEN: the highlight lost its place after a rebuild: '+(PAD.focus&&PAD.focus.getAttribute('data-gk')));
       E('gearall').click();
       L=document.querySelector('#gearlist .grow'); b=L.getAttribute('data-gp'); padSetFocus(L);
       press('Enter'); need(!rowOf(b)&&!!PAD.focus&&PAD.focus.classList.contains('grow'),'SEVEN: enter did not wear and move on: '+J(P.worn));
       L=document.querySelector('#gearlist .grow'); b=L.getAttribute('data-gp'); padSetFocus(L);
       PAD.prev=PAD.prev||[]; PAD.prev[0]=false; PAD.prev[1]=false;
       c=gearWornN();
       padMenu(function(n){ return n===0; }); PAD.aSpent=0;
       need(!rowOf(b)&&on('gearmodal'),'SEVEN: pad A did not wear the row');
       padMenu(function(){ return false; });
       // a backpack in the list holds the word back
       fresh(); a=wornAdd(P,wornMake('pack',1,20,5)); gearDraw();
       n0=P.gear.length; PAD.prev[1]=false;
       padSetFocus(rowOf(a.id));
       padMenu(function(n){ return n===1; });
       need(!on('gearmodal')&&P.gear.length===n0&&!P.worn.pack,'SEVEN: B on a list with a backpack: window '+on('gearmodal')+' worn '+J(P.worn));
       padMenu(function(){ return false; });
       // EIGHT: 200 pieces draw and scroll with nothing out of the window
       P.gear=[]; P.worn={}; P.outfits=[];
       for(i=0;i<200;i++) wornAdd(P,wornMake(pcs[i%pcs.length],i%4,1+(i%100),3000+i));
       renderHub();
       need(E('gearbtn').offsetHeight>0&&E('gearbtn').getBoundingClientRect().right<=window.innerWidth,'EIGHT: the gear button is out of the window');
       need(E('hub').scrollWidth<=E('hub').clientWidth+1,'EIGHT: the stash is wider than its window');
       E('gearbtn').click();
       L=E('gearlist');
       need(L.querySelectorAll('.grow').length===200,'EIGHT: '+L.querySelectorAll('.grow').length+' rows');
       need(L.scrollHeight>L.clientHeight+100,'EIGHT: the list does not scroll: '+L.scrollHeight+' over '+L.clientHeight);
       L.scrollTop=5000; need(L.scrollTop>0,'EIGHT: the list did not move');
       need(E('gearwrap').scrollHeight<=E('gearwrap').clientHeight+1&&E('gearwrap').scrollWidth<=E('gearwrap').clientWidth+1,'EIGHT: the window overflows: '+E('gearwrap').scrollHeight+' over '+E('gearwrap').clientHeight+', '+E('gearwrap').scrollWidth+' over '+E('gearwrap').clientWidth);
       ['geardoll','gearbox','gearside','gearout'].forEach(function(id){ var r=E(id).getBoundingClientRect(); need(r.bottom<=window.innerHeight&&r.right<=window.innerWidth&&r.left>=0&&r.top>=0,'EIGHT: '+id+' is out of the window: '+J(r)); });
       need(E('gearsum').scrollHeight<=E('gearsum').clientHeight+1||E('gearsum').clientHeight===0,'EIGHT: the sum is cut');
       gearClose();
       // NINE: the worn line on the pre-raid page opens the doll and comes back
       P.gear=[]; P.worn={}; a=mk('head','hide',0.03); wornWear(P,a.id);
       renderSector(); openModal('sectormodal');
       need(E('srworn').offsetHeight>0&&E('srworn').textContent==='worn 1 of 9','NINE: the line reads '+J(E('srworn').textContent));
       E('srworn').click();
       need(on('gearmodal')&&!on('sectormodal'),'NINE: the line did not open the doll');
       E('closegear').click();
       need(on('sectormodal')&&!on('gearmodal'),'NINE: close did not go back to the page');
       E('sectormodal').classList.remove('on');
       // TEN: an old save reloads with nothing lost, twice; a broken list is repaired
       P.pilGen=4; P.pil=pilMake('live',4); P.hall=[{name:'oldtimer',gen:1,end:{how:'dead'}}]; P.lifeEarn=7000; P.credits=4321;
       P.outfits=[{n:'kept',s:{head:a.id}}];
       for(i=0;i<3;i++){
         snap=JSON.parse(J(P)); snap.cfg=JSON.parse(J(CFG)); snap.cfgv=18;
         if(i===0) delete snap.outfits;
         A={c:snap.credits,s:J(snap.stash),w:J(snap.weapons),eq:snap.equipped,ct:J(snap.contracts),fg:J(snap.forged||{}),le:snap.lifeEarn,p:J(snap.pil),h:J(snap.hall),g:snap.pilGen,gr:J(snap.gear),wn:J(snap.worn)};
         applyLoadedProfile({value:J(snap)});
         B={c:P.credits,s:J(P.stash),w:J(P.weapons),eq:P.equipped,ct:J(P.contracts),fg:J(P.forged||{}),le:P.lifeEarn,p:J(P.pil),h:J(P.hall),g:P.pilGen,gr:J(P.gear),wn:J(P.worn)};
         need(J(A)===J(B),'TEN: load '+(i+1)+' moved the save: '+J(A)+' vs '+J(B));
         need(J(P.outfits)==='[]','TEN: load '+(i+1)+' outfits '+J(P.outfits));
       }
       P.outfits=[{n:'Kept',s:{head:'g1',bogus:'x',boots:5}},7,{s:{}},{n:'',s:[]},{n:'c'},{n:'d',s:{}},{n:'e',s:{}},{n:'f',s:{}},{n:'g',s:{}}];
       snap=JSON.parse(J(P)); snap.cfg=JSON.parse(J(CFG)); snap.cfgv=18;
       applyLoadedProfile({value:J(snap)});
       need(P.outfits.length===5&&J(P.outfits[0])===J({n:'kept',s:{head:'g1'}})&&P.outfits[1].n==='outfit'&&J(P.outfits[2])===J({n:'c',s:{}}),'TEN: repaired to '+J(P.outfits));
       A=J(P.outfits); snap=JSON.parse(J(P)); snap.cfg=JSON.parse(J(CFG)); snap.cfgv=18;
       applyLoadedProfile({value:J(snap)});
       need(J(P.outfits)===A,'TEN: the second load moved the outfits');
       // ELEVEN: the demo refuses it, the doors are not there
       P.gear=[]; P.worn={}; P.outfits=[]; a=mk('head','hide',0.03); b=mk('boots','quiet',0.03); wornWear(P,a.id); P.outfits=[{n:'o',s:{boots:b.id}}];
       A=J({g:P.gear,w:P.worn,o:P.outfits});
       ARCADE.on=1;
       renderHub(); need(!E('gearbtn'),'ELEVEN: the gear button shows in the demo');
       gearSrLine(); need(E('srworn').style.display==='none','ELEVEN: the worn line shows in the demo');
       need(gearOpen()===false&&!on('gearmodal'),'ELEVEN: the demo opened the doll');
       need(gearWear(b.id)===false&&gearOff('head')===false&&gearDress(0)===false&&gearOutfitSave('n')===null&&gearOutfitDel(0)===false&&J({g:P.gear,w:P.worn,o:P.outfits})===A,'ELEVEN: the demo moved a piece');
       ARCADE.on=arcOn;
       // TWELVE: a raid refuses it
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); q=__state();
       q.bag=[]; q.carriedIn=0; q.carriedKit=[]; q.issuedBandages=0; q.player.downed=false; q.player.hp=100; q.ents.length=0; q.player.iv=99; q.tel.kills={};
       need(state==='raid','TWELVE: the raid state is '+state);
       need(gearOpen()===false&&!on('gearmodal'),'TWELVE: a raid opened the doll');
       need(gearWear(b.id)===false&&gearOff('head')===false&&gearDress(0)===false&&gearOutfitSave('n')===null&&gearOutfitDel(0)===false&&J({g:P.gear,w:P.worn,o:P.outfits})===A,'TWELVE: a raid moved a piece');
     }catch(e2){ bad.push('threw: '+(e2&&e2.message||e2)); }
     finally{
       ARCADE.on=arcOn;
       try{ if(state==='raid'){ __endRaid('extract'); } }catch(_e){}
       try{ if(PADNAME) padNameClose(false); padSetFocus(null); PAD.focus=null; }catch(_p){}
       try{ E('gearmodal').classList.remove('on'); E('sectormodal').classList.remove('on'); }catch(_m){}
       P=saved;
       (function(){ var n, s=JSON.parse(snap0); for(n in P) if(Object.prototype.hasOwnProperty.call(P,n)) delete P[n]; for(n in s) P[n]=s[n]; })();
       storeSet=oldStore; saveProfile=oldSave;
       for(k in cfg) CFG[k]=cfg[k];
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'37.41',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
