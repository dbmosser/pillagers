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

# ITEMS ON THE HOTBAR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function beltDropRefusal(key,ix){
  var cls=beltClassOf(key);
  if(!ITEMS[key]) return '';
  if(cls&&BELT_CLASS[ix]===cls) return '';
  return beltClassWord(cls);
}
'@ @'
function beltDropRefusal(key,ix){
  var cls=beltClassOf(key);
  if(!ITEMS[key]) return '';
  if(cls&&BELT_CLASS[ix]===cls) return '';
  if(/^(throw|med|plate)$/.test(cls)&&ix>=0&&ix<HOTBAR_N) return '';   // cw-hotitems (his order of 10-27): a medkit, grenade, stim or plate goes on any key he drags it to
  return beltClassWord(cls);
}
'@

SubRx @'
    if(aix>=GUNKEYS||ait.use!=='gun') continue;   // v25.xx (belt3): a pin on a gun key is a gun; the class keys read their own pins (beltClassCells)
'@ @'
    if(aix>=HOTBAR_N||!/^(gun|throw|med|plate)$/.test(beltClassOf(akey))) continue;   // cw-hotitems (his order of 10-27): an item he dragged onto a key shows there
'@

SubRx @'
      var _pq=(G.pouch&&G.pouch[akey])||0;
'@ @'
      var _pq=beltHave(akey);   // cw-hotitems: the pouch and the backpack
'@

SubRx @'
  for(k in A){ if(!ITEMS[A[k]]||beltClassOf(A[k])!==BELT_CLASS[+k]){ (G.hotPruned=G.hotPruned||{})[k]=A[k]; delete A[k]; delete U[k]; } }
'@ @'
  for(k in A){ if(!ITEMS[A[k]]||(beltClassOf(A[k])!==BELT_CLASS[+k]&&!(/^(throw|med|plate)$/.test(beltClassOf(A[k]))&&+k<HOTBAR_N))){ (G.hotPruned=G.hotPruned||{})[k]=A[k]; delete A[k]; delete U[k]; } }   // cw-hotitems: an item pin stays
'@

SubRx @'
      if(g.bag.indexOf(_hk)<0&&!((g.pouch||{})[_hk]>0)){ (g.hotPruned=g.hotPruned||{})[_ha]=_hk; delete g.hotAssign[_ha]; }   // v14.86: kept aside for his plan
'@ @'
      if(/^(throw|med|plate)$/.test(beltClassOf(_hk))) continue;   // cw-hotitems: an item key he set stays, greyed when he has none
      if(g.bag.indexOf(_hk)<0&&!((g.pouch||{})[_hk]>0)){ (g.hotPruned=g.hotPruned||{})[_ha]=_hk; delete g.hotAssign[_ha]; }   // v14.86: kept aside for his plan
'@

SubRx @'
  for(k in P.hotAssign) if(!have[P.hotAssign[k]]) delete P.hotAssign[k];
'@ @'
  for(k in P.hotAssign) if(!have[P.hotAssign[k]]&&!/^(throw|med|plate)$/.test(beltClassOf(P.hotAssign[k]))) delete P.hotAssign[k];   // cw-hotitems: an item key stays when he has none
'@

