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

if ($s.Contains("  {v:'37.21',what:")) { throw "check 37.21 is in the fixture already" }

SubRx @'
  {v:'37.20',what:
'@ @'
  {v:'37.21',what:'cw-m1ranks, his rulings of 11-01 (season zero m1, answers 40 and 47 to 53): RANKS has 30 rows, scrounger to warlord, i to v, each step more than the last, every reward cash or a kit of real items; a profile just under rank 3 that earns past it through lifeEarnAdd is rank 3, paid its reward exactly once, with the line rank up: scrounger iii on the floor; spending never lowers the rank; a sale past rank 4 pays its kit once and a buy back keeps the rank; the Mainframe strip and the stats card, drawn through openOps and renderStatCards, show the rank, lifetime earnings, the next rank, its reward and the bar; an old save with large lifetime earnings loads at its rank with every reached rank marked paid, nothing paid and nothing lost, twice; a brand new profile literal has $1,000',
   run:function(){
     if(!(window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile)) return 'SKIP: this fixture cannot stage';
     if(typeof applyLoadedProfile!=='function'||typeof openOps!=='function'||typeof renderStatCards!=='function'||typeof lifeEarnAdd!=='function'||typeof stashSell!=='function'||typeof stashBuyBack!=='function'||typeof lifeEarnNow!=='function'||typeof sellPriceOf!=='function') return 'SKIP: no Mainframe or stash sale here';
     if(typeof RANKS==='undefined'||typeof rankNow!=='function'||typeof rankCheck!=='function'||typeof rankMig!=='function'||typeof rankRwTxt!=='function') return 'no ranks in this build (RANKS, rankNow, rankCheck, rankMig, rankRwTxt)';
     var saved=P, cfg={}, k, oldStore=storeSet, oldSave=saveProfile, st0=state, bad=[], i, R, nm=['scrounger','cutpurse','sacker','reaver','marauder','warlord'], st=['i','ii','iii','iv','v'],
         c0, s0, n, key=null, ks, it, base, snap, src, m, el, cards, sk, sv, ss, tst, ct, fg, pn, want, pass;
     function need(ok,msg){ if(!ok) bad.push(msg); }
     function cntOf(L,q){ var c=0, z; for(z=0;z<L.length;z++) if(L[z]===q) c++; return c; }
     function payOf(w){ return (w&&w.k==='cash')?w.v:0; }
     function kitOf(w){ return (w&&w.k==='kit')?w.v.length:0; }
     function txt(e){ return e?String(e.textContent).replace(/\s+/g,' ').trim().toLowerCase():''; }
     for(k in CFG) cfg[k]=CFG[k];
     try{
       // ONE: the table
       need(Array.isArray(RANKS)&&RANKS.length===30,'ONE: RANKS has '+(RANKS&&RANKS.length)+' rows, not 30');
       for(i=0;i<30&&i<RANKS.length;i++){
         R=RANKS[i];
         if(!R||R.n!==nm[Math.floor(i/5)]+' '+st[i%5]){ bad.push('ONE: row '+i+' is '+(R&&R.n)+', not '+nm[Math.floor(i/5)]+' '+st[i%5]); continue; }
         if(i===0){ need(R.need===0,'ONE: scrounger i needs '+R.need+', not 0'); continue; }
         need(R.need>RANKS[i-1].need,'ONE: '+R.n+' needs no more than the rank before');
         if(i>1) need(R.need-RANKS[i-1].need>RANKS[i-1].need-RANKS[i-2].need,'ONE: the step to '+R.n+' is not more than the step before');
         need(R.rw&&((R.rw.k==='cash'&&R.rw.v>0)||(R.rw.k==='kit'&&Array.isArray(R.rw.v)&&R.rw.v.length>0&&R.rw.v.every(function(q){ return !!ITEMS[q]; })&&typeof R.rw.l==='string'&&R.rw.l)),'ONE: '+R.n+' has no real reward '+JSON.stringify(R.rw));
       }
       if(bad.length) return bad.join('; ');
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       P=JSON.parse(JSON.stringify(saved));
       storeSet=function(){}; saveProfile=function(){};
       state='hub';
       // TWO: just under rank 3, earn past it through lifeEarnAdd: rank 3, its reward once, the line on the floor
       P.stash=[]; P.credits=5000; P.keep={}; P.junk={}; delete P.sellDay; P.mig1r=1; P.rankPaid=[0,1]; P.rankNote=null; P.lifeEarn=RANKS[2].need-10;
       need(rankNow()===1,'TWO: just under rank 3 reads rank '+(rankNow()+1));
       c0=P.credits; s0=P.stash.length;
       lifeEarnAdd(50);
       need(rankNow()===2,'TWO: past rank 3 reads rank '+(rankNow()+1));
       need(cntOf(P.rankPaid,2)===1,'TWO: rank 3 is marked paid '+cntOf(P.rankPaid,2)+' times');
       need(P.credits===c0+payOf(RANKS[2].rw)&&P.stash.length===s0+kitOf(RANKS[2].rw),'TWO: the reward paid $'+(P.credits-c0)+' and '+(P.stash.length-s0)+' items, not '+rankRwTxt(RANKS[2].rw));
       need(P.rankNote&&String(P.rankNote.t).indexOf('rank up: scrounger iii')===0,'TWO: the rank up line is '+JSON.stringify(P.rankNote));
       tst=document.getElementById('hubtoast');
       need(txt(tst).indexOf('rank up: scrounger iii')===0,'TWO: the floor line reads '+(tst?tst.textContent:'nothing'));
       c0=P.credits; s0=P.stash.length;
       lifeEarnAdd(50); rankCheck();
       need(P.credits===c0&&P.stash.length===s0&&cntOf(P.rankPaid,2)===1,'TWO: rank 3 paid a second time');
       // THREE: spending never lowers the rank; a sale past rank 4 pays its kit once; a buy back keeps the rank
       P.credits=0;
       need(rankNow()===2,'THREE: spending every $ moved the rank to '+(rankNow()+1));
       ks=Object.keys(ITEMS);
       for(i=0;i<ks.length;i++){ it=ITEMS[ks[i]]; if(it&&it.name&&!it.gk&&!/^gun_/.test(ks[i])&&sellPriceOf(ks[i])>0){ key=ks[i]; break; } }
       if(!key) bad.push('THREE: no sellable item');
       else {
         P.lifeEarn=RANKS[3].need-1; P.stash=[key]; c0=P.credits;
         sv=stashSell(key,1);   // what the sale paid (the market moves the price after it)
         need(sv>0&&rankNow()===3&&cntOf(P.rankPaid,3)===1,'THREE: a sale past rank 4 reads rank '+(rankNow()+1)+', paid '+cntOf(P.rankPaid,3)+' times');
         need(P.credits===c0+sv+payOf(RANKS[3].rw)&&P.stash.length===kitOf(RANKS[3].rw),'THREE: the sale past rank 4 paid $'+(P.credits-c0)+' and '+P.stash.length+' items, not $'+(sv+payOf(RANKS[3].rw))+' and '+kitOf(RANKS[3].rw));
         P.credits=1000000; n=P.stash.length;
         stashBuyBack(P.sellDay.s.length-1);
         need(P.stash.length===n+1,'THREE: the buy back did not happen');
         need(rankNow()===3,'THREE: a buy back lowered the rank to '+(rankNow()+1));
         c0=P.credits; sv=stashSell(key,1);
         need(sv>0&&P.stash.length===n&&P.credits===c0+sv&&cntOf(P.rankPaid,3)===1,'THREE: selling it again paid rank 4 again ($'+(P.credits-c0)+' for a $'+sv+' sale, '+P.stash.length+' items)');
       }
       // FOUR: the Mainframe strip and the stats card, through their real routes
       P.lifeEarn=RANKS[7].need+1234; delete P.sellDay; P.rankPaid=[0,1,2,3,4,5,6,7];
       openOps('con');
       el=document.getElementById('rankname');
       need(txt(el)===RANKS[7].n,'FOUR: the Mainframe rank reads '+(el?el.textContent:'nothing')+', not '+RANKS[7].n);
       el=document.getElementById('rankearn');
       need(txt(el)==='$'+lifeEarnNow().toLocaleString(),'FOUR: the Mainframe lifetime earnings read '+(el?el.textContent:'nothing')+', not $'+lifeEarnNow().toLocaleString());
       el=document.getElementById('rankstrip');
       need(el&&el.getBoundingClientRect().height>0,'FOUR: the Mainframe rank strip is not on screen');
       need(txt(el).indexOf(RANKS[8].n)>=0&&txt(el).indexOf(rankRwTxt(RANKS[8].rw).toLowerCase())>=0,'FOUR: the Mainframe does not name the next rank and its reward: '+txt(el));
       el=document.getElementById('rankfill'); want=1234/(RANKS[8].need-RANKS[7].need)*100;
       need(el&&Math.abs(parseFloat(el.style.width)-want)<0.2,'FOUR: the bar is '+(el?el.style.width:'missing')+', not '+want.toFixed(1)+'%');
       renderStatCards(); sv=null; ss=null;
       cards=document.querySelectorAll('#statgrid .scard');
       for(i=0;i<cards.length;i++){ sk=cards[i].querySelector('.sk'); if(sk&&txt(sk)==='lifetime earnings'){ sv=cards[i].querySelector('.sv'); ss=cards[i].querySelector('.ss'); } }
       need(sv&&txt(sv)==='$'+lifeEarnNow().toLocaleString(),'FOUR: the stats card lifetime earnings read '+(sv?sv.textContent:'nothing'));
       need(ss&&txt(ss).indexOf(RANKS[7].n)>=0,'FOUR: the stats card does not name the rank: '+(ss?ss.textContent:'nothing'));
       // FIVE: an old save with large lifetime earnings loads at its rank, every reached rank marked paid, nothing paid, nothing lost, and again
       P.stash=[key||'scrap','scrap']; P.credits=4321; P.weapons=['pistol','smg']; P.equipped='smg'; P.lifeEarn=500000; delete P.sellDay; P.rankNote=null;
       P.contracts=P.contracts||[]; ct=P.contracts.length; fg=JSON.stringify(P.forged||{}); pn=P.pil?P.pil.name+'/'+P.pil.gen:'';
       base=JSON.parse(JSON.stringify(P)); base.cfg=JSON.parse(JSON.stringify(CFG)); base.cfgv=18; delete base.rankPaid; delete base.mig1r; delete base.rankNote;
       want=[]; for(i=0;i<RANKS.length&&RANKS[i].need<=500000;i++) want.push(i);
       for(n=0;n<2;n++){
         applyLoadedProfile({value:JSON.stringify(n?snap:base)});
         need(rankNow()===want.length-1,'FIVE'+(n?' again':'')+': the old save loads at rank '+(rankNow()+1)+', not '+want.length);
         need(Array.isArray(P.rankPaid)&&JSON.stringify(P.rankPaid.slice().sort(function(a,b){ return a-b; }))===JSON.stringify(want),'FIVE'+(n?' again':'')+': ranks marked paid '+JSON.stringify(P.rankPaid));
         pass=P.credits===4321&&JSON.stringify(P.stash)===JSON.stringify([key||'scrap','scrap'])&&P.equipped==='smg'&&P.weapons.indexOf('smg')>=0&&(P.contracts||[]).length===ct&&JSON.stringify(P.forged||{})===fg;
         need(pass,'FIVE'+(n?' again':'')+': the old save lost or gained something (credits '+P.credits+', stash '+JSON.stringify(P.stash)+', guns '+JSON.stringify(P.weapons)+' '+P.equipped+', contracts '+(P.contracts||[]).length+')');
         need(P.lifeEarn===500000&&P.pil&&(P.pil.name+'/'+P.pil.gen)===pn&&typeof P.acctName==='string'&&P.mig1r===1,'FIVE'+(n?' again':'')+': the m0 records moved (lifetime '+P.lifeEarn+', pil '+(P.pil&&P.pil.name)+')');
         need(!P.rankNote||P.rankNote.shown,'FIVE'+(n?' again':'')+': an old save says a rank up');
         rankCheck();
         need(P.credits===4321&&P.stash.length===2,'FIVE'+(n?' again':'')+': a rank check after the load paid the old ranks');
         snap=JSON.parse(JSON.stringify(P));
       }
       // SIX: a brand new profile starts with $1,000 and is born ranked
       src=''; for(i=0;i<document.scripts.length;i++) src+=document.scripts[i].text||'';
       m=src.match(/\bvar P=\{credits:(\d+),[^\n]*/);
       need(m&&+m[1]===1000,'SIX: a new profile starts with $'+(m?m[1]:'?')+', not $1,000');
       need(m&&m[0].indexOf('rankPaid:[0]')>=0&&m[0].indexOf('mig1r:1')>=0,'SIX: a new profile is not born at scrounger i with its stamp');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       state=st0; P=saved; storeSet=oldStore; saveProfile=oldSave;
       for(k in CFG) if(!(k in cfg)) delete CFG[k]; for(k in cfg) CFG[k]=cfg[k];
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'37.20',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
