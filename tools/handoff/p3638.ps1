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

# ONE RARITY PER GUN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// v26.26 (rarvar1), HIS ORDER (2026-10-14): "all the green guns should also have blue variants. The current blue guns should have purple
// variants. The current purple guns should also have gold variants. Increase in rarity should only lead to slight damage increase, maybe
// 1.2-1.4? Don't change reload times, fire rates, other gun characteristics etc due to rarity". THE RARITY VARIANTS. A gun the game shows
// as green, blue or purple (the rank table WTIER, which gunRarity reads: green is tier 2, blue 3, purple 4, gold 5) has a twin one rarity
// up under the id <gun>_v: the Compact SMG is also found blue; the Magnum, Burst Carbine, Riot Scattergun and Auto Rifle also purple; the
// Support MG, Marksman Rifle and Whisper also gold. The twin is a gun of its own everywhere an id is a key (its item gun_<id>_v, the
// backpack, the stash, the armoury, a pile, a trade, the party), so it cannot lose its rarity on the way anywhere. It is the plain gun
// with ONE number changed: damage times VARIANT_DMG (1.25, his 1.2 to 1.4), so a Forge MK stacks on top of it. Reload, rate of fire,
// magazine, spread, range, noise, pellets, burst and scope are the model's. Its rank (WTIER) is the model's too, so the belt and the stat
// card still rank by tier and then the damage a second, and it is worth VARIANT_VAL (1.5) times the model: in the stall, in loot and in
// the arcade. RV_PCT percent of the finds come one up. No new number is drawn: rollFieldGun reuses the 0 to 100 roll it always made.
// The Scav Pistol (common) and the Longshot and the Meridian Lance (gold) have no twin, and a twin has none of its own.
var RV_PCT=20, VARIANT_DMG=1.25, VARIANT_VAL=1.5;
var RV_OF={}, RV_BASE={};
function gunBase(id){ return RV_BASE[id]||id; }
function rvGun(gk,f){ return (RV_OF[gk]&&f<RV_PCT/100)?RV_OF[gk]:gk; }
function rvKey(key,f){ var it=ITEMS[key]; return (it&&it.use==='gun'&&it.gk&&RV_OF[it.gk]&&f<RV_PCT/100)?('gun_'+RV_OF[it.gk]):key; }
(function(){
  var RN=['common','uncommon','rare','elite','gold'], ids=[], gk, i, b, w, it, k, t, vid;
  for(gk in WEAPONS){
    t=WTIER[gk];
    if(gk!=='fists'&&t>=2&&t<=4&&WEAPONS[gk].mag>0&&ITEMS['gun_'+gk]&&ITEMS['gun_'+gk].gk===gk) ids.push(gk);
  }
  for(i=0;i<ids.length;i++){
    gk=ids[i]; b=WEAPONS[gk]; t=WTIER[gk]; vid=gk+'_v'; w={};
    for(k in b) w[k]=b[k];
    w.id=vid; w.dmg=b.dmg*VARIANT_DMG; w.rv=1;
    WEAPONS[vid]=w; WTIER[vid]=t;
    it={}; for(k in ITEMS['gun_'+gk]) it[k]=ITEMS['gun_'+gk][k];
    it.gk=vid; it.rv=1; it.val=Math.round(it.val*VARIANT_VAL); it.r=(RN[t]==='gold')?'elite':RN[t];   // the item row keeps to the four loot ranks; the shown rarity is gunRarity
    ITEMS['gun_'+vid]=it; RV_OF[gk]=vid; RV_BASE[vid]=gk;
  }
})();
'@ @'
// v28.xx (cw-cx-onerarity), HIS ORDER (2026-10-29): "get rid of the lower-rarity of any weapons".
// Upgrade the original id in place to its former higher copy. Every source, including a direct WEAPONS clone,
// now gets that damage, value and colour. No roll, weight, pickup, sound or loot-row code changes.
// Keep the old map names for callers; there are no longer two live ids for a model.
var RV_PCT=20, VARIANT_DMG=1.25, VARIANT_VAL=1.5;
var RV_OF={}, RV_BASE={}, SINGLE_GUNS={}, SINGLE_GUN_LEGACY={};
function gunBase(id){ return Object.prototype.hasOwnProperty.call(SINGLE_GUN_LEGACY,id)?SINGLE_GUN_LEGACY[id]:id; }
function rvGun(gk,f){ return gunBase(gk); }
function rvKey(key,f){
  if(typeof key!=='string'||key.indexOf('gun_')!==0) return key;
  var gk=gunBase(key.slice(4));
  return ITEMS['gun_'+gk]?'gun_'+gk:key;
}
(function(){
  var RN=['common','uncommon','rare','elite','gold'], gk, b, it, t;
  for(gk in WEAPONS){
    t=WTIER[gk]; b=WEAPONS[gk]; it=ITEMS['gun_'+gk];
    if(gk==='fists'||!(t>=2&&t<=4)||!(b.mag>0)||!it||it.gk!==gk) continue;
    SINGLE_GUNS[gk]={dmg:b.dmg,val:it.val,tier:t}; SINGLE_GUN_LEGACY[gk+'_v']=gk;
    b.dmg*=VARIANT_DMG; WTIER[gk]=t+1;
    it.val=Math.round(it.val*VARIANT_VAL); it.r=(RN[t]==='gold')?'elite':RN[t];
  }
})();
// v28.xx (cw-cx-onerarity): lower copies already have the permanent id, so every cell and record stays put.
// Fold old higher ids back into it before any loader filters. Never rewrite names, prose or history.
function oneGunProfile(p){
  if(!p||typeof p!=='object') return;
  function token(s){ return (typeof s==='string'&&s.indexOf('gun_')===0)?rvKey(s,0):gunBase(s); }
  function walk(x,sum){
    var i, k, n, v, old;
    if(typeof x==='string') return token(x);
    if(!x||typeof x!=='object') return x;
    if(Array.isArray(x)){ for(i=0;i<x.length;i++) x[i]=walk(x[i],sum); return x; }
    for(k in x) if(Object.prototype.hasOwnProperty.call(x,k)){
      n=token(k); v=walk(x[k],sum);
      if(n===k){ x[k]=v; continue; }
      old=x[n];
      if(old===undefined) x[n]=v;
      else if(typeof old==='number'&&typeof v==='number') x[n]=sum?old+v:Math.max(old,v);
      else if(v&&old&&typeof v==='object'&&typeof old==='object'&&(v.fk|0)>(old.fk|0)) x[n]=v;
      delete x[k];
    }
    return x;
  }
  ['stash','weapons','equipped','equippedSec','kit','dropKit','hotAssign','keep','wear','forged','kitSaved',
   'kitBeforeFree','hotBeforeFree','gunBeforeFree','raidSpliced','gunPiled','floorDrops','gambleLog','codex','ghost',
   'gunKills','s','g','gk','kp','gh'].forEach(function(f){
    if(p[f]!==undefined) p[f]=walk(p[f],f==='gunKills'||f==='s'||f==='gk');
  });
  if(Array.isArray(p.weapons)) p.weapons=p.weapons.filter(function(k,i,a){ return a.indexOf(k)===i; });
}
'@

SubRx @'
if(d&&typeof d.credits==='number'){ P=d; keysMig(P);
'@ @'
if(d&&typeof d.credits==='number'){ P=d; oneGunProfile(P); keysMig(P); /* v28.xx (cw-cx-onerarity): migrate before item, belt and Forge validation; keep the profile key */
'@

SubRx @'
function restoreApply(o){
  if(!o||typeof o.c!=='number') return false;
'@ @'
function restoreApply(o){
  if(!o||typeof o.c!=='number') return false;
  oneGunProfile(o); // v28.xx (cw-cx-onerarity): old restore codes keep their guns, locks and records too.
'@

SubRx @'
var VER='36.37';
'@ @'
var VER='36.38';
'@

$pat = "(?m)^  now:'v36\.37:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.38: Each gun has one rarity; guns that had two are always the better one. Check 36.38 fails on v36.37',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
