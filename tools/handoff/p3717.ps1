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

# SEASON ZERO FOUNDATION: WHAT YOU WEAR CHANGES HOW YOU PLAY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var RIG_PAYOUT={rig_light:360,rig_medium:1280,rig_heavy:3120};
'@ @'
// v37.xx (cw-p0stat), HIS PLAN OF 11-01, season zero, m0: ONE PLACE EVERY STAT READS GEAR FROM. What the pillager wears is summed once when the
// raid is built (raidWornMods, kept on the body as p.wm) and read through wornM(stat) at each of the stats it changes: move speed, stamina,
// reload, spread, noise, how far you are seen, bandage and medkit time, time on the floor, reviving your partner, searching and damage taken.
// wornM is 0 with nothing worn, in the bot sim, in the demo (it plays on a copy and gets its own preset kit in m3) and for any body but your
// own, and every site multiplies by 1 plus or minus it, which with 0 is exactly 1: an old save, the robots and seed 4242 play exactly as before.
function raidWornMods(){
  var m, s, any=0;
  if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on) return null;
  if(!P||!P.worn||typeof P.worn!=='object'||typeof wornMods!=='function') return null;
  m=wornMods(P.worn); for(s in m) if(m[s]) any=1;
  return any?m:null;
}
function wornM(s){ var p=(typeof G!=='undefined'&&G)?G.player:null; return (p&&p.wm&&!G.sim)?(+p.wm[s]||0):0; }
function netRevNeed(){ return NET_REV_T*(1-wornM('revive')); }   // the reviver's own gear: the hold runs in his window
var RIG_PAYOUT={rig_light:360,rig_medium:1280,rig_heavy:3120};
'@

SubRx @'
    player:{x:start.x,y:start.y,r:11,hp:100,maxhp:100,
'@ @'
    player:{x:start.x,y:start.y,r:11,hp:100,maxhp:100,wm:(sim?null:raidWornMods()),   // v37.xx (cw-p0stat): what you wear, summed once
'@

SubRx @'
  var spd=CFG.pSpeed*armorById(p.rig).spd; if(crouch)
'@ @'
  var spd=CFG.pSpeed*armorById(p.rig).spd*(1+wornM('spd')); if(crouch)
'@

SubRx @'
else if(sprint) p.stam=Math.max(0,p.stam-26*dt); else p.stam=Math.min(100,p.stam+7.5*dt);
'@ @'
else if(sprint) p.stam=Math.max(0,p.stam-26*dt*(1-wornM('stam'))); else p.stam=Math.min(100,p.stam+7.5*dt*(1+wornM('stam')));   // v37.xx (cw-p0stat)
'@

SubRx @'
rlHave(p)){ p.reloading=p.wep.reload*buzzSlow();
'@ @'
rlHave(p)){ p.reloading=p.wep.reload*buzzSlow()*(1-wornM('reload'));
'@

SubRx @'
    p.reloading=p.wep.reload*buzzSlow(); T.reloads++; if(!G.sim) reloadFoley(p);   // v25.52 (his reload order)   // v10.56
'@ @'
    p.reloading=p.wep.reload*buzzSlow()*(1-wornM('reload')); T.reloads++; if(!G.sim) reloadFoley(p);   // v25.52 (his reload order)   // v10.56
'@

SubRx @'
          p.reloading=p.wep.reload; T.reloads++;
'@ @'
          p.reloading=p.wep.reload*(1-wornM('reload')); T.reloads++;
'@

SubRx @'
+(fromPlayer?bloomCone(G.player,wep):0);   // v26.xx (feel19)
'@ @'
+(fromPlayer?bloomCone(G.player,wep):0); if(fromPlayer) spx*=1-wornM('steady');   // v37.xx (cw-p0stat): steady aim   // v26.xx (feel19)
'@

SubRx @'
  if(src==='player'&&G.player&&!pre) s*=armorById(G.player.rig).noise;
'@ @'
  if(src==='player'&&G.player&&!pre) s*=armorById(G.player.rig).noise*(1-wornM('quiet'));   // v37.xx (cw-p0stat): quiet
'@

SubRx @'
    var _fSee=_far0*(e.alert>0?1.35:1)*pcon*wkSight, _aSee=_amb0*pcon*wkSight;
'@ @'
    var _wmh=(p===G.player)?1-wornM('hide'):1, _fSee=_far0*(e.alert>0?1.35:1)*pcon*wkSight*_wmh, _aSee=_amb0*pcon*wkSight*_wmh;   // v37.xx (cw-p0stat): hard to spot
'@

SubRx @'
                       :(CFG.healPrep===undefined?1.5:CFG.healPrep)),
'@ @'
                       :(CFG.healPrep===undefined?1.5:CFG.healPrep)*(1-wornM('heal'))),   // v37.xx (cw-p0stat): quick hands
'@

SubRx @'
p.hp=0; p.downed=true; p.downT=CFG.downTime;
'@ @'
p.hp=0; p.downed=true; p.downT=CFG.downTime*(1+wornM('grit')); p.downMax=p.downT;   /* v37.xx (cw-p0stat): grit */
'@

SubRx @'
bar(W/2-100,_barY,200,10,p.downT/CFG.downTime,
'@ @'
bar(W/2-100,_barY,200,10,p.downT/(p.downMax||CFG.downTime),
'@

SubRx @'
  if(G.netRevT<NET_REV_T) return true;
'@ @'
  if(G.netRevT<netRevNeed()) return true;   // v37.xx (cw-p0stat): medic
'@

SubRx @'
Math.min(1,G.netRevT/NET_REV_T)
'@ @'
Math.min(1,G.netRevT/netRevNeed())
'@

SubRx @'
sndRevCharge(G.netRevT/NET_REV_T)
'@ @'
sndRevCharge(G.netRevT/netRevNeed())
'@

SubRx @'
      near.prog=(near.prog||0)+dt/buzzSlow()*
'@ @'
      near.prog=(near.prog||0)+dt/buzzSlow()/(1-wornM('search'))*
'@

SubRx @'
  amt*=CFG.eDmg*easyDmgMul();   // v28.xx (cw-easymode)
'@ @'
  amt*=CFG.eDmg*easyDmgMul()*(1-wornM('tough'));   // v37.xx (cw-p0stat): tough   // v28.xx (cw-easymode)
'@

SubRx @'
var VER='37.16';
'@ @'
var VER='37.17';
'@

$pat = "(?m)^  now:'v37\.16:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.17: move speed, stamina, reload, spread, noise, how far you are seen, bandage time, time on the floor, reviving and searching all read what you wear, summed once per raid; nothing is worn yet so every raid plays exactly as before, the robots and the demo never read it Check 37.17 fails on v37.16',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
