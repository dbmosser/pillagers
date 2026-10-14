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

# BELT KEYS: PICK, USE AND KEYCAPS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
||code==='KeyF'||code==='KeyU') return;
'@ @'
||code==='KeyF'||code==='KeyU'||code==='KeyJ') return;
'@

SubRx @'
'KeyX','KeyU','F1','Backspace','ControlLeft','ShiftLeft']
'@ @'
'KeyX','KeyU','KeyJ','F1','Backspace','ControlLeft','ShiftLeft']
'@

SubRx @'
if(dn>=1&&dn<=9){ setHot(dn-1); if(ev) ev.preventDefault(); }
'@ @'
if(dn>=1&&dn<=9){
      // v26.02 (beltkeys), HIS ORDER 2026-10-13: "in each instance, the player should LEAVE THE GUN EQUIPPED and it should just instantly use the
      // item in the slot". Keys 1 to 4 select and draw guns as before. In a raid keys 5 to 9 are INSTANT keys: 5 and 6 throw the grenade on that
      // key, 7 and 8 use the heal on that key, 9 slots a plate, and the gun stays in his hands every time (beltInstant). They move neither the
      // G pick nor the H pick. The Undercroft floor keeps the old pick-the-key meaning of the digits.
      if(dn>GUNKEYS&&!G.hubFloor) beltInstant(dn-1); else setHot(dn-1);
      if(ev) ev.preventDefault();
    }
'@

SubRx @'
  if(code==='KeyU'&&G&&!G.over&&!repeat) cycleThrow();   // v25.xx (keyswap): switch throwable moved from Q (now the crowbar) to U
'@ @'
  if(code==='KeyU'&&G&&!G.over&&!repeat) cycleThrow();   // v25.xx (keyswap): switch throwable moved from Q (now the crowbar) to U
  if(code==='KeyJ'&&G&&!G.over&&!repeat) cycleHeal();   // v26.02 (beltkeys): J picks the next heal on the medical keys, as U picks the next grenade
'@

SubRx @'
['KeyU','switch throwable'],
'@ @'
['KeyU','switch throwable'],['KeyJ','switch medical'],
'@

SubRx @'
'KeyG','KeyU','KeyH']]
'@ @'
'KeyG','KeyU','KeyH','KeyJ']]
'@

