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

# A GUN KEEPS ITS KEY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var HOTBAR_N=9;
'@ @'
var HOTBAR_N=9;
// v21.83, the four-gun belt, build 2: the first GUNKEYS keys of the belt are GUN KEYS, tied to guns rather than to hands. A gun on
// one keeps it in his hands and in the backpack (gunKeysSettle). Two for now, so keys 1 and 2 read as they always have.
var GUNKEYS=2;
'@

SubRx @'
      if(!_hi||_hi.use==='gun') continue;
'@ @'
      if(!_hi) continue;
      // v21.83, the four-gun belt, build 2: a key he bound to a gun he did not bring is set aside too, so it holds no gun key for the
      // raid; a gun he brought keeps the key he gave it. A gun is in his hands or in the backpack, never in the pouch.
      if(_hi.use==='gun'){
        var _hpw=g.player;
        if(g.bag.indexOf(_hk)<0&&!((_hpw.wep&&_hpw.wep.id===_hi.gk)||(_hpw.sec&&_hpw.sec.id===_hi.gk))){ (g.hotPruned=g.hotPruned||{})[_ha]=_hk; delete g.hotAssign[_ha]; }
        continue;
      }
'@

SubRx @'
  G=buildRaid(false);
'@ @'
  G=buildRaid(false);
  try{ gunKeysSettle({deploy:1}); }catch(_gks){}   // v21.83: the guns in his hands take the gun keys the belt shows them on
'@

SubRx @'
function autoBelt(key){
'@ @'
// v21.83, the four-gun belt, build 2: A GUN KEEPS ITS KEY WHEN IT IS DRAWN OR STOWED. Keys 1 and 2 used to be the two hand slots, so
// drawing a third gun off key 7 put it on key 1, the gun it replaced went into the backpack with no key at all, and key 1 named
// whatever was in the hand that moment. A gun key now holds a gun: an automatic pin (G.hotAssign marked in G.hotAuto, the kind
// autoBelt makes, which never reaches his saved plan) that shows that gun wherever it is, in his hands, stowed, or in the backpack.
// This is the only writer of gun pins besides autoBelt, and like it, it never runs in the sim, after the raid, or on the floor.
// It lets go of a pin whose gun is gone, gives each real gun in his hands with no key the gun key the belt shows it on (else the
// lowest free gun key, else the key of the gun it pushed out when that key is a pin, else none: v17.17 shows it), and moves the
// highlight off a gun cell that is not the gun in his hands, so the trigger never fires one gun under a key naming another.
var _gunKeyHint='';
function gunKeysSettle(o){
  o=o||{};
  if(!G||G.sim||G.over||G.hubFloor||!G.player) return;
  var p=G.player, A=(G.hotAssign=G.hotAssign||{}), U=(G.hotAuto=G.hotAuto||{}), k, i, sl, h, w, has, at;
  function holds(gk){ return !!((p.wep&&p.wep.id===gk)||(p.sec&&p.sec.id===gk)); }
  for(k in A){ var it=ITEMS[A[k]]; if(U[k]&&it&&it.use==='gun'&&!holds(it.gk)&&G.bag.indexOf(A[k])<0){ delete A[k]; delete U[k]; } }
  for(k in U) if(A[k]===undefined) delete U[k];
  var sw=!!p.swapped, HG=[sw?p.sec:p.wep, sw?p.wep:p.sec];
  for(h=0;h<2;h++){
    w=HG[h]; if(!w||w.id==='fists'||w.mag===0||!ITEMS['gun_'+w.id]) continue;
    has=false; for(k in A) if(A[k]==='gun_'+w.id) has=true;
    if(has) continue;
    sl=hotbarSlots(); at=-1;
    for(i=0;i<GUNKEYS&&at<0;i++) if(A[i]===undefined&&sl[i]&&sl[i].kind==='gun'&&!sl[i].assigned&&sl[i].icon===w.id) at=i;
    for(i=0;i<GUNKEYS&&at<0;i++) if(A[i]===undefined&&sl[i]&&sl[i].kind==='gun'&&!sl[i].assigned&&(sl[i].vacant||sl[i].icon==='fists')) at=i;
    if(at<0&&o.pushed&&o.pushed!==w.id) for(k in A) if(A[k]==='gun_'+o.pushed&&U[k]&&G.bag.indexOf(A[k])>=0){ at=+k; break; }
    if(at>=0){ A[at]='gun_'+w.id; U[at]=1; }
  }
  sl=hotbarSlots();
  var c=sl[G.hot];
  if(c&&c.kind==='gun'&&!c.inHand) G.hot=gunCell();
}
// v21.83: which hand slot a gun drawn from the backpack takes. A Bare Hands slot first (v10.62); else the gun in his hands, except
// when that is issued kit and the stowed gun can go into the backpack: then the stowed gun is given up, or the loaner would be
// left behind (equipFromBag) and its key would empty. 1 is the hand, 2 the stowed slot, as equipFromBag reads them.
function giveUpSlot(){
  var p=G.player;
  function free(x){ return !x||x.id==='fists'||x.mag===0; }
  if(free(p.wep)) return 1;
  if(free(p.sec)) return 2;
  if(p.wepIssued&&!p.secIssued&&ITEMS['gun_'+p.sec.id]) return 2;
  return 1;
}
// v21.83: draw a backpack gun into his hands by the give-up rule and bring it up if it landed stowed. The highlight stays on the
// key it was pressed from when that key shows it in his hands now. False when the equip refuses (rolling, paused, down).
function drawGun(ix){
  var p=G&&G.player, it=ITEMS[G.bag[ix]], h0=G.hot;
  if(!p||!it||it.use!=='gun') return false;
  _gunKeyHint='';
  if(!equipFromBag(ix,giveUpSlot())) return false;
  if(p.wep.id!==it.gk&&p.sec&&p.sec.id===it.gk){ swapGuns(); if(_gunKeyHint) say(p.wep.name+' up. '+_gunKeyHint); }
  var s=hotbarSlots();
  if(s[h0]&&s[h0].kind==='gun'&&s[h0].inHand) G.hot=h0;
  else if(!(s[G.hot]&&s[G.hot].kind==='gun'&&s[G.hot].inHand)) G.hot=gunCell();
  return true;
}
function autoBelt(key){
'@

SubRx @'
  say(_oldLine?(_oldLine+' '+_newLine):_newLine);
'@ @'
  // v21.83: the gun keys settle. The drawn gun keeps the key it was drawn from, or takes a free gun key, or the key of the gun it
  // pushed out; the gun pushed out keeps its own key in the backpack, and the line names that key.
  _gunKeyHint='';
  if(!G.sim){
    var _pushId=(oldW&&oldW.id!=='fists'&&oldW.mag!==0&&!oldIssued)?oldW.id:null;
    gunKeysSettle({pushed:_pushId});
    if(_pushId&&!_oldLine&&G.bag.indexOf('gun_'+_pushId)>=0&&!((p.wep&&p.wep.id===_pushId)||(p.sec&&p.sec.id===_pushId))&&G.hotAssign)
      for(var _pk in G.hotAssign) if(G.hotAssign[_pk]==='gun_'+_pushId){ _gunKeyHint=(oldW.name+' to backpack, key '+(+_pk+1)).toUpperCase(); break; }
  }
  var _eqLine=_oldLine?(_oldLine+' '+_newLine):_newLine;
  say(_gunKeyHint?(_eqLine.replace(/\.$/,'')+'. '+_gunKeyHint):_eqLine);
'@

SubRx @'
  } else {
    p.sec=WEAPONS.fists; p.secAmmo=0; p.secIssued=true; p.secFromArmory=false;
  }
  G.tel.weapon=p.wep.name;
'@ @'
  } else {
    p.sec=WEAPONS.fists; p.secAmmo=0; p.secIssued=true; p.secFromArmory=false;
  }
  G.tel.weapon=p.wep.name;
  gunKeysSettle();   // v21.83: the gun keeps its key in the backpack; the highlight goes to the gun in his hands
