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
  {v:'37.42',what:'cw-m3bench: the workbench gear tab lists every stash piece and no worn piece; a reroll through the real click takes exactly the shown $, changes only the chosen trait to one in the pool the piece does not hold, keeps pips, rarity and power and leaves lifetime earnings alone; two saves with the same piece and counter roll the same; a piece he cannot afford is refused; salvage by the hold removes exactly that piece and adds exactly the table count of materials at about 80 percent of the sale; sell by the hold pays exactly the price and raises lifetime earnings by it; net worth rises by exactly the price of a piece in the stash or worn; ids stay unique; refused in the demo; pad and keys ask first; an old save loads',
   run:function(){
     if(!(window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile)) return 'SKIP: this fixture cannot stage';
     if(typeof renderBench!=='function'||typeof wornReroll!=='function'||typeof wornSalvage!=='function'||typeof wornSell!=='function'||typeof wornPrice!=='function') return 'no gear section at the workbench in this build';
     var saved=P, snap0=JSON.stringify(P), cfg={}, k, oldStore=storeSet, oldSave=saveProfile, oldPrice=sellPriceOf, arcOn=ARCADE.on, bad=[], a, b, c, d, i, c0, le0, nw0, pr, tab, was, now, snap, A, B, m, n, sum, v, ids;
     function need(ok,msg){ if(!ok) bad.push(msg); }
     function E(id){ return document.getElementById(id); }
     function J(x){ return JSON.stringify(x); }
     function on(id){ return E(id).classList.contains('on'); }
     function rowOf(id){ return document.querySelector('#benchlist [data-g="'+id+'"]'); }
     function pick(id){ rowOf(id).click(); }
     function count(L,M){ var t=0, j; for(j=0;j<L.length;j++) if(M.indexOf(L[j])>=0) t++; return t; }
     function stats(pc){ return pc.tr.map(function(t){ return t.s; }); }
     for(k in CFG) cfg[k]=CFG[k];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       storeSet=function(){}; saveProfile=function(){};
       P.gear=[]; P.worn={}; P.gearN=0; P.stash=[]; P.sellDay=null; P.lifeEarn=100; P.credits=100000;       showScreen('hub');
       // ONE: empty, then the tab lists stash pieces and never a worn one
       openTrader('gear');
       tab=[].filter.call(E('tradertabs').children,function(x){ return x.classList.contains('on'); })[0];
       need(tab&&tab.textContent.toLowerCase()==='gear'&&E('tpane_gear').style.display!=='none'&&E('tpane_gear').offsetParent,'ONE: the gear tab does not show');
       need(E('benchlist').textContent.toLowerCase().indexOf('no gear')>=0,'ONE: empty reads '+J(E('benchlist').textContent));
       a=wornAdd(P,wornMake('ring',2,50,31)); a.pip=2; b=wornAdd(P,wornMake('boots',0,40,32)); c=wornAdd(P,wornMake('amulet',3,60,33)); d=wornAdd(P,wornMake('head',1,50,34));
       need(wornWear(P,d.id),'ONE: the worn piece would not go on');
       renderBench();
       need(!!rowOf(a.id)&&!!rowOf(b.id)&&!!rowOf(c.id),'ONE: a stash piece has no row');
       need(!rowOf(d.id),'ONE: a worn piece is offered');
       need(document.querySelectorAll('#benchlist [data-g]').length===3,'ONE: rows '+document.querySelectorAll('#benchlist [data-g]').length);
       n=rowOf(a.id);
       need(n.textContent.indexOf(wornName(a))>=0&&n.textContent.indexOf('power 50')>=0&&n.querySelectorAll('.bpip.on').length===2&&n.querySelectorAll('.bpip').length===3,'ONE: the row reads '+J(n.textContent));
       need(n.textContent.indexOf(WORN_STATS[a.tr[0].s].n)>=0&&n.textContent.indexOf('+'+Math.round(wornTraitV(a,a.tr[0])*100)+'%')>=0,'ONE: the row has no trait: '+J(n.textContent));
       need(n.querySelector('.bnm').style.color!==''&&n.querySelector('.bnm').getAttribute('data-c')===WORN_RARS[a.r].c,'ONE: the name is not in the rarity colour');
       need(padFocusables(E('tradermodal')).indexOf(n)>=0&&padFocusables(E('tradermodal')).indexOf(rowOf(c.id))>=0,'ONE: pad and keys do not reach every row');
       // TWO: a reroll through the real click
       pick(a.id);
       need(E('bench_rr_1')&&E('bench_rr_1').offsetParent,'TWO: no reroll button on the second trait');
       pr=wornRerollPrice(a);
       need(pr===Math.round(wornPrice(a)*0.25),'TWO: the first reroll costs '+pr+', not a quarter of '+wornPrice(a));
       need(E('bench_rr_1').textContent.indexOf('$'+pr.toLocaleString())>=0,'TWO: the button reads '+J(E('bench_rr_1').textContent));
       was=J(a.tr[0]); now=stats(a); c0=P.credits; le0=lifeEarnNow(); m=wornRerollRoll(a);
       E('bench_rr_1').click();
       need(P.credits===c0-pr,'TWO: paid '+(c0-P.credits)+', not '+pr);
       need(lifeEarnNow()===le0,'TWO: lifetime earnings moved to '+lifeEarnNow());
       need(J(a.tr[0])===was,'TWO: the other trait moved: '+J(a.tr));
       need(a.tr[1].s!==now[1]&&now.indexOf(a.tr[1].s)<0&&wornPool('ring').indexOf(a.tr[1].s)>=0,'TWO: the new trait is '+a.tr[1].s+' from '+J(now));
       need(a.tr[1].s===m.s&&a.tr[1].v===m.v,'TWO: the roll is '+J(a.tr[1])+', the dice said '+J(m));
       need(a.pip===2&&a.r===2&&a.pw===50&&a.rr===1,'TWO: pips, rarity or power moved: '+J(a));
       // the price climbs by half, the cost rises with rarity
       need(wornRerollPrice(a)===Math.round(wornPrice(a)*0.25*1.5),'TWO: the second reroll costs '+wornRerollPrice(a));
       need(wornRerollPrice(wornMake('ring',3,50,1))>wornRerollPrice(wornMake('ring',2,50,1))&&wornRerollPrice(wornMake('ring',2,50,1))>wornRerollPrice(wornMake('ring',1,50,1)),'TWO: the price does not rise with rarity');
       // THREE: two saves, one piece, one counter, one roll: a reload cannot reroll the roll
       A=JSON.parse(J(a)); B=JSON.parse(J(a));
       need(J(wornRerollRoll(A))===J(wornRerollRoll(B)),'THREE: two saves rolled '+J(wornRerollRoll(A))+' and '+J(wornRerollRoll(B)));
       B.rr=B.rr+1; n=0; for(i=0;i<8;i++){ B.rr=i+5; if(J(wornRerollRoll(B))!==J(wornRerollRoll(A))) n++; }
       need(n>0,'THREE: the counter does not move the dice');
       // FOUR: refused when short
       pr=wornRerollPrice(a); P.credits=pr-1; was=J(a); renderBench();
       E('bench_rr_0').click();
       need(P.credits===pr-1&&J(a)===was,'FOUR: a short purse rerolled: credits '+P.credits+' piece '+J(a));
       need(wornReroll(P,a.id,0)===-1,'FOUR: the refusal is not -1');
       P.credits=pr; need(wornReroll(P,a.id,0)===pr&&P.credits===0,'FOUR: the exact price was refused');
       P.credits=100000;
       // a worn piece cannot be worked on
       need(wornReroll(P,d.id,0)===0&&wornSell(P,d.id)===0&&wornSalvage(P,d.id)===null&&P.worn.head===d,'FOUR: a worn piece was worked on');
       // a piece with no other trait in its pool says so and cannot pay
       n=wornAdd(P,wornMake('armor',1,50,44)); renderBench(); pick(n.id);
       need(E('bench_rr_0').disabled&&wornReroll(P,n.id,0)===0,'FOUR: an armor with both its pool traits rerolled');
       wornSell(P,n.id); P.credits=100000; P.sellDay=null; P.lifeEarn=100;
       // FIVE: net worth takes the price of what is in the stash and what is worn
       nw0=netWorth(); n=wornAdd(P,wornMake('boots',1,50,55)); v=Math.round(wornPrice(n)*CFG.lootMult);
       need(netWorth()===nw0+v,'FIVE: net worth rose '+(netWorth()-nw0)+', not '+v);
       need(wornWear(P,n.id)&&netWorth()===nw0+v,'FIVE: a worn piece does not count at its price: '+(netWorth()-nw0));
       wornOff(P,'boots');
       need(wornTip(wornMake('pants',2,50,3),{worn:{}})==='better','FIVE: a piece in an empty slot is not better');
       // SIX: salvage by the hold: a short hold and a mouse click do nothing
       renderBench(); pick(c.id);
       sum=WORN_SALV[c.r]; m=['scrap','wire','cell','board']; A=count(P.stash,m); was=P.gear.length; c0=P.credits; le0=lifeEarnNow();
       n=E('bench_salvage'); n.onmousedown({button:0}); craftHoldStep(0.5); window.dispatchEvent(new MouseEvent('mouseup')); craftHoldStep(1);
       need(P.gear.length===was,'SIX: a short hold salvaged');
       n=E('bench_salvage'); n.dispatchEvent(new MouseEvent('click',{detail:1,bubbles:true}));
       need(P.gear.length===was&&!on('askmodal'),'SIX: a mouse click salvaged');
       n=E('bench_salvage'); n.onmousedown({button:0}); craftHoldStep(0.5); need(P.gear.length===was,'SIX: half a hold salvaged'); craftHoldStep(0.6);
       need(P.gear.length===was-1&&!P.gear.some(function(g){ return g.id===c.id; }),'SIX: the piece is still there: '+J(P.gear));
       need(!!rowOf(a.id)&&!!rowOf(b.id)&&!rowOf(c.id),'SIX: another piece went or the row stayed');
       need(count(P.stash,m)===A+sum&&sum===14,'SIX: materials '+count(P.stash,m)+', not '+(A+sum));
       need(P.credits===c0&&lifeEarnNow()===le0,'SIX: salvage paid $');
       need(WORN_SALV.join()==='2,4,8,14','SIX: the table is '+WORN_SALV.join());
       // about 80 percent of the sale at the sale prices, fixed day prices so the market does not move the check; selling is the better money
       sellPriceOf=function(q){ return ival(q); };
       for(i=0;i<4;i++){
         n=wornMake('ring',i,50,60+i); n.id='gx'+i; v=0; A=wornSalvMix(n);
         for(k in A) v+=A[k]*sellPriceOf(k);
         sum=0; for(k in A) sum+=A[k];
         pr=Math.round(wornPrice(n)*CFG.lootMult);
         need(sum===WORN_SALV[i],'SIX: rarity '+i+' gives '+sum+' materials');
         need(v>=pr*0.7&&v<=pr*0.92,'SIX: rarity '+i+' salvage is worth '+v+' of a sale at '+pr);
         need(J(wornSalvMix(n))===J(A),'SIX: the mix moved on a second look');
       }
       sellPriceOf=oldPrice;
       // SEVEN: sell by the hold pays exactly the price, lifetime earnings by the same; no rank is crossed at this size
       P.lifeEarn=100; P.sellDay=null;
       renderBench(); pick(b.id);
       pr=Math.round(wornPrice(b)*CFG.lootMult); c0=P.credits; le0=lifeEarnNow(); was=P.gear.length; A=J(sellDayGet().s);
       n=E('bench_sell');
       need(n.textContent.indexOf('$'+pr.toLocaleString())>=0,'SEVEN: the button reads '+J(n.textContent));
       n.onmousedown({button:0}); craftHoldStep(1.1);
       need(P.credits===c0+pr,'SEVEN: paid '+(P.credits-c0)+', not '+pr);
       need(lifeEarnNow()===le0+pr,'SEVEN: lifetime earnings rose '+(lifeEarnNow()-le0)+', not '+pr);
       need(P.gear.length===was-1&&!P.gear.some(function(g){ return g.id===b.id; }),'SEVEN: the piece is still there');
       need(J(sellDayGet().s)===A,'SEVEN: the sale joined the buy back strip');
       // EIGHT: keys and the pad press with no hold, so they ask first; not yet comes back; yes does it
       renderBench(); pick(a.id); c0=P.credits; was=P.gear.length; pr=Math.round(wornPrice(a)*CFG.lootMult);
       E('bench_sell').click();
       need(on('askmodal')&&P.gear.length===was&&P.credits===c0,'EIGHT: a key press sold with no card');
       E('askno').click();
       need(!on('askmodal')&&on('tradermodal')&&P.gear.length===was,'EIGHT: not yet did not go back');
       E('bench_sell').click(); E('askyes').click();
       need(P.gear.length===was-1&&P.credits===c0+pr&&on('tradermodal'),'EIGHT: yes did not sell: credits '+P.credits+' bench '+on('tradermodal'));
       // ids stay unique across all of that
       ids={}; n=0; P.gear.forEach(function(g){ if(ids[g.id]) n++; ids[g.id]=1; }); for(k in P.worn){ if(ids[P.worn[k].id]) n++; ids[P.worn[k].id]=1; }
       need(n===0,'EIGHT: a doubled id');
       was=P.gearN; a=wornAdd(P,wornMake('ring',2,50,71)); need(a.id==='g'+(was+1)&&!(a.id in ids),'EIGHT: the next id is '+a.id);
       // NINE: never in the demo
       ARCADE.on=1; c0=P.credits; was=J(P.gear);
       openTrader('craft');
       need(![].some.call(E('tradertabs').children,function(x){ return x.textContent.toLowerCase()==='gear'; }),'NINE: the demo offers the gear tab');
       openTrader('gear');
       need(E('tpane_gear').style.display==='none','NINE: the demo opened the gear pane');
       need(wornReroll(P,a.id,0)===0&&wornSell(P,a.id)===0&&wornSalvage(P,a.id)===null&&P.credits===c0&&J(P.gear)===was,'NINE: the demo worked on a piece');
       ARCADE.on=arcOn; E('tradermodal').classList.remove('on');
       // TEN: a piece from the build before (no rr) loads, rerolls from zero, and reloads twice with nothing moved
       a.pip=1; P.credits=4321; P.stash=['scrap','core']; P.lifeEarn=7000;
       for(i=0;i<2;i++){
         snap=JSON.parse(J(P)); snap.cfg=JSON.parse(J(CFG)); snap.cfgv=18;
         if(i===0) snap.gear.forEach(function(g){ delete g.rr; });
         A={c:snap.credits,s:J(snap.stash),w:J(snap.weapons),eq:snap.equipped,ct:J(snap.contracts),fg:J(snap.forged||{}),le:snap.lifeEarn,p:J(snap.pil),h:J(snap.hall),g:snap.pilGen,n:snap.gearN,ids:J(snap.gear.map(function(g){ return g.id; })),tr:J(snap.gear.map(function(g){ return g.tr; })),wn:J(snap.worn)};
         applyLoadedProfile({value:J(snap)});
         B={c:P.credits,s:J(P.stash),w:J(P.weapons),eq:P.equipped,ct:J(P.contracts),fg:J(P.forged||{}),le:P.lifeEarn,p:J(P.pil),h:J(P.hall),g:P.pilGen,n:P.gearN,ids:J(P.gear.map(function(g){ return g.id; })),tr:J(P.gear.map(function(g){ return g.tr; })),wn:J(P.worn)};
         need(J(A)===J(B),'TEN: load '+(i+1)+' moved the save: '+J(A)+' vs '+J(B));
         need(P.gear.every(function(g){ return g.rr===0||g.rr>0; }),'TEN: load '+(i+1)+' left a piece with no counter: '+J(P.gear));
       }
       n=P.gear[P.gear.length-1];
       need(n.rr===0&&wornRerollPrice(n)===Math.round(wornPrice(n)*0.25),'TEN: an old piece costs '+wornRerollPrice(n));
     }catch(e2){ bad.push('threw: '+(e2&&e2.message||e2)); }
     finally{
       ARCADE.on=arcOn; sellPriceOf=oldPrice;
       try{ craftHoldCancel(); }catch(_h){}
       try{ padSetFocus(null); PAD.focus=null; }catch(_p){}
       try{ E('askmodal').classList.remove('on'); E('tradermodal').classList.remove('on'); }catch(_m){}
       ASKBACK=null;
       P=saved;
       (function(){ var n2, s=JSON.parse(snap0); for(n2 in P) if(Object.prototype.hasOwnProperty.call(P,n2)) delete P[n2]; for(n2 in s) P[n2]=s[n2]; })();
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