SubRx @'
function useBeltHeal(){
  var p=G.player, sl=hotbarSlots(), reach=healReach(p), best=null, anyBelt=false, ci, c, it, bi, a, b;
  if(reach>=p.maxhp){ say((p.healQ>0)?'ALREADY HEALING':'HEALTH FULL'); return false; }
  for(ci=GUNKEYS;ci<HOTBAR_N;ci++){
    if(BELT_CLASS[ci]!=='med') continue;
    c=sl[ci];
    if(!c||c.kind!=='heal'||!(c.count>0)||!ITEMS[c.itemKey]) continue;
    anyBelt=true; it=ITEMS[c.itemKey];
    if(reach>=healCeil(it)) continue;
    if(best){ a=it.amt||0; b=ITEMS[best.itemKey].amt||0; if(a>b||(a===b&&ival(c.itemKey)>=ival(best.itemKey))) continue; }
    best=c;
  }
  if(!best){
    if(anyBelt){ say('BANDAGES STOP AT '+Math.round(healCeil(ITEMS.bandage)),'info',{sub:'You need a Medkit.'}); return false; }
    if(findHeal()>=0){ say('NO HEAL ON BELT','info',{sub:(padOn()?padB('VIEW  BACKPACK'):('['+keyLabel('KeyB','B')+'] BACKPACK'))}); return false; }
    say('NO MEDICAL SUPPLIES');
    return false;
  }
  if(p.prep){ say('ALREADY APPLYING','info',{sub:String(ITEMS[p.prep.key]?ITEMS[p.prep.key].name:'Medical').toUpperCase()}); return false; }
  bi=G.bag.indexOf(best.itemKey);
  if(bi<0) return false;
  G.bag.splice(bi,1); if(!startPrep('heal',best.itemKey)) blip('pick');
  G.tel.heals++;
  spark(p.x,p.y,'#6fe0a0',10,90);
  return true;
}
'@ @'
// v26.02 (beltkeys), HIS ORDER 2026-10-13 ("U = next grenade, G = throw it / J = next heal, H = use it"). The medical keys' non-empty cells,
// in key order: a Bandage, a Medkit or a Stim.
function medCells(sl){
  var out=[], ci, c;
  for(ci=GUNKEYS;ci<HOTBAR_N;ci++){
    if(BELT_CLASS[ci]!=='med') continue;
    c=sl[ci];
    if(c&&(c.kind==='heal'||c.kind==='stim')&&(c.count>0)&&ITEMS[c.itemKey]) out.push(ci);
  }
  return out;
}
// The cheapest heal that can still raise him (v25.xx belt5b): a Bandage stops at its ceiling, a Medkit goes to full, never a Stim. Returns the key
// index (-1 when none helps) and whether the belt holds any heal at all. The belt keycaps and the default pick read this one function.
function beltHealPick(sl,reach){
  var best=-1, anyBelt=false, ci, c, it, a, b;
  for(ci=GUNKEYS;ci<HOTBAR_N;ci++){
    if(BELT_CLASS[ci]!=='med') continue;
    c=sl[ci];
    if(!c||c.kind!=='heal'||!(c.count>0)||!ITEMS[c.itemKey]) continue;
    anyBelt=true; it=ITEMS[c.itemKey];
    if(reach>=healCeil(it)) continue;
    if(best>=0){ a=it.amt||0; b=ITEMS[sl[best].itemKey].amt||0; if(a>b||(a===b&&ival(c.itemKey)>=ival(sl[best].itemKey))) continue; }
    best=ci;
  }
  return {i:best,any:anyBelt};
}
// The medical key H uses: the one J chose (G.msel, an item key) while it is still carried; otherwise the cheapest heal that helps, otherwise the
// first heal on the belt (never a Stim by default; a Stim is used when J chose it). -1 when the belt holds nothing to use.
function medSelIx(sl){
  var cs=medCells(sl), i, pk;
  if(!cs.length) return -1;
  if(G.msel) for(i=0;i<cs.length;i++) if(sl[cs[i]].itemKey===G.msel) return cs[i];
  pk=beltHealPick(sl,healReach(G.player));
  if(pk.i>=0) return pk.i;
  for(i=0;i<cs.length;i++) if(sl[cs[i]].kind==='heal') return cs[i];
  return -1;
}
// J: the next non-empty medical key, round, as U does for the grenades.
function cycleHeal(){
  var sl=hotbarSlots(), cs=medCells(sl), cur=medSelIx(sl), at=-1, i, nx;
  if(!cs.length){ say((findHeal()>=0)?'NO HEAL ON BELT':'NO MEDICAL SUPPLIES'); return false; }
  for(i=0;i<cs.length;i++) if(cs[i]===cur) at=i;
  nx=cs[(at+1)%cs.length];
  G.msel=sl[nx].itemKey;
  say((ITEMS[G.msel].name+' ready').toUpperCase());
  return true;
}
// Tap H: the SELECTED medical item (medSelIx), not the cheapest. ix names a key instead (the digits 7 and 8). A heal is refused at full
// health or past its ceiling and says why; a Stim is used whatever the health.
function useBeltHeal(ix){
  var p=G.player, sl=hotbarSlots(), reach=healReach(p), c, it, bi;
  if(ix===undefined) ix=medSelIx(sl);
  c=(ix>=0)?sl[ix]:null;
  if(c&&c.kind==='stim'&&(c.count>0)&&ITEMS[c.itemKey]) return useStim(G.bag.indexOf(c.itemKey));
  if(reach>=p.maxhp){ say((p.healQ>0)?'ALREADY HEALING':'HEALTH FULL'); return false; }
  if(!c||c.kind!=='heal'||!(c.count>0)||!ITEMS[c.itemKey]){
    if(findHeal()>=0){ say('NO HEAL ON BELT','info',{sub:(padOn()?padB('VIEW  BACKPACK'):('['+keyLabel('KeyB','B')+'] BACKPACK'))}); return false; }
    say('NO MEDICAL SUPPLIES');
    return false;
  }
  it=ITEMS[c.itemKey];
  if(reach>=healCeil(it)){
    if(c.itemKey==='bandage') say('BANDAGES STOP AT '+Math.round(healCeil(ITEMS.bandage)),'info',{sub:'You need a Medkit.'});
    else say((it.name+' stops at '+Math.round(healCeil(it))).toUpperCase());
    return false;
  }
  if(p.prep){ say('ALREADY APPLYING','info',{sub:String(ITEMS[p.prep.key]?ITEMS[p.prep.key].name:'Medical').toUpperCase()}); return false; }
  bi=G.bag.indexOf(c.itemKey);
  if(bi<0) return false;
  G.bag.splice(bi,1); if(!startPrep('heal',c.itemKey)) blip('pick');
  G.tel.heals++;
  spark(p.x,p.y,'#6fe0a0',10,90);
  return true;
}
// The digits 5 to 9 in a raid: the item on that key, at once, with the gun still in his hands. A grenade key throws its grenade through the quick
// throw path (G.tsel is pointed at it for the throw and put back, so the G pick does not move), a medical key uses its item through the path H
// uses (useBeltHeal), key 9 slots a plate as a hold on H does (quickPlate). An empty key gives the usual none line. G.hot never moves.
function beltInstant(i){
  var p=G&&G.player, sl, c, cls=BELT_CLASS[i], ti, sv;
  if(!G||G.sim||G.over||G.paused||G.trade||G.hubFloor||!p||i<GUNKEYS||i>=HOTBAR_N) return false;
  if(p.downed){ say('NOT WHILE DOWN'); return false; }
  if(p.dying||p.specOut) return false;
  sl=hotbarSlots(); c=sl[i];
  if(cls==='throw'){
    ti=(c&&c.kind==='throw'&&c.icon&&(c.count|0)>0)?THROWKEYS.indexOf(c.icon):-1;
    if(ti<0){ say('NO THROWABLE ON KEY '+(i+1)); return false; }
    sv=G.tsel; G.tsel=ti;
    try{ doThrow(); } finally { G.tsel=sv; }
    return true;
  }
  if(cls==='med') return useBeltHeal(i);
  if(cls==='plate') return quickPlate();
  return false;
}
// A click on a grenade or medical key picks it, as U and J do (it used to put the highlight there, so the trigger cooked it); a gun key draws.
function beltPickCell(i){
  var sl, c, ti;
  if(!G||G.hubFloor||G.sim||i<GUNKEYS||i>=HOTBAR_N) return false;
  sl=hotbarSlots(); c=sl[i];
  if(!c) return false;
  if(BELT_CLASS[i]==='throw'&&c.kind==='throw'&&c.icon&&(c.count|0)>0){
    ti=THROWKEYS.indexOf(c.icon); if(ti<0) return false;
    G.tsel=ti; say((c.name+' ready').toUpperCase()); return true;
  }
  if(BELT_CLASS[i]==='med'&&(c.kind==='heal'||c.kind==='stim')&&(c.count|0)>0&&c.itemKey&&ITEMS[c.itemKey]){
    G.msel=c.itemKey; say((c.name+' ready').toUpperCase()); return true;
  }
  return false;
}
'@

