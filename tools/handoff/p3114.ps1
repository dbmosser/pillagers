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

# melee is strong: one crowbar swing kills a crawler, elites take two, pillagers three, and every hit reads (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var CROWBAR_DMG=18;
'@ @'
// v28.xx (cw-meleeone), HIS ORDER (2026-10-18, newest, binding): "melee should be really strong and a viable combat option, should one-shot a crawler". IT REPLACES HIS NOTE OF
// 2026-10-13 ABOVE ("3 swings should kill a crawler"): ONE SWING KILLS A CRAWLER. The blow is no longer a fixed 18, it is worked out from the body it lands on (crowbarDmgOn):
//   a crawler or a snitch (the small bodies) dies to ONE swing at any enemy health setting, because the blow is its whole health (CROWBAR_DMG when that is more);
//   an elite takes one swing more (an elite crawler 2: the blow is half its health);
//   a pillager takes MELEE_SWINGS (3) from full health, an elite one 4, a wounded one fewer (the blow is a third of his health, 30 at least), and it still ignores armour;
//   every other machine takes the flat CROWBAR_DMG, 30 (was 18): a Sentry 5 swings, a Howler or a Listener 4; the Overseer keeps the old CROWBAR_BOSS, 18, and the golden enemy
//   takes the flat CROWBAR_DMG too (it has three times the health and a linked window cannot tell how much).
// The number reads maxhp and the kind, elite, golden and boss marks, which a linked window has from the host (the 'ent new' word), so player 2 swing sends the host the very number
// the host swing works out. DEMO and CAREER are the same. The bare hands punch (left click) stays 6; the reach (60), the 420 ms swing clock and the 1.5 times blow from behind on
// a machine are as they were; the arc is now the 140 degrees the swing is drawn over (CROWBAR_ARC, 1.2 rad each side; the bare hands keep 0.9). The bot never swings
// (meleeStrike refuses in a sim raid), and nothing here draws from the seeded stream.
var CROWBAR_DMG=30, CROWBAR_BOSS=18, CROWBAR_ARC=1.2, MELEE_SWINGS={crawler:1,snitch:1,raider:3};
'@

SubRx @'
function crowbarWep(){ var w=cloneObj(WEAPONS.fists); w.dmg=CROWBAR_DMG; return w; }
'@ @'
function crowbarDmgOn(e){
  var n, hp;
  if(!e) return CROWBAR_DMG;
  if(e.boss) return CROWBAR_BOSS;
  n=Object.prototype.hasOwnProperty.call(MELEE_SWINGS,e.kind)?MELEE_SWINGS[e.kind]:0;
  if(!n||e.golden) return CROWBAR_DMG;
  hp=Math.max(+e.maxhp||0,+e.hp||0);
  if(!(hp>0)) return CROWBAR_DMG;
  if(e.elite) n++;
  return Math.max(CROWBAR_DMG,Math.ceil(hp/n));
}
function crowbarWep(){ var w=cloneObj(WEAPONS.fists); w.dmg=CROWBAR_DMG; w.crowbar=1; w.arc=CROWBAR_ARC; return w; }   // v28.xx (cw-meleeone): the blow is worked out per body (crowbarDmgOn), and the swing is wide
// v28.xx (cw-meleeone): THE BLOW READS. Every crowbar hit shows its number over the body (the large one with a bang when it kills) and the hit marker in the crosshair (the kill marker, and
// its sound, on a kill); a pillager bleeds; a body the blow leaves standing is held for the hit stop beat (hitStopOn; a boss never is, and on a linked window the host holds it, the shot word
// carries hs). A kill is the heavy one: a harder kick of the screen (CROWBAR_KILL_SHAKE; a blow that does not kill keeps meleeImpact 1.8), a white burst and a low thud under the
// usual clack. Live play only, cosmetic stream only.
var CROWBAR_KILL_SHAKE=3.4;
function crowbarFeel(e,dmg,p){
  var kill, n, top, col;
  if(!G||G.sim||!e) return false;
  kill=hitKills(e,dmg); n=Math.max(1,Math.round(dmg)); top=e.y-Math.round((e.r||12)*1.1); col=dmgNumCol(null,'',false,false);
  if(!(NET.on&&netEntsPeer())) hitStopOn(e,HITSTOP_DMG);
  G.hitMark={t:0,life:kill?.2:.15,kill:kill,weak:false};
  if(CFG.dmgNumbers!==0){ dmgNum(e.x+fxn(-5,5),top,n,col,kill); if(NET.on) netFxDmg(e.x,top,n,col,kill); }
  if(e.kind==='raider') bloodFx(e.x,e.y-14,p.x,p.y,kill?40:Math.min(30,n));
  if(kill){ G.shake=Math.max(G.shake||0,CROWBAR_KILL_SHAKE); spark(e.x,e.y,'#ffffff',10,360); meleeFoley('kill',e.x,e.y); }
  return kill;
}
'@

SubRx @'
  if(kind==='hit'){ foley('plateClack',x,y,{rate:0.75,g:1.2}); foley('lmgClack',x,y,{rate:0.9,g:0.6,at:0.03,gap:0}); return true; }
'@ @'
  if(kind==='hit'){ foley('plateClack',x,y,{rate:0.75,g:1.2}); foley('lmgClack',x,y,{rate:0.9,g:0.6,at:0.03,gap:0}); return true; }
  if(kind==='kill'){ foley('plateClack',x,y,{rate:0.55,g:1.5}); foley('lmgClack',x,y,{rate:0.7,g:0.8,at:0.04,gap:0}); return true; }   // v28.xx (cw-meleeone): the killing blow lands lower and heavier
'@

SubRx @'
if(Math.abs(Math.atan2(Math.sin(_ma-base),Math.cos(_ma-base)))>0.9) continue;
'@ @'
if(Math.abs(Math.atan2(Math.sin(_ma-base),Math.cos(_ma-base)))>(wep.arc||0.9)) continue;   // v28.xx (cw-meleeone): the crowbar swings over the 140 degrees it is drawn over (CROWBAR_ARC); the bare hands keep 0.9
'@

SubRx @'
var _mdm=wep.dmg*pwrMul('dmg',fromPlayer);
'@ @'
var _mdm=(wep.crowbar?crowbarDmgOn(_me):wep.dmg)*pwrMul('dmg',fromPlayer);   // v28.xx (cw-meleeone): the crowbar blow is worked out from the body it lands on
'@

SubRx @'
if(NET.on&&netEntsPeer()) netShotSend(_me,_mdm,base,null); else _me.hp-=_mdm;
'@ @'
if(NET.on&&netEntsPeer()) netShotSend(_me,_mdm,base,null,0,'',0,wep.crowbar?1:0); else _me.hp-=_mdm;   // v28.xx (cw-meleeone): and the host holds a body the crowbar leaves standing (hs), as it holds its own
'@

SubRx @'
_swHit=true;
'@ @'
_swHit=true;
        if(wep.crowbar) crowbarFeel(_me,_mdm,sh);   // v28.xx (cw-meleeone): the number, the hit marker, the hit stop, and a kill that reads
'@

SubRx @'
var VER='31.13';
'@ @'
var VER='31.14';
'@

$pat = "(?m)^  now:'v31\.13:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.14: melee is strong: one crowbar swing kills a crawler, an elite takes two, a pillager three, and each hit shows its number. Check 31.14 fails on v31.13',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
