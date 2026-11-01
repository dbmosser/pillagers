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

# SEASON ZERO FOUNDATION: WORN GEAR PIECES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var RCOL={common:'#9da3a8',uncommon:'#5fbf6a',rare:'#3f9de9',elite:'#a866e0',gold:'#ffc72e'};
'@ @'
var RCOL={common:'#9da3a8',uncommon:'#5fbf6a',rare:'#3f9de9',elite:'#a866e0',gold:'#ffc72e'};
// v37.xx (cw-p0gear), HIS PLAN OF 11-01, season zero, m0 (foundation): WORN GEAR IS A SAVED THING OF ITS OWN. His words: "gear (not guns) the player
// wears that improve play"; "i like the idea of worn gear that you lose upon death"; nine slots, "headgear, amulet, armor, pants, 2 rings, boots,
// gloves, backpack -- no cloak"; the backpack is "just a helper piece like any other worn gear" (no loot cap); rarities scrap, sound, rare, relic;
// strength follows your current gear "kinda like how Destiny 2 does"; total power near +25%; a pip per extract worn, up to 3; never wears out.
// An item is a key in a list; a piece is a record: {id, k kind, r rarity 0 to 3, pw power, tr [{s stat, v fraction}], pip 0 to 3, dye, rule}.
// The stash keeps pieces in P.gear (no limit, his answer 69) and the pillager wears them in P.worn (slot to piece). This build only lays the
// records and the maker down: nothing drops, nothing is worn and no stat reads them yet (m3 drops and dresses; the next m0 build wires the stats).
// A PIECE IS ROLLED ON ITS OWN DICE (wornRand, a private generator), never the raid stream, so seed 4242 builds the same raid whatever drops.
var WORN_SLOTS=['head','amulet','armor','pants','ring1','ring2','boots','gloves','pack'];
var WORN_KINDS={head:{n:'headgear',slots:['head']},amulet:{n:'amulet',slots:['amulet']},armor:{n:'armor',slots:['armor']},pants:{n:'pants',slots:['pants']},
  ring:{n:'ring',slots:['ring1','ring2']},boots:{n:'boots',slots:['boots']},gloves:{n:'gloves',slots:['gloves']},pack:{n:'backpack',slots:['pack']}};
