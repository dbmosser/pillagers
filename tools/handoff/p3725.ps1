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

# SEASON ZERO M1: NO CASH IN RAIDS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function mfPayPer(){ return (P.racks||0)*RACK_PAY + arrayCount()*ARRAY_PAY; }
'@ @'
function mfPayPer(){ return (P.racks||0)*RACK_PAY + arrayCount()*ARRAY_PAY; }
// v37.xx (cw-m1nocash), HIS RULINGS OF 11-01 (season zero m1): "no cash in riads, keep it like a credit card"; "it shouldn't pay cash beyond just
// selling what you have and maybe some sort of bonus"; contracts "pay in gear and items to sell"; racks "make them pay materials instead of $".
// Two fills, both without dice (no RNGS, no FXS), so nothing seeded moves and the board can show exactly what a claim pays:
// payItemsFor(v) is salvage worth about v, the dearest that fits first and the four materials last (the survivor, raid goals, contracts);
// rackMatsFor(v) is the four rack parts worth about v, taken in turn (board, cell, wire, scrap) so a payout is a mix.
var PAY_POOL=['blackbox','titan','core','servo','optic','board','cell','wire','scrap'], RACK_MATS=['board','cell','wire','scrap'];
function payItemsFor(v){
  var out=[], rem=Math.round(+v||0), i, k, c;
  for(i=0;i<PAY_POOL.length&&out.length<16;i++){ k=PAY_POOL[i]; c=ival(k); if(!(c>0)) continue; while(rem>=c&&out.length<16){ out.push(k); rem-=c; } }
  return out;
}
function rackMatsFor(v){
  var out=[], rem=Math.round(+v||0), i=0, miss=0, k, c;
  while(miss<RACK_MATS.length&&out.length<400){ k=RACK_MATS[i%RACK_MATS.length]; i++; c=ival(k); if(c>0&&c<=rem){ out.push(k); rem-=c; miss=0; } else miss++; }
  return out;
}
function keysWorth(L){ var t=0, i; for(i=0;i<(L||[]).length;i++) t+=ival(L[i]); return t; }
function keysLine(L){
  var n={}, o=[], i, k;
  for(i=0;i<(L||[]).length;i++){ k=L[i]; if(!n[k]){ n[k]=0; o.push(k); } n[k]++; }
  return o.map(function(q){ return String(ITEMS[q]?ITEMS[q].name:q).toLowerCase()+(n[q]>1?(' x'+n[q]):''); }).join(', ');
}
// What a contract pays besides its gear: salvage worth about its old $ reward.
function contractPayKeys(c){ return payItemsFor((c&&typeof c.reward==='number'&&c.reward>0)?c.reward:0); }
// HIS PICK (answer 36): the extraction bonus is about 10% of the haul's value.
var EXTRACT_BONUS=0.10;
function extractBonusFor(v){ return Math.round(Math.max(0,+v||0)*EXTRACT_BONUS); }
'@

SubRx @'
  var pay=ri(900,1500);
  P.credits+=pay;
  G.strayPaid=(G.strayPaid||0)+pay;
  var gift=pick(['titan','core','optic','servo']);
  try{ grantLoot(mkContainer(e.x,e.y,'crate'),[gift]); G.strayGave=gift; }catch(_sg){}
'@ @'
  var pay=ri(900,1500);
  // v37.xx (cw-m1nocash), his 11-01 ruling ("no cash in riads"): the same roll is paid in salvage of about that value into the backpack, beside
  // his gift, through the one grant; no $. A death loses it with the backpack.
  var _sPay=payItemsFor(pay), _sq;
  var gift=pick(['titan','core','optic','servo']);
  try{ grantLoot(mkContainer(e.x,e.y,'crate'),[gift].concat(_sPay)); G.strayGave=gift; }catch(_sg){}
  G.strayPaid=(G.strayPaid||0)+keysWorth(_sPay)+(G.strayGave?ival(gift):0);
'@

SubRx @'
  if(G.strayGave) pickTag(gift,'FROM THE SURVIVOR');
  say('+'+'$'+pay.toLocaleString(),'pick',{tag:'FROM THE SURVIVOR',c:'gain'});
