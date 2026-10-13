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

# THE CLASS KEYS: THROWABLES, MEDICAL, ARMOUR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var GUNKEYS=4;
'@ @'
var GUNKEYS=4;
// v25.xx (belt3), HIS ORDER 2026-10-13: "grenades/throwables should be their own class of item, 2 slots -- same for heals/stims, 2 slots -- so
// player can only carry 4 guns max". NINE KEYS, ONE CLASS EACH: keys 1-4 GUNS, 5-6 THROWABLES, 7-8 MEDICAL (bandage, medkit, stim), 9 ARMOUR.
// BELT_FILL is the order a class fills its keys when he has bound nothing: frag, smoke, mine, decoy; bandage, medkit, stim; the plate.
var BELT_CLASS=['gun','gun','gun','gun','throw','throw','med','med','plate'];
var BELT_FILL={throw:['frag','smoke','trip','decoy'],med:['bandage','medkit','stim'],plate:['plate']};
var BELT_CNAME={gun:'Gun',throw:'Throwable',med:'Medical',plate:'Armour'};
'@

SubRx @'
function applyLoadedProfile(r){
'@ @'
// v25.xx (belt3), HIS ORDER 2026-10-13: THE SAVED BELT PLAN IS RE-HOMED TO THE CLASS KEYS, ONCE (P.beltV=4). An item already on a key of its own
// class stays; every other throwable, heal, stim, plate or gun goes to the lowest free key of its class in key order, and comes off the plan
// when its class has no free key. A valuable, a door key or ammo has no class and comes off. The same goes for the plan set aside for the
// freebie kit and the one kept from before it.
function beltClassPlan(h){
  if(!h||typeof h!=='object') return h;
  var out={}, ks=[], used={}, k, i, ix, key, cls, ci;
  for(k in h) if(Object.prototype.hasOwnProperty.call(h,k)&&h[k]!==undefined&&h[k]!==null&&isFinite(+k)) ks.push(+k);
  ks.sort(function(a,b){ return a-b; });
  for(i=0;i<ks.length;i++){ ix=ks[i]; key=h[ix]; cls=ITEMS[key]?beltClassOf(key):''; if(cls&&ix<HOTBAR_N&&BELT_CLASS[ix]===cls&&!used[key]){ out[ix]=key; used[key]=1; } }
  for(i=0;i<ks.length;i++){
    ix=ks[i]; key=h[ix]; cls=ITEMS[key]?beltClassOf(key):''; if(!cls||used[key]) continue;
    for(ci=0;ci<HOTBAR_N;ci++) if(BELT_CLASS[ci]===cls&&out[ci]===undefined){ out[ci]=key; used[key]=1; break; }
  }
  return out;
}
function applyLoadedProfile(r){
'@

SubRx @'
// v25.xx (belt2): the same three plans lose their gun bindings past the gun keys, once.
if((P.beltV|0)<3){
  P.hotAssign=beltGunsOff(P.hotAssign||{});
  if(P.kitSaved&&P.kitSaved.hot) P.kitSaved.hot=beltGunsOff(P.kitSaved.hot);
  if(P.hotBeforeFree) P.hotBeforeFree=beltGunsOff(P.hotBeforeFree);
  P.beltV=3;
}
'@ @'
// v25.xx (belt2): the same three plans lose their gun bindings past the gun keys, once.
if((P.beltV|0)<3){
  P.hotAssign=beltGunsOff(P.hotAssign||{});
  if(P.kitSaved&&P.kitSaved.hot) P.kitSaved.hot=beltGunsOff(P.kitSaved.hot);
  if(P.hotBeforeFree) P.hotBeforeFree=beltGunsOff(P.hotBeforeFree);
  P.beltV=3;
}
// v25.xx (belt3): and the three plans are re-homed to the class keys, once.
if((P.beltV|0)<4){
  P.hotAssign=beltClassPlan(P.hotAssign||{});
  if(P.kitSaved&&P.kitSaved.hot) P.kitSaved.hot=beltClassPlan(P.kitSaved.hot);
  if(P.hotBeforeFree) P.hotBeforeFree=beltClassPlan(P.hotBeforeFree);
  P.beltV=4;
}
'@

SubRx @'
mig739:1,mig945:1,beltV:3,
'@ @'
mig739:1,mig945:1,beltV:4,
'@

SubRx @'
  for(var i=0;i<THROWKEYS.length;i++){
    var tk=THROWKEYS[i];
    if(tk==='trip') continue;   // v23.xx (feat1a): the Tripwire Mine cell is added after Medical, below, and only while carried
    out.push({k:'throw:'+tk,name:ITEMS[tk].name,kind:'throw',icon:tk,
      count:G.pouch[tk]||0,c:ITEMS[tk].c});
  }
  var hi=findHeal();
  out.push({k:'heal',name:hi>=0?ITEMS[G.bag[hi]].name:'Medical',kind:'heal',icon:(hi>=0?G.bag[hi]:'bandage'),
    count:countHeals(),c:'#6fe0a0'});
  // ARMOUR YOU ARE CARRYING, v2.17. A plate had no way to be used. It is listed
  // in the shop at 620 credits and the deploy loadout ranks armour FIRST, above
  // ammo and medical, on the stated reasoning that "armour and ammo are spent the
  // moment you land". You land at myRig().cap, which is FULL, so the take was
  // refused every single time and a bought plate never reached a raid at all.
  // Only appears when you are actually carrying one, so the slot order does not
  // move for anyone who is not.
  if(countArmor()>0) out.push({k:'plate',name:'Armour Plate',kind:'armor',icon:'plate',
    count:countArmor(),c:'#5aa9e6'});
  // v23.xx (feat1a), HIS #6 and his answer 32 (2026-10-12): THE TRIPWIRE MINE GOES ON THE BELT LIKE A GRENADE. Its cell is added
  // only while one is carried, and after Medical and the plate, so no key anyone has learned moves: the belt of anyone without a
  // mine is the belt of before, and with one it takes the first free key (key 9 on the usual belt). A pin on that key yields as it
  // does for the plate (v8.04).
  if(G.pouch&&G.pouch.trip>0&&ITEMS.trip&&out.length<HOTBAR_N) out.push({k:'throw:trip',name:ITEMS.trip.name,kind:'throw',icon:'trip',
    count:G.pouch.trip,c:ITEMS.trip.c});

  // HIS REQUEST, 2026-08-25: "I want the inventory to be physical like minecraft
  // so you can drag icons down to the quick bars". The bar above is DERIVED: it
  // is rebuilt from scratch every frame from what you happen to be carrying, and
  // nothing about it is yours. Dragging needs a slot to be a place you put a
  // thing, so an assignment map overrides the derived slot at that index.
  // Overrides rather than a full stored layout on purpose: the derived list stays
  // exactly as it was, so nothing that already works can regress, and an
  // assignment that no longer makes sense simply falls away.
  // HIS NOTE: "Can we increase the hotbar to 9 items?" The bar is DERIVED, so its
  // length was however many things you happened to be carrying, seven or eight.
  // The digits 1 to 9 have selected slots since v2.94, so two of them addressed
  // nothing. Padded to a fixed nine: the derived slots keep their order, and the
  // remainder are real empty slots you can drag anything onto, which is what
  // makes the extra keys worth having rather than just present.
  while(out.length<HOTBAR_N) out.push({k:'empty:'+out.length,name:'Empty slot',kind:'empty',count:0,c:'#4d5762'});
  if(out.length>HOTBAR_N) out.length=HOTBAR_N;
  // v8.04, audit: the derived bar GROWS - equip a second gun and Medical slides
  // right; pick up a plate and a new cell appears. An AUTOMATIC pin sitting on
  // the index a derived cell grows into would mask that cell for the raid
  // (Medical vanished, only KeyF healed). Automatic pins yield: they move to
  // the highest empty slot instead. His own placements still override, as the
  // v6.61 note above demands.
  if(G.hotAssign&&G.hotAuto){
    for(var pa in G.hotAssign){
      var pax=+pa;
      if(!G.hotAuto[pa]) continue;
      if(pax<GUNKEYS&&ITEMS[G.hotAssign[pa]]&&ITEMS[G.hotAssign[pa]].use==='gun') continue;   // v21.83: a gun pin on a gun key never yields
      if(pax<GUNKEYS&&out[pax]&&out[pax].gunFill) continue;   // v22.42: nor any pin on a gun key no gun took (the fill comes after)
      if(pax>=0&&pax<out.length&&out[pax].kind!=='empty'){
        var nix=-1;
        for(var ni=out.length-1;ni>=0;ni--)
          if(out[ni].kind==='empty'&&G.hotAssign[ni]===undefined){ nix=ni; break; }
        // v22.42, from the review of the four-gun belt (build 3): AN AUTOMATIC PIN WITH NO EMPTY KEY LEFT TAKES A FREE GUN KEY 3 OR 4,
        // instead of vanishing. With four gun keys, three throws and Medical, key 9 is the only empty key, and the plate takes it the
        // moment he picks a plate up: a Stim pinned there found no empty key, its pin was deleted, and the Stim left the belt.
        if(nix<0) for(ni=GUNKEYS-1;ni>=2;ni--) if(G.hotAssign[ni]===undefined){ nix=ni; break; }
        var pkey=G.hotAssign[pa];
        delete G.hotAssign[pa]; delete G.hotAuto[pa];
        if(nix>=0){ G.hotAssign[nix]=pkey; G.hotAuto[nix]=1; }
      }
    }
  }

'@ @'
  // v25.xx (belt3), HIS ORDER 2026-10-13: THE CLASS KEYS. Keys 5-6 are throwables, 7-8 medical, 9 armour (BELT_CLASS), built by beltClassCells
  // from what he carries and what he bound, and this function WRITES NOTHING: the pin that yielded to a growing derived cell (v8.04), the
  // Medical cell that counted every heal, the plate and mine cells that came and went, and the mine that took a gun key (v23.xx) are gone.
  var _bcc=beltClassCells();
  for(var _bci=0;_bci<_bcc.length;_bci++) out.push(_bcc[_bci]);
  while(out.length<HOTBAR_N) out.push({k:'empty:'+out.length,name:'Empty slot',kind:'empty',count:0,c:'#4d5762'});
  if(out.length>HOTBAR_N) out.length=HOTBAR_N;

'@

SubRx @'
    var ait=ITEMS[akey]; if(!ait) continue;
'@ @'
    var ait=ITEMS[akey]; if(!ait) continue;
    if(aix>=GUNKEYS||ait.use!=='gun') continue;   // v25.xx (belt3): a pin on a gun key is a gun; the class keys read their own pins (beltClassCells)
'@

SubRx @'
  for(var _dg=0;_dg<2;_dg++){
    var _gc=_dGun[_dg];
    if(!_gc||_gc.vacant||_hcUsed[_dg]) continue;
    if(!_gc.inHand&&_gc.icon==='fists') continue;
    var _gShown=false;
    for(var _gj=0;_gj<out.length;_gj++) if(out[_gj]&&out[_gj].kind==='gun'&&out[_gj].equipped&&!!out[_gj].inHand===!!_gc.inHand) _gShown=true;
    if(_gShown) continue;
    for(var _gn=out.length-1;_gn>=GUNKEYS;_gn--)
      if(out[_gn]&&out[_gn].kind==='empty'&&!(G.hotAssign&&G.hotAssign[_gn]!==undefined)){ out[_gn]=_gc; break; }
  }
  // v6.70, his note that moving a belt item does not work: the bar is DERIVED and an
  // assignment only overrides one slot, so the thing you dragged stayed visible in the
  // slot it came from too. Anything now assigned somewhere is cleared from the derived
  // slot that would otherwise show the same thing, and the freed slot becomes empty.
  // Done as a second pass so the assignment loop above stays the only writer of slots.
  for(var di=0;di<out.length;di++){
    var dsl=out[di];
    if(!dsl||dsl.assigned) continue;
    var dupe=false;
    for(var aj in (G.hotAssign||{})){
      var ajx=+aj; if(ajx===di||!(ajx>=0&&ajx<out.length)) continue;
      if(!out[ajx]||!out[ajx].assigned) continue;      // that assignment did not take
      var ak2=G.hotAssign[aj], ai2=ITEMS[ak2]; if(!ai2) continue;
      // v14.84, belt audit finding 1: A HEAL ON A KEY BLANKS MEDICAL ONLY WHEN EVERY HEAL CARRIED IS ON A KEY. Medical is the one
      // cell that uses the heals he did not bind, so a Medkit on key 8 blanked it and the Bandages in the backpack could not be
      // used for the rest of the raid once the Medkit was spent.
      if(ai2.use==='heal'&&dsl.k==='heal'){ if(!unkeyedHeals()) dupe=true; }
      else if(ai2.use==='armor'&&dsl.k==='plate') dupe=true;
      else if(dsl.k==='throw:'+ak2) dupe=true;
      // v15.25, his note: KEY 1 NEVER GOES BLACK WHILE HE HOLDS A GUN. A gun on a belt key that he was holding blanked the gun
      // cell showing the same gun, so taking a gun from the backpack with its key put it in his hands and turned cell 1 black
      // (cell 2 when it went to the empty second slot) while he held it. Cells 1 and 2 are the two guns in his hands and always
      // show them. The key he bound keeps showing it too, because keys he set never move; gunCell and swapGuns still pick his
      // key first, as they did while the gun cell was blank.
      if(dupe) break;
    }
    if(dupe) out[di]={k:'empty:'+di,name:'Empty slot',kind:'empty',count:0,c:'#4d5762'};
  }
  // v23.xx (gameplayfixa), from the review of feat1a, his #6 and answer 32 ("on the belt like a grenade"): THE TRIPWIRE MINE HAS
  // A KEY WHILE A PLATE IS CARRIED. Four gun keys, three throws, Medical and the plate fill all nine keys, so the mine cell was never
  // pushed: Q passed it over (no cell, v15.06) and the pad, which throws only from a belt cell, could not throw it at all until the
  // plate was spent. A carried mine that no cell shows now takes the highest vacant gun key (4, then 3), as a Stim does (v22.42),
  // as an automatic pin, so it stays on that key for the raid: spending the plate later does not move it to key 9.
  if(G.pouch&&G.pouch.trip>0&&ITEMS.trip&&!G.sim&&!G.hubFloor&&!G.over){
    var _tpS=false, _tpI;
    for(_tpI=0;_tpI<out.length;_tpI++) if(out[_tpI]&&(out[_tpI].k==='throw:trip'||out[_tpI].itemKey==='trip')) _tpS=true;
    if(!_tpS){
      G.hotAssign=G.hotAssign||{};
      for(_tpI=GUNKEYS-1;_tpI>=2;_tpI--){
        if(_tpI<out.length&&out[_tpI]&&out[_tpI].vacant&&out[_tpI].k==='gunkey:'+_tpI&&G.hotAssign[_tpI]===undefined){
          G.hotAssign[_tpI]='trip'; G.hotAuto=G.hotAuto||{}; G.hotAuto[_tpI]=1;
          out[_tpI]={k:'throw:trip',name:ITEMS.trip.name,icon:'trip',kind:'throw',count:G.pouch.trip,c:ITEMS.trip.c||'#cdd6dd',assigned:1,itemKey:'trip',empty:0};
          break;
        }
      }
    }
  }

'@ @'
  // v25.xx (belt3): the hand guns placed on a free key past the gun keys (v17.17), the pass that blanked a derived cell an assignment also
  // showed (v6.70) and the mine that took a gun key (v23.xx) are gone with the derived cells they served. Guns live on keys 1 to 4.

'@

SubRx @'
function unkeyedHeals(){
'@ @'
// v25.xx (belt3): what class an item belongs to: gun, throw (smoke, decoy, frag, mine), med (a heal or a stim), plate; '' for anything else.
function beltClassOf(key){
  var it=ITEMS[key];
  if(!it) return '';
  if(it.use==='gun') return 'gun';
  if(it.use==='throw') return 'throw';
  if(it.use==='heal'||it.use==='stim') return 'med';
  if(it.use==='armor') return 'plate';
  return '';
}
function beltClassWord(cls){
  return cls==='gun'?('GUNS GO ON KEYS 1 TO '+GUNKEYS):(cls==='throw'?'THROWABLES GO ON KEYS 5 AND 6':(cls==='med'?'MEDICAL GOES ON KEYS 7 AND 8':(cls==='plate'?'PLATES GO ON KEY 9':'NOT A BELT ITEM')));
}
// '' when key ix may take the item, else the refusal in words
function beltDropRefusal(key,ix){
  var cls=beltClassOf(key);
  if(!ITEMS[key]) return '';
  if(cls&&BELT_CLASS[ix]===cls) return '';
  return beltClassWord(cls);
}
// how many of a class item he carries: the pouch for a throwable, the backpack for the rest
function beltHave(key){
  var it=ITEMS[key], n=0, i;
  if(!it||!G) return 0;
  if(it.use==='throw') return ((G.pouch&&G.pouch[it.tk])|0);
  for(i=0;i<G.bag.length;i++) if(G.bag[i]===key) n++;
  return n;
}
// One class cell. pinned: a key he bound (or an automatic pin); otherwise the fill. A throwable and the plate keep the cell shapes they always had.
function beltClassCell(key,pinned,ci){
  var it=ITEMS[key], n=beltHave(key), au=(G.hotAuto&&G.hotAuto[ci])?1:0, c;
  if(it.use==='throw'){
    c={k:'throw:'+key,name:it.name,icon:key,kind:'throw',count:n,c:it.c||'#cdd6dd'};
    if(pinned){ c.assigned=1; c.itemKey=key; c.empty=(n<=0)?1:0; c.auto=au; }
    return c;
  }
  if(it.use==='armor'){
    if(!pinned) return {k:'plate',name:'Armour Plate',kind:'armor',icon:'plate',count:n,c:'#5aa9e6'};
    return {k:'item:'+key,name:it.name,icon:key,kind:'armor',count:n,c:it.c||'#cdd6dd',assigned:1,itemKey:key,empty:(n<=0)?1:0,auto:au};
  }
  c={k:'item:'+key,name:it.name,icon:key,kind:(it.use==='stim'?'stim':'heal'),count:n,c:it.c||'#cdd6dd',itemKey:key};
  if(pinned){ c.assigned=1; c.empty=(n<=0)?1:0; c.auto=au; } else c.fill=1;
  return c;
}
// The five class cells, keys 5 to 9. A key he bound shows what he bound, greyed at 0 when none is left (v9.03); an automatic pin whose item has run
// out lets go, so the next kind fills the key. A key nothing is bound to shows the next kind he carries in BELT_FILL order, and an empty class
// cell when there is none. A pin of another class is not read. No state is written here.
function beltClassCells(){
  var res=[], A=G.hotAssign||{}, U=G.hotAuto||{}, pinT={}, used={}, ci, cls, list, key, k, t, n;
  for(ci=GUNKEYS;ci<HOTBAR_N;ci++) res.push(null);
  for(ci=GUNKEYS;ci<HOTBAR_N;ci++){
    key=A[ci]; cls=BELT_CLASS[ci];
    if(key===undefined||beltClassOf(key)!==cls||pinT[key]) continue;
    n=beltHave(key);
    if(U[ci]&&n<=0) continue;
    pinT[key]=1; res[ci-GUNKEYS]=beltClassCell(key,true,ci);
  }
  for(ci=GUNKEYS;ci<HOTBAR_N;ci++){
    if(res[ci-GUNKEYS]) continue;
    cls=BELT_CLASS[ci]; list=BELT_FILL[cls]; key=null;
    for(k=0;k<list.length;k++){ t=list[k]; if(ITEMS[t]&&!pinT[t]&&!used[t]&&beltHave(t)>0){ key=t; break; } }
    if(key){ used[key]=1; res[ci-GUNKEYS]=beltClassCell(key,false,ci); }
    else res[ci-GUNKEYS]={k:'empty:'+ci,name:BELT_CNAME[cls]+' slot',kind:'empty',count:0,c:'#4d5762',cls:cls};
  }
  return res;
}
// A class item he picks up (a heal, a stim, a plate, a grenade) takes the lowest vacant key of its class as an automatic pin, so the key he
// learned never moves when a kind that sorts earlier turns up; with no vacant key it waits in the backpack (the pouch for a grenade).
function beltClassPin(key,quiet,slots){
  var it=ITEMS[key], cls=beltClassOf(key), ci, c, vac=-1, fillAt=-1, shown=false, at, txt;
  if(G.hubFloor) return;
  for(ci=GUNKEYS;ci<HOTBAR_N;ci++){
    if(BELT_CLASS[ci]!==cls) continue;
    c=slots[ci];
    if(!c) continue;
    if(c.kind==='empty'){ if(vac<0) vac=ci; }
    else if(c.itemKey===key||c.icon===key||(cls==='plate'&&c.k==='plate')){ if(c.assigned) shown=true; else if(fillAt<0) fillAt=ci; }   // a key he bound (or a pin) shows it; a fill only shows what the key would take, so the pin is made on that key
  }
  if(shown) return;
  at=(fillAt>=0)?fillAt:vac;
  if(at>=0){
    G.hotAssign[at]=key; G.hotAuto=G.hotAuto||{}; G.hotAuto[at]=1;
    BELTAT=at;
    if(quiet) return;
    txt=(it.name+' to slot '+(at+1)).toUpperCase(); say(txt); return txt;
  }
  if(cls==='throw') return;
  BELTAT=-2; if(!quiet) say('NO FREE KEY','info',{sub:String(it.name).toUpperCase()});
}
// At the raid start: what each class key shows is pinned as an automatic pin (like the guns, gunKeysSettle), so a key keeps its item for the raid.
// A pin of the wrong class (an item of his on a gun key, a heal on a grenade key) is set aside for his plan and not read.
function classKeysSettle(o){
  if(!G||G.sim||G.over||G.hubFloor||!G.player) return;
  var A=(G.hotAssign=G.hotAssign||{}), U=(G.hotAuto=G.hotAuto||{}), k, ci, sl, c, ik;
  for(k in A){ if(!ITEMS[A[k]]||beltClassOf(A[k])!==BELT_CLASS[+k]){ (G.hotPruned=G.hotPruned||{})[k]=A[k]; delete A[k]; delete U[k]; } }
  sl=hotbarSlots();
  for(ci=GUNKEYS;ci<HOTBAR_N;ci++){
    c=sl[ci]; if(!c||c.kind==='empty'||c.assigned||A[ci]!==undefined) continue;
    ik=c.itemKey||c.icon;
    if(ik&&beltClassOf(ik)===BELT_CLASS[ci]){ A[ci]=ik; U[ci]=1; }
  }
}
function unkeyedHeals(){
'@

SubRx @'
  if(it.use!=='gun'&&it.use!=='stim') return;
'@ @'
  if(!beltClassOf(key)) return;   // v25.xx (belt3): a gun, a throwable, a heal, a stim or a plate; anything else has no key
'@

SubRx @'
  for(var bi=0;bi<slots.length;bi++){
    if(slots[bi].kind==='empty'&&G.hotAssign[bi]===undefined){
      G.hotAssign[bi]=key;
      // Marked automatic so a drag can tell his placements from mine: only his
      // reach the profile, and mine yield to derived cells instead of masking.
      G.hotAuto=G.hotAuto||{};
      G.hotAuto[bi]=1;
      var _beltTxt=(it.name+' to slot '+(bi+1)).toUpperCase();   // v22.43: the shooter voice   // v22.xx (R52): the slot word
      BELTAT=bi; if(!quiet) say(_beltTxt);
      // v13.35: handed back as well, because the loot grant writes its Found line over this one.
      return _beltTxt;
    }
  }
  // v22.42, from the review of the four-gun belt (build 3): A STIM WITH NO EMPTY KEY TAKES A VACANT GUN KEY 3 OR 4. Carrying a plate
  // (the freebie kit always has one), key 9 is the plate and no key is empty, so a Stim found or paid at a revive got no key and no
  // line. It goes on the highest vacant gun key (any item may go on a gun key, decision D2); with none it says so.
  if(it.use==='stim'&&!G.hubFloor){
    for(var _svi=GUNKEYS-1;_svi>=2;_svi--){
      if(G.hotAssign[_svi]===undefined&&slots[_svi]&&slots[_svi].vacant){
        G.hotAssign[_svi]=key; G.hotAuto=G.hotAuto||{}; G.hotAuto[_svi]=1;
        var _svTxt=(it.name+' to slot '+(_svi+1)).toUpperCase();   // v22.xx (R52): the slot word
        BELTAT=_svi; if(!quiet) say(_svTxt);
        return _svTxt;
      }
    }
    BELTAT=-2; if(!quiet) say('NO FREE KEY','info',{sub:String(it.name).toUpperCase()});
  }
}
'@ @'
  // v25.xx (belt3), HIS ORDER 2026-10-13: a throwable, a heal, a stim or a plate takes the lowest vacant key of ITS class (beltClassPin). The
  // pin on any empty key, and the Stim that borrowed a gun key (v22.42, decision D2), are gone: a gun key holds guns.
  return beltClassPin(key,quiet,slots);
}
'@

SubRx @'
    else if(itm.use==='throw') G.pouch[itm.tk]++;
'@ @'
    else if(itm.use==='throw'){ G.pouch[itm.tk]++; if(!G.sim){ _beltGot=autoBelt(key,1); if(_beltGot) _beltKeep.push(_beltGot); if(beltTag()) _ptags[l]=beltTag(); } }   // v25.xx (belt3): a grenade takes the lowest vacant throwable key, and its row says which
'@

SubRx @'
  if(s2.assigned&&s2.itemKey){
'@ @'
  if((s2.assigned||s2.fill)&&s2.itemKey){   // v25.xx (belt3): and a medical key nothing is bound to, which shows a kind by itself (fill)
'@

SubRx @'
        var _siOpen=!!(_si&&HC.i>=2&&HC.i<GUNKEYS&&_si.vacant&&!(_dit&&_dit.use==='gun'));
'@ @'
        var _siOpen=false;   // v25.xx (belt3): a gun key takes guns only; decision D2 (an item on a vacant gun key 3 or 4) is withdrawn
'@

SubRx @'
        if(_dit&&_dit.use==='gun'&&HC.i>=GUNKEYS&&d.fromHot!==HC.i){   // v25.xx (belt2b): a press and release on the key it came from is a click, and a click still brings the gun up (v18.90)
          say('GUNS GO ON KEYS 1 TO '+GUNKEYS,'info',null); sndUi('deny');
          dropped=true; break;
        }
'@ @'
        var _bdr=(d.fromHot!==HC.i)?beltDropRefusal(d.key,HC.i):'';   // v25.xx (belt3): every key takes its own class (a press and release on the key it came from is a click, v18.90)
        if(_bdr){
          say(_bdr,'info',null); sndUi('deny');
          dropped=true; break;
        }
'@

SubRx @'
          if(_H.i>=GUNKEYS&&ITEMS[d.key]&&ITEMS[d.key].use==='gun'){ hubToast('GUNS GO ON KEYS 1 TO '+GUNKEYS); return; }   // v25.xx (belt2): a gun belongs on keys 1 to GUNKEYS
'@ @'
          var _hbr=beltDropRefusal(d.key,_H.i); if(_hbr){ hubToast(_hbr); return; }   // v25.xx (belt3): every key takes its own class
'@

SubRx @'
  if((slot|0)>=GUNKEYS) return 'GUNS GO ON KEYS 1 TO '+GUNKEYS;   // v25.xx (belt2): a gun belongs on keys 1 to GUNKEYS
'@ @'
  if(beltDropRefusal(key,slot|0)) return beltDropRefusal(key,slot|0);   // v25.xx (belt3): every key takes its own class
'@

SubRx @'
  if(ITEMS[key].use==='gun'&&(slot|0)>=GUNKEYS) return 'GUNS GO ON KEYS 1 TO '+GUNKEYS;   // v25.xx (belt2): a gun belongs on keys 1 to GUNKEYS
'@ @'
  if(beltDropRefusal(key,slot|0)) return beltDropRefusal(key,slot|0);   // v25.xx (belt3): every key takes its own class
'@

SubRx @'
        if(ITEMS[key].use==='gun'){ try{ sfx('clank'); }catch(e){} return; }
'@ @'
        if(ITEMS[key].use==='gun'){ try{ sfx('clank'); }catch(e){} return; }
        if(beltDropRefusal(key,ix)){ say2(beltDropRefusal(key,ix)); try{ sfx('clank'); }catch(e){} return; }   // v25.xx (belt3): every key takes its own class
'@

SubRx @'
  try{ gunKeysSettle({deploy:1}); }catch(_gks){}   // v21.83: the guns in his hands take the gun keys the belt shows them on
'@ @'
  try{ gunKeysSettle({deploy:1}); }catch(_gks){}   // v21.83: the guns in his hands take the gun keys the belt shows them on
  try{ classKeysSettle({deploy:1}); }catch(_cks){}   // v25.xx (belt3): and what the throwable, medical and armour keys show is pinned for the raid
'@

SubRx @'
  if(G===g){ try{ gunKeysSettle({deploy:1}); }catch(_gk){} try{ G.hot=gunCell(); }catch(_gc){} }
'@ @'
  if(G===g){ try{ gunKeysSettle({deploy:1}); }catch(_gk){} try{ classKeysSettle({deploy:1}); }catch(_ck){} try{ G.hot=gunCell(); }catch(_gc){} }   // v25.xx (belt3): the class keys too
'@

SubRx @'
var VER='25.90';
'@ @'
var VER='25.91';
'@

$pat = "(?m)^  now:'v25\.90:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.91: The belt now has a class for each key: 4 guns, 2 throwables, 2 medical and the armour plate. Check 25.91 fails on v25.90',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
