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

# SEASON ZERO M3: THE WORKBENCH WORKS ON GEAR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function wornName(pc){ return pc&&WORN_KINDS[pc.k]?(WORN_RARS[pc.r].id+' '+WORN_KINDS[pc.k].n):''; }
'@ @'
function wornName(pc){ return pc&&WORN_KINDS[pc.k]?(WORN_RARS[pc.r].id+' '+WORN_KINDS[pc.k].n):''; }
// v37.xx (cw-m3bench), m3 shared helpers: the sale value of a piece at power 50 by rarity (tune here only, from real numbers), its price before CFG.lootMult as an
// ITEMS val is, and the compare tip against what is worn. A ring is compared in place of the weaker ring, or in an empty ring.
var WORN_VAL=[150,400,1000,2600];
function wornPrice(pc){ return Math.round(WORN_VAL[pc.r]*wornPwMul(pc.pw)*(1+(pc.pip|0)*0.1)); }
function wornPcSum(pc){ var t=0, i; for(i=0;i<pc.tr.length;i++) t+=wornTraitV(pc,pc.tr[i])/WORN_STATS[pc.tr[i].s].base; return t; }
function wornTip(pc,p){
  var w={}, s, t=WORN_KINDS[pc.k].slots[0], sum=0, was, now;
  for(s in p.worn) if(Object.prototype.hasOwnProperty.call(p.worn,s)) w[s]=p.worn[s];
  if(pc.k==='ring') t=!w.ring1?'ring1':(!w.ring2?'ring2':(wornPcSum(w.ring2)<wornPcSum(w.ring1)?'ring2':'ring1'));
  was=wornMods(w); w[t]=pc; now=wornMods(w);
  for(s in WORN_STATS) if(Object.prototype.hasOwnProperty.call(WORN_STATS,s)) sum+=(now[s]-was[s])/WORN_STATS[s].base;
  return sum>0.01?'better':(sum<-0.01?'worse':'even');
}
'@

SubRx @'
    v=WORN_STATS[s].base*rar.mul*wornPwMul(pw)*(0.75+0.5*R());
    tr.push({s:s,v:Math.round(v*1000)/1000});
'@ @'
    tr.push({s:s,v:wornTraitRoll(s,rar,pw,R)});   // v37.xx (cw-m3bench): the same sum and the same one die, now shared with the reroll
'@

SubRx @'
function wornTraitV(pc,t){ return (+t.v||0)*(1+Math.max(0,Math.min(3,pc.pip|0))/3); }
'@ @'
function wornTraitV(pc,t){ return (+t.v||0)*(1+Math.max(0,Math.min(3,pc.pip|0))/3); }
function wornTraitRoll(s,rar,pw,R){ return Math.round(WORN_STATS[s].base*rar.mul*wornPwMul(pw)*(0.75+0.5*R())*1000)/1000; }
'@

SubRx @'
  if(typeof pc.id!=='string') pc.id=''; if(typeof pc.dye!=='string') pc.dye=''; if(typeof pc.rule!=='string') pc.rule='';
'@ @'
  if(typeof pc.id!=='string') pc.id=''; if(typeof pc.dye!=='string') pc.dye=''; if(typeof pc.rule!=='string') pc.rule='';
  pc.rr=Math.max(0,pc.rr|0);   // v37.xx (cw-m3bench): how many rerolls this piece has had
'@