SubRx @'
function nextGun(){
  var p=G&&G.player, sl, cur, n=GUNKEYS, k, i;
  if(!G||G.over||G.paused||G.trade||!p||p.downed||p.dying||p.roll>0) return false;
  sl=hotbarSlots(); cur=heldGunCell(sl); if(cur<0) cur=clamp(G.hot||0,0,n-1);
  for(k=1;k<=n;k++){
    i=(cur+k)%n;
    if(!sl[i]||sl[i].kind!=='gun'||sl[i].vacant||sl[i].inHand) continue;
    if(G.hot===i) G.hot=cur;   // setHot ignores the key the highlight is already on
    setHot(i);
    return true;
  }
  return false;
}
'@ @'
// v26.02 (beltkeys): the gun F brings up next, as a pure pick, so the belt can draw the F keycap on it. cur is the key of the gun in hand.
function nextGunCell(sl){
  var n=GUNKEYS, cur=heldGunCell(sl), k, i;
  if(cur<0) cur=clamp(G.hot||0,0,n-1);
  for(k=1;k<=n;k++){
    i=(cur+k)%n;
    if(!sl[i]||sl[i].kind!=='gun'||sl[i].vacant||sl[i].inHand) continue;
    return {i:i,cur:cur};
  }
  return null;
}
function nextGun(){
  var p=G&&G.player, sl, ng;
  if(!G||G.over||G.paused||G.trade||!p||p.downed||p.dying||p.roll>0) return false;
  sl=hotbarSlots(); ng=nextGunCell(sl);
  if(!ng) return false;
  if(G.hot===ng.i) G.hot=ng.cur;   // setHot ignores the key the highlight is already on
  setHot(ng.i);
  return true;
}
'@

SubRx @'
if(!_bagGun) setHot(_HC2.i);
'@ @'
if(!_bagGun&&!beltPickCell(_HC2.i)) setHot(_HC2.i);   // v26.02 (beltkeys): a click on a grenade or medical key picks it, as U and J do
'@

SubRx @'
    if(_gTs.length) _gSel=(_gTs.indexOf(THROWKEYS[G.tsel])>=0)?THROWKEYS[G.tsel]:_gTs[0];
