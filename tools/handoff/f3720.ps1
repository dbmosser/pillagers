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

if ($s.Contains("  {v:'37.20',what:")) { throw "check 37.20 is in the fixture already" }

SubRx @'
  {v:'37.19',what:
'@ @'
  {v:'37.20',what:'cw-m1mkt, his answer 38 of 11-01 (season zero m1, the market): one day gives one price and another day moves at least one; every price sits in the 80 to 120 percent drift band; three different wanted items a day, all from the loot tables, pay 1.5x what they would have; selling one item ten times drops its next price below what it got unsold (never under 70 percent) and leaves another item alone; the sales aging out lets the price creep back up and a week later it is back; lifetime earnings never raise a price; buy back returns exactly the price paid after the market moved; the stash shows a wanted strip of three; the Peddler pays the market price and draws the wanted line; an old save without P.mkt loads with nothing lost, twice',
   run:function(){
     if(!(window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile&&window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot stage';
     var hub=document.getElementById('hub');
     if(!hub||typeof renderHub!=='function'||typeof applyLoadedProfile!=='function'||typeof stashSell!=='function'||typeof stashBuyBack!=='function'||typeof sellDayGet!=='function'||typeof ival!=='function'||typeof pedSellAll!=='function'||typeof pedBuyRate!=='function') return 'SKIP: no stash sale or stall here';
     if(typeof mktPriceAt!=='function'||typeof mktWanted!=='function'||typeof mktDay!=='function'||typeof mktPool!=='function') return 'no market in this build (mktPriceAt, mktWanted, mktDay, mktPool)';
     var saved=P, was=hub.classList.contains('on'), cfg={}, k, oldStore=storeSet, oldSave=saveProfile, bad=[], d, L, w, i, j, a, b, v, c0, key=null, twin=null, p0, p1, p10, moved=0, s, ix, el, ch, t, base, snap, ct0, x0, g, tr, drops={}, tb;
     function need(ok,msg){ if(!ok) bad.push(msg); }
     for(k in CFG) cfg[k]=CFG[k];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       storeSet=function(){}; saveProfile=function(){};
       P.stash=[]; P.kit=[]; P.keep={}; P.junk={}; P.credits=1000000; P.lifeEarn=0; delete P.sellDay; delete P.mkt;
       d=mktDay(); L=mktPool(); w=mktWanted(d);
       for(tb in LOOT) for(i=0;i<LOOT[tb].length;i++) drops[LOOT[tb][i][0]]=1;
       // ONE: one day, one price; another day moves at least one; every price inside the drift band
       need(L.length>=6,'ONE: the market knows '+L.length+' items');
       for(i=0;i<L.length;i++){
         a=mktPriceAt(L[i],d); b=mktPriceAt(L[i],d);
         need(a===b,'ONE: '+L[i]+' priced '+a+' then '+b+' on one day');
         if(mktPriceAt(L[i],d+1,1)!==mktPriceAt(L[i],d,1)) moved++;
         v=ival(L[i]); a=mktPriceAt(L[i],d,1);
         need(a>=Math.floor(v*0.8)-1&&a<=Math.ceil(v*1.2)+1,'ONE: '+L[i]+' worth '+v+' priced '+a+', out of the 80 to 120 percent band');
         need(drops[L[i]]===1,'ONE: '+L[i]+' is in the market but drops nowhere');
       }
       need(moved>0,'ONE: the next day moved no price');
       need(sellPriceOf(L[0])===mktPriceAt(L[0],d),'ONE: sellPriceOf '+sellPriceOf(L[0])+' is not the market price '+mktPriceAt(L[0],d));
       // TWO: three different wanted items, all from the market, the same all day
       need(w.length===3&&w[0]!==w[1]&&w[1]!==w[2]&&w[0]!==w[2],'TWO: wanted today '+JSON.stringify(w));
       for(i=0;i<w.length;i++) need(L.indexOf(w[i])>=0,'TWO: wanted '+w[i]+' is not an item that drops');
       need(JSON.stringify(mktWanted(d))===JSON.stringify(w),'TWO: the wanted list changed within a day');
       for(moved=0,i=1;i<=7;i++) if(JSON.stringify(mktWanted(d+i))!==JSON.stringify(w)) moved++;
       need(moved>0,'TWO: the wanted list never changes over a week');
       // THREE: a wanted item pays 1.5x what it would have; an item not wanted gets no bonus
       for(i=0;i<w.length;i++){ a=mktPriceAt(w[i],d); b=mktPriceAt(w[i],d,1); need(Math.abs(a-1.5*b)<=1,'THREE: wanted '+w[i]+' pays '+a+', not 1.5x its '+b); }
       for(i=0;i<L.length;i++) if(w.indexOf(L[i])<0){ need(mktPriceAt(L[i],d)===mktPriceAt(L[i],d,1),'THREE: '+L[i]+' is not wanted and still gets a bonus'); break; }
       // FOUR: sell one item ten times: its next price falls below what it got unsold, never under 70 percent, and another item keeps its price
       for(i=0;i<L.length;i++) if(w.indexOf(L[i])<0&&ival(L[i])>=100){ if(!key) key=L[i]; else if(!twin){ twin=L[i]; break; } }
       if(!key||!twin) return 'SKIP: no two unwanted items worth 100 here';
       p0=sellPriceOf(key); p1=sellPriceOf(twin);
       for(i=0;i<10;i++){ P.stash.push(key); stashSell(key,1); }
       p10=sellPriceOf(key);
       need(p10<p0,'FOUR: after ten sales '+key+' still pays '+p10+' against '+p0+' unsold');
       need(p10>=Math.floor(p0*0.7)-1,'FOUR: after ten sales '+key+' pays '+p10+', under 70 percent of '+p0);
       need(sellPriceOf(twin)===p1,'FOUR: selling '+key+' moved '+twin+' from '+p1+' to '+sellPriceOf(twin));
       for(i=0;i<5;i++){ P.stash.push(key); stashSell(key,1); }
       need(sellPriceOf(key)>=Math.floor(p0*0.7)-1,'FOUR: after fifteen sales '+key+' pays '+sellPriceOf(key)+', under the 70 percent floor of '+p0);
       // FIVE: what nobody sold creeps back up: the same sales three days old weigh less, eight days old not at all
       s=P.mkt&&P.mkt.s; need(s&&s[d]&&s[d][key]===15,'FIVE: the market record holds '+JSON.stringify(s)+', not 15 '+key+' sold today');
       if(s&&s[d]){
         a=sellPriceOf(key); s[d-3]=s[d]; delete s[d];
         b=mktPriceAt(key,d);
         need(b>a&&b<p0,'FIVE: the same sales three days old price '+key+' at '+b+', not between '+a+' and '+p0);
         s[d-8]=s[d-3]; delete s[d-3];
         need(mktPriceAt(key,d)===p0,'FIVE: sales eight days old still price '+key+' at '+mktPriceAt(key,d)+', not '+p0);
         delete s[d-8];
       }
       // SIX: lifetime earnings never raise a price (his answer 42)
       a=sellPriceOf(twin); P.lifeEarn=999999999; need(sellPriceOf(twin)===a,'SIX: lifetime earnings moved '+twin+' from '+a+' to '+sellPriceOf(twin)); P.lifeEarn=0;
       // SEVEN: buy back returns exactly the price paid after the market moved
       P.stash.push(twin); v=sellPriceOf(twin); stashSell(twin,1);
       for(i=0;i<5;i++) P.stash.push(twin);
       stashSell(twin,5);
       need(sellPriceOf(twin)<v,'SEVEN: six sales left '+twin+' at '+sellPriceOf(twin)+', so the market did not move');
       s=sellDayGet().s; ix=-1; for(i=0;i<s.length;i++) if(s[i].k===twin&&s[i].n===1) ix=i;
       if(ix<0) bad.push('SEVEN: the one '+twin+' sale is not listed for buy back');
       else { c0=P.credits; a=stashBuyBack(ix); need(a===v&&P.credits===c0-v,'SEVEN: the buy back took '+a+' ('+(c0-P.credits)+'), not the '+v+' it paid'); }
       // EIGHT: the stash shows three wanted items under one lower case label
       renderHub(); hub.classList.add('on'); renderHub();
       el=document.getElementById('wanted'); ch=el?el.querySelectorAll('[data-want]'):[];
       need(el&&el.style.display!=='none'&&ch.length===3,'EIGHT: the stash shows '+ch.length+' wanted items');
       for(i=0;i<ch.length;i++) need(w.indexOf(ch[i].getAttribute('data-want'))>=0&&ch[i].textContent.indexOf('$'+sellPriceOf(ch[i].getAttribute('data-want')).toLocaleString())>=0,'EIGHT: the wanted chip '+ch[i].textContent+' is not a wanted item at its price');
       t=el?String(el.textContent):'';
       need(t.indexOf('wanted +50%')===0&&t===t.toLowerCase(),'EIGHT: the strip reads '+JSON.stringify(t));
       hub.classList.remove('on');
       // NINE: the Peddler pays the market price (a wanted item 1.5x) and draws the wanted line
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); g.ents.length=0; g.hotAssign={}; g.hotAuto={}; g.issuedBandages=0;
       g.trade={kind:'peddler',hp:100,x:g.player.x,y:g.player.y,stock:[]}; g.pedCarry=0; g.pedSold=0;
       g.bag=[w[0]]; a=Math.round(sellPriceOf(w[0])*pedBuyRate()); b=Math.round(mktPriceAt(w[0],d,1)*pedBuyRate());
       if(window.__textTrace){ tr=__textTrace(function(){ drawTrade(); }); need(tr.some(function(q){ return q.t==='wanted +50%'; }),'NINE: the Peddler panel draws no wanted line'); }
       pedSellAll();
       need(g.bag.length===0&&g.pedCarry===a,'NINE: the stall paid '+g.pedCarry+' for wanted '+w[0]+', not '+a);
       need(a>b,'NINE: the stall pays '+a+' for wanted '+w[0]+', no more than '+b+' unwanted');
       need(P.mkt.s[d][w[0]]===1,'NINE: the stall sale is not in the market record');
       g.trade=null; __endRaid('abandon');
       // TEN: an old save (no P.mkt) loads with nothing lost and prices as unsold, and again
       __topClear();
       P.stash=[key,twin,'scrap']; P.credits=4321; P.weapons=['pistol','smg']; P.equipped='smg'; P.lifeEarn=777; P.contracts=P.contracts||[]; ct0=P.contracts.length; x0=JSON.stringify(P.forged||{});
       base=JSON.parse(JSON.stringify(P)); base.cfg=JSON.parse(JSON.stringify(CFG)); base.cfgv=18; delete base.mkt; delete base.sellDay;
       applyLoadedProfile({value:JSON.stringify(base)});
       need(P.credits===4321&&JSON.stringify(P.stash)===JSON.stringify([key,twin,'scrap'])&&P.equipped==='smg'&&P.weapons.indexOf('smg')>=0&&(P.contracts||[]).length===ct0&&JSON.stringify(P.forged||{})===x0,'TEN: the old save lost something (credits '+P.credits+', stash '+JSON.stringify(P.stash)+', guns '+JSON.stringify(P.weapons)+' '+P.equipped+', contracts '+(P.contracts||[]).length+')');
       need(P.lifeEarn===777&&P.pil&&P.pil.gen>=1&&typeof P.acctName==='string','TEN: the m0 records moved (lifetime '+P.lifeEarn+')');
       var unsold=function(q){ var m=P.mkt, r; P.mkt={s:{}}; r=sellPriceOf(q); if(m===undefined) delete P.mkt; else P.mkt=m; return r; };
       a=sellPriceOf(key); b=sellPriceOf(twin);
       need(a===unsold(key)&&b===unsold(twin),'TEN: an old save prices '+key+' '+a+' and '+twin+' '+b+', not unsold '+unsold(key)+' and '+unsold(twin));
       renderHub();
       v=sellPriceOf(key); stashSell(key,1);
       need(P.credits===4321+v&&P.mkt&&P.mkt.s&&P.mkt.s[d]&&P.mkt.s[d][key]===1,'TEN: a sale on the old save paid '+(P.credits-4321)+' and recorded '+JSON.stringify(P.mkt));
       snap=JSON.parse(JSON.stringify(P)); applyLoadedProfile({value:JSON.stringify(snap)});
       need(P.credits===4321+v&&P.stash.length===2&&P.lifeEarn===777&&P.mkt&&P.mkt.s&&P.mkt.s[d]&&P.mkt.s[d][key]===1&&sellPriceOf(key)<unsold(key),'TEN: a second load moved it (credits '+P.credits+', stash '+P.stash.length+', lifetime '+P.lifeEarn+', market '+JSON.stringify(P.mkt)+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2&&g2.trade) g2.trade=null; if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       try{ if(!was) hub.classList.remove('on'); }catch(_h){}
       P=saved; storeSet=oldStore; saveProfile=oldSave;
       for(k in CFG) if(!(k in cfg)) delete CFG[k]; for(k in cfg) CFG[k]=cfg[k];
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'37.19',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