SubRx @'
// What the stash would sell for today, and net worth (cash plus that). Worn gear and P.gear join once m3 gives them a price.
function stashWorth(){ var t=0, i, L=(P&&P.stash)||[]; for(i=0;i<L.length;i++) t+=sellPriceOf(L[i]); return t; }
function netWorth(){ return ((P&&P.credits)||0)+stashWorth(); }
'@ @'
// What the stash would sell for today, what the gear would sell for, in the stash and worn (v37.xx cw-m3bench), and net worth (cash plus those).
function stashWorth(){ var t=0, i, L=(P&&P.stash)||[]; for(i=0;i<L.length;i++) t+=sellPriceOf(L[i]); return t; }
function gearWorth(){ var t=0, i, s, L=(P&&P.gear)||[], W=(P&&P.worn)||{}; for(i=0;i<L.length;i++) t+=wornSalePrice(L[i]); for(s in W) if(Object.prototype.hasOwnProperty.call(W,s)&&W[s]) t+=wornSalePrice(W[s]); return t; }
function netWorth(){ return ((P&&P.credits)||0)+stashWorth()+gearWorth(); }
// v37.xx (cw-m3bench), HIS RULINGS OF 11-01 (season zero m3), answer 67: reroll one trait for $ at the workbench; answer 66: salvage unwanted gear into materials;
// "most the money should come from selling gear". THE BENCH WORKS ON P.gear ONLY: a worn piece is not offered, take it off first. Spending never touches lifetime
// earnings; a sale goes through lifeEarnAdd at once, because a piece has no item key for the day's buy back strip: the hold is the guard. Never in the demo.
function wornSalePrice(pc){ return Math.round(wornPrice(pc)*CFG.lootMult); }
function wornBenchPc(p,id){ var i; if(!p||trDemo()||!wornClean(p)) return null; for(i=0;i<p.gear.length;i++) if(p.gear[i].id===id) return p.gear[i]; return null; }
// The dice of a piece come from its id and a number, so a reload cannot change a roll.
function wornPcSeed(pc,n){ var h=2166136261, s=String(pc.id), i; for(i=0;i<s.length;i++) h=Math.imul(h^s.charCodeAt(i),16777619); return (h+Math.imul(n|0,0x9E3779B1))>>>0; }
// REROLL: about a quarter of the price, up by half with each reroll of this piece.
function wornRerollPrice(pc){ return Math.round(wornPrice(pc)*0.25*Math.pow(1.5,pc.rr|0)); }
// The next roll: another trait from the kind's pool, at the piece's rarity and power, never one it holds. Null when the pool has no other.
function wornRerollRoll(pc){
  var L=wornPool(pc.k).filter(function(s){ return !pc.tr.some(function(t){ return t.s===s; }); }), R, s;
  if(!L.length) return null;
  R=wornRand(wornPcSeed(pc,(pc.rr|0)+1)); s=L[Math.floor(R()*L.length)];
  return {s:s,v:Math.min(WORN_STATS[s].cap,wornTraitRoll(s,WORN_RARS[pc.r],pc.pw,R))};
}
// Reroll trait ti of stash piece id. Returns the $ taken, 0 for nothing to do, -1 when the $ is short.
function wornReroll(p,id,ti){
  var pc=wornBenchPc(p,id), c, q;
  if(!pc||!pc.tr[ti|0]) return 0;
  q=wornRerollRoll(pc); if(!q) return 0;
  c=wornRerollPrice(pc);
  if((p.credits||0)<c) return -1;
  p.credits-=c; pc.tr[ti|0]=q; pc.rr=(pc.rr|0)+1;
  return c;
}
// SALVAGE: the table says how many materials; the piece's dice pick which, aiming at about 80 percent of what selling it pays at today's material prices,
// so selling is usually the better money and salvage the way to rack parts. The last one is whichever lands nearest.
var WORN_SALV=[2,4,8,14], WORN_SALV_MATS=['scrap','wire','cell','board'];
function wornSalvMix(pc){
  var n=WORN_SALV[pc.r], left=0.8*wornSalePrice(pc), R=wornRand(wornPcSeed(pc,0)), M=WORN_SALV_MATS.slice(), out={}, i, j, a, lo, hi, k;
  M.sort(function(x,y){ return sellPriceOf(x)-sellPriceOf(y); });
  for(i=0;i<n;i++){
    a=left/(n-i);
    for(j=0;j<M.length-1&&sellPriceOf(M[j+1])<=a;j++);
    lo=sellPriceOf(M[j]); hi=(j+1<M.length)?sellPriceOf(M[j+1]):lo; k=M[j];
    if(hi>lo&&a>lo&&((i===n-1)?(a-lo>hi-a):(R()<(a-lo)/(hi-lo)))) k=M[j+1];
    out[k]=(out[k]||0)+1; left-=sellPriceOf(k);
  }
  return out;
}
// Salvage stash piece id: it is gone, the materials go in the stash. Returns the mix, null for nothing done.
function wornSalvage(p,id){
  var pc=wornBenchPc(p,id), m, k, i;
  if(!pc) return null;
  m=wornSalvMix(pc);
  p.gear.splice(p.gear.indexOf(pc),1);
  for(k in m) for(i=0;i<m[k];i++) p.stash.push(k);
  return m;
}
// Sell stash piece id. Returns the $ paid, 0 for nothing done.
function wornSell(p,id){
  var pc=wornBenchPc(p,id), c;
  if(!pc) return 0;
  c=wornSalePrice(pc);
  p.gear.splice(p.gear.indexOf(pc),1);
  p.credits=(p.credits||0)+c; lifeEarnAdd(c);
  return c;
}
'@