// scrap 1 small trait (most drops), sound 2, rare 2 stronger, relic 2 stronger and a rule breaker (the rule comes in m7). Colours are the loot row colours.
var WORN_RARS=[{id:'scrap',n:1,mul:1,c:RCOL.common},{id:'sound',n:2,mul:1,c:RCOL.uncommon},{id:'rare',n:2,mul:1.5,c:RCOL.rare},{id:'relic',n:2,mul:1.5,rule:1,c:RCOL.elite}];
// Every trait, as the fraction it helps the wearer at power 50 and no pips; cap is the most all worn pieces can add (gear near +25%, his answer 72).
var WORN_STATS={
  spd:   {n:'move speed',  base:0.035,cap:0.15},   // walk, sprint and crouch speed up
  stam:  {n:'stamina',     base:0.06, cap:0.25},   // sprint drains slower, refills faster
  reload:{n:'reload',      base:0.05, cap:0.25},   // reload time down
  steady:{n:'steady aim',  base:0.05, cap:0.25},   // spread down
  quiet: {n:'quiet',       base:0.05, cap:0.25},   // every noise you make reaches less far
  hide:  {n:'hard to spot',base:0.04, cap:0.20},   // machines and pillagers see you from less far
  heal:  {n:'quick hands', base:0.06, cap:0.25},   // bandage and medkit time down
  grit:  {n:'grit',        base:0.08, cap:0.30},   // more time before you bleed out
  revive:{n:'medic',       base:0.08, cap:0.30},   // reviving your partner is quicker
  search:{n:'search',      base:0.05, cap:0.25},   // containers open quicker
  tough: {n:'tough',       base:0.03, cap:0.15}    // damage taken down
};
// What each kind rolls from (the plan's slot themes). Rings and the amulet take any trait.
var WORN_POOL={head:['hide','steady','revive'],armor:['tough','grit'],pants:['spd','stam'],boots:['quiet','hide','spd'],gloves:['reload','steady','heal'],pack:['search','quiet','stam']};
var WORN_PW_MAX=100;
function wornPool(k){ var a=WORN_POOL[k], s; if(a) return a; a=[]; for(s in WORN_STATS) if(Object.prototype.hasOwnProperty.call(WORN_STATS,s)) a.push(s); return a; }
// mulberry32 on its own state: the raid stream (RNGS) and the cosmetic stream (FXS) are never read or moved.
function wornRand(seed){ var t=(seed>>>0)||1; return function(){ t=(t+0x6D2B79F5)>>>0; var q=Math.imul(t^(t>>>15),t|1); q^=q+Math.imul(q^(q>>>7),q|61); return ((q^(q>>>14))>>>0)/4294967296; }; }
function wornPwMul(pw){ return 0.6+0.4*Math.max(1,Math.min(WORN_PW_MAX,pw|0))/50; }
// One piece of kind k, rarity r, power pw, from seed. The same four in give the same piece out.
function wornMake(k,r,pw,seed){
  var R=wornRand(seed), rar=WORN_RARS[Math.max(0,Math.min(3,r|0))], pool=wornPool(k).slice(), tr=[], i, j, s, v;
  if(!WORN_KINDS[k]) return null;
  pw=Math.max(1,Math.min(WORN_PW_MAX,pw|0));
  for(i=0;i<rar.n&&pool.length;i++){
    j=Math.floor(R()*pool.length); s=pool.splice(j,1)[0];
    v=WORN_STATS[s].base*rar.mul*wornPwMul(pw)*(0.75+0.5*R());
    tr.push({s:s,v:Math.round(v*1000)/1000});
  }
  return {id:'',k:k,r:WORN_RARS.indexOf(rar),pw:pw,tr:tr,pip:0,dye:'',rule:''};
}
// How much one trait gives with its pips: each pip a third stronger, up to 3.
function wornTraitV(pc,t){ return (+t.v||0)*(1+Math.max(0,Math.min(3,pc.pip|0))/3); }
function wornName(pc){ return pc&&WORN_KINDS[pc.k]?(WORN_RARS[pc.r].id+' '+WORN_KINDS[pc.k].n):''; }
'@