'@ @'
    if(_gTs.length) _gSel=(_gTs.indexOf(THROWKEYS[G.tsel])>=0)?THROWKEYS[G.tsel]:_gTs[0];
    // v26.02 (beltkeys), HIS ORDER 2026-10-13 ("give players keybinds/button glyphs in a contextual manner where possible"): a small keycap on the cell
    // each key acts on right now, recorded as it is drawn (G.beltCaps, like G.hotCells). G on the grenade G throws and U on the other; H on the heal H
    // uses and J on the other; HOLD H on the plate; F on the gun F brings up next; R on the gun in hand when its magazine is empty and he carries rounds.
    // Each prints the key as set (keyLabel); on a controller it prints the pad button where the pad has one for the act, and no cap where it has none.
    var _bcaps=[], _mSel=-1, _nG=-1, _ng;
    G.beltCaps=_bcaps;
    if(state!=='hub'){ _mSel=medSelIx(sl); _ng=nextGunCell(sl); if(_ng) _nG=_ng.i; }
'@

SubRx @'
      if(state!=='hub'&&S.kind==='throw'&&S.icon&&S.icon===_gSel){   // the G keycap on the throwable key G throws
        var _gs=Math.round(bw*0.2), _gkx=bx+LH(4), _gky=hy+bw-LH(5)-_gs;
        ctx.fillStyle='#ffc04a'; ctx.beginPath(); if(ctx.roundRect) ctx.roundRect(_gkx,_gky,_gs,_gs,Math.max(2,_gs*0.2)); else ctx.rect(_gkx,_gky,_gs,_gs); ctx.fill();
        ctx.font=beltFS(bw,0.13); ctx.fillStyle='#1a1408'; ctx.textAlign='center'; ctx.fillText(String(keyLabel('KeyG','G')).slice(0,2),_gkx+_gs/2,_gky+_gs*0.76); ctx.textAlign='left';
      }
'@ @'
      if(state!=='hub'){   // v26.02 (beltkeys): the keycap of the key that acts on this cell (the G cap of v25.xx belt6b, and the rest)
        var _cc='', _cpre='', _cgr=false;
        if(S.kind==='throw'&&S.icon&&_gSel){ if(S.icon===_gSel) _cc='KeyG'; else if((S.count|0)>0){ _cc='KeyU'; _cgr=true; } }
        else if((S.kind==='heal'||S.kind==='stim')&&(S.count|0)>0&&_mSel>=0){ if(q===_mSel) _cc='KeyH'; else { _cc='KeyJ'; _cgr=true; } }
        else if(S.kind==='armor'&&(S.count|0)>0){ _cc='KeyH'; _cpre='HOLD '; }
        else if(S.kind==='gun'&&!S.vacant&&S.icon){ if(_bgHalf&&S.inHand) _cc='KeyR'; else if(q===_nG){ _cc='KeyF'; _cgr=true; } }
        if(_cc&&!(padOn()&&!PADLABEL[_cc])){
          var _ct=_cpre+String(keyLabel(_cc,_cc.slice(3))), _cs=Math.round(bw*0.2), _cw, _ckx=bx+LH(4), _cky;
          _cky=(_gunReal?(hy+bw-LH(4)-Math.max(3,Math.round(bw*0.05))-LH(3)):(hy+bw-LH(5)))-_cs;   // above the magazine bar on a gun key
          ctx.font=beltFS(bw,0.13);
          _cw=Math.min(Math.round(bw*0.62),Math.max(_cs,Math.round(ctx.measureText(_ct).width+_cs*0.6)));
          ctx.fillStyle=_cgr?'#59626b':'#ffc04a'; ctx.beginPath(); if(ctx.roundRect) ctx.roundRect(_ckx,_cky,_cw,_cs,Math.max(2,_cs*0.2)); else ctx.rect(_ckx,_cky,_cw,_cs); ctx.fill();
          ctx.fillStyle=_cgr?'#eef3f7':'#1a1408'; ctx.textAlign='center'; ctx.fillText(_ct,_ckx+_cw/2,_cky+_cs*0.76,_cw-LH(2)); ctx.textAlign='left';
          _bcaps.push({i:q,s:_ct,k:_cc,x:_ckx,y:_cky,w:_cw,h:_cs});
        }
      }
'@

SubRx @'
  if(!padOn()){   // v25.xx (belt6b): and the key of its class
    if(it.use==='throw') o.keys.push([String(keyLabel('KeyG','G')),'THROW']);
    else if(it.use==='heal') o.keys.push([String(keyLabel('KeyH','H')),'HEAL']);
    else if(it.use==='armor') o.keys.push(['HOLD '+String(keyLabel('KeyH','H')),'PLATE']);
  }