'@ @'
  if(G.strayGave){ pickTag(gift,'FROM THE SURVIVOR'); for(_sq=0;_sq<_sPay.length;_sq++) pickTag(_sPay[_sq],'FROM THE SURVIVOR'); }
'@

SubRx @'
  label(e.x,e.y-34,'+$'+pay,'#ffc04a',0.35,false);
'@ @'

'@

SubRx @'
  return Math.round(pedBuyRate()*100)+'% of value, paid now. You still have to walk it out.';
'@ @'
  return Math.round(pedBuyRate()*100)+'% of value, banked now';   // v37.xx (cw-m1nocash): banked at the sale, a death keeps it
'@

SubRx @'
  G.pedCarry=(G.pedCarry||0)+tot;
'@ @'
  // v37.xx (cw-m1nocash), HIS RULING OF 11-01: "no cash in riads, keep it like a credit card". The stall pays straight onto the account at the
  // sale, so a death never takes it, and it counts in lifetime earnings. Nothing in a raid holds money (G.pedCarry stays 0). A sim raid touches no P.
  if(!G.sim&&P){ P.credits=(P.credits||0)+tot; lifeEarnAdd(tot); try{ saveProfile(); }catch(_psv){} }
'@

SubRx @'
    say('+'+'$'+tot.toLocaleString(),'pick',{tag:'CARRIED',c:'gain'});
'@ @'
    say('+'+'$'+tot.toLocaleString(),'pick',{tag:'BANKED',c:'gain'});   // v37.xx (cw-m1nocash): banked at the sale, so not CARRIED
'@

SubRx @'
    var _mfPay=mfPayPer();
    P.credits+=_mfPay;
'@ @'
    var _mfPay=mfPayPer();
    // v37.xx (cw-m1nocash), HIS RULING OF 11-01 on racks: "make them pay materials instead of $". The same value, in rack parts, to the stash.
    var _mfMats=rackMatsFor(_mfPay), _mfi;
    for(_mfi=0;_mfi<_mfMats.length;_mfi++) P.stash.push(_mfMats[_mfi]);
'@

SubRx @'
    _mfLine='<span style="color:var(--ash)">Mainframe server bonus: $'+
      _mfPay.toLocaleString()+'</span>';
'@ @'
    _mfLine='<span style="color:var(--ash)">mainframe parts: '+escHtml(keysLine(_mfMats))+'</span>';   // v37.xx (cw-m1nocash): parts, not $
'@

SubRx @'
      var cut=Math.round(mhaul*0.10);
      P.credits+=cut;
'@ @'
      var cut=Math.round(mhaul*0.10);
      P.credits+=cut; lifeEarnAdd(cut);   // v37.xx (cw-m1nocash): every $ earned counts in lifetime earnings
'@

SubRx @'
        var cut2=Math.round((_mrow.val||0)*0.10);
        P.credits+=cut2;
'@ @'
        var cut2=Math.round((_mrow.val||0)*0.10);
        P.credits+=cut2; lifeEarnAdd(cut2);   // v37.xx (cw-m1nocash)
'@

SubRx @'
  if(G.strayPaid){
    // v11.86, HIS NOTE: no "already banked"; and the gift, on the card of a run
    // that brought it home (a death or an abandonment lost the bag it went into).
    lines.push('<span style="color:var(--coolant)">The survivor paid you '+'$'+G.strayPaid.toLocaleString()+
      (how==='extract'&&G.strayGave&&ITEMS[G.strayGave]?' and gave you a '+escHtml(ITEMS[G.strayGave].name):'')+'.</span>');
  }
  if(G.pedSold){
    lines.push(how==='extract'
      ?'<span style="color:var(--coolant)">Stall money carried out: '+'$'+(G.pedCarry||0).toLocaleString()+', banked.</span>'
      :(how==='dead'
        ?'<span style="color:var(--rust)">Stall money lost where you fell: '+'$'+(G.pedCarry||0).toLocaleString()+'.</span>'
        // v13.77, downed and extraction audit: an abandoned run did not fall anywhere.
        :'<span style="color:var(--rust)">Stall money left behind: '+'$'+(G.pedCarry||0).toLocaleString()+'.</span>'));
  }
