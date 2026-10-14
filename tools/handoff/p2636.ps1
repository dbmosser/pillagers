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

# EVERY GUN HAS ITS OWN KEY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var _gunKeyHint='';
function gunKeysSettle(o){
'@ @'
// v26.xx (gunkeys1), HIS ORDER 2026-10-14: "could we make it so the gun always goes to the same slot on the bar so the player always presses the same
// button to access it?" THE CLASS KEYS. Every gun model has a class and every class has a key, so a gun always lands on the same key. His table:
// 1 pistol (Scav Pistol, Magnum), 2 SMG (Compact SMG), 3 rifle (Auto Rifle), 4 carbine (Burst Carbine), 5 LMG (Support MG), 6 shotgun (Riot
// Scattergun), 7 marksman (Marksman Rifle, Whisper), 8 sniper (Longshot), 9 energy (Meridian Lance). A rarity twin (<gun>_v) is its model's class.
// A gun that arrives goes to the key that already holds its class; else to its class key when that is free; else to the lowest free gun key; else
// to the backpack. When its class is already on a key, the better gun by the stat card (the tier, then the damage a second: beltGunLow) keeps the
// key and the other goes to the backpack with no key. When the gun it beats is in his hands (or stowed) it swaps in at once and the rounds in the
// magazine come with it, up to the new magazine (what does not fit stays with the gun that goes to the backpack). This replaces the v25.xx (belt1)
// rule that a tenth gun takes the key of the weakest. A drag on the bar still moves a gun to any key, for this raid only: the table is the default
// and the plan on the profile is not written by a raid drag. The table is P.gunKeys when the stash set one (CAREER); DEMO always uses his table.
var GUN_CLASSES=['pistol','smg','rifle','carbine','lmg','shotgun','marksman','sniper','energy'];
var GUN_CLASS_OF={pistol:'pistol',magnum:'pistol',tacker:'pistol',smg:'smg',sputter:'smg',rifle:'rifle',chatter:'rifle',carbine:'carbine',lmg:'lmg',shotgun:'shotgun',scuttle:'shotgun',dmr:'marksman',whisper:'marksman',sniper:'sniper',lance:'energy'};
function gunClassOf(gk){ var b=(typeof RV_BASE==='object'&&RV_BASE&&RV_BASE[gk])||gk; return Object.prototype.hasOwnProperty.call(GUN_CLASS_OF,b)?GUN_CLASS_OF[b]:''; }
function gunKeyTable(){   // the class on each key, from the profile when it holds a whole table (nine classes, each once), else his table
  var src=(typeof P==='object'&&P&&Array.isArray(P.gunKeys))?P.gunKeys:null, ok=!!src&&src.length===GUN_CLASSES.length, seen={}, i;
  for(i=0;ok&&i<src.length;i++){ if(GUN_CLASSES.indexOf(src[i])<0||seen[src[i]]) ok=false; else seen[src[i]]=1; }
  return ok?src:GUN_CLASSES;
}
function gunKeyList(){ return (typeof G==='object'&&G&&G.arcade&&!G.career)?GUN_CLASSES:gunKeyTable(); }   // DEMO always uses his table
function gunClassKey(cls){ return cls?gunKeyList().indexOf(cls):-1; }
// the gun a belt cell shows: {gk, w (the gun as it is), where: hand, sec or bag, key (its item key when a key holds it)}, or null
function gunKeyOcc(gs){
  var p=G&&G.player, bk;
  if(!p||!(gs&&gs.kind==='gun'&&!gs.vacant&&gs.icon&&gs.icon!=='fists')) return null;
  if(gs.itemKey&&!gs.equipped){
    bk=ITEMS[gs.itemKey];
    return (bk&&bk.use==='gun'&&bk.gk)?{gk:bk.gk,w:gunQPeek(bk.gk)||beltGunField(bk.gk),where:'bag',key:gs.itemKey}:null;
  }
  if(p.wep&&p.wep.id===gs.icon&&p.wep.id!=='fists'&&p.wep.mag!==0) return {gk:p.wep.id,w:p.wep,where:'hand',key:gs.itemKey||null};
  if(p.sec&&p.sec.id===gs.icon&&p.sec.id!=='fists'&&p.sec.mag!==0) return {gk:p.sec.id,w:p.sec,where:'sec',key:gs.itemKey||null};
  return null;
}
// the first gun key whose gun is of class cls: {i, o} or null
function gunClassHeld(sl,cls){
  var i, o;
  if(!cls) return null;
  for(i=0;i<GUNKEYS&&i<sl.length;i++){ o=gunKeyOcc(sl[i]); if(o&&gunClassOf(o.gk)===cls) return {i:i,o:o}; }
  return null;
}
// the key a gun with no key takes: its class key when free, else the lowest free gun key, else -1. A packed gun (bagGun) takes none when a gun of its class already has a key.
function gunKeyFor(gk,sl,A,bagGun){
  var cls=gunClassOf(gk), ck=gunClassKey(cls), i;
  function ok(j){ var c=sl[j]; return A[j]===undefined&&!!c&&c.kind==='gun'&&!c.assigned&&(c.vacant||c.icon===gk||(c.icon==='fists'&&!c.inHand)); }
  if(bagGun&&gunClassHeld(sl,cls)) return -1;
  if(ck>=0&&ck<GUNKEYS&&ok(ck)) return ck;
  for(i=0;i<GUNKEYS;i++) if(ok(i)) return i;
  return -1;
}
// a better gun of the class swaps in for the gun in his hands (o.where hand) or the stowed gun (sec): the find leaves the backpack, the old gun goes in with what the magazine
// could not carry across, the key now names the find. Issued kit is left behind, as everywhere.
function gunClassSwapIn(o,oi,key,nw){
  var p=G.player, A=G.hotAssign, U=(G.hotAuto=G.hotAuto||{}), gk=ITEMS[key].gk, hand=(o.where==='hand'), old=hand?p.wep:p.sec, oam=(hand?p.ammo:p.secAmmo)|0;
  var issued=hand?p.wepIssued:p.secIssued, arm=hand?p.wepFromArmory:p.secFromArmory, nc={}, k2, ix, carry, bagged=false;
  ix=G.bag.lastIndexOf(key); if(ix>=0){ G.bag.splice(ix,1); gunQTrim(gk); }
  for(k2 in nw) nc[k2]=nw[k2];
  carry=Math.min(nc.mag|0,oam);
  if(!issued&&ITEMS['gun_'+old.id]){
    G.bag.push('gun_'+old.id); stowRounds(old.id,oam-carry); gunQPush(old); bagged=true;
    if(arm&&P&&P.weapons){ ix=P.weapons.indexOf(old.id); if(ix>=0){ P.weapons.splice(ix,1); (G.spliced=G.spliced||[]).push(old.id); (P.raidSpliced=P.raidSpliced||[]).push(old.id); } }
  }
  if(hand){ p.wep=nc; p.ammo=carry; p.wepIssued=false; p.wepFromArmory=false; p.reloading=0; G.tel.weapon=nc.name; }
  else { p.sec=nc; p.secAmmo=carry; p.secIssued=false; p.secFromArmory=false; }
  G.tel.gunsEquipped=(G.tel.gunsEquipped||0)+1;
  for(k2 in A) if(A[k2]===key){ delete A[k2]; delete U[k2]; }
  A[oi]=key; U[oi]=1;
  BELTAT=oi;
  BELTDISP={item:'gun_'+old.id,name:String(old.name||old.id),tag:bagged?'BACKPACK':'LEFT BEHIND'};
  if(bagged&&bagWeight()>PACKCAP[P.pack]){ ix=G.bag.lastIndexOf('gun_'+old.id); if(ix>=0){ dropItem(ix); say('BACKPACK FULL','pick',{key:'bagfull',c:'danger',sub:(BELTDISP.name+' dropped').toUpperCase()}); BELTDISP=null; } }
  if(hand) G.hot=gunCell();
  if(!gearFoley('swap',nc)) blip('pick');
}
// a gun that arrived (already in the backpack, as autoBelt is called): where it goes by the class keys. Returns the line, as autoBelt did.
function gunClassPlace(key,quiet,slots,xo){
  var it=ITEMS[key], gk=it.gk, A=G.hotAssign, U=(G.hotAuto=G.hotAuto||{}), q=G.stowQ&&G.stowQ[gk], txt, at, h;
  var nw=(xo&&xo.found)||((q&&q.length)?q[q.length-1]:null)||beltGunField(gk);
  h=gunClassHeld(slots,gunClassOf(gk));
  if(h){
    if(!beltGunLow(h.o.w,nw)){ BELTAT=-2; txt=(it.name+' to backpack').toUpperCase(); if(!quiet) say(txt); return txt; }
    if(h.o.where==='bag'){
      A[h.i]=key; U[h.i]=1; BELTAT=h.i;
      BELTDISP={item:h.o.key,name:String(h.o.w.name||ITEMS[h.o.key].name),tag:'BACKPACK'};
    } else gunClassSwapIn(h.o,h.i,key,nw);
    at=h.i;
  } else {
    at=gunKeyFor(gk,slots,A,false);
    if(at<0){ BELTAT=-2; txt=(it.name+' to backpack').toUpperCase(); if(!quiet) say(txt); return txt; }
    A[at]=key; U[at]=1; BELTAT=at;
  }
  txt=(it.name+' to slot '+(at+1)).toUpperCase();
  if(!quiet){ say(txt); if(BELTDISP){ say(BELTDISP.name,'pick',{item:BELTDISP.item,tag:BELTDISP.tag}); BELTDISP=null; } }
  return txt;
}
// the DEMO pickup route (arcadeGunLoot): a better gun of a class he already has on a key swaps in by the same rule; null when it is not that case
function gunClassUpgrade(ct,key,itm,found){
  var gk=itm.gk, h;
  if(!G||G.sim||G.hubFloor||!found||!gunClassOf(gk)) return null;
  h=gunClassHeld(hotbarSlots(),gunClassOf(gk));
  if(!h||h.o.gk===gk||!beltGunLow(h.o.w,found)) return null;
  G.bag.push(key);
  if(ct&&ct.dropped) gunQTrim(gk,gunQCount(gk)-1); else gunQPush(found);
  autoBelt(key,1,{found:found,dropped:!!(ct&&ct.dropped)});
  if(BELTDISP){ say(BELTDISP.name,'pick',{item:BELTDISP.item,tag:BELTDISP.tag}); BELTDISP=null; }
  if(found.qRank>=2) blip('pickGun');
  return {tag:(BELTAT>=0)?('SLOT '+(BELTAT+1)):'BACKPACK',line:''};
}
var _gunKeyHint='';
function gunKeysSettle(o){
'@

SubRx @'
  if(o.deploy) for(h=0;h<2&&h<GUNKEYS;h++){
    w=HG[h]; if(!w||w.id==='fists'||w.mag===0||!ITEMS['gun_'+w.id]||A[h]!==undefined) continue;
    has=false; for(k in A) if(A[k]==='gun_'+w.id) has=true;
    if(!has){ A[h]='gun_'+w.id; U[h]=1; }
  }
'@ @'
  if(o.deploy) for(h=0;h<2&&h<GUNKEYS;h++){
    w=HG[h]; if(!w||w.id==='fists'||w.mag===0||!ITEMS['gun_'+w.id]) continue;
    has=false; for(k in A) if(A[k]==='gun_'+w.id) has=true;
    if(has) continue;
    at=gunKeyFor(w.id,hotbarSlots(),A,false);   // v26.xx (gunkeys1): a gun in his hands takes its class key, else the lowest free gun key
    if(at>=0){ A[at]='gun_'+w.id; U[at]=1; }
  }
'@

SubRx @'
      at=-1;
      for(_dj=2;_dj<GUNKEYS&&at<0;_dj++) if(A[_dj]===undefined&&_dsl[_dj]&&_dsl[_dj].kind==='gun'&&!_dsl[_dj].assigned&&(_dsl[_dj].vacant||(_dsl[_dj].icon==='fists'&&!_dsl[_dj].inHand))) at=_dj;
      if(at<0) break;
'@ @'
      at=gunKeyFor(_dit.gk,_dsl,A,true);   // v26.xx (gunkeys1): a packed gun takes its class key, and no key when a gun of its class already has one
      if(at<0) continue;
'@

SubRx @'
    sl=hotbarSlots(); at=-1;
    for(i=0;i<GUNKEYS&&at<0;i++) if(A[i]===undefined&&sl[i]&&sl[i].kind==='gun'&&!sl[i].assigned&&sl[i].icon===w.id) at=i;
    for(i=0;i<GUNKEYS&&at<0;i++) if(A[i]===undefined&&sl[i]&&sl[i].kind==='gun'&&!sl[i].assigned&&(sl[i].vacant||sl[i].icon==='fists')) at=i;
'@ @'
    sl=hotbarSlots(); at=gunKeyFor(w.id,sl,A,false);   // v26.xx (gunkeys1): its class key when free, else the lowest free gun key
'@

SubRx @'
  if(it.use==='gun'){
    if(G.hubFloor) return;
'@ @'
  if(it.use==='gun'){
    if(G.hubFloor) return;
    return gunClassPlace(key,quiet,slots,xo);   // v26.xx (gunkeys1), HIS ORDER 2026-10-14: a gun goes to its class key (gunClassPlace); the rules below (the lowest free key, the weakest gun replaced by a tenth) no longer run
'@

SubRx @'
  if(G.hubFloor) for(_fk=0;_fk<2&&_fk<GUNKEYS&&_fk<out.length;_fk++)
'@ @'
  // v26.xx (gunkeys1): ON THE FLOOR EACH GUN SHOWS ON ITS CLASS KEY, the key the raid start gives it (gunKeysSettle): the guns in his hands first, then the packed guns in packed
  // order. A packed gun whose class already has a key shows nowhere: it goes up in the backpack with no key.
  if(G.hubFloor){
    var _ckA, _ckL=[], _ckP, _ckI, _ckM, _ckT;
    for(_fh=0;_fh<2;_fh++) if(_hcReal(_hc[_fh])&&!_hcUsed[_fh]){ _ckA=gunClassKey(gunClassOf(_hc[_fh].icon)); if(_ckA>=0&&out[_ckA]&&out[_ckA].gunFill){ out[_ckA]=_hc[_fh]; _hcUsed[_fh]=true; } }
    while((_ckP=_hcPacked())) _ckL.push(_ckP);
    for(_ckI=0;_ckI<_ckL.length;_ckI++){
      _ckT=ITEMS[_ckL[_ckI]]; _ckM=(WEAPONS[_ckT.gk]&&WEAPONS[_ckT.gk].mag)||0; _ckA=gunClassKey(gunClassOf(_ckT.gk));
      if(_ckA>=0&&out[_ckA]&&out[_ckA].gunFill) out[_ckA]={k:'item:'+_ckL[_ckI],name:_ckT.name,icon:_ckL[_ckI],kind:'gun',inHand:false,count:Math.ceil(_ckM/2),c:_ckT.c||'#cdd6dd',itemKey:_ckL[_ckI],floorGun:1,mag:_ckM};
    }
  }
  if(G.hubFloor) for(_fk=0;_fk<2&&_fk<GUNKEYS&&_fk<out.length;_fk++)
'@

SubRx @'
    if(!moved) plan[s]=pr[s];
  }
  return plan;
}
'@ @'
    if(!moved) plan[s]=pr[s];
  }
  // v26.xx (gunkeys1), HIS ORDER 2026-10-14: "players should still be able to drag guns around on the bar, this is just the default". A drag on the raid bar moves a gun for THIS
  // raid; it never rewrites the keys his plan on the profile gives the guns (the class keys are the default, and the plan is only what the stash set).
  var _kq, _kw=(typeof P==='object'&&P&&P.hotAssign)||{};
  for(_kq in plan) if(ITEMS[plan[_kq]]&&ITEMS[plan[_kq]].use==='gun') delete plan[_kq];
  for(_kq in _kw) if(ITEMS[_kw[_kq]]&&ITEMS[_kw[_kq]].use==='gun'&&plan[_kq]===undefined) plan[_kq]=_kw[_kq];
  return plan;
}
'@

SubRx @'
  var p=G.player, T=G.tel, gk=itm.gk, ft=WTIER[gk]||0, st, worst=99, j, it2, k, n, push=null, oi, pk;
'@ @'
  var p=G.player, T=G.tel, gk=itm.gk, ft=WTIER[gk]||0, st, worst=99, j, it2, k, n, push=null, oi, pk;
  var _gcu=gunClassUpgrade(ct,key,itm,found); if(_gcu) return _gcu;   // v26.xx (gunkeys1), HIS ORDER 2026-10-14: a better rarity of a gun of a class he has on a key swaps in, in DEMO as in CAREER
'@

SubRx @'
var VER='26.35';
'@ @'
var VER='26.36';
'@

$pat = "(?m)^  now:'v26\.35:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.36: Every kind of gun has its own key on the bar, and a better rarity of the gun you hold swaps in at once with your rounds. Check 26.36 fails on v26.35',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
