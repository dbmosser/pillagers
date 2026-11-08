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

# SEASON ZERO M3: GEAR FROM THE SELLER, WIRT, CONTRACTS, RANKS AND THE KIT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  return sum>0.01?'better':(sum<-0.01?'worse':'even');
}
'@ @'
  return sum>0.01?'better':(sum<-0.01?'worse':'even');
}
// v37.xx (cw-m3shop), HIS RULINGS OF 11-01 (season zero m3, plan "worn gear"): gear from home. The seller stocks gear up to rare (answer 65); Wirt: "no i like it just
// add worn gear" (answer 45); contracts pay in gear and items to sell (answer 34); a reward at every rank, gear crates among them; the privileged kit wears a sound armor
// piece (open question 2 default). THE ONE DOOR for a piece made at home: kind k (any kind when k is not one), rarity r, power from wornDropPw, all on its own dice
// (wornRand), never RNGS or FXS, so seed 4242 never moves. It goes to P.gear and its key is registered, so the gamble log can show it. Never in the demo.
function wornSeedNow(){ return ((Math.random()*4294967296)^Date.now())>>>0; }
function wornGiftKey(k,r,seed){
  var R=wornRand(seed>>>0), kinds=Object.keys(WORN_KINDS);
  if(!Object.prototype.hasOwnProperty.call(WORN_KINDS,k)) k=kinds[Math.floor(R()*kinds.length)];
  return wornKeyOf(k,Math.max(0,Math.min(3,r|0)),wornDropPw(k,R),(R()*4294967296)>>>0);
}
function wornGift(p,k,r,seed){
  var key, q, pc;
  if(!p||trDemo()) return null;
  key=wornGiftKey(k,r,seed===undefined?wornSeedNow():seed); q=key.split('_');
  pc=wornMake(q[1],+q[2],+q[3],+q[4]);
  if(!pc||!wornAdd(p,pc)) return null;
  wornItemEnsure(key);
  return {pc:pc,key:key};
}
// THE SELLER: a few pieces a day after the stock, scrap to rare, the same all day like the market (rolled from the local day on wornRand and kept in P.gearShop with
// what was bought, so a reload or a better piece never rerolls the day), at about twice the sale price, $ only. Never in the demo.
var WORN_SHOP_N=4, WORN_SHOP_ODDS=[55,33,12];   // scrap, sound, rare, percent: never above rare
function wornShopPrice(pc){ return Math.max(10,Math.round(wornPrice(pc)*2*CFG.lootMult/10)*10); }
function wornShopGet(){
  var d, S, R, kinds, i, n, r, k, s=[];
  if(!P||trDemo()) return null;
  d=mktDay(); S=P.gearShop;
  if(!S||typeof S!=='object'||S.d!==d||!Array.isArray(S.s)||!Array.isArray(S.b)){
    R=wornRand((Math.imul(d|0,0x9E3779B1)^0x5E11)>>>0); kinds=Object.keys(WORN_KINDS);
    for(i=0;i<WORN_SHOP_N&&kinds.length;i++){
      k=kinds.splice(Math.floor(R()*kinds.length),1)[0];
      n=R()*100; for(r=0;r<2&&n>=WORN_SHOP_ODDS[r];r++) n-=WORN_SHOP_ODDS[r];
      s.push({k:k,r:r,pw:wornDropPw(k,R),sd:(R()*4294967296)>>>0});
    }
    S=P.gearShop={d:d,s:s,b:[]};
  }
  return S;
}
function wornShopPc(q){ return (q&&Object.prototype.hasOwnProperty.call(WORN_KINDS,q.k)&&(q.r===0||q.r===1||q.r===2))?wornMake(q.k,q.r,q.pw|0,q.sd>>>0):null; }
// Today's pieces not yet bought, as the rows after SHOP: {kind:'gear', k (the piece key), i (its place in the day), pc, price}.
function wornShopList(){
  var S=wornShopGet(), L=[], i, q, pc, it;
  for(i=0;S&&i<S.s.length;i++){
    q=S.s[i]; pc=(S.b.indexOf(i)<0)?wornShopPc(q):null; if(!pc) continue;
    it=wornItemEnsure(wornKeyOf(pc.k,pc.r,pc.pw,q.sd>>>0)); if(!it) continue;
    L.push({kind:'gear',k:wornKeyOf(pc.k,pc.r,pc.pw,q.sd>>>0),i:i,pc:it.pc,price:wornShopPrice(it.pc),rep:0});
  }
  return L;
}
function shopListNow(){ return SHOP.concat(wornShopList()); }
// Buy piece i of the day: exactly its shown price; it goes to P.gear and leaves the counter for the day. Spending: lifetime earnings are not touched.
function wornShopBuy(i){
  var S=wornShopGet(), pc, c;
  if(!S||S.b.indexOf(i)>=0) return null;
  pc=wornShopPc(S.s[i]); if(!pc) return null;
  c=wornShopPrice(pc);
  if((+P.credits||0)<c) return null;
  P.credits-=c; S.b.push(i);
  return wornAdd(P,pc);
}
// The traits and the tip on the counter panel, before he buys.
function wornShopDetail(pc){
  var v=wornTip(pc,P), st='font-size:15px;padding:4px 0;border-bottom:1px solid #ddd5c4', s='<div class="vstat" style="'+st+'"><span>power</span><b>'+pc.pw+'</b></div>', i;
  for(i=0;i<pc.tr.length;i++) s+='<div class="vstat" style="'+st+'"><span>'+escHtml(WORN_STATS[pc.tr[i].s].n)+'</span><b>+'+Math.round(wornTraitV(pc,pc.tr[i])*100)+'%</b></div>';
  s+='<div class="vstat" style="'+st+'"><span>vs worn</span><b style="color:'+(v==='better'?UIC.ok:(v==='worse'?UIC.danger:HUDC.dim))+'">'+v+'</b></div>';
  return '<div class="vstats" style="margin:-4px 0 18px">'+s+'</div>';
}
// WIRT: worn gear joins his prizes (GAMBLE_POOL: one piece key per rarity at weights 4, 4, 3 and 1, so 12 in 112, about one roll in 9), in the same odds rows. The
// key only names the rarity: the roll makes a new piece of it, any kind, into P.gear, and returns that piece's key for his log. Price, voice and lot are unchanged.
function wornGambleWin(key){
  var g;
  if(!wornKeyIs(key)) return key;
  g=wornGift(P,'',+key.split('_')[2]);
  return g?g.key:'scrap';
}
// CONTRACTS: about one card in three names a piece as kind and rarity (more on the hard ones); its power is rolled at the claim. Its own dice, never rr(), so the
// board's other rolls are the same. Cards already on the board keep what they paid.
var WORN_CON_CH={std:0.3,hard:0.45,elite:0.6}, WORN_CON_ODDS={std:[35,50,15,0],hard:[0,55,40,5],elite:[0,25,60,15]};
function wornConRoll(c){
  var t, R, O, n, r, kinds;
  if(!c||trDemo()) return c;
  t=Object.prototype.hasOwnProperty.call(WORN_CON_CH,c.tier)?c.tier:'std'; R=wornRand(wornSeedNow());
  if(R()>=WORN_CON_CH[t]) return c;
  O=WORN_CON_ODDS[t]; n=R()*100; for(r=0;r<3&&n>=O[r];r++) n-=O[r];
  kinds=Object.keys(WORN_KINDS); c.wg={k:kinds[Math.floor(R()*kinds.length)],r:r};
  return c;
}
function wornConOk(c){ var w=c&&c.wg; return !!(w&&Object.prototype.hasOwnProperty.call(WORN_KINDS,w.k)&&(w.r===0||w.r===1||w.r===2||w.r===3)); }
function wornConTxt(c){ return wornConOk(c)?('gear: '+WORN_RARS[c.wg.r].id+' '+WORN_KINDS[c.wg.k].n):''; }
// THE PRIVILEGED KIT: its sound armor piece, on dice from the generation, worn at once on an empty armor slot, else into the gear.
function wornKitPiece(p,w,gen){
  var g=wornGift(p,w.k,w.r,(Math.imul((gen|0)+1,0x9E3779B1)^0x4B17)>>>0), sl;
  if(!g) return null;
  sl=WORN_KINDS[g.pc.k].slots[0];
  if(!p.worn[sl]) wornWear(p,g.pc.id,sl);
  return g.pc;
}
'@

