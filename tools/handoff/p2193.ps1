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

# FOUR GUN KEYS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// one keeps it in his hands and in the backpack (gunKeysSettle). Two for now, so keys 1 and 2 read as they always have.
var GUNKEYS=2;
'@ @'
// one keeps it in his hands and in the backpack (gunKeysSettle).
// v21.93, HIS ORDER OF 2026-10-09, build 3: "MAKE THE GUNS GO TO SLOTS 1-4 AND THEN EVERYTHING ELSE SLIDES DOWN BY 2" and "THEN
// ADDTNL GUNS GO TO BACKPACK AFTER 4 GUNS ON BELT". Four gun keys: Smoke, Decoy and Frag are keys 5 to 7, Medical key 8, a plate
// key 9. A fifth gun goes into the backpack with no key (autoBelt). Old saved belt plans slide down two once (beltSlidePlan).
var GUNKEYS=4;
'@

SubRx @'
function applyLoadedProfile(r){
'@ @'
// v21.93, the four-gun belt, build 3: AN OLD SAVED BELT PLAN SLIDES DOWN TWO, ONCE (P.beltV=2). Keys 1 and 2 stay as he set them;
// a gun he bound to keys 3 to 9 moves to key 3, then key 4; everything else moves down two, so a Frag on key 5 is on key 7, where
// the Frag now sits; a key pushed past key 9 takes the highest free key from 9 down. A new profile is born with beltV set.
function beltSlidePlan(h){
  if(!h||typeof h!=='object') return h;
  var out={}, ks=[], rest=[], over=[], k, i, j, ix, gn=2;
  for(k in h) if(Object.prototype.hasOwnProperty.call(h,k)&&h[k]!==undefined&&h[k]!==null&&isFinite(+k)) ks.push(+k);
  ks.sort(function(a,b){ return a-b; });
  for(i=0;i<ks.length;i++){
    ix=ks[i];
    if(ix<2) out[ix]=h[ix];
    else if(String(h[ix]).indexOf('gun_')===0&&gn<4) out[gn++]=h[ix];
    else rest.push(ix);
  }
  for(i=0;i<rest.length;i++){ ix=rest[i]+2; if(ix<HOTBAR_N&&out[ix]===undefined) out[ix]=h[rest[i]]; else over.push(h[rest[i]]); }
  for(i=0;i<over.length;i++) for(j=HOTBAR_N-1;j>=0;j--) if(out[j]===undefined){ out[j]=over[i]; break; }
  return out;
}
function applyLoadedProfile(r){
'@

SubRx @'
if(P.hotAssignAuto){ P.hotAssign={}; delete P.hotAssignAuto; } if(!P.menuZoom)P.menuZoom=1.3; if(P.menuZoom<1)P.menuZoom=1;   /* v10.22: never below the screen */ if(!Array.isArray(P.kit))P.kit=[]; if(!Array.isArray(P.dropKit))P.dropKit=[];
'@ @'
if(P.hotAssignAuto){ P.hotAssign={}; delete P.hotAssignAuto; } if(!P.menuZoom)P.menuZoom=1.3; if(P.menuZoom<1)P.menuZoom=1;   /* v10.22: never below the screen */ if(!Array.isArray(P.kit))P.kit=[]; if(!Array.isArray(P.dropKit))P.dropKit=[];
// v21.93, the four-gun belt, build 3: the plan, the plan set aside for the freebie kit and the one kept from before it slide down
// two, once (beltSlidePlan above).
if(P.beltV!==2){
  P.hotAssign=beltSlidePlan(P.hotAssign||{});
  if(P.kitSaved&&P.kitSaved.hot) P.kitSaved.hot=beltSlidePlan(P.kitSaved.hot);
  if(P.hotBeforeFree) P.hotBeforeFree=beltSlidePlan(P.hotBeforeFree);
  P.beltV=2;
}
'@

SubRx @'
  mig739:1,mig945:1,
'@ @'
  mig739:1,mig945:1,beltV:2,   // v21.93: beltV, the four-gun belt plan, born set (beltSlidePlan)
'@

SubRx @'
    if(!has){ A[h]='gun_'+w.id; U[h]=1; }
  }
  for(h=0;h<2;h++){
'@ @'
    if(!has){ A[h]='gun_'+w.id; U[h]=1; }
  }
  // v21.93, the four-gun belt, build 3: AT THE RAID START THE PACKED GUNS TAKE KEYS 3 AND 4, in backpack order, as the Undercroft belt
  // showed them: a key no key of his covers that shows a vacant gun slot or stowed Bare Hands. One key per kind of gun, none for a copy of
  // a gun in his hands, and the rest stay in the backpack with no key.
  if(o.deploy){
    var _dsl=hotbarSlots(), _dseen={}, _di, _dj, _dk, _dit;
    for(_di=0;_di<G.bag.length;_di++){
      _dk=G.bag[_di]; _dit=ITEMS[_dk];
      if(!_dit||_dit.use!=='gun'||!_dit.gk||_dseen[_dk]) continue;
      _dseen[_dk]=1;
      if(holds(_dit.gk)) continue;
      has=false; for(k in A) if(A[k]===_dk) has=true;
      if(has) continue;
      at=-1;
      for(_dj=2;_dj<GUNKEYS&&at<0;_dj++) if(A[_dj]===undefined&&_dsl[_dj]&&_dsl[_dj].kind==='gun'&&!_dsl[_dj].assigned&&(_dsl[_dj].vacant||(_dsl[_dj].icon==='fists'&&!_dsl[_dj].inHand))) at=_dj;
      if(at<0) break;
      A[at]=_dk; U[at]=1; _dsl=hotbarSlots();
    }
  }
  for(h=0;h<2;h++){
'@

SubRx @'
  G.hotAssign=G.hotAssign||{};
  for(var ai in G.hotAssign) if(G.hotAssign[ai]===key) return;
  var slots=hotbarSlots();
'@ @'
  G.hotAssign=G.hotAssign||{};
  for(var ai in G.hotAssign) if(G.hotAssign[ai]===key) return;
  var slots=hotbarSlots();
  // v21.93, the four-gun belt, build 3: A GUN GOES ON A GUN KEY. It takes the lowest gun key no key of his covers that shows a vacant
  // gun slot or stowed Bare Hands (never the cell in his hands), and never an item key past the gun keys. With four guns on the keys it goes into the backpack only.
  if(it.use==='gun'){
    if(G.hubFloor) return;
    for(var gi=0;gi<GUNKEYS&&gi<slots.length;gi++){
      var gs=slots[gi];
      if(G.hotAssign[gi]===undefined&&gs&&gs.kind==='gun'&&!gs.assigned&&(gs.vacant||(gs.icon==='fists'&&!gs.inHand))){
        G.hotAssign[gi]=key; G.hotAuto=G.hotAuto||{}; G.hotAuto[gi]=1;
        var _gbTxt=it.name+' to belt slot '+(gi+1)+'.';
        say(_gbTxt);
        return _gbTxt;
      }
    }
    var _gfTxt=('Gun slots full. '+it.name+' in backpack').toUpperCase();
    say(_gfTxt);
    return _gfTxt;
  }
'@

SubRx @'
          else G.bag.push(_rpk);
'@ @'
          else { G.bag.push(_rpk); autoBelt(_rpk); }   // v21.93: a gun he pays goes on a free gun key, as loot does (a Stim on a free key)
'@

SubRx @'
  var _hcUsed=[false,false], _fk, _fh, _fp;
'@ @'
  var _hcUsed=[false,false], _fk, _fh, _fp, _fpk, _pkUsed={};
  // v21.93, the four-gun belt, build 3: ON THE UNDERCROFT FLOOR A FREE GUN KEY PREVIEWS A PACKED GUN, in packed order, one key for
  // each kind, none for a gun in his hands or a gun a key of his already shows, so the floor belt shows the keys the raid starts on.
  function _hcPacked(){
    for(var _pi=0;_pi<G.bag.length;_pi++){
      var _pk=G.bag[_pi], _pit=ITEMS[_pk], _psh=false, _pj;
      if(!_pit||_pit.use!=='gun'||!_pit.gk||_pkUsed[_pk]) continue;
      if((p.wep&&p.wep.id===_pit.gk)||(p.sec&&p.sec.id===_pit.gk)) continue;
      for(_pj=0;_pj<out.length;_pj++) if(out[_pj]&&out[_pj].itemKey===_pk) _psh=true;
      if(_psh) continue;
      _pkUsed[_pk]=1; return _pk;
    }
    return null;
  }
'@

SubRx @'
    _fp=-1;
    if(G.hubFloor){
'@ @'
    _fp=-1; _fpk=null;
    if(G.hubFloor&&_fk<2){   // v21.93: keys 1 and 2; keys 3 and 4 fill as in a raid, with the packed guns after the guns in his hands
'@

SubRx @'
      if(_fp<0&&_hc[1]&&_hc[1].vacant&&!_hcUsed[1]) _fp=1;
    }
    if(_fp>=0){ out[_fk]=_hc[_fp]; _hcUsed[_fp]=true; }
'@ @'
      if(_fp<0&&!_fpk&&_hc[1]&&_hc[1].vacant&&!_hcUsed[1]) _fp=1;
    }
    if(_fpk){
      var _fpi=ITEMS[_fpk], _fpm=(WEAPONS[_fpi.gk]&&WEAPONS[_fpi.gk].mag)||0;
      out[_fk]={k:'item:'+_fpk,name:_fpi.name,icon:_fpk,kind:'gun',inHand:false,count:Math.ceil(_fpm/2),c:_fpi.c||'#cdd6dd',itemKey:_fpk,floorGun:1};
    }
    else if(_fp>=0){ out[_fk]=_hc[_fp]; _hcUsed[_fp]=true; if(_hc[_fp].vacant&&_fk>=2) _hc[_fp].name=(_fk===2?'Third weapon':'Fourth weapon'); }
'@

SubRx @'
      for(_fh=0;_fh<2&&_fp<0;_fh++) if(!_hcUsed[_fh]&&_hc[_fh]&&!_hc[_fh].vacant&&!_hcReal(_hc[_fh])) _fp=_fh;
'@ @'
      if(_fp<0&&G.hubFloor) _fpk=_hcPacked();   // v21.93: a packed gun before Bare Hands on keys 3 and 4 of the floor
      if(!_fpk) for(_fh=0;_fh<2&&_fp<0;_fh++) if(!_hcUsed[_fh]&&_hc[_fh]&&!_hc[_fh].vacant&&!_hcReal(_hc[_fh])) _fp=_fh;
'@

SubRx @'
  var _hot0=G.hot;   // v21.83: where the highlight goes back to when a draw is refused
'@ @'
  // v21.93, the four-gun belt, build 3: A VACANT GUN KEY NEVER TAKES THE HIGHLIGHT. With four gun keys two of them are usually
  // vacant, and the highlight on one held nothing, so the trigger had nothing to fire. It says so and the highlight stays.
  if(sl[i]&&sl[i].vacant){
    if(!G.sim) say(i<2?'No second weapon. Drag one here to carry it.':('Gun slot '+(i+1)+' empty').toUpperCase());
    blip('pick');
    return;
  }
  var _hot0=G.hot;   // v21.83: where the highlight goes back to when a draw is refused
'@

SubRx @'
function hotSel(){ return clamp(G.hot||0,0,hotbarSlots().length-1); }
'@ @'
function hotSel(){ return clamp(G.hot||0,0,hotbarSlots().length-1); }
// v21.93, the four-gun belt, build 3: THE PAD WALK STEPS OVER A VACANT GUN KEY, which never takes the highlight (setHot), so the
// bumpers would stop dead at one. dir is 1 (RB) or -1 (LB); it wraps at both ends as before.
function beltStep(dir){
  var sl=hotbarSlots(), n=sl.length, i=hotSel(), k;
  if(n<=0) return;
  for(k=0;k<n;k++){ i=(i+dir+n)%n; if(!(sl[i]&&sl[i].vacant)) break; }
  setHot(i);
}
'@

SubRx @'
      if(!_lbN&&PAD.prev[4]&&!PAD.lbHeld) setHot((hotSel()-1+_slN)%_slN);
      if(!_rbN&&PAD.prev[5]&&!PAD.rbHeld) setHot((hotSel()+1)%_slN);
'@ @'
      if(!_lbN&&PAD.prev[4]&&!PAD.lbHeld) beltStep(-1);   // v21.93: over vacant gun keys
      if(!_rbN&&PAD.prev[5]&&!PAD.rbHeld) beltStep(1);
'@

SubRx @'
  var hotGun=(!HSC||HSC.kind==='gun'||HSC.kind==='item');
'@ @'
  var hotGun=(!HSC||(HSC.kind==='gun'&&!HSC.vacant)||HSC.kind==='item');   // v21.93: a vacant gun key fires nothing; it says which key does
'@

SubRx @'
    if(HSC&&HSC.kind==='empty'){
'@ @'
    if(HSC&&(HSC.kind==='empty'||HSC.vacant)){
'@

SubRx @'
  ['WEAPONS','Keys 1 and 2 bring up'],
  ['','either gun.'],
'@ @'
  ['WEAPONS','Keys 1 to 4 bring up'],   // v21.93: four gun keys
  ['','your guns.'],
'@

SubRx @'
var VER='21.92';
'@ @'
var VER='21.93';
'@

$pat = "(?m)^  now:'v21\.92:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.93: Keys 1 to 4 are your guns, the grenades and Medical are keys 5 to 8, and a fifth gun goes to the backpack. Check 21.93 fails on v21.92',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
