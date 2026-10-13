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

# FOUR GUNS MAX, THE WEAKEST SWAPS OUT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function beltTag(){ return (BELTAT>=0)?('SLOT '+(BELTAT+1)):(BELTAT===-2?'BACKPACK':''); }
'@ @'
function beltTag(){ return (BELTAT>=0)?('SLOT '+(BELTAT+1)):(BELTAT===-2?'BACKPACK':''); }
// v25.xx (belt1), HIS ORDER 2026-10-13: "so player can only carry 4 guns max", and his decision (1 b): "swap with lowest gun that is not
// actively being used, move lowest gun to inventory". GUN SLOTS FULL IS GONE. With keys 1 to GUNKEYS all showing a real gun, a gun that
// arrives takes the place of the WEAKEST gun that is not in his hands (the stowed gun, or a backpack gun on a gun key), and that gun goes
// to the backpack with no key. A find weaker than all of them, or tied, goes straight to the backpack and nothing moves. The rank is the
// tier (the Forge MK counted, gunTierOf) and then the sustained damage the stat card shows; between belt guns that tie the higher key goes.
// The gun in his hands is never chosen. An issued loaner in the stowed slot is left behind, as equipFromBag does. BELTDISP is the gun that
// was pushed out, for the caller's pickup row (BACKPACK). Only autoBelt calls this, and autoBelt never runs in the sim.
var BELTDISP=null;
function beltGunLow(a,b){
  var ta=gunTierOf(a), tb=gunTierOf(b);
  if(ta!==tb) return ta<tb;
  return gunStats(a).dps<gunStats(b).dps;
}
function beltGunField(gk){ var g={}, k; for(k in WEAPONS[gk]) g[k]=WEAPONS[gk][k]; g.q='field'; g.qRank=1; return g; }
function beltGunFull(key,quiet,slots,xo){
  var it=ITEMS[key], gk=it.gk, p=G.player, A=G.hotAssign, U=(G.hotAuto=G.hotAuto||{}), q=G.stowQ&&G.stowQ[gk];
  var nw=(xo&&xo.found)||((q&&q.length)?q[q.length-1]:null)||beltGunField(gk);
  var worst=null, gi, gs, c, bk, ow, bagged, ix, sl2, txt, nc, k2;
  for(gi=0;gi<GUNKEYS&&gi<slots.length;gi++){
    gs=slots[gi]; c=null;
    if(!(gs&&gs.kind==='gun'&&!gs.vacant&&gs.icon&&gs.icon!=='fists'&&!gs.inHand)) continue;
    if(gs.itemKey&&!gs.equipped){
      bk=ITEMS[gs.itemKey];
      if(bk&&bk.use==='gun'&&bk.gk&&gs.itemKey!==key) c={ci:gi,kind:'bag',key:gs.itemKey,w:gunQPeek(bk.gk)||beltGunField(bk.gk)};
    } else if(p.sec&&p.sec.mag!==0&&p.sec.id===gs.icon) c={ci:gi,kind:'sec',w:p.sec};
    if(c&&(!worst||!beltGunLow(worst.w,c.w))) worst=c;   // the weakest; on a tie the higher key
  }
  if(!worst||!beltGunLow(worst.w,nw)){
    BELTAT=-2; txt=(it.name+' to backpack').toUpperCase(); if(!quiet) say(txt); return txt;   // nothing on the keys is weaker: it stays in the backpack
  }
  if(worst.kind==='bag'){
    A[worst.ci]=key; U[worst.ci]=1;   // the find takes the key; the weaker gun stays in the backpack with no key
    BELTAT=worst.ci;
    BELTDISP={item:worst.key,name:String(worst.w.name||ITEMS[worst.key].name),tag:'BACKPACK'};
  } else {
    ow=p.sec; bagged=false;
    ix=G.bag.lastIndexOf(key); if(ix>=0) G.bag.splice(ix,1);   // the find goes to his stowed slot, not the backpack
    gunQTrim(gk);
    if(!p.secIssued&&ITEMS['gun_'+ow.id]){
      G.bag.push('gun_'+ow.id); stowRounds(ow.id,p.secAmmo); gunQPush(ow); bagged=true;   // as bagHeldGun: with its rounds and its quality
      if(p.secFromArmory&&P&&P.weapons){ ix=P.weapons.indexOf(ow.id); if(ix>=0){ P.weapons.splice(ix,1); (G.spliced=G.spliced||[]).push(ow.id); (P.raidSpliced=P.raidSpliced||[]).push(ow.id); } }
    }
    nc={}; for(k2 in nw) nc[k2]=nw[k2];
    p.sec=nc; p.secAmmo=(xo&&xo.found&&!xo.dropped)?Math.ceil(nc.mag/2):takeRounds(nc.id,nc.mag); p.secIssued=false; p.secFromArmory=false;
    G.tel.gunsEquipped=(G.tel.gunsEquipped||0)+1;
    gunKeysSettle({pushed:bagged?ow.id:null,arrived:nc.id});   // the find takes a free key, else the key of the gun it pushed out
    sl2=hotbarSlots(); BELTAT=-1;
    for(gi=0;gi<GUNKEYS&&gi<sl2.length;gi++) if(sl2[gi]&&sl2[gi].kind==='gun'&&!sl2[gi].vacant&&!sl2[gi].inHand&&sl2[gi].icon===nc.id){ BELTAT=gi; break; }
    BELTDISP={item:'gun_'+ow.id,name:String(ow.name||ow.id),tag:bagged?'BACKPACK':'LEFT BEHIND'};
    if(bagged&&bagWeight()>PACKCAP[P.pack]){   // no room for the gun it pushed out: it drops at his feet, and the red row names it
      ix=G.bag.lastIndexOf('gun_'+ow.id);
      if(ix>=0){ dropItem(ix); say('BACKPACK FULL','pick',{key:'bagfull',c:'danger',sub:(BELTDISP.name+' dropped').toUpperCase()}); BELTDISP=null; }
    }
  }
  txt=(BELTAT>=0)?(it.name+' to slot '+(BELTAT+1)).toUpperCase():(it.name+' stowed').toUpperCase();
  if(!quiet){ say(txt); if(BELTDISP){ say(BELTDISP.name,'pick',{item:BELTDISP.item,tag:BELTDISP.tag}); BELTDISP=null; } }
  return txt;
}
'@

