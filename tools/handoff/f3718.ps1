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

if ($s.Contains("  {v:'37.18',what:")) { throw "check 37.18 is in the fixture already" }

SubRx @'
  {v:'37.17',what:
'@ @'
  {v:'37.18',what:'cw-m1sell, his answers 37, 39, 44 and 47 of 11-01 (season zero m1): sell one from the stash menu pays sellPriceOf in $ and no XP, takes the item and adds the same to lifetime earnings; sell all N does the same for a stack; the sale shows as a buy back chip on the stash screen and the chip returns the item and takes exactly the price paid, leaving lifetime earnings where they started; short of $ refuses; a locked item offers no sell row and never sells; the next day banks the day once into lifetime earnings and clears the list; net worth on the stats cards is cash plus the stash at sale prices; an old save without P.sellDay loads with nothing lost, twice',
   run:function(){
     if(!(window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile)) return 'SKIP: this fixture cannot stage';
     var hub=document.getElementById('hub');
     if(!hub||typeof renderHub!=='function'||typeof itemMenuRows!=='function'||typeof applyLoadedProfile!=='function'||typeof renderStatCards!=='function'||typeof ival!=='function') return 'SKIP: no stash screen here';
     if(typeof sellPriceOf!=='function'||typeof stashSell!=='function'||typeof stashBuyBack!=='function'||typeof lifeEarnNow!=='function'||typeof sellDayGet!=='function'||typeof netWorth!=='function') return 'no stash sale and buy back in this build (sellPriceOf, stashSell, stashBuyBack, lifeEarnNow, sellDayGet, netWorth)';
     var saved=P, was=hub.classList.contains('on'), cfg={}, k, oldStore=storeSet, oldSave=saveProfile, bad=[], key=null, other=null, ks=Object.keys(ITEMS), i, it, row, v, sv, c0, le0, x0, n, bb, snap, base, sum, cards, nw, sk, ct0;
     function need(ok,msg){ if(!ok) bad.push(msg); }
     function cnt(q){ var c=0; P.stash.forEach(function(z){ if(z===q) c++; }); return c; }
     function rowOf(q,label,c){ return itemMenuRows(q,'stash',c).filter(function(r){ return r&&typeof r.label==='string'&&r.label.indexOf(label)===0; })[0]; }
     function chips(){ return document.querySelectorAll('#buyback [data-bb]'); }
     for(k in CFG) cfg[k]=CFG[k];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       storeSet=function(){}; saveProfile=function(){};
       for(i=0;i<ks.length;i++){ it=ITEMS[ks[i]]; if(it&&it.name&&!it.gk&&!/^gun_/.test(ks[i])&&ival(ks[i])>0){ if(!key) key=ks[i]; else if(!other&&ival(ks[i])!==ival(key)){ other=ks[i]; break; } } }
       if(!key||!other) return 'SKIP: no sellable items here';
       P.stash=[key,key,key,other,other]; P.kit=[]; P.keep={}; P.junk={}; P.credits=5000; P.xp=1000; P.lifeEarn=20000; delete P.sellDay;
       renderHub(); hub.classList.add('on');
       // ONE: sell one through the stash menu row
       v=sellPriceOf(key); c0=P.credits; le0=lifeEarnNow(); x0=P.xp;
       need(v===ival(key),'ONE: sellPriceOf '+v+' is not the price the stash pays ('+ival(key)+')');
       need(le0===20000,'ONE: lifetime earnings read '+le0+' with nothing sold, not 20000');
       row=rowOf(key,'Sell one',3);
       if(!row) bad.push('ONE: the stash menu has no Sell one row');
       else {
         need(row.hint==='$'+v.toLocaleString(),'ONE: the row is priced '+row.hint+', not $'+v.toLocaleString());
         row.act();
         need(cnt(key)===2,'ONE: sell one left '+cnt(key)+' of 3');
         need(P.credits===c0+v,'ONE: credits up '+(P.credits-c0)+', not '+v);
         need(lifeEarnNow()===le0+v,'ONE: lifetime earnings up '+(lifeEarnNow()-le0)+', not '+v);
         need(P.xp===x0,'ONE: the sale paid '+(P.xp-x0)+' XP');
       }
       // TWO: the sale is a buy back chip on the stash screen; the chip buys it back at the price paid
       renderHub();
       bb=chips();
       need(bb.length===1,'TWO: the buy back strip shows '+bb.length+' sales, not 1');
       if(bb.length===1){
         c0=P.credits; bb[0].click();
         need(cnt(key)===3,'TWO: after the buy back the stash holds '+cnt(key)+' of 3');
         need(P.credits===c0-v,'TWO: the buy back took '+(c0-P.credits)+', not '+v);
         need(lifeEarnNow()===le0,'TWO: lifetime earnings '+lifeEarnNow()+' after the buy back, not '+le0+' where they started');
         need(P.lifeEarn===20000,'TWO: the banked lifetime earnings moved to '+P.lifeEarn);
         need(chips().length===0,'TWO: the bought back sale is still listed');
       }
       // THREE: sell all on a stack; with no $ its buy back refuses
       row=rowOf(other,'Sell all',2);
       if(!row) bad.push('THREE: a stack of 2 has no Sell all row');
       else {
         sv=sellPriceOf(other); c0=P.credits; le0=lifeEarnNow(); row.act();
         need(cnt(other)===0&&P.credits===c0+2*sv&&lifeEarnNow()===le0+2*sv,'THREE: sell all 2 left '+cnt(other)+', paid '+(P.credits-c0)+' and lifetime '+(lifeEarnNow()-le0)+', not '+(2*sv));
         P.credits=0; renderHub();
         bb=chips();
         if(bb.length) bb[0].click();
         need(bb.length===1&&cnt(other)===0&&P.credits===0&&chips().length===1,'THREE: a buy back with no $ went through ('+cnt(other)+' back, credits '+P.credits+', '+bb.length+' chips)');
         P.credits=5000;
       }
       // FOUR: a locked item offers no sell row and never sells
       P.keep={}; P.keep[key]=1; c0=P.credits; renderHub();
       need(!rowOf(key,'Sell one',3)&&!rowOf(key,'Sell all',3),'FOUR: a locked item offers a sell row');
       need(stashSell(key,1)===0&&cnt(key)===3&&P.credits===c0,'FOUR: a locked item sold');
       P.keep={};
       // FIVE: net worth on the stats cards is cash plus the stash at today's prices
       sum=0; P.stash.forEach(function(q){ sum+=sellPriceOf(q); });
       renderStatCards(); nw=null;
       cards=document.querySelectorAll('#statgrid .scard');
       for(i=0;i<cards.length;i++){ sk=cards[i].querySelector('.sk'); if(sk&&/^net worth$/i.test(String(sk.textContent).trim())) nw=cards[i].querySelector('.sv'); }
       need(nw&&String(nw.textContent).trim()==='$'+(P.credits+sum).toLocaleString(),'FIVE: net worth reads '+(nw?nw.textContent:'nothing')+', not $'+(P.credits+sum).toLocaleString());
       need(netWorth()===P.credits+sum,'FIVE: netWorth() '+netWorth()+', not '+(P.credits+sum));
       // SIX: the next day banks the day once and clears the list
       le0=P.lifeEarn; v=sellPriceOf(key); stashSell(key,1);
       need(P.lifeEarn===le0&&lifeEarnNow()===le0+v+2*sellPriceOf(other),'SIX: today counts '+(lifeEarnNow()-le0)+', not '+(v+2*sellPriceOf(other)));
       P.sellDay.d='1999-1-1'; n=sellDayGet();
       need(P.lifeEarn===le0+v+2*sellPriceOf(other)&&n.e===0&&n.s.length===0&&lifeEarnNow()===P.lifeEarn,'SIX: a new day banked '+(P.lifeEarn-le0)+', left '+n.e+' and '+n.s.length+' sales listed');
       sellDayGet();
       need(P.lifeEarn===le0+v+2*sellPriceOf(other),'SIX: the day was banked twice');
       // SEVEN: an old save (no P.sellDay) loads with nothing lost, and again
       P.stash=[key,other,'scrap']; P.credits=4321; P.weapons=['pistol','smg']; P.equipped='smg'; P.lifeEarn=777; P.contracts=P.contracts||[]; ct0=P.contracts.length; x0=JSON.stringify(P.forged||{});
       base=JSON.parse(JSON.stringify(P)); base.cfg=JSON.parse(JSON.stringify(CFG)); base.cfgv=18; delete base.sellDay;
       applyLoadedProfile({value:JSON.stringify(base)});
       need(P.credits===4321&&JSON.stringify(P.stash)===JSON.stringify([key,other,'scrap'])&&P.equipped==='smg'&&P.weapons.indexOf('smg')>=0&&(P.contracts||[]).length===ct0&&JSON.stringify(P.forged||{})===x0,'SEVEN: the old save lost something (credits '+P.credits+', stash '+JSON.stringify(P.stash)+', guns '+JSON.stringify(P.weapons)+' '+P.equipped+', contracts '+(P.contracts||[]).length+')');
       need(P.lifeEarn===777&&lifeEarnNow()===777&&P.pil&&P.pil.gen>=1&&typeof P.acctName==='string','SEVEN: the m0 records moved (lifetime '+P.lifeEarn+', pil '+JSON.stringify(P.pil)+')');
       renderHub();
       n=sellDayGet(); need(n&&n.e===0&&n.s.length===0,'SEVEN: an old save starts the day with '+JSON.stringify(n));
       need(chips().length===0,'SEVEN: an old save shows buy back chips');
       snap=JSON.parse(JSON.stringify(P)); applyLoadedProfile({value:JSON.stringify(snap)});
       need(P.credits===4321&&P.stash.length===3&&P.lifeEarn===777&&P.sellDay&&P.sellDay.e===0,'SEVEN: a second load moved it (credits '+P.credits+', stash '+P.stash.length+', lifetime '+P.lifeEarn+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(!was) hub.classList.remove('on'); }catch(_h){}
       P=saved; storeSet=oldStore; saveProfile=oldSave;
       for(k in CFG) if(!(k in cfg)) delete CFG[k]; for(k in cfg) CFG[k]=cfg[k];
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'37.17',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
