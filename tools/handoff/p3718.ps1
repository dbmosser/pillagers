$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
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

# SEASON ZERO: SELL FROM THE STASH AND BUY BACK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function lifeEarnAdd(n){ n=Math.round(+n||0); if(n<=0||!P) return 0; acctEnsure(P); P.lifeEarn+=n; return n; }
'@ @'
function lifeEarnAdd(n){ n=Math.round(+n||0); if(n<=0||!P) return 0; acctEnsure(P); P.lifeEarn+=n; return n; }
// v37.xx (cw-m1sell), HIS ANSWERS OF 11-01 (season zero m1): 37, where you sell: "the Peddler, or straight from the stash screen"; 39, buy back what you
// sold today at the same price: "yes"; 44, show net worth (stash cash plus stash value): "yes"; 47, lifetime earnings counts "every dollar earned".
// A sale pays $ only: the plan has no XP, so no sale pays XP or moves a level.
// ONE PRICE: sellPriceOf(k) is what the stash pays for k today (the plain item value). The market (m1d) changes only this function.
function sellPriceOf(k){ return ival(k); }
// TODAY'S SALES: P.sellDay {d the local calendar day, e the $ sold today and not bought back, s [{k item, n copies, p each}] oldest first}. The day's
// sales go into lifetime earnings when the day closes, through lifeEarnAdd (still the only writer), so a buy back just takes its sale off the day:
// lifetime earnings never count a sale that was undone and never go down. lifeEarnNow() is lifetime earnings with today's sales in; read that one.
// An old save has no P.sellDay and starts an empty day.
var SELL_DAY_MAX=12;
function sellDayKey(){ var t=new Date(); return t.getFullYear()+'-'+(t.getMonth()+1)+'-'+t.getDate(); }
function sellDayGet(){
  var s=P.sellDay, d=sellDayKey(), L=[], e, i, q;
  if(!s||typeof s!=='object'||Array.isArray(s)) s=P.sellDay={d:d,e:0,s:[]};
  if(!Array.isArray(s.s)) s.s=[];
  for(i=0;i<s.s.length;i++){ q=s.s[i]; if(q&&typeof q.k==='string'&&(q.n|0)>0&&isFinite(+q.p)&&+q.p>=0) L.push({k:q.k,n:q.n|0,p:Math.round(+q.p)}); }
  s.s=L.slice(-SELL_DAY_MAX); e=Math.round(+s.e||0); s.e=(isFinite(e)&&e>0)?e:0;
  if(s.d!==d){ e=s.e; s.d=d; s.e=0; s.s=[]; if(e>0) lifeEarnAdd(e); }   // the day closed: bank it once, clear the list
  return s;
}
function lifeEarnNow(){ var s=P&&P.sellDay, e=(s&&isFinite(+s.e)&&+s.e>0)?Math.round(+s.e):0; return Math.round((P&&+P.lifeEarn)||0)+e; }
// Sell up to n copies of k from the stash at today's price and list the sale for buy back. A locked item (P.keep) never sells. Returns the $ paid.
function stashSell(k,n){
  var p, got=0, ix, s;
  if(!P||!k||stashLocked(k)) return 0;
  p=sellPriceOf(k); n=Math.max(1,n|0);
  while(got<n){ ix=P.stash.indexOf(k); if(ix<0) break; P.stash.splice(ix,1); got++; }
  if(!got) return 0;
  clearKeysFor(k);
  s=sellDayGet(); s.s.push({k:k,n:got,p:p}); s.e+=got*p;
  if(s.s.length>SELL_DAY_MAX) s.s.shift();   // the oldest leaves the list; its $ still counts
  P.credits+=got*p;
  return got*p;
}
// Buy back today's sale i, the whole sale, at exactly what it paid. Returns the $ taken, 0 for no such sale, -1 when the $ is short.
function stashBuyBack(i){
  var s=sellDayGet(), q=s.s[i|0], c, j;
  if(!q) return 0;
  c=q.n*q.p;
  if((P.credits||0)<c) return -1;
  P.credits-=c; s.e=Math.max(0,s.e-c); s.s.splice(i|0,1);
  for(j=0;j<q.n;j++) P.stash.push(q.k);
  return c;
}
// What the stash would sell for today, and net worth (cash plus that). Worn gear and P.gear join once m3 gives them a price.
function stashWorth(){ var t=0, i, L=(P&&P.stash)||[]; for(i=0;i<L.length;i++) t+=sellPriceOf(L[i]); return t; }
function netWorth(){ return ((P&&P.credits)||0)+stashWorth(); }
'@