SubRx @'
function autoBelt(key,quiet){
  BELTAT=-1;
'@ @'
function autoBelt(key,quiet,xo){   // v25.xx (belt1): xo = {found:the rolled gun, dropped:1 for a pile he dropped}, so the swap ranks the gun as it is
  BELTAT=-1; BELTDISP=null;
'@

SubRx @'
    var _gfTxt='GUN SLOTS FULL';   // v22.43: a headline and its detail, not one long line
    BELTAT=-2; if(!quiet) say(_gfTxt,'info',{sub:(it.name+' in backpack').toUpperCase()});
    return _gfTxt;
'@ @'
    // v25.xx (belt1), HIS ORDER 2026-10-13: four guns max. No key is free: the weakest gun not in his hands goes to the backpack (beltGunFull).
    return beltGunFull(key,quiet,slots,xo);
'@

SubRx @'
var _gunLine='', _beltKeep=[], _beltGot, _ptags=[]; _lootSub='';
'@ @'
var _gunLine='', _beltKeep=[], _beltGot, _ptags=[], _bdRows=[]; _lootSub='';
'@

SubRx @'
        _beltGot=autoBelt(key,1); if(_beltGot) _beltKeep.push(_beltGot); if(beltTag()) _ptags[l]=beltTag();   // v22.54 (R17): said on its row, not as a line
'@ @'
        _beltGot=autoBelt(key,1,{found:found,dropped:!!(ct&&ct.dropped)}); if(_beltGot) _beltKeep.push(_beltGot); if(beltTag()) _ptags[l]=beltTag(); if(BELTDISP){ _bdRows.push(BELTDISP); BELTDISP=null; }   // v22.54 (R17): said on its row, not as a line   // v25.xx (belt1): and the gun it pushed out, tagged where it went
'@

SubRx @'
for(var _pk=0;_pk<keys.length;_pk++) if(ITEMS[keys[_pk]]) say(ITEMS[keys[_pk]].name,'pick',{item:keys[_pk],tag:_ptags[_pk]||''});
'@ @'
for(var _pk=0;_pk<keys.length;_pk++) if(ITEMS[keys[_pk]]) say(ITEMS[keys[_pk]].name,'pick',{item:keys[_pk],tag:_ptags[_pk]||''});
      for(var _bd=0;_bd<_bdRows.length;_bd++) say(_bdRows[_bd].name,'pick',{item:_bdRows[_bd].item,tag:_bdRows[_bd].tag});   // v25.xx (belt1): the gun a find pushed out, tagged BACKPACK
'@

SubRx @'
var VER='25.86';
'@ @'
var VER='25.87';
'@

$pat = "(?m)^  now:'v25\.86:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.87: A fifth gun now swaps with your weakest gun that is not in your hands, and that gun goes to the backpack. Check 25.87 fails on v25.86',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
