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

# SEASON ZERO: THE MARKET (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// ONE PRICE: sellPriceOf(k) is what the stash pays for k today (the plain item value). The market (m1d) changes only this function.
function sellPriceOf(k){ return ival(k); }
'@ @'
// ONE PRICE: sellPriceOf(k) is what the stash and the Peddler pay for k today. The market (m1d) lives here and nowhere else.
// v37.xx (cw-m1mkt), HIS NOTE (answer 38, 11-01): "i feel like prices should move around based on....something". Plan m1: THE MARKET. Today's price is
// the item value times three things: a daily drift of 80 to 120 percent (seeded from the local calendar day and the item, never a raid stream, so seed
// 4242 never moves); selling pressure (the copies sold in the last 7 days, newer sales weigh more: 10 sold today takes it to the 70 percent floor, and it
// creeps back up as the sales age out); and three wanted items a day, drawn from items the loot tables drop, that pay 1.5x. Lifetime earnings never raise
// a price (his answer 42). A buy back pays back exactly what its sale paid (the sale list keeps the price) and takes its copies off the pressure. The
// demo and robot raids keep the plain value. P.mkt {s:{day number:{item:copies sold}}}, the last 7 days; an old save has none and starts with nothing sold.
var MKT_DAYS=7, MKT_LO=0.8, MKT_HI=1.2, MKT_FLOOR=0.7, MKT_PER=0.03, MKT_WANT=1.5, MKT_NWANT=3, MKT_POOL=null, MKT_WC=null;
function mktDay(){ var t=new Date(); return Math.round(Date.UTC(t.getFullYear(),t.getMonth(),t.getDate())/864e5); }
function mktHash(s){ var h=2166136261, i; s=String(s); for(i=0;i<s.length;i++){ h^=s.charCodeAt(i); h=Math.imul(h,16777619); } h^=h>>>13; h=Math.imul(h,0x5bd1e995); h^=h>>>15; return (h>>>0)/4294967296; }
// The items the market trades: every item a loot table drops, but no gun and no key.
function mktPool(){
  var o={}, L=[], t, i, k;
  if(MKT_POOL) return MKT_POOL;
  for(t in LOOT) for(i=0;i<LOOT[t].length;i++){ k=LOOT[t][i][0]; if(ITEMS[k]&&!ITEMS[k].gk&&!/^gun_/.test(k)&&ITEMS[k].use!=='key'&&ITEMS[k].use!=='gun'&&(+ITEMS[k].val||0)>0) o[k]=1; }
  for(k in o) L.push(k);
  L.sort(); return (MKT_POOL=L);
}
function mktWanted(dn){
  var L, w=[], i;
  if(dn===undefined) dn=mktDay();
  if(MKT_WC&&MKT_WC.d===dn) return MKT_WC.w.slice();
  L=mktPool().slice();
  while(w.length<MKT_NWANT&&L.length){ i=Math.floor(mktHash('want:'+dn+':'+w.length)*L.length); w.push(L.splice(i,1)[0]); }
  MKT_WC={d:dn,w:w}; return w.slice();
}
// The selling pressure on k seen from day dn: each copy sold a days before counts (7-a)/7.
function mktPress(k,dn){
  var s=P&&P.mkt&&P.mkt.s, t=0, a, q, n;
  if(!s||typeof s!=='object') return 0;
  for(a=0;a<MKT_DAYS;a++){ q=s[dn-a]; n=(q&&typeof q==='object')?(q[k]|0):0; if(n>0) t+=n*(MKT_DAYS-a)/MKT_DAYS; }
  return t;
}
// The market price of k on day dn; noWant leaves out the wanted bonus (what it would have paid).
function mktPriceAt(k,dn,noWant){
  var b=ival(k), f;
  if(b<=0) return 0;
  f=MKT_LO+(MKT_HI-MKT_LO)*mktHash(k+':'+dn);
  f*=Math.max(MKT_FLOOR,1-MKT_PER*mktPress(k,dn));
  if(!noWant&&mktWanted(dn).indexOf(k)>=0) f*=MKT_WANT;
  return Math.max(1,Math.round(b*f));
}
// The record of the last 7 days, repaired; mktNote counts n copies of k sold today (a negative n takes a bought back sale off).
function mktGet(){
  var m=P.mkt, q, s={}, d=mktDay(), k, j, o, x;
  if(!m||typeof m!=='object'||Array.isArray(m)) m=P.mkt={s:{}};
  q=(m.s&&typeof m.s==='object'&&!Array.isArray(m.s))?m.s:{};
  for(k in q){
    if(!Object.prototype.hasOwnProperty.call(q,k)) continue;
    j=+k; if(!(j>d-MKT_DAYS&&j<=d)||!q[k]||typeof q[k]!=='object') continue;
    o={}; for(x in q[k]) if(Object.prototype.hasOwnProperty.call(q[k],x)&&(q[k][x]|0)>0) o[x]=q[k][x]|0;
    s[k]=o;
  }
  m.s=s; return m;
}
function mktNote(k,n){
  var m, q, d;
  n=n|0; if(!P||!k||!n||trDemo()) return;
  m=mktGet(); d=String(mktDay()); q=m.s[d]||(m.s[d]={});
  q[k]=Math.max(0,(q[k]|0)+n); if(!q[k]) delete q[k];
}
function sellPriceOf(k){
  if(trDemo()||(typeof G==='object'&&G&&G.sim)) return ival(k);
  return mktPriceAt(k,mktDay());
}
'@