SubRx @'
    rows.push({label:isJ?'Untag junk':'Tag as junk',hint:isJ?null:'$'+ival(key).toLocaleString()+' each',
'@ @'
    rows.push({label:isJ?'Untag junk':'Tag as junk',hint:isJ?null:'$'+sellPriceOf(key).toLocaleString()+' each',
'@

SubRx @'
    if(ctx==='stash'&&held>0&&_hbS&&_hbS.classList.contains('on')&&!stashLocked(key)) rows.push({label:'Sell one',hint:'$'+ival(key).toLocaleString(),act:function(){
'@ @'
    if(ctx==='stash'&&held>0&&_hbS&&_hbS.classList.contains('on')&&!stashLocked(key)) rows.push({label:'Sell one',hint:'$'+sellPriceOf(key).toLocaleString(),act:function(){
'@

SubRx @'
      P.stash.splice(ix,1); clearKeysFor(key); P.credits+=ival(key); P.xp=(P.xp||0)+ival(key); syncXpLevel(); saveProfile(); refreshInv();
'@ @'
      if(stashSell(key,1)){ saveProfile(); refreshInv(); }   // v37.xx (cw-m1sell): today's price, $ only, listed for buy back
'@

SubRx @'
    if(ctx==='stash'&&_sn>1&&_hbS&&_hbS.classList.contains('on')&&!stashLocked(key)) rows.push({label:'Sell all '+_sn,hint:'$'+(ival(key)*_sn).toLocaleString(),act:function(){
'@ @'
    if(ctx==='stash'&&_sn>1&&_hbS&&_hbS.classList.contains('on')&&!stashLocked(key)) rows.push({label:'Sell all '+_sn,hint:'$'+(sellPriceOf(key)*_sn).toLocaleString(),act:function(){
'@

SubRx @'
      var got=0, ix2;
'@ @'
      var got=stashSell(key,_sn);   // v37.xx (cw-m1sell): takes the copies, pays today's price in $ only, lists the sale for buy back
'@

SubRx @'
      for(var q=0;q<_sn;q++){ ix2=P.stash.indexOf(key); if(ix2<0) break; P.stash.splice(ix2,1); got++; }
'@ @'

'@

SubRx @'
      clearKeysFor(key); P.credits+=ival(key)*got; P.xp=(P.xp||0)+ival(key)*got; syncXpLevel(); saveProfile(); refreshInv();
'@ @'
      saveProfile(); refreshInv();
'@

SubRx @'
        if(ix>=0){ P.stash.splice(ix,1); clearKeysFor(k); P.credits+=ival(k); P.xp=(P.xp||0)+ival(k); syncXpLevel(); saveProfile(); renderHub(); }   // v12.67: XP moved, so the level does
'@ @'
        if(ix>=0&&stashSell(k,1)){ saveProfile(); renderHub(); }   // v37.xx (cw-m1sell): today's price, $ only, listed for buy back
'@

SubRx @'
    _sv+=ival(_sk); _sn++;
'@ @'
    _sv+=sellPriceOf(_sk); _sn++;
'@

SubRx @'
      ? ('Sell all salvage  \u00b7  '+'$'+_sv.toLocaleString()+'  +'+_sv.toLocaleString()+' XP')
'@ @'
      ? ('Sell all salvage  \u00b7  '+'$'+_sv.toLocaleString())   // v37.xx (cw-m1sell): a sale pays no XP
'@

SubRx @'
  if(_sh) _sh.style.display='none';   /* v28.xx (cw-uc-stash2): Q8, the sell note was a three sentence paragraph under the sell button (reason in notes/ui/changes.md) */
'@ @'
  if(_sh) _sh.style.display='none';   /* v28.xx (cw-uc-stash2): Q8, the sell note was a three sentence paragraph under the sell button (reason in notes/ui/changes.md) */
  // v37.xx (cw-m1sell), his answer 39: TODAY'S SALES, newest first, under the sell button. A chip is one sale (its item, count and the $ it paid);
  // pressing it buys that sale back at exactly that price. The strip folds away when nothing was sold today.
  var _bb=document.getElementById('buyback');
  if(_bb){
    var _sd=sellDayGet(), _bh='', _bi, _br, _bn, _bbs;
    for(_bi=_sd.s.length-1;_bi>=0;_bi--){
      _br=_sd.s[_bi]; _bn=String(ITEMS[_br.k]?ITEMS[_br.k].name:_br.k).toLowerCase();
      _bh+='<button type="button" data-bb="'+_bi+'" title="buy back '+escHtml(_bn)+'" style="height:28px;padding:0 8px;font-size:16px;letter-spacing:.04em;border:1px solid var(--ui-line-hi);border-radius:4px;display:inline-flex;align-items:center;gap:6px">'+
        (ITEMS[_br.k]?iconImgHTML(_br.k,20,1):'')+'<span>'+escHtml(_bn)+(_br.n>1?(' x'+_br.n):'')+'</span><b style="color:var(--amber);font-weight:600">$'+(_br.n*_br.p).toLocaleString()+'</b></button>';
    }
    _bb.innerHTML=_bh?('<span style="font-size:16px;letter-spacing:.04em;color:var(--ash)">buy back</span>'+_bh):'';
    _bb.style.display=_bh?'flex':'none';
    _bbs=_bb.querySelectorAll('[data-bb]');
    for(_bi=0;_bi<_bbs.length;_bi++) _bbs[_bi].onclick=function(){
      var got=stashBuyBack(+this.getAttribute('data-bb'));
      if(got<0){ say2('not enough $'); try{ sfx('clank'); }catch(_bc){} return; }
      saveProfile(); renderHub();
    };
  }
'@

SubRx @'
        <button id="sellall" style="width:100%">SELL JUNK AND LOOSE SALVAGE</button>
'@ @'
        <button id="sellall" style="width:100%">SELL JUNK AND LOOSE SALVAGE</button>
        <div id="buyback" style="display:none;flex-wrap:wrap;gap:8px;align-items:center;margin-top:8px"></div><!-- v37.xx (cw-m1sell): today's sales, buy back -->
'@

SubRx @'
  var kept=[],gained=0,sold=0,_soldKeys=[];   // v8.51: remember what left
'@ @'
  var kept=[],gained=0,sold=0,_soldKeys=[],_cnt={};   // v8.51: remember what left; v37.xx (cw-m1sell): and how many of each
'@

SubRx @'
    if(sellable(k)){ gained+=ival(k); sold++; _soldKeys.push(k); } else kept.push(k);
'@ @'
    if(sellable(k)){ if(!_cnt[k]){ _cnt[k]=0; _soldKeys.push(k); } _cnt[k]++; sold++; } else kept.push(k);
'@

SubRx @'
  P.credits+=gained; P.xp=(P.xp||0)+gained; P.stash=kept;   // v10.02, his answer 42: no bar bonus on a sale
'@ @'
  // v37.xx (cw-m1sell): each item through stashSell, at today's price, in $ only (no XP), listed for buy back
  for(var _sq=0;_sq<_soldKeys.length;_sq++) gained+=stashSell(_soldKeys[_sq],_cnt[_soldKeys[_sq]]);
'@

SubRx @'
  syncXpLevel();   // v12.67: XP moved, so the level and the racks it gates move with it
'@ @'

'@

SubRx @'
          'Total value extracted minus value carried in, across all runs. Deaths and abandons count what you lost.');
'@ @'
          'Total value extracted minus value carried in, across all runs. Deaths and abandons count what you lost.');
  // v37.xx (cw-m1sell), his answer 44: net worth, the cash and what the stash would sell for today
  h+=card('net worth', '$'+netWorth().toLocaleString(), 'cash $'+(P.credits||0).toLocaleString()+'  &middot;  stash $'+stashWorth().toLocaleString());
'@

SubRx @'
         le:P.lifeEarn||0,   // v37.xx (cw-p0acct): lifetime earnings travel with the character
'@ @'
         le:lifeEarnNow(),   // v37.xx (cw-p0acct): lifetime earnings travel with the character; v37.xx (cw-m1sell): today's sales in
'@

SubRx @'
var VER='37.17';
'@ @'
var VER='37.18';
'@

$pat = "(?m)^  now:'v37\.17:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.18: every stash sale pays one price (sellPriceOf) in $ only and counts in lifetime earnings; the sales of the day show as buy back chips under the sell button and a chip buys that sale back at the price paid; a locked item never sells; the stats page shows net worth (cash plus the stash at sale prices) Check 37.18 fails on v37.17',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