SubRx @'
'cash $'+(P.credits||0).toLocaleString()+'  &middot;  stash $'+stashWorth().toLocaleString());
'@ @'
'cash $'+(P.credits||0).toLocaleString()+'  &middot;  stash $'+stashWorth().toLocaleString()+(gearWorth()?('  &middot;  gear $'+gearWorth().toLocaleString()):''));
'@

SubRx @'
    <div class="plist" id="worklist" style="display:none"></div>
  </div>
'@ @'
    <div class="plist" id="worklist" style="display:none"></div>
  </div>

  <div class="tpane" id="tpane_gear" style="display:none"><!-- v37.xx (cw-m3bench): the gear section of the workbench -->
    <div class="msub" id="wallet_gear" style="color:var(--amber);font-weight:700"></div>
    <div class="vend">
      <div class="vendgrid" id="benchlist"></div>
      <div class="vdet" id="benchdetail"></div>
    </div>
  </div>
'@

SubRx @'
  var T=[['buy','BUY','req'],['craft','CRAFT','work'],['hire','HIRE',null]];
  var want=tab||'buy';
  try{ renderShop(); }catch(e){}
  try{ renderWork(); }catch(e){}
'@ @'
  var T=[['buy','BUY','req'],['craft','CRAFT','work'],['gear','GEAR',null],['hire','HIRE',null]];
  var want=tab||'buy';
  if(trDemo()){ T.splice(2,1); if(want==='gear') want='craft'; (function(){ var _gp=document.getElementById('tpane_gear'); if(_gp) _gp.style.display='none'; })(); }   // v37.xx (cw-m3bench): gear is never in the demo
  try{ renderShop(); }catch(e){}
  try{ renderWork(); }catch(e){}
  try{ renderBench(); }catch(e){}   // v37.xx (cw-m3bench)
'@