SubRx @'
  s=sellDayGet(); s.s.push({k:k,n:got,p:p}); s.e+=got*p;
'@ @'
  s=sellDayGet(); s.s.push({k:k,n:got,p:p}); s.e+=got*p;
  mktNote(k,got);   // v37.xx (cw-m1mkt): selling pressure
'@

SubRx @'
  P.credits-=c; s.e=Math.max(0,s.e-c); s.s.splice(i|0,1);
'@ @'
  P.credits-=c; s.e=Math.max(0,s.e-c); s.s.splice(i|0,1);
  mktNote(q.k,-q.n);   // v37.xx (cw-m1mkt): an undone sale puts no pressure on the market
'@

SubRx @'
lifeEarn:0,mig1x:1,
'@ @'
lifeEarn:0,mig1x:1,mkt:{s:{}},
'@

SubRx @'
        <button id="sellall" style="width:100%">SELL JUNK AND LOOSE SALVAGE</button>
'@ @'
        <div id="wanted" style="display:none;flex-wrap:wrap;gap:8px;align-items:center;margin-bottom:8px"></div><!-- v37.xx (cw-m1mkt): the three wanted items of the day -->
        <button id="sellall" style="width:100%">SELL JUNK AND LOOSE SALVAGE</button>
'@

SubRx @'
  // v37.xx (cw-m1sell), his answer 39: TODAY'S SALES, newest first, under the sell button.
'@ @'
  // v37.xx (cw-m1mkt), his answer 38: THE WANTED STRIP over the sell button: the three items the market wants today (+50%), each at today's price.
  var _wd=document.getElementById('wanted');
  if(_wd){
    var _wl=trDemo()?[]:mktWanted(), _wh='', _wi, _wn;
    for(_wi=0;_wi<_wl.length;_wi++){
      _wn=String(ITEMS[_wl[_wi]]?ITEMS[_wl[_wi]].name:_wl[_wi]).toLowerCase();
      _wh+='<span data-want="'+_wl[_wi]+'" style="height:28px;padding:0 8px;font-size:16px;letter-spacing:.04em;border:1px solid var(--ui-line-hi);border-radius:4px;display:inline-flex;align-items:center;gap:6px">'+
        iconImgHTML(_wl[_wi],20,1)+'<span>'+escHtml(_wn)+'</span><b style="color:var(--amber);font-weight:600">$'+sellPriceOf(_wl[_wi]).toLocaleString()+'</b></span>';
    }
    _wd.innerHTML=_wh?('<span style="font-size:16px;letter-spacing:.04em;color:var(--amber)">wanted +50%</span>'+_wh):'';
    _wd.style.display=_wh?'flex':'none';
  }
  // v37.xx (cw-m1sell), his answer 39: TODAY'S SALES, newest first, under the sell button.
'@

SubRx @'
  var _ck={}, _ckOut=[], _ckV=0, _cj, _ckL=G.carriedKit||[];