'@

SubRx @'
        p.sec=found; p.secAmmo=(ct&&ct.dropped)?takeRounds(found.id,found.mag):Math.ceil(found.mag/2); p.secIssued=false; p.secFromArmory=false;
'@ @'
        var _gkPush=(p.sec&&p.sec.id!=='fists'&&p.sec.mag!==0&&!p.secIssued)?p.sec.id:null;   // v21.83
        p.sec=found; p.secAmmo=(ct&&ct.dropped)?takeRounds(found.id,found.mag):Math.ceil(found.mag/2); p.secIssued=false; p.secFromArmory=false;
        gunKeysSettle({pushed:_gkPush});   // v21.83: the found gun takes a gun key; the gun it pushed out keeps its own
'@

SubRx @'
        p.wep=found; p.ammo=(ct&&ct.dropped)?takeRounds(found.id,found.mag):Math.ceil(p.wep.mag/2); p.wepIssued=false; p.wepFromArmory=false; p.reloading=0;   // v13.81
'@ @'
        var _gkPush2=(p.wep&&p.wep.id!=='fists'&&p.wep.mag!==0&&!p.wepIssued)?p.wep.id:null;   // v21.83
        p.wep=found; p.ammo=(ct&&ct.dropped)?takeRounds(found.id,found.mag):Math.ceil(p.wep.mag/2); p.wepIssued=false; p.wepFromArmory=false; p.reloading=0;   // v13.81
        gunKeysSettle({pushed:_gkPush2});   // v21.83: the found gun takes a gun key; the gun it pushed out keeps its own