'@ @'
  if(!padOn()){   // v25.xx (belt6b): and the key of its class
    if(state!=='hub'&&(it.use==='throw'||it.use==='heal'||it.use==='stim'||it.use==='armor')){   // v26.02 (beltkeys): the digit acts at once, G and H act on the pick, U and J move it
      var _hk=String(keyLabel('Digit'+(c.i+1),String(c.i+1))), _hh=String(keyLabel('KeyH','H'));
      if(it.use==='throw') o.keys=[[_hk,'THROW'],[String(keyLabel('KeyG','G')),'THROW CHOSEN'],[String(keyLabel('KeyU','U')),'NEXT']];
      else if(it.use==='heal') o.keys=[[_hk,'HEAL'],[_hh,'HEAL CHOSEN'],[String(keyLabel('KeyJ','J')),'NEXT']];
      else if(it.use==='stim') o.keys=[[_hk,'USE'],[_hh,'USE CHOSEN'],[String(keyLabel('KeyJ','J')),'NEXT']];
      else o.keys=[[_hk,'SLOT'],['HOLD '+_hh,'PLATE']];
    }
    else if(it.use==='throw') o.keys.push([String(keyLabel('KeyG','G')),'THROW']);
    else if(it.use==='heal') o.keys.push([String(keyLabel('KeyH','H')),'HEAL']);
    else if(it.use==='armor') o.keys.push(['HOLD '+String(keyLabel('KeyH','H')),'PLATE']);
  }
'@

SubRx @'
G quick throw &nbsp; H quick heal &nbsp; 1-4 guns &nbsp; 5-6 throwables &nbsp; 7-8 medical &nbsp; 9 armour &nbsp;
'@ @'
G throw &nbsp; U next grenade &nbsp; H heal, hold plate &nbsp; J next heal &nbsp; 1-4 guns &nbsp; 5-6 throw that grenade &nbsp; 7-8 use that heal &nbsp; 9 plate &nbsp;
'@

SubRx @'
+s('KeyG')+' quick throw &nbsp; '+s('KeyH')+' quick heal, hold for armour plate &nbsp; '+k('1-4')+' guns &nbsp; '+k('5-6')+' throwables &nbsp; '+k('7-8')+' medical &nbsp; '+k('9')+' armour &nbsp; '
'@ @'
+s('KeyG')+' throw &nbsp; '+s('KeyU')+' next grenade &nbsp; '+s('KeyH')+' heal, hold for plate &nbsp; '+s('KeyJ')+' next heal &nbsp; '+k('1-4')+' guns &nbsp; '+k('5-6')+' throw that grenade &nbsp; '+k('7-8')+' use that heal &nbsp; '+k('9')+' plate &nbsp; '
'@

SubRx @'
['5-6','throwables'],['7-8','medical'],['9','armour plate'],['FIRE','use selected key'],['G','throw the chosen grenade'],['U','switch which grenade'],['H','tap heal, hold plate']
'@ @'
['5-6','throw that grenade'],['7-8','use that heal'],['9','plate'],['FIRE','use selected key'],['G','throw the chosen grenade'],['U','next grenade'],['H','use the chosen heal, hold plate'],['J','next heal']
'@

SubRx @'
['G','throw'],['H','heal'],['U','switch throw'],
'@ @'
['G','throw'],['H','heal'],['U / J','next throw, heal'],
'@

SubRx @'
'U':['KeyU'],'F1':['F1']
'@ @'
'U':['KeyU'],'J':['KeyJ'],'U / J':['KeyU','KeyJ'],'F1':['F1']
'@

SubRx @'
  ['TACTICAL BELT','1-4 guns, 5-6 throw,'],
  ['','7-8 medical, 9 armour.'],
  ['','FIRE uses the key.'],
  ['','Only one item in hand.'],
'@ @'
  ['TACTICAL BELT','1-4 guns, 5-6 throw,'],
  ['','7-8 heal, 9 plate. G, H use'],
  ['','the pick. U, J pick the next.'],
  ['','Gun stays in hand.'],
'@

SubRx @'
var VER='26.01';
'@ @'
var VER='26.02';
'@

$pat = "(?m)^  now:'v26\.01:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.02: Keys 5 to 9 now use their belt item at once with the gun still in hand, U and J pick the next grenade and heal, and keycaps on the belt show which key does what. Check 26.02 fails on v26.01',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