SubRx @'
    s.appendChild(row);
  });
  renderShopGrid();
}
'@ @'
    s.appendChild(row);
  });
  wornShopList().forEach(function(o){   // v37.xx (cw-m3shop): today's gear
    var row=document.createElement('div'); row.className='row'; row.setAttribute('data-wg',o.i);
    var nm=document.createElement('div'); nm.className='nm'; nm.textContent=wornName(o.pc);
    var vl=document.createElement('div'); vl.className='vl'; vl.textContent='$'+o.price.toLocaleString();
    var b=document.createElement('button'); b.textContent='buy'; b.disabled=P.credits<o.price;
    b.onclick=function(){
      var pc=wornShopBuy(o.i);
      if(!pc) return;
      shopBought(wornName(pc),o.price,'in your gear.');
      saveProfile(); renderShop(); renderHub();
    };
    row.appendChild(iconImg(o.k,26,1)); row.appendChild(nm); row.appendChild(vl); row.appendChild(b);
    s.appendChild(row);
  });
  renderShopGrid();
}
'@

SubRx @'
  if(P._shopSel===undefined||P._shopSel>=SHOP.length) P._shopSel=0;
  SHOP.forEach(function(o,i){
'@ @'
  var _sl=shopListNow();   // v37.xx (cw-m3shop): the stock, then today's gear
  if(P._shopSel===undefined||P._shopSel>=_sl.length) P._shopSel=0;
  _sl.forEach(function(o,i){
'@

SubRx @'
+(shopStocked(o)?'':' sold');   // v26.xx (career6)   // v21.46
'@ @'
+(shopStocked(o)?'':' sold')+(o.kind==='gear'?' wg':'');   // v26.xx (career6)   // v21.46
'@

SubRx @'
  var o=SHOP[P._shopSel]; if(!o){ d.innerHTML=''; return; }
'@ @'
  var o=shopListNow()[P._shopSel]; if(!o){ d.innerHTML=''; return; }   // v37.xx (cw-m3shop)
'@

SubRx @'
  var cat=(o.kind==='wep')?'WEAPON':
'@ @'
  var cat=(o.kind==='gear')?WORN_KINDS[o.pc.k].n:(o.kind==='wep')?'WEAPON':
'@

SubRx @'
  var rar=shopEntryRarity(o);
'@ @'
  var rar=(o.kind==='gear')?WORN_RARS[o.pc.r].id:shopEntryRarity(o);
'@

SubRx @'
  } else {
    var it=ITEMS[o.k];
    h+='<div class="vdesc">'+escHtml(it?(itemBlurb(o.k)||''):'')+'</div>';
'@ @'
  } else if(o.kind==='gear'){
    h+=wornShopDetail(o.pc);   // v37.xx (cw-m3shop): power, traits and the tip before he buys
  } else {
    var it=ITEMS[o.k];
    h+='<div class="vdesc">'+escHtml(it?(itemBlurb(o.k)||''):'')+'</div>';
'@

SubRx @'
  var stackable=(o.kind!=='wep');
'@ @'
  var stackable=(o.kind!=='wep'&&o.kind!=='gear');
'@

SubRx @'
function shopStocked(o){ return !xfL('xfShop')||!o||
'@ @'
function shopStocked(o){ return !xfL('xfShop')||!o||o.kind==='gear'||
'@

SubRx @'
  ['blackbox',4],['relay',4],['codex',4],['reactor',4],['bloom',4]
];
'@ @'
  ['blackbox',4],['relay',4],['codex',4],['reactor',4],['bloom',4],
  ['wg_ring_0_1_1',4],['wg_ring_1_1_1',4],['wg_ring_2_1_1',3],['wg_ring_3_1_1',1]   // v37.xx (cw-m3shop), his answer 45: worn gear, a piece of that rarity (wornGambleWin)
];
(function(){ var i; for(i=0;i<GAMBLE_POOL.length;i++) if(wornKeyIs(GAMBLE_POOL[i][0])) wornItemEnsure(GAMBLE_POOL[i][0]); })();
'@

SubRx @'
  key=rvKey(key,_gf);   // v26.30 (rarvar2): a gun out of the gamble is the twin one time in five, decided by where the pick fell
  P.stash.push(key);
'@ @'
  key=rvKey(key,_gf);   // v26.30 (rarvar2): a gun out of the gamble is the twin one time in five, decided by where the pick fell
  key=wornGambleWin(key);   // v37.xx (cw-m3shop): a piece goes to the gear, not the stash
  if(!wornKeyIs(key)) P.stash.push(key);
'@

SubRx @'
  for(var i=0;i<log.length;i++){
    var it=ITEMS[log[i]];
'@ @'
  for(var i=0;i<log.length;i++){
    var it=wornItemEnsure(log[i]);   // v37.xx (cw-m3shop): a piece shows like any prize, in its rarity colour
'@

SubRx @'
      c.tier=t; c.reward=Math.round(c.reward*M.r); c.gear=rollGear(t);
'@ @'
      c.tier=t; c.reward=Math.round(c.reward*M.r); c.gear=rollGear(t); wornConRoll(c);   // v37.xx (cw-m3shop)
'@

SubRx @'
  c.reward=Math.round(c.reward*M.r);
  c.gear=rollGear(t);
  return c;
'@ @'
  c.reward=Math.round(c.reward*M.r);
  c.gear=rollGear(t);
  wornConRoll(c);   // v37.xx (cw-m3shop): about one card in three names a piece
  return c;
'@

SubRx @'
  var got=payGear(c.gear);
  var TT2=CTIER[c.tier]||CTIER.std;
'@ @'
  var got=payGear(c.gear);
  var _wgc=wornConOk(c)?wornGift(P,c.wg.k,c.wg.r):null;   // v37.xx (cw-m3shop): the piece the card names, its power rolled now
  if(_wgc) got=(got?got+', ':'')+wornName(_wgc.pc);
  var TT2=CTIER[c.tier]||CTIER.std;
'@

SubRx @'
      gd.textContent='Pays: '+gl;
'@ @'
      gd.textContent='Pays: '+gl+(wornConTxt(c)?('  \u00b7  '+wornConTxt(c)):'');   // v37.xx (cw-m3shop)
'@

SubRx @'
  var gks=gearKeys(c.gear).concat(contractPayKeys(c)),seen={};   // v37.xx (cw-m1nocash): and the salvage the claim pays
'@ @'
  var gks=gearKeys(c.gear).concat(contractPayKeys(c)),seen={};   // v37.xx (cw-m1nocash): and the salvage the claim pays
  if(wornConOk(c)&&wornItemEnsure(wornKeyOf(c.wg.k,c.wg.r,1,1))) gks.push(wornKeyOf(c.wg.k,c.wg.r,1,1));   // v37.xx (cw-m3shop): the piece by kind and rarity
'@

SubRx @'
    cell.title=((c.gear&&(c.gear.kind==='wep'
'@ @'
    cell.title=wornKeyIs(gkey)?wornConTxt(c):((c.gear&&(c.gear.kind==='wep'
'@

SubRx @'
  {n:'sacker i',      need:265000,  rw:{k:'cash',v:4500}},
'@ @'
  // v37.xx (cw-m3shop): a gear crate every third rank from sacker i, {k:'gear', g kind, r rarity}, paid as one piece into the gear (wornGift)
  {n:'sacker i',      need:265000,  rw:{k:'gear',g:'armor',r:1}},
'@

SubRx @'
  {n:'sacker iv',     need:380000,  rw:{k:'kit',l:'data core',v:['core','cell','cell']}},
'@ @'
  {n:'sacker iv',     need:380000,  rw:{k:'gear',g:'gloves',r:1}},
'@

SubRx @'
  {n:'reaver ii',     need:518000,  rw:{k:'cash',v:6500}},
'@ @'
  {n:'reaver ii',     need:518000,  rw:{k:'gear',g:'boots',r:2}},
'@

SubRx @'
  {n:'reaver v',      need:682000,  rw:{k:'kit',l:'four plates',v:['plate','plate','plate','plate','medkit','medkit']}},
'@ @'
  {n:'reaver v',      need:682000,  rw:{k:'gear',g:'head',r:2}},
'@

SubRx @'
  {n:'marauder iii',  need:878000,  rw:{k:'cash',v:9000}},
'@ @'
  {n:'marauder iii',  need:878000,  rw:{k:'gear',g:'pack',r:2}},
'@

SubRx @'
  {n:'warlord i',     need:1113000, rw:{k:'kit',l:'war chest',v:['plate','plate','plate','plate','stim','stim','medkit','medkit']}},
'@ @'
  {n:'warlord i',     need:1113000, rw:{k:'gear',g:'amulet',r:3}},
'@

SubRx @'
  {n:'warlord iv',    need:1393000, rw:{k:'cash',v:15000}},
'@ @'
  {n:'warlord iv',    need:1393000, rw:{k:'gear',g:'ring',r:3}},
'@

SubRx @'
function rankRwTxt(w){ if(!w) return '';
'@ @'
function rankRwTxt(w){ if(!w) return ''; if(w.k==='gear') return Object.prototype.hasOwnProperty.call(WORN_KINDS,w.g)?('gear: '+WORN_RARS[Math.max(0,Math.min(3,w.r|0))].id+' '+WORN_KINDS[w.g].n):'gear'; /* v37.xx (cw-m3shop) */
'@

SubRx @'
  else if(w.k==='kit'&&Array.isArray(w.v)){ if(!Array.isArray(P.stash)) P.stash=[];
'@ @'
  else if(w.k==='gear') wornGift(P,w.g,w.r);   // v37.xx (cw-m3shop): a gear crate is one piece
  else if(w.k==='kit'&&Array.isArray(w.v)){ if(!Array.isArray(P.stash)) P.stash=[];
'@

SubRx @'
  priv:{id:'priv',n:'privileged',c:1500,t:'burst carbine, medkit, armor plate',s:'carbine \u00b7 2 items',items:['medkit','plate'],gun:'carbine'}
'@ @'
  priv:{id:'priv',n:'privileged',c:1500,t:'burst carbine, medkit, sound armor',s:'carbine \u00b7 medkit',items:['medkit'],gun:'carbine',wg:{k:'armor',r:1}}   // v37.xx (cw-m3shop): the plate is a sound armor piece now gear exists
'@

SubRx @'
  if(K.gun){ P.credits-=c; P.birthKit=K.id; kitApply('free'); P.kitPick='free'; }   // spending: lifetime earnings are not touched
'@ @'
  if(K.gun){ P.credits-=c; P.birthKit=K.id; kitApply('free'); P.kitPick='free'; }   // spending: lifetime earnings are not touched
  if(K.gun&&K.wg&&c>0) wornKitPiece(P,K.wg,P.pil&&P.pil.gen);   // v37.xx (cw-m3shop): worn at birth, once, when the kit is paid for
'@

SubRx @'
var VER='37.59';
'@ @'
var VER='37.60';
'@

$pat = "(?m)^  now:'v37\.59:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.60: the shop counter has 4 gear pieces a day after its stock, scrap to rare, the same all day, at about twice the sale price, with power, traits and better or worse shown before buying; Wirt can roll a piece of any rarity, 12 in 112 rolls, same price, the other prizes in proportion; about one contract in three names a piece (more on hard and elite), shown as gear: rare gloves, paid at the claim; sacker i, sacker iv, reaver ii, reaver v, marauder iii, warlord i and warlord iv pay a gear crate; the privileged kit wears a sound armor piece at birth (into the gear when armor is already worn), price unchanged; never in the demo Check 37.60 fails on v37.59',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
