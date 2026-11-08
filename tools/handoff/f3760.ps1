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
  {v:'37.60',what:'cw-m3shop: the seller shows 4 pieces of at most rare, the same twice on one day and after a reload, another stock on each of 60 other days; the real panel shows power, every trait and the tip, buying takes exactly the shown $, adds exactly that piece, leaves lifetime earnings alone and takes it off the counter; a short purse and the demo get nothing; Wirt pays a piece about 12 in 112 over 3000 rolls at 2500 a roll, the old prize rows unchanged and still in proportion, a piece shows in his log in its rarity colour; a card naming gear shows gear: rare gloves on the board and the strip, its claim adds that piece and no $, a card without pays none, about one standard card in three names gear and hard and elite more; every third rank from sacker i is a gear crate, crossing sacker i adds exactly one piece once with the rank up line, an old save at sacker iv and one from before the ranks get none; the privileged kit costs 1500, wears a sound armor piece at birth, the same on the same birth, into the gear over worn armor, its row says sound armor; an old save loads twice with nothing moved and a bought mark kept',
   run:function(){
     if(!(window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile)) return 'SKIP: this fixture cannot stage';
     if(typeof wornShopList!=='function'||typeof wornShopBuy!=='function'||typeof wornGift!=='function'||typeof wornConTxt!=='function'||typeof wornKitPiece!=='function') return 'no gear from the seller, Wirt, contracts, ranks or the kit in this build';
     var saved=P, snap0=JSON.stringify(P), cfg={}, k, oldStore=storeSet, oldSave=saveProfile, oldDay=mktDay, oRG=renderGamble, oRH=renderHub, oBlip=blip, oAc=ac, r0=RNGS, st0=state, arcOn=ARCADE.on, bad=[], D=mktDay(),
         A, B, L, L2, c, c0, g0, le0, pc, o, i, j, n, m, q, cells, txt, snap, rk, by, N, sv;
     function need(ok,msg){ if(!ok) bad.push(msg); }
     function E(id){ return document.getElementById(id); }
     function J(x){ return JSON.stringify(x); }
     function keys(L){ return L.map(function(x){ return x.k; }); }
     function same(a,b){ return J({k:a.k,r:a.r,pw:a.pw,tr:a.tr})===J({k:b.k,r:b.r,pw:b.pw,tr:b.tr}); }
     function col(c){ var t=document.createElement('span'); t.style.color=c; return t.style.color; }
     function put(s){ var n2, x=JSON.parse(s); for(n2 in P) if(Object.prototype.hasOwnProperty.call(P,n2)) delete P[n2]; for(n2 in x) P[n2]=x[n2]; }
     function sum(p){ return {c:p.credits,s:J(p.stash),w:J(p.weapons),eq:p.equipped,ct:J(p.contracts),fg:J(p.forged||{}),le:p.lifeEarn,p:J(p.pil),h:J(p.hall),g:p.pilGen,n:p.gearN,gr:J(p.gear),wn:J(p.worn),rp:J(p.rankPaid),gs:J(p.gearShop||null)}; }
     for(k in CFG) cfg[k]=CFG[k];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       storeSet=function(){}; saveProfile=function(){};
       P.gear=[]; P.worn={}; P.gearN=0; P.stash=[]; P.sellDay=null; P.lifeEarn=100; P.credits=100000; delete P.gearShop;
       mktDay=function(){ return D; };
       showScreen('hub');
       // ONE: the seller
       L=wornShopList();
       need(L.length===WORN_SHOP_N&&L.length>=3,'ONE: the counter has '+L.length+' pieces');
       need(L.every(function(x){ return x.pc.r>=0&&x.pc.r<=2&&!!WORN_KINDS[x.pc.k]; }),'ONE: a piece above rare: '+J(L.map(function(x){ return x.pc.r; })));
       need(L.every(function(x){ var w=wornPrice(x.pc)*CFG.lootMult; return x.price>=w*1.9&&x.price<=w*2.1+10; }),'ONE: a price is not about twice the sale: '+J(L.map(function(x){ return [x.price,wornPrice(x.pc)]; })));
       need(J(keys(wornShopList()))===J(keys(L)),'ONE: a second look on the same day changed the stock');
       A=J(P.gearShop); P.gearShop=JSON.parse(A); need(J(keys(wornShopList()))===J(keys(L)),'ONE: the same day after a reload changed the stock');
       by=[0,0,0,0]; m=0;
       for(i=1;i<=60;i++){ mktDay=function(){ return D+i; }; L2=wornShopList(); L2.forEach(function(x){ by[x.pc.r]++; }); if(J(keys(L2))!==J(keys(L))) m++; }
       need(by[3]===0&&by[0]>0&&by[1]>0&&by[2]>0,'ONE: over 60 days the rarities were '+J(by));
       need(m===60,'ONE: '+(60-m)+' other days had the same stock');
       mktDay=function(){ return D; }; delete P.gearShop;
       L=wornShopList();
       openTrader('buy');
       cells=document.querySelectorAll('#shopgrid .vcell.wg');
       need(cells.length===L.length,'ONE: '+cells.length+' gear cells for '+L.length+' pieces');
       need(document.querySelectorAll('#shopgrid .vcell:not(.wg)').length===SHOP.length,'ONE: the stock cells moved');
       for(i=0;i<cells.length&&i<L.length;i++) need(cells[i].textContent.indexOf(wornName(L[i].pc))>=0&&cells[i].textContent.indexOf(L[i].price.toLocaleString())>=0,'ONE: cell '+i+' reads '+J(cells[i].textContent));
       o=L[0]; if(cells[0]) cells[0].click();
       txt=E('shopdetail').textContent;
       need(txt.indexOf(wornName(o.pc))>=0&&txt.indexOf('$'+o.price.toLocaleString())>=0&&txt.indexOf('power')>=0,'ONE: the panel reads '+J(txt));
       need(o.pc.tr.every(function(t){ return txt.indexOf(WORN_STATS[t.s].n)>=0&&txt.indexOf('+'+Math.round(wornTraitV(o.pc,t)*100)+'%')>=0; }),'ONE: the panel does not show every trait: '+J(txt));
       need(txt.indexOf(wornTip(o.pc,P))>=0,'ONE: the panel has no tip: '+J(txt));
       need(!E('shopdetail').querySelector('.vqty'),'ONE: a piece has a quantity');
       c0=P.credits; g0=P.gear.length; le0=lifeEarnNow();
       q=E('shopdetail').querySelector('.vbuy'); if(q) q.click();
       need(P.credits===c0-o.price,'ONE: buying took $'+(c0-P.credits)+', not '+o.price);
       need(P.gear.length===g0+1&&same(P.gear[P.gear.length-1],o.pc),'ONE: the gear is '+J(P.gear)+', not the piece shown');
       need(lifeEarnNow()===le0,'ONE: buying moved lifetime earnings');
       L2=wornShopList();
       need(L2.length===L.length-1&&keys(L2).indexOf(o.k)<0,'ONE: the bought piece is still on the counter');
       need(document.querySelectorAll('#shopgrid .vcell.wg').length===L.length-1,'ONE: the bought cell is still there');
       need(wornShopBuy(o.i)===null&&P.credits===c0-o.price,'ONE: the bought piece sold twice');
       q=L2[0]; P.credits=q.price-1; need(wornShopBuy(q.i)===null&&P.credits===q.price-1&&P.gear.length===g0+1,'ONE: a short purse bought');
       P.credits=100000;
       ARCADE.on=1; need(wornShopList().length===0&&shopListNow().length===SHOP.length,'ONE: the demo counter has gear'); ARCADE.on=arcOn;
       E('tradermodal').classList.remove('on');
       // TWO: Wirt
       need(GAMBLE_PRICE===2500,'TWO: a roll costs '+GAMBLE_PRICE);
       A=GAMBLE_POOL.filter(function(x){ return !wornKeyIs(x[0]); });
       need(J(A)===J([['scrap',1],['wire',1],['cell',1],['bandage',2],['ammobox',2],['smoke',1],['decoy',1],['board',2],['comp',1],['optic',3],['plate',8],['servo',3],['medkit',7],['frag',6],['core',3],['coil',4],['ledger',4],['titan',4],['KEY',2],['gun_smg',4],['gun_carbine',4],['gun_shotgun',4],['gun_rifle',4],['gun_lmg',5],['gun_magnum',3],['blackbox',4],['relay',4],['codex',4],['reactor',4],['bloom',4]]),'TWO: the old prize rows moved: '+J(A));
       B=GAMBLE_POOL.filter(function(x){ return wornKeyIs(x[0]); });
       need(J(B.map(function(x){ return [+x[0].split('_')[2],x[1]]; }))===J([[0,4],[1,4],[2,3],[3,1]]),'TWO: the gear rows are '+J(B));
       q=gambleOdds().map(function(x){ return x[0]; });
       need(q.every(function(x){ return ['common','uncommon','rare','elite','gold'].indexOf(x)>=0; }),'TWO: odds rows '+J(q));
       renderGamble=function(){}; renderHub=function(){}; blip=function(){}; ac=function(){};
       N=3000; P.credits=GAMBLE_PRICE*N+7; P.stash=[]; P.gear=[]; P.worn={}; P.gearN=0; P.gambleLog=[]; n=0; by=[0,0,0,0];
       for(i=0;i<N;i++){ j=P.gear.length; E('gamblebtn').onclick(); if(P.gear.length>j){ n++; by[P.gear[P.gear.length-1].r]++; } }
       need(P.credits===7,'TWO: '+N+' rolls took $'+(GAMBLE_PRICE*N+7-P.credits));
       need(n+P.stash.length===N,'TWO: '+n+' pieces and '+P.stash.length+' items from '+N+' rolls');
       need(Math.abs(n/N-12/112)<0.025,'TWO: '+n+' pieces in '+N+' rolls, not about 12 in 112');
       need(by[0]>0&&by[1]>0&&by[2]>0&&by[3]>0&&by[0]>by[3]&&by[1]>by[3],'TWO: piece rarities '+J(by));
       need(!P.stash.some(wornKeyIs),'TWO: a piece key went to the stash');
       m=0; P.stash.forEach(function(x){ if(x==='plate'||x==='medkit'||x==='frag') m++; });
       need(Math.abs(m/N-21/112)<0.03,'TWO: plates, medkits and frags came '+m+' in '+N+', not about 21 in 112');
       P.credits=GAMBLE_PRICE*400; j=P.gear.length;
       for(i=0;i<400&&P.gear.length===j;i++) E('gamblebtn').onclick();
       renderGamble=oRG; renderGamble();
       pc=P.gear[P.gear.length-1]; q=P.gambleLog[P.gambleLog.length-1];
       need(P.gear.length===j+1&&wornKeyIs(q),'TWO: no piece in 400 rolls');
       A=E('gamblelist').querySelector('.row .nm');
       need(A&&pc&&A.textContent===wornName(pc)&&A.style.color===col(WORN_RARS[pc.r].c),'TWO: the prize row reads '+(A?J(A.textContent)+' in '+A.style.color:'nothing'));
       blip=oBlip; ac=oAc; RNGS=r0;
       // THREE: contracts
       renderHub=oRH; P.gear=[]; P.gearN=0; P.stash=[]; P.credits=5000;
       P.contracts=[]; ensureContracts();
       c=P.contracts[0]; c.prog=c.n; c.wg={k:'gloves',r:2};
       renderHub();
       need(E('contracts').textContent.indexOf('gear: rare gloves')>=0,'THREE: the board does not say gear: rare gloves');
       P._conSel=0; renderConDetail();
       need(E('condetail')&&[].filter.call(E('condetail').querySelectorAll('.crewcell'),function(x){ return x.title==='gear: rare gloves'; }).length===1,'THREE: the rewards strip has no gear cell');
       c0=P.credits; g0=P.gear.length;
       q=claimContractAt(0);
       need(q&&P.gear.length===g0+1&&P.gear[P.gear.length-1].k==='gloves'&&P.gear[P.gear.length-1].r===2,'THREE: the claim paid '+J(P.gear.slice(g0)));
       need(P.credits===c0,'THREE: the claim paid $'+(P.credits-c0));
       need(q&&String(q.gear).indexOf('rare gloves')>=0,'THREE: the receipt reads '+J(q&&q.gear));
       c=P.contracts[1]; c.prog=c.n; delete c.wg; g0=P.gear.length; c0=P.credits;
       need(claimContractAt(1)&&P.gear.length===g0&&P.credits===c0,'THREE: a card with no gear paid a piece or $');
       sv=RNGS; P.cstand=20; by={std:[0,0],hard:[0,0],elite:[0,0]}; m=0;
       for(i=0;i<3000;i++){ c=genContract(); q=by[c.tier]; if(!q) continue; q[0]++; if(wornConOk(c)) q[1]++; if(c.wg&&c.wg.r===3&&c.tier==='std') m++; }
       RNGS=sv;
       A=by.std[1]/Math.max(1,by.std[0]); B=by.hard[1]/Math.max(1,by.hard[0]); n=by.elite[1]/Math.max(1,by.elite[0]);
       need(A>0.24&&A<0.37,'THREE: standard cards name gear '+A.toFixed(3)+' of the time, not about one in three');
       need(B>A+0.06&&n>B,'THREE: hard and elite cards do not name gear more often: '+J(by));
       need(m===0,'THREE: a standard card named a relic');
       // FOUR: rank rewards
       A=[]; for(i=0;i<RANKS.length;i++) if(RANKS[i].rw&&RANKS[i].rw.k==='gear') A.push(i);
       need(A.length>=6&&A[0]===10&&A.every(function(x,ii){ return ii===0||x-A[ii-1]===3; })&&A.every(function(x){ var w=RANKS[x].rw; return !!WORN_KINDS[w.g]&&w.r>=0&&w.r<=3; }),'FOUR: gear ranks '+J(A));
       state='hub'; P.gear=[]; P.worn={}; P.gearN=0; P.stash=[]; P.credits=5000; P.mig1r=1; P.rankNote=null; delete P.sellDay;
       P.rankPaid=[]; for(i=0;i<10;i++) P.rankPaid.push(i); P.lifeEarn=RANKS[10].need-10;
       c0=P.credits; rk=RANKS[10].rw;
       lifeEarnAdd(50);
       need(P.gear.length===1&&P.gear[0].k===rk.g&&P.gear[0].r===rk.r&&P.credits===c0&&P.stash.length===0,'FOUR: sacker i paid '+J(P.gear)+' and $'+(P.credits-c0));
       need(P.rankNote&&String(P.rankNote.t).indexOf('rank up: sacker i')===0&&String(P.rankNote.t).indexOf(rankRwTxt(rk))>0&&rankRwTxt(rk)==='gear: '+WORN_RARS[rk.r].id+' '+WORN_KINDS[rk.g].n,'FOUR: the line is '+J(P.rankNote));
       lifeEarnAdd(50); rankCheck();
       need(P.gear.length===1,'FOUR: sacker i paid again');
       P.gear=[]; P.gearN=0; P.rankNote=null; P.lifeEarn=RANKS[13].need+5; P.rankPaid=[]; for(i=0;i<=13;i++) P.rankPaid.push(i);
       snap=JSON.parse(J(P)); snap.cfg=JSON.parse(J(CFG)); snap.cfgv=18; delete snap.gearShop;
       applyLoadedProfile({value:J(snap)}); rankCheck(); lifeEarnAdd(1);
       need(P.gear.length===0,'FOUR: an old save at sacker iv was paid '+J(P.gear));
       snap=JSON.parse(J(P)); snap.cfg=JSON.parse(J(CFG)); snap.cfgv=18; delete snap.mig1r; delete snap.rankPaid; delete snap.gearShop;
       applyLoadedProfile({value:J(snap)}); rankCheck(); lifeEarnAdd(1);
       need(P.gear.length===0,'FOUR: a save from before the ranks was paid '+J(P.gear));
       // FIVE: the privileged kit
       need(BIRTH_KITS.priv.c===1500&&BIRTH_KITS.priv.items.indexOf('plate')<0&&BIRTH_KITS.priv.wg&&BIRTH_KITS.priv.wg.k==='armor'&&BIRTH_KITS.priv.wg.r===1&&/sound armor/.test(BIRTH_KITS.priv.t),'FIVE: the kit is '+J(BIRTH_KITS.priv));
       state='hub'; P.gear=[]; P.worn={}; P.gearN=0; P.credits=5000; P.birthKit=null;
       if(acctEnsure(P)) pilEnd(P,{how:'test'});
       birthDraw();
       q=document.querySelector('#birthkits [data-bkit="priv"]');
       need(q&&q.textContent.toLowerCase().indexOf('sound armor')>=0&&q.textContent.indexOf('1,500')>=0,'FIVE: the kit row reads '+(q?J(q.textContent):'nothing'));
       snap=J(P); c0=P.credits;
       need(birthBorn(0,'','priv')&&P.pil,'FIVE: no birth');
       pc=P.worn.armor;
       need(pc&&pc.k==='armor'&&pc.r===1&&P.gear.length===0&&P.credits===c0-1500,'FIVE: the birth wears '+J(P.worn)+' with gear '+J(P.gear)+' and took $'+(c0-P.credits));
       A=pc?J(pc.tr):'';
       put(snap);
       need(birthBorn(0,'','priv')&&P.worn.armor&&J(P.worn.armor.tr)===A,'FIVE: the same birth rolled '+J(P.worn.armor)+', not '+A);
       pc=P.worn.armor; pilEnd(P,{how:'test'}); P.credits=5000; P.birthKit=null;
       need(birthBorn(1,'','priv')&&P.worn.armor===pc&&P.gear.length===1&&P.gear[0].k==='armor'&&P.gear[0].r===1,'FIVE: over worn armor the kit gave worn '+J(P.worn.armor&&P.worn.armor.id)+' and gear '+J(P.gear));
       // SIX: the save
       P.credits=100000; P.stash=['scrap','core']; P.lifeEarn=7000; delete P.gearShop;
       L=wornShopList(); q=L[1]; need(!!wornShopBuy(q.i),'SIX: the buy did not happen');
       snap=JSON.parse(J(P)); snap.cfg=JSON.parse(J(CFG)); snap.cfgv=18;
       A=sum(snap); applyLoadedProfile({value:J(snap)}); B=sum(P);
       need(J(A)===J(B),'SIX: a reload moved the save: '+J(A)+' vs '+J(B));
       need(wornShopList().length===L.length-1&&keys(wornShopList()).indexOf(q.k)<0,'SIX: the bought mark did not survive a reload');
       for(i=0;i<2;i++){
         snap=JSON.parse(J(P)); snap.cfg=JSON.parse(J(CFG)); snap.cfgv=18;
         if(i===0) delete snap.gearShop;
         A=sum(snap); applyLoadedProfile({value:J(snap)}); B=sum(P);
         need(J(A)===J(B),'SIX: old save load '+(i+1)+' moved the save: '+J(A)+' vs '+J(B));
       }
       need(wornShopList().length===WORN_SHOP_N,'SIX: an old save has no counter');
     }catch(e2){ bad.push('threw: '+(e2&&e2.message||e2)); }
     finally{
       mktDay=oldDay; renderGamble=oRG; renderHub=oRH; blip=oBlip; ac=oAc; RNGS=r0; state=st0; ARCADE.on=arcOn;
       try{ ['tradermodal','gamblemodal','birthmodal'].forEach(function(id){ var m2=E(id); if(m2) m2.classList.remove('on'); }); }catch(_m){}
       P=saved;
       (function(){ var n2, s=JSON.parse(snap0); for(n2 in P) if(Object.prototype.hasOwnProperty.call(P,n2)) delete P[n2]; for(n2 in s) P[n2]=s[n2]; })();
       storeSet=oldStore; saveProfile=oldSave;
       for(k in CFG) CFG[k]=cfg[k];
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