'@

SubRx @'
  out.push({k:'gunA',name:A.name,kind:'gun',inHand:!sw,icon:A.id,
    count:(A.mag===0?null:Aam),c:A.tint||'#ffd48a'});
'@ @'
  // v21.83, the four-gun belt, build 2: the two hand cells are built here as before, but they no longer sit on keys 1 and 2 by
  // themselves. Keys 1 to GUNKEYS are gun keys: a gun pinned to one (gunKeysSettle) shows there wherever it is, and a gun key no
  // assignment takes is filled after the assignments below (the fill).
  var _hc=[{k:'gunA',name:A.name,kind:'gun',inHand:!sw,icon:A.id,
    count:(A.mag===0?null:Aam),c:A.tint||'#ffd48a'}];
'@

SubRx @'
  if(B) out.push({k:'gunB',name:B.name,kind:'gun',inHand:sw,icon:B.id,
    count:(B.mag===0?null:Bam),c:B.tint||'#ffd48a'});
  else out.push({k:'gunB',name:'Second weapon',kind:'gun',inHand:false,icon:null,
    count:0,c:'#4d5762',vacant:1});
'@ @'
  if(B) _hc.push({k:'gunB',name:B.name,kind:'gun',inHand:sw,icon:B.id,
    count:(B.mag===0?null:Bam),c:B.tint||'#ffd48a'});
  else _hc.push({k:'gunB',name:'Second weapon',kind:'gun',inHand:false,icon:null,
    count:0,c:'#4d5762',vacant:1});
  for(var _gk0=0;_gk0<GUNKEYS;_gk0++) out.push({k:'gunkey:'+_gk0,name:'Second weapon',kind:'gun',inHand:false,icon:null,count:0,c:'#4d5762',vacant:1,gunFill:1});
'@

SubRx @'
      if(!G.hotAuto[pa]) continue;
'@ @'
      if(!G.hotAuto[pa]) continue;
      if(pax<GUNKEYS&&ITEMS[G.hotAssign[pa]]&&ITEMS[G.hotAssign[pa]].use==='gun') continue;   // v21.83: a gun pin on a gun key never yields
'@

SubRx @'
  var _dGun=[out[0],out[1]];   // v17.17, belt hunt 2026-09-28: the two gun cells as derived, before any key covers them
'@ @'
  var _dGun=_hc;   // v17.17, belt hunt 2026-09-28: the two gun cells as derived, before any key covers them (v21.83: built aside above)
'@

SubRx @'
        count:(_eq.w.mag===0?null:_eq.am),c:_eq.w.tint||'#ffd48a',assigned:1,itemKey:akey,equipped:1};
'@ @'
        count:(_eq.w.mag===0?null:_eq.am),c:_eq.w.tint||'#ffd48a',assigned:1,itemKey:akey,equipped:1,auto:(G.hotAuto&&G.hotAuto[ai])?1:0};   // v21.83: auto, a gun pin
'@

SubRx @'
count:have,c:(_sq&&_sq.tint)||ait.c||'#cdd6dd',assigned:1,itemKey:akey,empty:(have<=0)?1:0};
'@ @'
count:have,c:(_sq&&_sq.tint)||ait.c||'#cdd6dd',assigned:1,itemKey:akey,empty:(have<=0)?1:0};
      // v21.83: a gun pin is marked as one, and a backpack gun on a gun key counts the rounds it will come back with (takeRounds).
      if(_agk&&have>0){
        if(G.hotAuto&&G.hotAuto[ai]) out[aix].auto=1;
        if(aix<GUNKEYS){ var _gsa=G.stowAmmo&&G.stowAmmo[_agk], _gsm=(_sq&&_sq.mag)||(WEAPONS[_agk]&&WEAPONS[_agk].mag)||0; out[aix].count=(_gsa&&_gsa.length)?Math.min(_gsm,Math.max(0,_gsa[0]|0)):Math.ceil(_gsm/2); }
      }
'@

