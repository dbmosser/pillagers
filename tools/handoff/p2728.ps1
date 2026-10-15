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

# BEST KIT: 3 GUNS, UP TO 3 OF EACH (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function kitFill(rand){
  if(rand) return kitFillRandom();   // v26.xx (kit2): RANDOM KIT is two guns and one of each wheel item
  var own=(P.weapons||[]).filter(function(g){ return g&&g!=='fists'&&WEAPONS[g]; }), g=null, pool=(P.stash||[]).slice(), out=[], i, j, t, cap=0, tc={}, c;
  if(own.length){
    if(rand){
      // v21.13, HIS ORDER (2026-10-08): "'random from stash' loadout should never start player with a scav pistol if i have guns
      // in the stash. give me 2 random stash guns always". It picked one gun at random from everything he owns, the Scav Pistol
      // included, and left the second slot as it was, so he could go up holding a Scav Pistol or carrying one on his back. Now
      // both slots are filled at random from his guns, two different kinds, and the Scav Pistol is never picked while he owns
      // any other gun; with only one other gun, it goes in his hands and the back slot stays empty.
      var _rp=own.filter(function(k){ return k!=='pistol'; }), _rs;
      if(!_rp.length) _rp=own.slice();
      g=_rp[Math.floor(Math.random()*_rp.length)];
      _rs=_rp.filter(function(k){ return k!==g; });
      P.equippedSec=_rs.length?_rs[Math.floor(Math.random()*_rs.length)]:'none';
    } else { own.sort(function(a,b){ return (WTIER[b]||0)-(WTIER[a]||0); }); g=own[0]; }
  }
  if(g){ if(P.equippedSec===g) P.equippedSec='none'; P.equipped=g; }
  try{ cap=rigCeil(myRig()); }catch(_rc){ cap=0; }
  function ok(k){ var q=ITEMS[k]; return !!q&&(q.use==='throw'||q.use==='ammo'||q.use==='heal'||(q.use==='armor'&&cap>0)); }
  if(rand){
    c=pool.filter(ok);
    for(i=0;i<6&&c.length;i++){ j=Math.floor(Math.random()*c.length); out.push(c[j]); c.splice(j,1); }
  } else {
    for(i=0;i<pool.length;i++){ t=ITEMS[pool[i]]; if(t&&t.use==='throw'&&(tc[pool[i]]||0)<2){ tc[pool[i]]=(tc[pool[i]]||0)+1; out.push(pool[i]); pool[i]=null; } }
    ['armor','ammo','heal','heal'].forEach(function(u){
      var bi=-1, bv=-1, j2, q;
      for(j2=0;j2<pool.length;j2++){ if(!pool[j2]||!ok(pool[j2])) continue; q=ITEMS[pool[j2]]; if(q.use===u&&(q.amt||0)>bv){ bi=j2; bv=q.amt||0; } }
      if(bi>=0){ out.push(pool[bi]); pool[bi]=null; }
    });
  }
  P.kit=out;
  return {gun:g,kit:out};
}
'@ @'
// v26.xx (kit3), HIS WORD (2026-10-14): "if 'best kit', give 3 guns" and "top gear should pull up to 3 of each". BEST KIT: HIS THREE BEST GUNS, by the rarity each wears (the colour: a rarity twin
// outranks its model), then the tier, then what it is worth, three different models (never a gun and its own twin). The best is in his hands, the second in the other hand, the third packed
// from the stash (an armoury gun is moved out to the stash for it), each on its class key, as RANDOM KIT does (kitPlaceGuns). THE ITEMS: UP TO THREE of each of the eight wheel types he
// has in the stash, in wheel order (Medkit, Smoke, Frag, Tripwire, Armour, Decoy, Bandage, Stim; one item to a type in this build, so no variant to rank), the Armour only with a rig
// that holds plates, then the biggest Ammo Box, never more than the pack room. The items stay in the stash until the raid starts. (The old TOP GEAR was one gun, two of each grenade and a
// plate, an ammo and two heals.)
function kitFillBest(){
  var own=kitOwnGuns(), sorted, list=[], seenB={}, i;
  sorted=own.slice().sort(function(a,b){
    return ((_RRANK[gunRarity(b)]||0)-(_RRANK[gunRarity(a)]||0))||((WTIER[b]||0)-(WTIER[a]||0))||(ival('gun_'+b)-ival('gun_'+a))||(a<b?-1:1);
  });
  for(i=0;i<sorted.length&&list.length<3;i++){ if(seenB[gunBase(sorted[i])]) continue; seenB[gunBase(sorted[i])]=1; list.push(sorted[i]); }
  P.kit=kitWheelItems(3,kitPlaceGuns(list),function(am){ var bi=am[0], j; for(j=1;j<am.length;j++) if((ITEMS[am[j]].amt||0)>(ITEMS[bi].amt||0)) bi=am[j]; return bi; });
  return {gun:list[0]||null,kit:P.kit};
}
function kitFill(rand){
  if(rand) return kitFillRandom();   // v26.xx (kit2): RANDOM KIT is two guns and one of each wheel item
  return kitFillBest();   // v26.xx (kit3): BEST KIT is the three best guns and up to three of each
}
'@

SubRx @'
var VER='27.27';
'@ @'
var VER='27.28';
'@

$pat = "(?m)^  now:'v27\.27:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.28: BEST KIT gives your three best guns and up to three of each wheel item. Check 27.28 fails on v27.27',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