SubRx @'
var RIG_PAYOUT={rig_light:360,rig_medium:1280,rig_heavy:3120};
'@ @'
// v37.xx (cw-p0gear): THE SAVED PIECES ARE CHECKED ON EVERY LOAD. A piece with a kind, rarity or trait this build does not know is dropped; numbers
// are pulled back into range; a piece in the wrong slot goes to the stash; a second copy of one id is dropped. An old save has neither list and
// gets two empty ones, so it loads exactly as it was.
function wornCleanPc(pc){
  var t=[], i, q;
  if(!pc||typeof pc!=='object'||!WORN_KINDS[pc.k]) return null;
  pc.r=Math.max(0,Math.min(3,pc.r|0)); pc.pw=Math.max(1,Math.min(WORN_PW_MAX,pc.pw|0)); pc.pip=Math.max(0,Math.min(3,pc.pip|0));
  if(typeof pc.id!=='string') pc.id=''; if(typeof pc.dye!=='string') pc.dye=''; if(typeof pc.rule!=='string') pc.rule='';
  if(Array.isArray(pc.tr)) for(i=0;i<pc.tr.length&&t.length<3;i++){ q=pc.tr[i]; if(q&&WORN_STATS[q.s]&&typeof q.v==='number'&&isFinite(q.v)) t.push({s:q.s,v:Math.max(0,Math.min(WORN_STATS[q.s].cap,q.v))}); }
  pc.tr=t;
  return pc;
}
function wornClean(p){
  var seen={}, out=[], w={}, i, s, pc, L;
  if(!p||typeof p!=='object') return false;
  if(typeof p.gearN!=='number'||!isFinite(p.gearN)||p.gearN<0) p.gearN=0;
  var take=function(pc){ pc=wornCleanPc(pc); if(!pc) return null; if(!pc.id) pc.id='g'+(++p.gearN); if(seen[pc.id]) return null; seen[pc.id]=1; return pc; };
  if(p.worn&&typeof p.worn==='object'&&!Array.isArray(p.worn)) for(i=0;i<WORN_SLOTS.length;i++){ s=WORN_SLOTS[i]; pc=take(p.worn[s]); if(!pc) continue;
    if(WORN_KINDS[pc.k].slots.indexOf(s)>=0) w[s]=pc; else out.push(pc); }
  L=Array.isArray(p.gear)?p.gear:[];
  for(i=0;i<L.length;i++){ pc=take(L[i]); if(pc) out.push(pc); }
  p.gear=out; p.worn=w;
  return true;
}
// A new piece into the stash, with an id of its own.
function wornAdd(p,pc){ if(!p||!wornCleanPc(pc)) return null; wornClean(p); pc.id='g'+(++p.gearN); p.gear.push(pc); return pc; }
// Wear a stash piece. slot is optional: the first free slot its kind fits, else the first. What was there goes back to the stash.
function wornWear(p,id,slot){
  var i, ix=-1, pc, sl, was;
  if(!p||!wornClean(p)) return false;
  for(i=0;i<p.gear.length;i++) if(p.gear[i].id===id){ ix=i; break; }
  if(ix<0) return false;
  pc=p.gear[ix]; sl=WORN_KINDS[pc.k].slots;
  if(slot===undefined||slot===null){ slot=sl[0]; for(i=0;i<sl.length;i++) if(!p.worn[sl[i]]){ slot=sl[i]; break; } }
  if(sl.indexOf(slot)<0) return false;
  was=p.worn[slot]; p.gear.splice(ix,1); p.worn[slot]=pc; if(was) p.gear.push(was);
  return true;
}
function wornOff(p,slot){ if(!p||!wornClean(p)||!p.worn[slot]) return false; p.gear.push(p.worn[slot]); delete p.worn[slot]; return true; }
// THE ONE SUM OF EVERYTHING WORN: stat to fraction. The same trait on both rings does not stack (the stronger counts, his plan); every stat stops at
// its cap. With nothing worn every stat is 0, which the stat build multiplies in as exactly 1.
function wornMods(worn){
  var m={}, ring={}, i, j, s, pc, v;
  for(s in WORN_STATS) if(Object.prototype.hasOwnProperty.call(WORN_STATS,s)) m[s]=0;
  if(!worn||typeof worn!=='object') return m;
  for(i=0;i<WORN_SLOTS.length;i++){ pc=worn[WORN_SLOTS[i]]; if(!pc||!Array.isArray(pc.tr)) continue;
    for(j=0;j<pc.tr.length;j++){ s=pc.tr[j].s; if(!WORN_STATS[s]) continue; v=wornTraitV(pc,pc.tr[j]);
      if(pc.k==='ring'){ ring[s]=Math.max(ring[s]||0,v); continue; }
      m[s]+=v; } }
  for(s in ring) m[s]+=ring[s];
  for(s in m) m[s]=Math.round(Math.min(WORN_STATS[s].cap,m[s])*10000)/10000;
  return m;
}
var RIG_PAYOUT={rig_light:360,rig_medium:1280,rig_heavy:3120};
'@

SubRx @'
  try{ acctEnsure(P); }catch(_ae){}   // v37.xx (cw-p0acct): a first launch has its generation one pillager too
'@ @'
  try{ acctEnsure(P); }catch(_ae){}   // v37.xx (cw-p0acct): a first launch has its generation one pillager too
  try{ wornClean(P); }catch(_wc){}   // v37.xx (cw-p0gear): the stash gear and the worn slots, checked; an old save gets two empty lists
'@

SubRx @'
var VER='37.15';
'@ @'
var VER='37.16';
'@

$pat = "(?m)^  now:'v37\.15:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.16: the save holds stash gear and nine worn slots, each piece with a kind, rarity, power, traits and pips, rolled on its own dice; every load checks them; nothing drops or is worn yet Check 37.16 fails on v37.15',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