SubRx @'
  for(var _dg=0;_dg<2;_dg++){
    var _gc=_dGun[_dg];
    if(!_gc||_gc.vacant||out[_dg]===_gc) continue;
'@ @'
  // v21.83, the four-gun belt, build 2: THE FILL. Each gun key no assignment took gets, in key order, a real gun in his hands that no
  // gun key shows (A then B), then Bare Hands (A then B), then a vacant gun cell. With no pins (the sim, the Undercroft) that is A
  // on key 1 and B on key 2, the cells of before. v17.17 below now places only what the fill could not.
  var _hcUsed=[false,false], _fk, _fh, _fp;
  function _hcReal(hc){ return !!(hc&&!hc.vacant&&hc.icon&&hc.icon!=='fists'&&hc.count!==null); }
  function _hcOnKey(hc){ for(var _ok=0;_ok<GUNKEYS;_ok++){ var _oc=out[_ok]; if(_oc&&_oc.equipped&&!!_oc.inHand===!!hc.inHand) return true; } return false; }
  for(_fk=0;_fk<GUNKEYS&&_fk<out.length;_fk++){
    if(!(out[_fk]&&out[_fk].gunFill)) continue;
    _fp=-1;
    for(_fh=0;_fh<2&&_fp<0;_fh++) if(!_hcUsed[_fh]&&_hcReal(_hc[_fh])&&!_hcOnKey(_hc[_fh])) _fp=_fh;
    for(_fh=0;_fh<2&&_fp<0;_fh++) if(!_hcUsed[_fh]&&_hc[_fh]&&!_hc[_fh].vacant&&!_hcReal(_hc[_fh])) _fp=_fh;
    if(_fp<0&&_hc[1]&&_hc[1].vacant&&!_hcUsed[1]) _fp=1;
    if(_fp>=0){ out[_fk]=_hc[_fp]; _hcUsed[_fp]=true; }
    else out[_fk]={k:'gunkey:'+_fk,name:(_fk<2?'Second weapon':(_fk===2?'Third weapon':'Fourth weapon')),kind:'gun',inHand:false,icon:null,count:0,c:'#4d5762',vacant:1};
  }
  for(var _dg=0;_dg<2;_dg++){
    var _gc=_dGun[_dg];
    if(!_gc||_gc.vacant||_hcUsed[_dg]) continue;
'@

SubRx @'
    for(var _gn=out.length-1;_gn>=2;_gn--)
'@ @'
    for(var _gn=out.length-1;_gn>=GUNKEYS;_gn--)
'@

SubRx @'
  if(i===G.hot&&!(sl[i]&&sl[i].kind==='gun'&&sl[i].itemKey&&!sl[i].equipped)) return;
  G.hot=i;
'@ @'
  if(i===G.hot&&!(sl[i]&&sl[i].kind==='gun'&&sl[i].itemKey&&!sl[i].equipped)) return;
  var _hot0=G.hot;   // v21.83: where the highlight goes back to when a draw is refused
  G.hot=i;
'@

SubRx @'
    else if(!equipFromBag(_bix,1)) say('Cannot equip '+s2.name+' right now.');
'@ @'
    else if(!drawGun(_bix)){ say('Cannot equip '+s2.name+' right now.'); G.hot=_hot0; }   // v21.83: by the give-up rule, and swapped up (drawGun); refused, the highlight goes back
'@

SubRx @'
      equipFromBag(ix,0); return;
'@ @'
      drawGun(ix); return;   // v21.83: the give-up rule, and up into his hands (equipFromBag(ix,0) could leave it stowed)
'@

SubRx @'
      if(S.assigned){
'@ @'
      if(S.assigned&&!S.auto){   // v21.83: not on a gun pin, which the game set, not he
'@

SubRx @'
        if(_hs2&&_dk&&!(_hs2.k==='gunA'||_hs2.k==='gunB')){
'@ @'
        // v21.83, the four-gun belt, build 2: a gun key showing a gun in his hands drags as the hand cell does (v11.97), named by the
        // hand it is in, so a release off the belt stows it and a release on another gun key trades the two keys. The press only
        // picks it up (v18.90); a click selects it on the release.
        var _pinHand=!!(_hs2&&_HC2.i<GUNKEYS&&_hs2.kind==='gun'&&_hs2.equipped&&_hs2.icon&&_hs2.icon!=='fists'&&G.player);
        if(_pinHand){
          var _phs=!!G.player.swapped;
          G.drag={key:'gun_'+_hs2.icon,gunSlot:(_hs2.inHand?(_phs?'gunB':'gunA'):(_phs?'gunA':'gunB')),fromHot:_HC2.i,px:mouse.x,py:mouse.y,pin:1};
          blip('pick');
        }
        else if(_hs2&&_dk&&!(_hs2.k==='gunA'||_hs2.k==='gunB')){
'@

SubRx @'
      if(_onCell<0&&_moved) bagHeldGun(d.gunSlot);
      else if(_onCell>=0&&_onCell!==d.fromHot){
        // v18.89, his report (2026-10-07): "can't move a gun from slot 8 to slot 1". A gun in a hand cell dropped on another belt key was always refused, so nothing could change which gun keys 1 and 2 show, and a gun the belt had moved down to key 8 or 9 (because an item is bound over its own key) could never go back. Dropped on the other gun's key, the two keys trade places (p.swapped; the hands do not change). Dropped back on its own key, the item bound there goes to the key the gun came from. Anywhere else it is refused in words, as before.
        var _gw8s=hotbarSlots(), _gw8t=_gw8s[_onCell], _gw8p=G.player, _gw8g=null, _gw8q, _gw8h=(d.gunSlot==='gunA')?0:1;
        for(_gw8q=0;_gw8q<_gw8s.length;_gw8q++) if(_gw8s[_gw8q]&&_gw8s[_gw8q].k===d.gunSlot){ _gw8g=_gw8s[_gw8q]; break; }
        var _gw8n=(_gw8g&&_gw8g.name)||'That gun';
        if(_gw8t&&(_gw8t.k==='gunA'||_gw8t.k==='gunB')&&_gw8t.k!==d.gunSlot&&_gw8p&&_gw8p.wep&&_gw8p.sec){
          _gw8p.swapped=!_gw8p.swapped; G.hot=gunCell(); blip('pick');
          // v19.18, from the review (2026-10-07): the words said the key he dropped on even when the belt shows that gun on another key
          // (a key he bound it to himself keeps showing it, so the moved-down cell is not drawn twice). They now name where it really is.
          var _gw8id=_gw8g&&_gw8g.icon, _gw8z=hotbarSlots(), _gw8at=-1, _gw8o=(_gw8t&&_gw8t.name)||'the other gun';
          if(_gw8z[_onCell]&&_gw8z[_onCell].kind==='gun'&&_gw8z[_onCell].icon===_gw8id) _gw8at=_onCell;
          else for(_gw8q=0;_gw8q<_gw8z.length;_gw8q++) if(_gw8z[_gw8q]&&_gw8z[_gw8q].kind==='gun'&&_gw8z[_gw8q].icon===_gw8id){ _gw8at=_gw8q; break; }
          say((_gw8at===_onCell)?(_gw8n+' to slot '+(_onCell+1)+'.'):(_gw8n+' traded places with '+_gw8o+(_gw8at>=0?('; '+_gw8n+' is on key '+(_gw8at+1)+'.'):'.')));
        }
        else if(_onCell===_gw8h&&d.fromHot>=2&&G.hotAssign&&G.hotAssign[_gw8h]!==undefined&&G.hotAssign[d.fromHot]===undefined){
          var _gw8c=G.hotAssign[_gw8h]; G.hotAuto=G.hotAuto||{}; var _gw8a=G.hotAuto[_gw8h];
          delete G.hotAssign[_gw8h]; delete G.hotAuto[_gw8h];
          G.hotAssign[d.fromHot]=_gw8c; if(_gw8a) G.hotAuto[d.fromHot]=1;
          if(!G.sim){ var _gw8f={}; for(var _gw8k in G.hotAssign) if(!G.hotAuto[_gw8k]) _gw8f[_gw8k]=G.hotAssign[_gw8k]; P.hotAssign=JSON.parse(JSON.stringify(hotKeepPruned(_gw8f))); try{ saveProfile(); }catch(_gw8e){} }
          G.hot=gunCell(); blip('pick');
          say(_gw8n+' to slot '+(_gw8h+1)+'. '+((ITEMS[_gw8c]&&ITEMS[_gw8c].name)||'Item')+' to slot '+(d.fromHot+1)+'.');
        }
        else say('Drop it off the belt to stow it in the backpack; its own key brings it up.');
      }
      d={key:null}; dropped=true;
'@ @'
      if(_onCell<0&&_moved){
        // v21.83: off the belt it goes into the backpack (v11.97), and a gun key pin comes off with it, so it leaves the belt.
        if(bagHeldGun(d.gunSlot)&&d.pin&&d.fromHot!==undefined&&G.hotAssign&&G.hotAssign[d.fromHot]===d.key&&G.hotAuto&&G.hotAuto[d.fromHot]){
          delete G.hotAssign[d.fromHot]; delete G.hotAuto[d.fromHot]; gunKeysSettle();
        }
      }
      else if(d.pin&&(_onCell===d.fromHot||_onCell<0)) setHot(d.fromHot);   // v21.83: a click on a gun key selects it there
      else if(_onCell>=0&&_onCell!==d.fromHot){
        // v21.83, the four-gun belt, build 2: dropped on another gun key, THE TWO KEYS TRADE WHAT THEY HOLD and the guns in his hands
        // stay as they are. This replaces the p.swapped flip of v18.89, which only meant something while keys 1 and 2 were the two
        // hands. A gun the belt shows there by itself (the fill, or moved down by v17.17) is pinned where it lands, and an item of
        // his on the gun key goes to the key the gun came from, as v18.89 sent it. Onto a key past the gun keys it is refused.
        var _gw8s=hotbarSlots(), _gw8t=_gw8s[_onCell], _gw8g=_gw8s[d.fromHot], _gw8n=(_gw8g&&_gw8g.name)||'That gun';
        if(_onCell<GUNKEYS){
          var _gwA=(G.hotAssign=G.hotAssign||{}), _gwU=(G.hotAuto=G.hotAuto||{});
          var _gwC=function(ix,c){ if(_gwA[ix]!==undefined) return {a:_gwA[ix],u:_gwU[ix]?1:0}; if(c&&(c.k==='gunA'||c.k==='gunB')&&!c.vacant&&c.icon&&c.icon!=='fists'&&ITEMS['gun_'+c.icon]) return {a:'gun_'+c.icon,u:1}; return null; };
          var _gwF=_gwC(d.fromHot,_gw8g), _gwT=_gwC(_onCell,_gw8t), _gwHis=!!((_gwF&&!_gwF.u)||(_gwT&&!_gwT.u));
          delete _gwA[d.fromHot]; delete _gwU[d.fromHot]; delete _gwA[_onCell]; delete _gwU[_onCell];
          if(_gwF){ _gwA[_onCell]=_gwF.a; if(_gwF.u) _gwU[_onCell]=1; }
          if(_gwT){ _gwA[d.fromHot]=_gwT.a; if(_gwT.u) _gwU[d.fromHot]=1; }
          if(_gwHis&&!G.sim){ var _gw8f={}; for(var _gw8k in _gwA) if(!_gwU[_gw8k]) _gw8f[_gw8k]=_gwA[_gw8k]; P.hotAssign=JSON.parse(JSON.stringify(hotKeepPruned(_gw8f))); try{ saveProfile(); }catch(_gw8e){} }
          G.hot=gunCell(); blip('pick');
          var _gwTi=_gwT&&ITEMS[_gwT.a];
          say((_gwTi&&_gwTi.use!=='gun')?(_gw8n+' to slot '+(_onCell+1)+'. '+_gwTi.name+' to slot '+(d.fromHot+1)+'.'):(_gw8n+' to slot '+(_onCell+1)+'.'));
        }
        else say('Drop it off the belt to stow it in the backpack; its own key brings it up.');
      }
      d={key:null}; dropped=true;
'@

SubRx @'
        var _siDerived=(_si&&(_si.k==='gunA'||_si.k==='gunB'));
        if(_si&&_siDerived&&_dit&&_dit.use==='gun'){
          var _pp=G.player;
          var _bx=(G.bag[d.bagIx]===d.key)?d.bagIx:G.bag.indexOf(d.key);
          // v18.87, his report (2026-10-07): "can't move a gun from slot 8 to slot 1". A gun on key 8 that is already in his hands is not in the backpack (equipFromBag took it out the first time key 8 brought it up), so this drop looked for it there, found nothing, did nothing and said nothing. Keys 1 and 2 show his two guns by p.swapped alone, so turning it over puts the gun on the key he let go on without changing what is in his hands, and the key it came from lets it go, as any item moved between keys does.
          var _r8gk=_dit.gk, _r8on=(_bx<0&&!!_r8gk&&((_pp.wep&&_pp.wep.id===_r8gk)||(_pp.sec&&_pp.sec.id===_r8gk)));
          if(_r8on){
            var _r8w=(_pp.wep&&_pp.wep.id===_r8gk)?_pp.wep:_pp.sec;
            // v19.12, from the review (2026-10-07): the key the drag came from is let go FIRST, tentatively, so a gun cell the belt had
            // moved down (v17.17) can show again on the key it was dropped on; before, its own binding hid it and the drop was refused
            // with p.swapped left flipped, key 1 showing the wrong gun, the trigger on the old cell and the words saying his only gun.
            // A refusal now puts the binding and p.swapped back, keeps the trigger on the gun in his hands and says what happened.
            var _r8sw=_pp.swapped, _r8had=(d.fromHot!==undefined&&d.fromHot!==HC.i&&G.hotAssign&&G.hotAssign[d.fromHot]===d.key), _r8au=(_r8had&&G.hotAuto)?G.hotAuto[d.fromHot]:undefined;
            if(_r8had){ delete G.hotAssign[d.fromHot]; if(G.hotAuto) delete G.hotAuto[d.fromHot]; }
            if(_si.icon!==_r8gk&&_pp.wep&&_pp.sec) _pp.swapped=!_pp.swapped;
            var _r8s=hotbarSlots();
            if(!(_r8s[HC.i]&&_r8s[HC.i].kind==='gun'&&_r8s[HC.i].icon===_r8gk)){
              _pp.swapped=_r8sw; if(_r8had){ G.hotAssign[d.fromHot]=d.key; if(G.hotAuto&&_r8au!==undefined) G.hotAuto[d.fromHot]=_r8au; }
              G.hot=gunCell();
              say((_pp.wep&&_pp.sec&&_pp.wep.id!=='fists'&&_pp.sec.id!=='fists')?(_r8w.name+' cannot go on key '+(HC.i+1)+'; it stays where it is.'):(_r8w.name+' stays where it is: it is your only gun, so there is no other gun for it to trade places with.'));
            }
            else if(_r8s[HC.i]&&_r8s[HC.i].kind==='gun'&&_r8s[HC.i].icon===_r8gk){
              if(_r8had){
                if(!G.sim){ var _r8f={}; for(var _r8k in G.hotAssign) if(!G.hotAuto||!G.hotAuto[_r8k]) _r8f[_r8k]=G.hotAssign[_r8k]; P.hotAssign=JSON.parse(JSON.stringify(hotKeepPruned(_r8f))); try{ saveProfile(); }catch(_r8e){} }
              }
              G.hot=gunCell(); blip('pick');
              say(_r8w.name+' to slot '+(HC.i+1)+'.');
            }
            else say(_r8w.name+' stays where it is: it is your only gun, so there is no other gun for it to trade places with.');
          }
          else if(_bx<0) say(_dit.name+' is no longer in your backpack.');
          if(_bx>=0){
            var _isA=(_si.k==='gunA');
            var _tgt=_isA?(_pp.swapped?2:1):(_pp.swapped?1:2);
            // v18.88, his report (2026-10-07): "can't move a gun from slot 8 to slot 1". A backpack gun dropped on key 1 while key 2 held Bare Hands went to key 2 instead (the v10.62 free-slot rule, which is for a key press and a pickup), and key 8 kept showing it, so the next try found it out of the backpack and did nothing. A drop goes on the key he let go on: the gun fills the free hand slot, keys 1 and 2 trade places (p.swapped) so it shows where he dropped it and the gun he had stays in his hands, and the key it came from lets it go. A refusal says why.
            var _r9t=(_tgt===2)?_pp.sec:_pp.wep, _r9o=(_tgt===2)?_pp.wep:_pp.sec;
            var _r9f=!!(_r9t&&_r9t.id!=='fists'&&_r9t.mag!==0&&(!_r9o||_r9o.id==='fists'||_r9o.mag===0));
            if(!equipFromBag(_bx,_r9f?(_tgt===2?1:2):_tgt)){
              say(_pp.roll>0?'Cannot equip a gun while rolling.':(G.paused?'Cannot equip a gun while paused.':((_pp.downed||_pp.dying)?'Cannot equip a gun while down.':'Cannot equip that right now.')));
            } else {
              if(_r9f) _pp.swapped=!_pp.swapped;
              if(d.fromHot!==undefined&&G.hotAssign&&G.hotAssign[d.fromHot]===d.key){
                delete G.hotAssign[d.fromHot]; if(G.hotAuto) delete G.hotAuto[d.fromHot];
                if(!G.sim){ var _r9p={}; for(var _r9k in G.hotAssign) if(!G.hotAuto||!G.hotAuto[_r9k]) _r9p[_r9k]=G.hotAssign[_r9k]; P.hotAssign=JSON.parse(JSON.stringify(hotKeepPruned(_r9p))); try{ saveProfile(); }catch(_r9e){} }
              }
              if(_r9f||G.hot===d.fromHot) G.hot=gunCell();
              if(_r9f){
                var _r9n=(_tgt===2)?_pp.wep:_pp.sec, _r9s=hotbarSlots(), _r9i=-1, _r9q;
                for(_r9q=0;_r9q<_r9s.length;_r9q++) if(_r9s[_r9q]&&(_r9s[_r9q].k==='gunA'||_r9s[_r9q].k==='gunB')&&_r9s[_r9q].icon===_r9t.id){ _r9i=_r9q; break; }
                say(_r9n.name+' to slot '+(HC.i+1)+'.'+(_r9i>=0?(' '+_r9t.name+' to slot '+(_r9i+1)+'.'):''));
              }
            }
          }
          dropped=true;
          break;
        }
'@ @'
        // v21.83, the four-gun belt, build 2: a gun-key cell is any cell on keys 1 to GUNKEYS that shows a gun, Bare Hands or a vacant
        // gun slot (kind gun). A gun key he covered with an item of his own stays an ordinary key (v8.14).
        var _siDerived=!!(_si&&HC.i<GUNKEYS&&_si.kind==='gun');
        if(_si&&_siDerived&&_dit&&_dit.use==='gun'){
          // v21.83: A GUN DROPPED ON A GUN KEY TAKES THAT KEY. What was there goes to the key the gun came from, else the lowest free
          // gun key, else it has no key and the line says so. A backpack gun then comes up into his hands (v18.88), giving up the gun
          // that key showed when that is one of his two, else by the give-up rule; a gun already in his hands stays as it is
          // (v18.87). Rolling, paused or down, nothing changes and the line says why. A drop back on its own key is the click.
          var _pp=G.player, _r8gk=_dit.gk, _gq;
          var _bx=(G.bag[d.bagIx]===d.key)?d.bagIx:G.bag.indexOf(d.key);
          var _r8on=!!_r8gk&&!!((_pp.wep&&_pp.wep.id===_r8gk)||(_pp.sec&&_pp.sec.id===_r8gk))&&(_bx<0||d.fromHot!==undefined);
          if(d.fromHot===HC.i){ setHot(HC.i); dropped=true; break; }
          if(!_r8on&&_bx<0){ say(_dit.name+' is no longer in your backpack.'); dropped=true; break; }
          if(!_r8on&&(_pp.roll>0||G.paused||_pp.downed||_pp.dying)){ say(_pp.roll>0?'Cannot equip a gun while rolling.':(G.paused?'Cannot equip a gun while paused.':((_pp.downed||_pp.dying)?'Cannot equip a gun while down.':'Cannot equip that right now.'))); dropped=true; break; }
          var _gA=(G.hotAssign=G.hotAssign||{}), _gU=(G.hotAuto=G.hotAuto||{});
          var _gOld=(_gA[HC.i]!==undefined)?{a:_gA[HC.i],u:_gU[HC.i]?1:0}:(((_si.k==='gunA'||_si.k==='gunB')&&!_si.vacant&&_si.icon&&_si.icon!=='fists'&&ITEMS['gun_'+_si.icon])?{a:'gun_'+_si.icon,u:1}:null);
          var _gOldHand=(!_si.vacant&&_si.icon&&_si.icon!=='fists'&&(_si.equipped||_si.k==='gunA'||_si.k==='gunB'))?(_si.inHand?1:2):0;
          if(_gOld&&_gOld.a===d.key){ G.hot=gunCell(); dropped=true; break; }
          var _gHis=!!(_gOld&&!_gOld.u);
          for(_gq in _gA) if(_gA[_gq]===d.key){ if(!_gU[_gq]) _gHis=true; delete _gA[_gq]; delete _gU[_gq]; }
          _gA[HC.i]=d.key; _gU[HC.i]=1;
          var _gLost='';
          if(_gOld){
            var _gTo=-1, _gOid=ITEMS[_gOld.a]&&ITEMS[_gOld.a].gk;
            if(d.fromHot!==undefined&&_gA[d.fromHot]===undefined) _gTo=d.fromHot;
            else { var _gS=hotbarSlots(); for(_gq=0;_gq<GUNKEYS&&_gTo<0;_gq++) if(_gq!==HC.i&&_gA[_gq]===undefined&&_gS[_gq]&&_gS[_gq].kind==='gun'&&!_gS[_gq].assigned&&(_gS[_gq].vacant||_gS[_gq].icon==='fists'||_gS[_gq].icon===_gOid)) _gTo=_gq; }
            if(_gTo>=0){ _gA[_gTo]=_gOld.a; if(_gOld.u) _gU[_gTo]=1; }
            else _gLost=' '+(String(_si.name||'Gun')+': no key').toUpperCase();
          }
          if(_gHis&&!G.sim){ var _gF={}; for(var _gFk in _gA) if(!_gU[_gFk]) _gF[_gFk]=_gA[_gFk]; P.hotAssign=JSON.parse(JSON.stringify(hotKeepPruned(_gF))); try{ saveProfile(); }catch(_gFe){} }
          if(_r8on){
            G.hot=gunCell(); blip('pick');
            var _gNow=hotbarSlots()[HC.i];
            say(((_gNow&&_gNow.name)||_dit.name)+' to slot '+(HC.i+1)+'.'+_gLost);
          } else {
            var _gSlot=(_gOldHand===1&&!_pp.wepIssued)?1:((_gOldHand===2&&!_pp.secIssued)?2:giveUpSlot());
            if(!equipFromBag(_bx,_gSlot)) say('Cannot equip that right now.');
            else {
              if(_pp.wep.id!==_r8gk&&_pp.sec&&_pp.sec.id===_r8gk) swapGuns();
              G.hot=HC.i;
              var _gUp=hotbarSlots()[HC.i];
              if(!(_gUp&&_gUp.kind==='gun'&&_gUp.inHand)) G.hot=gunCell();
              say(((_gUp&&_gUp.name)||_dit.name)+' to slot '+(HC.i+1)+'.'+_gLost+(_gunKeyHint?' '+_gunKeyHint:''));
            }
          }
          dropped=true;
          break;
        }
'@

SubRx @'
var VER='21.82';
'@ @'
var VER='21.83';
'@

$pat = "(?m)^  now:'v21\.82:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.83: A gun keeps its belt key when you draw it or put it away, so key 1 stays your rifle. Check 21.83 fails on v21.82',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