'@ @'
  var _ck={}, _ckOut=[], _ckV=0, _cj, _ckL=G.carriedKit||[], _mp, _mkS={}, _mk;   // v37.xx (cw-m1mkt): _mkS, the copies sold, for the market
'@

SubRx @'
    tot+=Math.round(ival(k)*pedBuyRate()); full+=ival(k); n++;
'@ @'
    _mp=sellPriceOf(k); tot+=Math.round(_mp*pedBuyRate()); full+=_mp; n++; _mkS[k]=(_mkS[k]||0)+1;   // v37.xx (cw-m1mkt): today's market price
'@

SubRx @'
  G.bag=kept; if(G.bandSeen!==undefined) G.bandSeen-=_soldB;
'@ @'
  G.bag=kept; if(G.bandSeen!==undefined) G.bandSeen-=_soldB;
  if(!G.sim) for(_mk in _mkS) mktNote(_mk,_mkS[_mk]);   // v37.xx (cw-m1mkt): a stall sale is selling pressure too
'@

SubRx @'
  var T=G.trade,PW=LH(340),PH=LH(238),x=Math.round(W/2-PW/2),y=Math.round(H/2-PH/2);
'@ @'
  var T=G.trade,_mw=(trDemo()||G.sim)?[]:mktWanted(),PW=LH(340),PH=LH(238+(_mw.length?16:0)),x=Math.round(W/2-PW/2),y=Math.round(H/2-PH/2);   // v37.xx (cw-m1mkt): a row taller for the wanted line
'@

SubRx @'
    tot+=Math.round(ival(k)*pedBuyRate()); fullv+=ival(k); n++;
'@ @'
    var _tp=sellPriceOf(k); tot+=Math.round(_tp*pedBuyRate()); fullv+=_tp; n++;   // v37.xx (cw-m1mkt): today's market price
'@

SubRx @'
    ctx.fillText('Carried home: '+'$'+fullv.toLocaleString()+'.',x+14,cy);   // v37.xx (cw-m1xpoff): no xp
  }
'@ @'
    ctx.fillText('Carried home: '+'$'+fullv.toLocaleString()+'.',x+14,cy);   // v37.xx (cw-m1xpoff): no xp
  }
  // v37.xx (cw-m1mkt), his answer 38: the wanted line, as on the stash screen: the label, then each item's icon and name (icons only when the names do not fit).
  if(_mw.length){
    cy+=LH(16);
    ctx.font=FS(TYPE.micro); ctx.fillStyle='#ffc04a';
    ctx.fillText('wanted +50%',x+14,cy);
    var _mx=x+14+ctx.measureText('wanted +50%').width+LH(10), _mz=LH(14), _mnm=[], _mwd=0, _mj, _mfit;
    for(_mj=0;_mj<_mw.length;_mj++){ _mnm.push(String(ITEMS[_mw[_mj]]?ITEMS[_mw[_mj]].name:_mw[_mj]).toLowerCase()); _mwd+=_mz+LH(4)+ctx.measureText(_mnm[_mj]).width+LH(10); }
    _mfit=_mx+_mwd-LH(10)<=x+PW-14;
    for(_mj=0;_mj<_mw.length;_mj++){
      drawItemIconArt(ctx,_mw[_mj],_mx+_mz/2,cy-LH(4),_mz);
      _mx+=_mz+LH(4);
      if(_mfit){ ctx.font=FS(TYPE.micro); ctx.fillStyle='#cdd6dd'; ctx.textAlign='left'; ctx.fillText(_mnm[_mj],_mx,cy); _mx+=ctx.measureText(_mnm[_mj]).width+LH(10); }
      else _mx+=LH(6);
    }
  }
'@

SubRx @'
var VER='37.19';
'@ @'
var VER='37.20';
'@

$pat = "(?m)^  now:'v37\.19:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.20: sale prices drift day to day (80 to 120 percent of value, seeded from the calendar day), what you sold a lot of this week sells for less (down to 70 percent) and creeps back up as the week passes, three wanted items a day pay 50 percent more and show as a wanted strip on the stash screen and a wanted line at the Peddler; the Peddler pays market prices too; buy back still returns the exact price paid; lifetime earnings never raise a price Check 37.20 fails on v37.19',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
