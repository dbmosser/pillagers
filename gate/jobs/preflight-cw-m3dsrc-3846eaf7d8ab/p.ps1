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

# SEASON ZERO M3: GEAR FROM WRECKS, PILLAGERS AND KEYCARD ROOMS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function wornBoxRoll(ct){
  var R, kinds, i, n, r, k, key;
  if(!WORN_DROPS_ON||!ct||ct.gearDone||!G||G.sim||G.arcade||G.hubFloor||(typeof ARCADE==='object'&&ARCADE&&ARCADE.on)) return null;
  if(typeof NET==='object'&&NET&&NET.on&&NET.role==='join') return null;
  if(ct.opened||ct.dropped||ct.mercSrc||ct.net||!(ct.d>=0)||ct.type==='botwreck'||!Array.isArray(ct.loot)) return null;
  ct.gearDone=1;
  R=wornRand(wornBoxSeed(ct));
  if(R()>=WORN_BOX_CH) return null;
  kinds=Object.keys(WORN_KINDS); k=kinds[Math.floor(R()*kinds.length)];
  n=R()*100; for(r=0;r<3&&n>=WORN_RAR_ODDS[r];r++) n-=WORN_RAR_ODDS[r];
  i=(R()*4294967296)>>>0;   // the piece's own seed
  key=wornKeyOf(k,r,wornDropPw(k,R),i);
  if(!wornItemEnsure(key)) return null;
  for(i=0;i<ct.loot.length&&ival(ct.loot[i])<=ival(key);i++);
  ct.loot.splice(i,0,key);
  return key;
}
'@ @'
// v37.xx (cw-m3dsrc), HIS RULINGS OF 11-01 (season zero m3): machines drop gear, "bigger machines better odds" (answer 68); a hostile pillager drops what he wears, so killing a
// geared one pays (answer 46); keycard rooms hold gear; a raid averages 4 or 5 pieces in all (answer 57). THE ONE TABLE, tune here only: n is the chance of each piece in turn (a
// second only after a first), o the rarity odds in percent (scrap, sound, rare, relic). A pillager's row: tough is a medium or heavy rig, elite an elite; what he wears is never
// drawn on him and never read by the fight. boss is the overseer and the juggernaut. locked is a keycard room box: always one, one rarity step up.
// THE NUMBERS, his 26 real raids v35.38 to v37.56 (abandons left out): 13.4 containers opened a raid; killed a raid 13.5 crawlers, 4.2 sentries, 0.6 snitches, 0.15 bulwarks,
// 0.15 howlers, 0.7 pillagers. A kill leaves 12.2 wrecks and 0.7 bodies; with 3 in 4 opened containers map boxes (00p-m3a), bodies all opened (they carry his gun), about 1 wreck
// in 5 gets searched. So boxes 10.1 x 0.34 = 3.4, wrecks about 0.45, pillagers 0.7 x 0.65 = 0.45, keycard rooms about 0.1 more: about 4.4 a raid.
var WORN_SRC={
  crawler:{n:[0.12],o:[70,24,5,1]}, snitch:{n:[0.12],o:[70,24,5,1]}, sentry:{n:[0.25],o:[60,28,10,2]}, listener:{n:[0.4],o:[50,32,14,4]},
  bulwark:{n:[0.55],o:[40,36,18,6]}, howler:{n:[0.55],o:[40,36,18,6]}, choir:{n:[0.65],o:[35,36,21,8]}, warden:{n:[0.85,0.3],o:[25,35,28,12]},
  boss:{n:[1,0.6],o:[15,35,32,18]},
  pillager:{n:[0.5,0.15],o:[60,28,10,2]}, tough:{n:[0.7,0.3],o:[50,32,14,4]}, elite:{n:[0.9,0.45],o:[35,36,21,8]},
  locked:{n:[1],o:[0,60,28,12]}
};
// One piece on the caller's dice: its kind, its rarity on the odds O, its own seed, then its power, the order 00p-m3a rolled in, so a map box gives the piece it gave before.
function wornPieceKey(R,O){
  var kinds=Object.keys(WORN_KINDS), k=kinds[Math.floor(R()*kinds.length)], n=R()*100, r, s, key;
  for(r=0;r<3&&n>=O[r];r++) n-=O[r];
  s=(R()*4294967296)>>>0;   // the piece's own seed
  key=wornKeyOf(k,r,wornDropPw(k,R),s);
  return wornItemEnsure(key)?key:null;
}
// Into a container in value order; the normal items, their order, the look and the search time stay as they were.
function wornSlot(ct,key){ var i; for(i=0;i<ct.loot.length&&ival(ct.loot[i])<=ival(key);i++); ct.loot.splice(i,0,key); }
function wornKillRow(e){
  if(e.boss||e.boss2) return 'boss';
  if(e.kind==='raider') return e.elite?'elite':((e.rig==='medium'||e.rig==='heavy')?'tough':'pillager');
  return Object.prototype.hasOwnProperty.call(WORN_SRC,e.kind)?e.kind:null;
}
// The fixed thing about the dead: its place in the raid's build (wsi, stamped at buildRaid). One spawned later takes the next number past the build's when it dies.
function wornKillSeed(e){
  var h=(((G&&G.seed)>>>0)^Math.imul(0x4B11,0x9E3779B1))>>>0, s=String(e.kind), c=0, i;
  if(!(e.wsi>0)){ G.wornKillN=(G.wornKillN|0)+1; e.wsi=100000+G.wornKillN; }
  for(i=0;i<s.length;i++) c=(Math.imul(c,31)+s.charCodeAt(i))>>>0;
  h=(h^Math.imul(e.wsi|0,374761393))>>>0;
  h=(h^Math.imul(c|0,668265263))>>>0;
  h=Math.imul(h^(h>>>15),2246822519)>>>0;
  h=Math.imul(h^(h>>>13),3266489917)>>>0;
  return (h^(h>>>16))>>>0;
}
// THE KILL ROLL, once per death, into the wreck or body that death already leaves (never a new one, so a kill that left nothing still leaves nothing): a machine's row by its kind,
// a pillager's by how tough he is, on its own dice, so RNGS and FXS never move and seed 4242 builds the same raid. The host rolls for the party, a linked window never; G.sim,
// the arcade, the demo, a hire and a partner roll nothing.
function wornKillRoll(ct,e){
  var out=[], row, R, i, key;
  if(!WORN_DROPS_ON||!ct||!e||ct.gearDone||!G||G.sim||G.arcade||G.hubFloor||(typeof ARCADE==='object'&&ARCADE&&ARCADE.on)) return out;
  if(typeof NET==='object'&&NET&&NET.on&&NET.role==='join') return out;
  if(e.merc||e.friendlyPC||e.net||!Array.isArray(ct.loot)) return out;
  row=WORN_SRC[wornKillRow(e)]; if(!row) return out;
  ct.gearDone=1;
  R=wornRand(wornKillSeed(e));
  for(i=0;i<row.n.length&&R()<row.n[i];i++){ key=wornPieceKey(R,row.o); if(key){ wornSlot(ct,key); out.push(key); } }
  return out;
}
function wornBoxRoll(ct){
  var R, key;
  if(!WORN_DROPS_ON||!ct||ct.gearDone||!G||G.sim||G.arcade||G.hubFloor||(typeof ARCADE==='object'&&ARCADE&&ARCADE.on)) return null;
  if(typeof NET==='object'&&NET&&NET.on&&NET.role==='join') return null;
  if(ct.opened||ct.dropped||ct.mercSrc||ct.net||!(ct.d>=0)||ct.type==='botwreck'||!Array.isArray(ct.loot)) return null;
  ct.gearDone=1;
  R=wornRand(wornBoxSeed(ct));
  if(R()>=WORN_BOX_CH&&!ct.inLocked) return null;   // v37.xx (cw-m3dsrc): a keycard room box always holds one
  key=wornPieceKey(R,ct.inLocked?WORN_SRC.locked.o:WORN_RAR_ODDS);
  if(key) wornSlot(ct,key);
  return key;
}
'@