'@ @'
  // v37.xx (cw-m1nocash): the survivor pays salvage into the backpack, so his gift is on the card of a run that brought it home.
  if(G.strayPaid&&how==='extract') lines.push('<span style="color:var(--coolant)">survivor gift worth $'+G.strayPaid.toLocaleString()+'</span>');
  // v37.xx (cw-m1nocash): the stall banks at the sale, so every outcome kept it.
  if(G.pedSold) lines.push('<span style="color:var(--coolant)">stall sales $'+G.pedSold.toLocaleString()+' banked</span>');
'@

SubRx @'
    if(G.pedCarry&&!G.sim){ P.credits+=G.pedCarry; }
'@ @'
    // v37.xx (cw-m1nocash): no stall money rides the raid any more; it was banked at the sale.
'@

SubRx @'
    lines.push('You extracted with '+Math.round(G.player.hp)+' of 100 health');
'@ @'
    // v37.xx (cw-m1nocash), HIS PICK OF 11-01 (answer 36): an extraction pays a bonus of about 10% of the haul's value, the value this card just
    // said was secured, straight onto the account and into lifetime earnings. A death or an abandon never reaches this branch, so pays none.
    var _xb=extractBonusFor(_secV);
    if(_xb>0){ P.credits=(P.credits||0)+_xb; lifeEarnAdd(_xb); lines.push('<span style="color:var(--amber)">extraction bonus +$'+_xb.toLocaleString()+'</span>'); }
    if(G.tel) G.tel.extBonus=_xb;
    lines.push('You extracted with '+Math.round(G.player.hp)+' of 100 health');
'@

SubRx @'
function runEarnings(rec){ return ((rec.outcome==='extract')?((rec.haul||0)+(rec.pedSold||0)):0)-(rec.carriedIn||0)-(rec.kitSold||0); }
'@ @'
// v37.xx (cw-m1nocash): a stall sale is banked at the sale since this build (pedBank on the row), so it counts whatever the outcome; an older row as before.
function runEarnings(rec){ return ((rec.outcome==='extract')?(rec.haul||0):0)+((rec.outcome==='extract'||rec.pedBank)?(rec.pedSold||0):0)-(rec.carriedIn||0)-(rec.kitSold||0); }
'@

SubRx @'
    pedSold:T.pedSold||0,pedKilled
'@ @'
    pedSold:T.pedSold||0,pedBank:1,pedKilled
'@

SubRx @'
    var _pgv=ival('gun_'+g.k);
    if(_pgv>0){ P.credits=(P.credits||0)+_pgv;
      return WEAPONS[g.k].name+', already yours, so its value of '+'$'+_pgv.toLocaleString()+' instead'; }
'@ @'
    // v37.xx (cw-m1nocash), his 11-01 ruling (contracts "pay in gear and items to sell"): no $; the spare goes to the stash, to sell or keep.
    if(ITEMS['gun_'+g.k]){ P.stash.push('gun_'+g.k);
      return WEAPONS[g.k].name+', a spare to the stash'; }
'@

SubRx @'
  // v5.78: a contract pays money, not standing.
  P.credits+=c.reward;
'@ @'
  // v37.xx (cw-m1nocash), HIS RULING OF 11-01: contracts "pay in gear and items to sell". Salvage worth about its old $ reward goes to the
  // stash (contractPayKeys, no dice, so the board shows exactly this), with the gear it carries. No $.
  var _ck=contractPayKeys(c), _cq;
  for(_cq=0;_cq<_ck.length;_cq++) P.stash.push(_ck[_cq]);
'@

SubRx @'
  return {pay:c.reward, gear:got};
'@ @'
  return {pay:keysWorth(_ck), gear:got, items:_ck};
'@

SubRx @'
  var got=0,total=0,gear=[];
'@ @'
  var got=0,total=0,gear=[],items=[];
'@

SubRx @'
    got++; total+=r.pay; if(r.gear) gear.push(r.gear);
'@ @'
    got++; total+=r.pay; items=items.concat(r.items||[]); if(r.gear) gear.push(r.gear);
'@

SubRx @'
  say2(got+' contract'+(got===1?'':'s')+' paid: '+'$'+total.toLocaleString()+
       (gear.length?(' and '+gear.join(', ')):'')+'.');