SubRx @'
// ================================================================ wiring
// v6.11: the same door as the lift on the floor. This called startRaid() directly,
'@ @'
// v37.xx (cw-m3bench): THE GEAR TAB OF THE WORKBENCH: every piece in P.gear down the left (it scrolls, the pad and the keys reach every row), the chosen piece on the right
// with a reroll button on each trait and the two holds. The same panels as the craft tab. Pad and keys press with no hold, so they get the confirm card.
var BENCH_SEL='';
function benchPips(pc){ var h='', i; for(i=0;i<3;i++) h+='<i class="bpip'+(i<(pc.pip|0)?' on':'')+'"></i>'; return h; }
function benchTr(pc,t){ return WORN_STATS[t.s].n+' +'+Math.round(wornTraitV(pc,t)*100)+'%'; }
function renderBench(){
  var L=document.getElementById('benchlist'), d=document.getElementById('benchdetail'), top, i, pc, c;
  if(!L||!d||!P||trDemo()) return;
  careerStyle('cwbench','#root #benchlist{grid-template-columns:1fr;grid-auto-rows:min-content;align-content:start}#root #benchlist .vcell{aspect-ratio:auto;flex-direction:row;justify-content:space-between;align-items:center;gap:24px;padding:12px 16px;min-height:72px}#benchlist .bnm{font-family:var(--f-cond);font-size:24px;font-weight:700;line-height:1.15}#benchlist .btr{font-size:16px;color:var(--tx-2);margin-top:4px}#benchlist .bpw{font-size:16px;color:var(--tx-2);white-space:nowrap;display:flex;align-items:center;gap:10px;flex:none}#root .bpip{display:inline-block;width:10px;height:10px;margin-left:4px;border:1px solid var(--tx-2);border-radius:50%}#root .bpip.on{background:var(--acc);border-color:var(--acc)}#benchdetail .bline{font-size:16px;color:var(--tx-2);margin:0 0 12px}#benchdetail .btrow{display:flex;align-items:center;justify-content:space-between;gap:12px;margin-bottom:8px}#benchdetail .btrow span{font-size:18px;color:var(--tx-1)}#benchdetail .btrow button{flex:none;min-height:40px;min-width:136px;font-size:16px;padding:0 12px}#benchdetail .vbuy.alt{background:transparent;color:var(--tx-1);border:1px solid var(--ui-line-hi)}');
  walletLine('wallet_gear');
  try{ wornClean(P); }catch(_bw){}
  top=L.scrollTop; L.innerHTML='';
  if(!P.gear.length){
    c=document.createElement('div'); c.className='hint'; c.textContent='no gear'; L.appendChild(c);
    d.innerHTML=''; d.style.display='none'; BENCH_SEL=''; return;
  }
  d.style.display='';
  if(!P.gear.some(function(g){ return g.id===BENCH_SEL; })) BENCH_SEL=P.gear[0].id;
  for(i=0;i<P.gear.length;i++){
    pc=P.gear[i]; c=document.createElement('div');
    c.className='vcell'+(pc.id===BENCH_SEL?' on':''); c.setAttribute('data-g',pc.id);
    c.innerHTML='<div><div class="bnm" data-c="'+WORN_RARS[pc.r].c+'" style="color:'+WORN_RARS[pc.r].c+'">'+escHtml(wornName(pc))+'</div>'+
      '<div class="btr">'+escHtml(pc.tr.map(function(t){ return benchTr(pc,t); }).join('  \u00b7  '))+'</div></div>'+
      '<div class="bpw"><span>power '+pc.pw+'</span><span>'+benchPips(pc)+'</span></div>';
    c.onclick=(function(id){ return function(){ BENCH_SEL=id; benchSelPaint(); benchDetail(); }; })(pc.id);
    L.appendChild(c);
  }
  L.scrollTop=top;
  benchDetail();
}
function benchSelPaint(){ var q=document.querySelectorAll('#benchlist [data-g]'), i; for(i=0;i<q.length;i++) q[i].classList.toggle('on',q[i].getAttribute('data-g')===BENCH_SEL); }
function benchAfter(){ try{ saveProfile(); }catch(_ba){} renderBench(); renderHub(); }
function benchHold(b,fire,ask){
  b.onmousedown=function(e){ if(e&&e.button!==undefined&&e.button!==0) return; craftHoldStart(b,fire); };
  b.onmouseleave=function(){ craftHoldCancel(); };
  b.onclick=function(e){ if(e&&e.detail){ try{ say2('hold to confirm'); }catch(_bh){} return; } ask(); };
}
function benchAsk(q,sub,yes,fire){
  var y=document.getElementById('askyes'), a=document.getElementById('askalt'), n=document.getElementById('askno');
  document.getElementById('askq').textContent=q;
  document.getElementById('asksub').textContent=sub;
  ASKYES=fire; ASKALT=null;
  kitExtraHide();
  if(y) y.textContent=yes; if(a) a.style.display='none'; if(n) n.textContent='not yet';
  ASKBACK='tradermodal';
  openModal('askmodal');
  try{ if(padOn()) padSetFocus(n); }catch(_bq){}
}
function benchDetail(){
  var d=document.getElementById('benchdetail'), pc=null, i, h, m, k, mix=[], sale, b, roll;
  for(i=0;i<P.gear.length;i++) if(P.gear[i].id===BENCH_SEL) pc=P.gear[i];
  if(!d||!pc) return;
  sale=wornSalePrice(pc); m=wornSalvMix(pc); roll=wornRerollRoll(pc);
  h='<div class="vpills"><span class="vpill">'+escHtml(WORN_KINDS[pc.k].n)+'</span><span class="vpill r">'+escHtml(WORN_RARS[pc.r].id)+'</span></div>'+
    '<h4 style="color:'+WORN_RARS[pc.r].c+'">'+escHtml(wornName(pc))+'</h4>'+
    '<div class="bline">power '+pc.pw+'  '+benchPips(pc)+'</div><div class="crlab">traits</div><div id="benchtr"></div><div class="crlab">salvage</div>';
  for(k in m) mix.push('<div class="cres">'+iconImgHTML(k,30,1)+'<span class="crn">'+escHtml(String(ITEMS[k].name).toLowerCase())+'</span><span class="crv">x'+m[k]+'</span></div>');
  d.innerHTML=h+mix.join('');
  var host=document.getElementById('benchtr');
  pc.tr.forEach(function(t,ti){
    var r=document.createElement('div'), n=document.createElement('span'), rb=document.createElement('button'), price=wornRerollPrice(pc);
    r.className='btrow'; n.textContent=benchTr(pc,t); rb.id='bench_rr_'+ti; rb.type='button';
    rb.textContent=roll?('reroll $'+price.toLocaleString()):'no other trait'; rb.disabled=!roll;
    rb.onclick=function(){
      var got=wornReroll(P,pc.id,ti);
      if(got<0){ say2('not enough $'); try{ sfx('clank'); }catch(_br){} return; }
      if(got>0){ try{ sndUi('ok'); }catch(_bo){} benchAfter(); }
    };
    r.appendChild(n); r.appendChild(rb); host.appendChild(r);
  });
  function doSell(){ var c=wornSell(P,pc.id); if(!c) return; say2('sold  +$'+c.toLocaleString()); try{ sndUi('ok'); }catch(_bs){} benchAfter(); }
  function doSalv(){ var q=wornSalvage(P,pc.id); if(!q) return; say2('salvaged'); try{ sndUi('ok'); }catch(_bv){} benchAfter(); }
  b=document.createElement('button'); b.id='bench_sell'; b.type='button'; b.className='vbuy'; b.textContent='hold to sell  $'+sale.toLocaleString();
  benchHold(b,doSell,function(){ benchAsk('sell '+wornName(pc)+'?','+$'+sale.toLocaleString(),'sell',doSell); });
  d.appendChild(b);
  b=document.createElement('button'); b.id='bench_salvage'; b.type='button'; b.className='vbuy alt'; b.textContent='hold to salvage';
  benchHold(b,doSalv,function(){ benchAsk('salvage '+wornName(pc)+'?','the piece is gone','salvage',doSalv); });
  d.appendChild(b);
}

// ================================================================ wiring
// v6.11: the same door as the lift on the floor. This called startRaid() directly,
'@

SubRx @'
var VER='37.41';
'@ @'
var VER='37.42';
'@

$pat = "(?m)^  now:'v37\.41:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.42: the trader has a gear tab beside craft: every stash piece with name in rarity colour, power, pips and traits; each trait has a reroll button with its price, a quarter of the sale value and up by half each time; hold to sell pays the sale price and counts in lifetime earnings; hold to salvage gives 2, 4, 8 or 14 materials worth about 80 percent of a sale; keys and pad get a confirm card; worn pieces are not offered; net worth counts gear in the stash and worn; never in the demo Check 37.42 fails on v37.41',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
