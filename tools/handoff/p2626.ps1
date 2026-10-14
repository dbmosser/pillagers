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

# GUNS CAN BE FOUND ONE RARITY UP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var RCOL={common:'#9da3a8',uncommon:'#5fbf6a',rare:'#3f9de9',elite:'#a866e0',gold:'#ffc72e'};
'@ @'
var RCOL={common:'#9da3a8',uncommon:'#5fbf6a',rare:'#3f9de9',elite:'#a866e0',gold:'#ffc72e'};
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
'@

SubRx @'
function gunRarity(gk){ var t=WTIER[gk]; if(t===undefined) return 'common';
'@ @'
function gunRarity(gk){ var t=WTIER[gk]; if(t===undefined) return 'common';
  if(RV_BASE[gk]) t++;   // v26.26 (rarvar1): a rarity twin wears the next rarity up (its rank in WTIER is the model's)
'@

SubRx @'
  var base=WEAPONS[gk],roll=rr()*100,acc=0,Q=GUNQ[1];
'@ @'
  var roll=rr()*100,acc=0,Q=GUNQ[1],base;
  // v26.26 (rarvar1): THE SAME ROLL DECIDES THE RARITY. It is the number this function always drew (0 to 100, still one draw), and under
  // RV_PCT it is the twin one rarity up. Nothing new is drawn, so the seeded stream and the seed 4242 raid are what they were.
  gk=rvGun(gk,roll/100);
  base=WEAPONS[gk];
'@

SubRx @'
  g.dmg=Math.round(base.dmg*Q.dmg*10)/10;
'@ @'
  g.dmg=(Q.dmg===1)?base.dmg:Math.round(base.dmg*Q.dmg*10)/10;   // v26.26 (rarvar1): the one row changes nothing, so a twin keeps exactly VARIANT_DMG times the model
'@

SubRx @'
    var key=keys[l],itm=ITEMS[key];
    T.items++; T.rar[itm.r]++;
'@ @'
    var key=keys[l],itm=ITEMS[key],_rvF=null;
    // v26.26 (rarvar1): a gun out of a box is rolled HERE, before its popup, so the popup, the pickup row and the backpack all see the
    // rarity it came out as. The roll is the one the gun branch below always made (one draw per gun found, the same place in the loop);
    // a pile he dropped is not rolled (it keeps the rarity it was dropped with), and the twin's key replaces the box key in the list.
    if(itm&&itm.use==='gun'&&itm.gk&&!ct.dropped){ _rvF=rollFieldGun(itm.gk); if(_rvF.id!==itm.gk&&ITEMS['gun_'+_rvF.id]){ key='gun_'+_rvF.id; keys[l]=key; itm=ITEMS[key]; } }
    T.items++; T.rar[itm.r]++;
'@

SubRx @'
})():rollFieldGun(itm.gk);
'@ @'
})():_rvF;
'@

SubRx @'
  var id=(w&&w.id)||'', S=[], k;
'@ @'
  var id=gunBase((w&&w.id)||''), S=[], k;   // v26.26 (rarvar1): a rarity twin reloads like its model
'@

SubRx @'
    if(RLFX.w&&RLFX.w.id==='whisper') o.g=
'@ @'
    if(RLFX.w&&gunBase(RLFX.w.id)==='whisper') o.g=
'@

SubRx @'
  if(fromPlayer&&wep.id==='smg'&&G.player.fireHold)
'@ @'
  if(fromPlayer&&gunBase(wep.id)==='smg'&&G.player.fireHold)
'@

SubRx @'
    var V=FV[arguments[3]]||FV.rifle;
'@ @'
    var V=FV[gunBase(arguments[3])]||FV.rifle;   // v26.26 (rarvar1): a rarity twin has its model's voice
'@

SubRx @'
    var can=(id==='whisper');
    P([[-52,-12]
'@ @'
    var can=(gunBase(id)==='whisper');
    P([[-52,-12]
'@

SubRx @'
    var can=(id==='whisper');
    part(-20,-5
'@ @'
    var can=(gunBase(id)==='whisper');
    part(-20,-5
'@

SubRx @'
  var wt=(w&&WTIER[w.id]!==undefined)?WTIER[w.id]:1;
'@ @'
  var wt=(w&&WTIER[w.id]!==undefined)?WTIER[w.id]+(RV_BASE[w.id]?1:0):1;   // v26.26 (rarvar1): a rarity twin wears the next rarity up
'@

SubRx @'
  var _wid=_wp?_wp.id:'rifle';
  var _wt=WTIER[_wid]===undefined?1:WTIER[_wid];
'@ @'
  var _wid=_wp?_wp.id:'rifle';
  var _wt=WTIER[_wid]===undefined?1:WTIER[_wid]+(RV_BASE[_wid]?1:0);   // v26.26 (rarvar1): a rarity twin wears the next rarity up
  _wid=gunBase(_wid);   // v26.26 (rarvar1): and has its model's shape
'@

SubRx @'
                lmg:'lmg',dmr:'marksman',sniper:'marksman',lance:'lance'};
'@ @'
                lmg:'lmg',dmr:'marksman',sniper:'marksman',lance:'lance'};
// v26.26 (rarvar1): a rarity twin is drawn, held and timed as its model: the model's row in every table keyed by a gun id.
(function(){ var T=[GUN_FAMILY,GUNDEF,DRAWT,GEAR_LIGHT], i, b; for(b in RV_OF) for(i=0;i<T.length;i++) if(T[i]&&T[i][b]!==undefined) T[i][RV_OF[b]]=T[i][b]; })();
'@

SubRx @'
var VER='26.25';
'@ @'
var VER='26.26';
'@

$pat = "(?m)^  now:'v26\.25:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.26: Green, blue and purple guns now turn up one rarity higher about one find in five, doing 25 percent more damage and nothing else changed. Check 26.26 fails on v26.25',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