'@ @'
  say2(got+' contract'+(got===1?'':'s')+' paid: '+keysLine(items)+(gear.length?(', '+gear.join(', ')):''));   // v37.xx (cw-m1nocash): items, no $
'@

SubRx @'
        say2('Contract paid: '+'$'+r.pay.toLocaleString()+''+(r.gear?' and '+r.gear:'')+'.');
'@ @'
        say2('contract paid: '+keysLine(r.items||[])+(r.gear?', '+r.gear:''));   // v37.xx (cw-m1nocash): items, no $
'@

SubRx @'
    st.innerHTML=Math.min(c.prog,c.n)+' / '+c.n+' &middot; <b>'+'$'+c.reward.toLocaleString()+'</b>';
'@ @'
    st.innerHTML=Math.min(c.prog,c.n)+' / '+c.n+' &middot; <b>worth '+'$'+c.reward.toLocaleString()+'</b>';   // v37.xx (cw-m1nocash): it pays items of that worth
'@

SubRx @'
  money.innerHTML='$'+(c.reward||0).toLocaleString();
'@ @'
  money.innerHTML='worth $'+(c.reward||0).toLocaleString();   // v37.xx (cw-m1nocash): the items below are worth this
'@

SubRx @'
  var gks=gearKeys(c.gear),seen={};
'@ @'
  var gks=gearKeys(c.gear).concat(contractPayKeys(c)),seen={};   // v37.xx (cw-m1nocash): and the salvage the claim pays
'@

SubRx @'
    cell.title=((c.gear&&(c.gear.kind==='wep'||c.gear.kind==='key'))?
'@ @'
    cell.title=((c.gear&&(c.gear.kind==='wep'||c.gear.kind==='key')&&PAY_POOL.indexOf(gkey)<0)?
'@

SubRx @'
      else R.cash+=(gl.chip|0)*5;
    } else R.cash+=(gl.chip|0)*5;
'@ @'
      else R.items=R.items.concat(payItemsFor((gl.chip|0)*5));
    } else R.items=R.items.concat(payItemsFor((gl.chip|0)*5));   // v37.xx (cw-m1nocash): salvage of the old $ value, banked on extraction, lost on a death
'@

SubRx @'
  return goalPaysItem(gl)?'bonus loot':('$'+((gl.chip|0)*5).toLocaleString());
'@ @'
  return goalPaysItem(gl)?'bonus loot':'bonus salvage';   // v37.xx (cw-m1nocash): no $ in a raid
'@

SubRx @'
    k=R.items[i]; bankItem(k); G.goalPaid.value+=ival(k);
    lines.push('<span class="goalreward">run goals '+escHtml(ITEMS[k].name.toLowerCase())+'</span>');
  }
'@ @'
    k=R.items[i]; bankItem(k); G.goalPaid.value+=ival(k);
  }
  if(R.items.length) lines.push('<span class="goalreward">run goals '+escHtml(keysLine(R.items))+'</span>');   // v37.xx (cw-m1nocash): one line for the lot
'@

SubRx @'
  say('Array '+P.arrays+' comes online. The wall is clear again, and it pays $'+
'@ @'
  say('Array '+P.arrays+' comes online. The wall is clear again, and it pays parts worth $'+
'@

SubRx @'
  say('Rack '+P.racks+' hums to life. '+'$'+mfPayPer().toLocaleString()+' every time you make it home.'+
'@ @'
  say('Rack '+P.racks+' hums to life. Parts worth '+'$'+mfPayPer().toLocaleString()+' every time you make it home.'+
'@

SubRx @'
' per extraction</span>'
'@ @'
' in parts per extraction</span>'
'@

SubRx @'
var VER='37.24';
'@ @'
var VER='37.25';
'@

$pat = "(?m)^  now:'v37\.24:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.25: an extraction pays a bonus of 10 percent of the secured haul onto the account and into lifetime earnings, shown as extraction bonus on the card; a death or a walk out pays none; the stall banks a sale at once so a death keeps it; the survivor and the raid goals pay salvage of the same value instead of money; a contract pays salvage worth its old reward plus its gear, and a gun you own comes as a spare to the stash; racks and arrays pay rack parts worth what they paid; hire cuts count in lifetime earnings Check 37.25 fails on v37.24',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
