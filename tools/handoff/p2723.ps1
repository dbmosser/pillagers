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

# RANDOM KIT: 2 GUNS, 1 OF EACH (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function kitFill(rand){
'@ @'
// v26.xx (kit2), HIS WORD (2026-10-14): "should still have options to spawn with 'random kit', 'best kit', etc -- if random, give 2 guns" and "random from stash should pull 1x of each wheel
// usable item". RANDOM KIT: TWO DIFFERENT RANDOM GUNS he owns (the armoury and the gun items in the stash, one per model), never the Scav Pistol while he owns any other gun (v21.13), and never a gun and its own rarity twin;
// with only one other gun, that gun alone. The first is in his hands, the second is the other hand, each is bound to its CLASS KEY (1 pistol, 2 SMG, 3 rifle, 4 carbine, 5 LMG,
// 6 shotgun, 7 marksman, 8 sniper, 9 energy, the v26.36 table in gunKeyTable; a second gun of a class already taken takes the lowest free gun key), and the old plan's gun keys are
// cleared first. A gun that was only in the stash is moved into the armoury, as Equip as your gun does. With no gun at all the hands stay empty and the raid hands out the Scav
// Pistol (v26.17). THE ITEMS: ONE of each of the eight item wheel types he has in the stash (WHEEL_ORDER: Medkit, Smoke, Frag, Tripwire, Armour, Decoy, Bandage, Stim; there is one
// item to a type in this build, so no variant is picked), the Armour only with a rig that holds plates (rigCeil, v10.11), then one Ammo Box picked at random (the ammo rule as it was),
// and no more than the backpack room (DEPLOY_SLOTS) takes, filled in wheel order. The items stay in the stash until the raid starts, as before.
function kitOwnGuns(){
  var out=[], seen={}, i, k, it;
  for(i=0;i<(P.weapons||[]).length;i++){ k=P.weapons[i]; if(k&&k!=='fists'&&WEAPONS[k]&&!seen[k]){ seen[k]=1; out.push(k); } }
  for(i=0;i<(P.stash||[]).length;i++){ it=ITEMS[P.stash[i]]; if(it&&it.use==='gun'&&it.gk&&WEAPONS[it.gk]&&!seen[it.gk]){ seen[it.gk]=1; out.push(it.gk); } }
  return out;
}
// the chosen guns into place: list[0] in his hands, list[1] in the other hand, the rest packed from the stash; each on its class key. Returns the packed gun items.
function kitPlaceGuns(list){
  var packed=[], used={}, i, j, g, key, ix, ck;
  if(!P.hotAssign||typeof P.hotAssign!=='object') P.hotAssign={};
  for(j in P.hotAssign) if(ITEMS[P.hotAssign[j]]&&ITEMS[P.hotAssign[j]].use==='gun') delete P.hotAssign[j];
  P.equipped='fists'; P.equippedSec='none';
  for(i=0;i<list.length;i++){
    g=list[i]; key='gun_'+g;
    if(i<2){
      if((P.weapons||[]).indexOf(g)<0){ ix=(P.stash||[]).indexOf(key); if(ix>=0){ P.stash.splice(ix,1); P.weapons.push(g); } }
      if(i===0) P.equipped=g; else P.equippedSec=g;
    } else {
      if((P.weapons||[]).indexOf(g)>=0) rackToStash(key);
      if((P.stash||[]).indexOf(key)>=0) packed.push(key);
    }
    ck=gunClassKey(gunClassOf(g));
    if(ck<0||ck>=GUNKEYS||used[ck]){ ck=-1; for(j=0;j<GUNKEYS;j++) if(!used[j]){ ck=j; break; } }
    if(ck>=0){ used[ck]=1; P.hotAssign[ck]=key; }
  }
  return packed;
}
// the item part of a kit: per of each wheel type out of the stash (what the guns packed above already took is counted out), then one Ammo Box; room is what the pack takes in all
function kitWheelItems(per,packed,pickAmmo){
  var left={}, out=packed.slice(), ord=wheelOrderTable(), cap=0, i, k, n, am=[], best;
  for(i=0;i<(P.stash||[]).length;i++) left[P.stash[i]]=(left[P.stash[i]]||0)+1;
  for(i=0;i<packed.length;i++) left[packed[i]]=(left[packed[i]]||0)-1;
  try{ cap=rigCeil(myRig()); }catch(_rc){ cap=0; }
  for(i=0;i<ord.length;i++){
    k=ord[i]; if(!ITEMS[k]) continue;
    if(ITEMS[k].use==='armor'&&!(cap>0)) continue;
    n=Math.min(per,left[k]||0,DEPLOY_SLOTS-out.length);
    while(n-->0){ out.push(k); left[k]--; }
  }
  for(k in left) if(left[k]>0&&ITEMS[k]&&ITEMS[k].use==='ammo') am.push(k);
  if(am.length&&out.length<DEPLOY_SLOTS) out.push(pickAmmo(am));
  return out;
}
function kitFillRandom(){
  var own=kitOwnGuns(), pool=own.filter(function(k){ return k!=='pistol'; }), list=[], j;
  if(!pool.length) pool=own.slice();
  while(list.length<2&&pool.length){ j=Math.floor(Math.random()*pool.length); list.push(pool[j]); pool=pool.filter(function(x){ return gunBase(x)!==gunBase(list[list.length-1]); }); }
  P.kit=kitWheelItems(1,kitPlaceGuns(list),function(am){ return am[Math.floor(Math.random()*am.length)]; });
  return {gun:list[0]||null,kit:P.kit};
}
function kitFill(rand){
  if(rand) return kitFillRandom();   // v26.xx (kit2): RANDOM KIT is two guns and one of each wheel item
'@

SubRx @'
var VER='27.22';
'@ @'
var VER='27.23';
'@

$pat = "(?m)^  now:'v27\.22:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.23: RANDOM KIT gives two random guns on their class keys and one of each wheel item. Check 27.23 fails on v27.22',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