SubRx @'
    var _sm=ents[_sl];
'@ @'
    var _sm=ents[_sl];
    _sm.wsi=_sl+1;   // v37.xx (cw-m3dsrc): its place in the build, the fixed thing its kill roll seeds from
'@

SubRx @'
cw.cache=1; cw.time=2.0; cw.tag='WARDEN WRECK'; G.containers.push(cw);
'@ @'
cw.cache=1; cw.time=2.0; cw.tag='WARDEN WRECK'; G.containers.push(cw); wornKillRoll(cw,e);   /* v37.xx (cw-m3dsrc) */
'@

SubRx @'
cq.cache=1; cq.time=2.4; cq.tag='PILLBOX WRECK'; G.containers.push(cq);
'@ @'
cq.cache=1; cq.time=2.4; cq.tag='PILLBOX WRECK'; G.containers.push(cq); wornKillRoll(cq,e);   /* v37.xx (cw-m3dsrc) */
'@

SubRx @'
var c=setLoot(mkContainer(e.x,e.y,'body'),_drop); G.containers.push(c);
'@ @'
var c=setLoot(mkContainer(e.x,e.y,'body'),_drop); G.containers.push(c); wornKillRoll(c,e);   /* v37.xx (cw-m3dsrc): what he wore, his answer 46 */
'@

SubRx @'
cl2.time=1.3; G.containers.push(cl2);
'@ @'
cl2.time=1.3; G.containers.push(cl2); wornKillRoll(cl2,e);   /* v37.xx (cw-m3dsrc) */
'@

SubRx @'
c2.time=.8; G.containers.push(c2);
'@ @'
c2.time=.8; G.containers.push(c2); wornKillRoll(c2,e);   /* v37.xx (cw-m3dsrc): bigger machines better odds, his answer 68 */
'@

SubRx @'
c3.time=.7; c3.bot='snitch';
'@ @'
c3.time=.7; c3.bot='snitch'; wornKillRoll(c3,e);   /* v37.xx (cw-m3dsrc) */
'@

SubRx @'
var VER='37.59';
'@ @'
var VER='37.60';
'@

$pat = "(?m)^  now:'v37\.59:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.60: a machine wreck may hold a worn piece, more often and rarer on a bigger machine; a dead pillager body holds what he wore (0 to 2 pieces, more on a tough or elite one; he looks and fights the same); every box in a keycard room holds a piece of sound or better; all on their own dice from the raid seed and the spawn, so seed 4242 and the raid streams never move and no new wreck or body appears; one table, WORN_SRC, holds every rate Check 37.60 fails on v37.59',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