SubRx @'
function clearKeysFor(key){
  if(!P.hotAssign) return;
  var live=stageKitLive(), still=0, i;
'@ @'
function clearKeysFor(key){
  if(!P.hotAssign) return;
  if(/^(throw|med|plate)$/.test(beltClassOf(key))) return;   // cw-hotitems: an item key stays, greyed, until he drags it off
  var live=stageKitLive(), still=0, i;
'@

SubRx @'
      if(dn>GUNKEYS&&!G.hubFloor) beltInstant(dn-1); else setHot(dn-1);
'@ @'
      var _ic=(!G.hubFloor)?hotbarSlots()[dn-1]:null; if((dn>GUNKEYS||(_ic&&/^(throw|heal|stim|armor)$/.test(_ic.kind)))&&!G.hubFloor) beltInstant(dn-1); else setHot(dn-1);   // cw-hotitems: an item key uses its item at once
'@

SubRx @'
        if(_si&&_siDerived){
          say('SLOT '+slotKeyName(HC.i)+' TAKES GUNS ONLY');   // v22.43: the shooter voice   // v22.xx (R52): the slot word
'@ @'
        if(_si&&_siDerived&&!(_dit&&/^(throw|med|plate)$/.test(beltClassOf(d.key)))){   // cw-hotitems (his order of 10-27): an item takes a gun key, the gun stays where it is
          say('SLOT '+slotKeyName(HC.i)+' TAKES GUNS ONLY');   // v22.43: the shooter voice   // v22.xx (R52): the slot word
'@

SubRx @'
        if(d.fromHot===undefined&&G.bag.indexOf(d.key)<0){ dropped=true; break; }
'@ @'
        if(d.fromHot===undefined&&G.bag.indexOf(d.key)<0&&!((G.pouch||{})[d.key]>0)){ dropped=true; break; }   // cw-hotitems: a pouch grenade binds too
'@

SubRx @'
        G.hot=HC.i;
        blip('pick');
        say(((ITEMS[d.key]?ITEMS[d.key].name:'Item')+' to slot '+(HC.i+1)).toUpperCase());   // v22.58: the shooter voice   // v22.xx (R52): the slot word
'@ @'
        G.hot=(ITEMS[d.key]&&ITEMS[d.key].use==='gun')?HC.i:gunCell();   // cw-hotitems: an item on a key leaves the gun in his hands selected
        blip('pick');
        say(((ITEMS[d.key]?ITEMS[d.key].name:'Item')+' to slot '+slotKeyName(HC.i)).toUpperCase());   // v22.58: the shooter voice   // v22.xx (R52): the slot word
'@

SubRx @'
function beltInstant(i){
  var p=G&&G.player, sl, c, cls=BELT_CLASS[i], ti, sv;
  if(!G||G.sim||G.over||G.paused||G.trade||G.hubFloor||!p||i<GUNKEYS||i>=HOTBAR_N) return false;
  if(p.downed){ say('NOT WHILE DOWN'); return false; }
  if(p.dying||p.specOut) return false;
  sl=hotbarSlots(); c=sl[i];
  if(cls==='throw'){
    ti=(c&&c.kind==='throw'&&c.icon&&(c.count|0)>0)?THROWKEYS.indexOf(c.icon):-1;
    if(ti<0){ say('NO THROWABLE ON KEY '+(i+1)); return false; }
'@ @'
function beltInstant(i){
  var p=G&&G.player, sl, c, cls='', ti, sv;
  if(!G||G.sim||G.over||G.paused||G.trade||G.hubFloor||!p||i<0||i>=HOTBAR_N) return false;
  if(p.downed){ say('NOT WHILE DOWN'); return false; }
  if(p.dying||p.specOut) return false;
  sl=hotbarSlots(); c=sl[i];
  cls=BELT_CLASS[i]; if(c&&c.kind==='throw') cls='throw'; else if(c&&(c.kind==='heal'||c.kind==='stim')) cls='med'; else if(c&&c.kind==='armor') cls='plate'; else if(i<GUNKEYS) return false;   // cw-hotitems: the item on the key decides
  if(cls==='throw'){
    ti=(c&&c.kind==='throw'&&c.icon&&(c.count|0)>0)?THROWKEYS.indexOf(c.icon):-1;
    if(ti<0){ say('NO THROWABLE ON KEY '+slotKeyName(i)); return false; }
'@

SubRx @'
function beltPickCell(i){
  var sl, c, ti;
  if(!G||G.hubFloor||G.sim||i<GUNKEYS||i>=HOTBAR_N) return false;
  sl=hotbarSlots(); c=sl[i];
  if(!c) return false;
  if(BELT_CLASS[i]==='throw'&&c.kind==='throw'&&c.icon&&(c.count|0)>0){
'@ @'
function beltPickCell(i){
  var sl, c, ti;
  if(!G||G.hubFloor||G.sim||i<0||i>=HOTBAR_N) return false;   // cw-hotitems: any key may hold an item
  sl=hotbarSlots(); c=sl[i];
  if(!c) return false;
  if(c.kind==='throw'&&c.icon&&(c.count|0)>0){
'@

SubRx @'
  if(BELT_CLASS[i]==='med'&&(c.kind==='heal'||c.kind==='stim')&&(c.count|0)>0&&c.itemKey&&ITEMS[c.itemKey]){
'@ @'
  if((c.kind==='heal'||c.kind==='stim')&&(c.count|0)>0&&c.itemKey&&ITEMS[c.itemKey]){
'@

SubRx @'
var VER='35.07';
'@ @'
var VER='35.08';
'@

$pat = "(?m)^  now:'v35\.07:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.08: drag a medkit, grenade, stim or plate onto any key of the bar, in raid, stash, undercroft or pre-raid; its key uses it at once and the gun stays in hand; a gun that lost its key moves to a free one Check 35.08 fails on v35.07',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
