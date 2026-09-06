$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# HIS NOTES, 2026-09-06 (his 06:26 export, runs 3 and 4): "countdown on 'still
# applying prior healing item' isn't accurate -- just get rid of it" and
# "player should be able to equip armor plates while bandage is applying
# healing; player should be able to use next bandage while prior bandage is
# healing". This reverses his v3.34 rule (one heal at a time, the next only
# after the full cycle) and he has done so himself. Three parts: a heal
# already running no longer refuses the next one, and the wrong countdown
# goes with the refusal; a second item ADDS its health, at the faster rate
# and the higher ceiling; and the application timer is two timers, medical
# and armour, so a plate goes on while a bandage is being applied.

# 1. STACKING IN applyHeal, and the v3.34 comment brought up to date.
SubRx @'
    // Now a heal already running refuses the next one outright, at the two call
    // sites that can start one, and the rate itself is divided by healSlow.
    // healSolo 0 restores stacking and healSlow 1 restores the old speed.
    p.healQ=amt; p.healAmt0=amt;
    p.healRate=amt/(hot*(CFG.healSlow===undefined?1.6:CFG.healSlow));
    // v9.62: the ceiling travels with the heal, because the drain runs for
    // seconds afterwards and has no idea which item started it.
    p.healCap=healCeil(it);
    return 0;
'@ @'
    // The rate itself is divided by healSlow; healSlow 1 restores the old speed.
    // v11.82, HIS NOTE: the refusal is gone again. The next bandage goes on
    // while the prior one is still healing; a second item ADDS its health and
    // takes the faster of the two rates and the higher of the two ceilings.
    // The healSolo dial that gated the refusal is gone with it.
    var _rate=amt/(hot*(CFG.healSlow===undefined?1.6:CFG.healSlow)), _cap=healCeil(it);
    if((p.healQ||0)>0){
      p.healQ+=amt; p.healAmt0=p.healQ;
      p.healRate=Math.max(p.healRate||0,_rate);
      p.healCap=Math.max((p.healCap===undefined)?0:p.healCap,_cap);
    } else {
      p.healQ=amt; p.healAmt0=amt;
      p.healRate=_rate;
      // v9.62: the ceiling travels with the heal, because the drain runs for
      // seconds afterwards and has no idea which item started it.
      p.healCap=_cap;
    }
    return 0;
'@

# 2. THE TWO REFUSALS, and their countdown.
SubRx @'
  // What is already on its way counts as health you have.
  if((p.healQ||0)>0&&CFG.healSolo!==0){
    say('Still applying prior healing item. '+(p.healQ).toFixed(0)+' to go.');
    return false;
  }
  if(p.hp+(p.healQ||0)>=p.maxhp){
'@ @'
  // What is already on its way counts as health you have. v11.82, HIS NOTE: a
  // heal already running no longer refuses the next one, and the countdown
  // that refusal printed (which was wrong) is gone with it.
  if(p.hp+(p.healQ||0)>=p.maxhp){
'@
SubRx @'
      // The same refusal as useMedical. Two ways in, one rule: a named slot must
      // not be a way around a limit the generic verb enforces.
      if((_pp.healQ||0)>0&&CFG.healSolo!==0){
        say('Still applying prior healing item. '+(_pp.healQ).toFixed(0)+' to go.'); return;
      }
      if(_pp.hp+(_pp.healQ||0)>=_pp.maxhp){
'@ @'
      // The same rules as useMedical. Two ways in, one rule: a named slot must
      // not be a way around a limit the generic verb enforces. v11.82: the
      // one-heal-at-a-time refusal is gone from both, on his note.
      if(_pp.hp+(_pp.healQ||0)>=_pp.maxhp){
'@
SubRx @'
smokeR:165,fragR:190,healSolo:1
'@ @'
smokeR:165,fragR:190
'@

# 3. TWO TIMERS: prep is medical, prepA is armour.
SubRx @'
function startPrep(kind,key){
  G.player.prep={t:0,
    max:(kind==='armor'?(CFG.armorPrep===undefined?2:CFG.armorPrep)
                       :(CFG.healPrep===undefined?1.5:CFG.healPrep)),
    kind:kind,key:key};
}
function tickPrep(dt){
  var p=G.player;
  if(!p.prep) return;
  p.prep.t+=dt;
  if(p.prep.t<p.prep.max) return;
  var PR=p.prep; p.prep=null;
  var it=ITEMS[PR.key];
'@ @'
// v11.82, HIS NOTE: a plate goes on while a bandage is being applied. Two
// timers, prep for medical and prepA for armour, each ticked on its own, so
// neither verb waits for the other; each still refuses a second of its own
// kind while it runs.
function startPrep(kind,key){
  var _pr={t:0,
    max:(kind==='armor'?(CFG.armorPrep===undefined?2:CFG.armorPrep)
                       :(CFG.healPrep===undefined?1.5:CFG.healPrep)),
    kind:kind,key:key};
  if(kind==='armor') G.player.prepA=_pr; else G.player.prep=_pr;
}
function tickPrep(dt){
  var p=G.player;
  tickPrepSlot(p,'prep',dt); tickPrepSlot(p,'prepA',dt);
}
function tickPrepSlot(p,slot,dt){
  if(!p[slot]) return;
  p[slot].t+=dt;
  if(p[slot].t<p[slot].max) return;
  var PR=p[slot]; p[slot]=null;
  var it=ITEMS[PR.key];
'@
SubRx @'
  if(p.armor>=cap){ say('Armour is already full.'); return; }
  if(p.prep){ say('Already applying '+(ITEMS[p.prep.key]?ITEMS[p.prep.key].name:'something')+'.'); return; }
'@ @'
  if(p.armor>=cap){ say('Armour is already full.'); return; }
  // v11.82: only another plate blocks a plate; a bandage being applied does not.
  if(p.prepA){ say('Already slotting '+(ITEMS[p.prepA.key]?ITEMS[p.prepA.key].name:'a plate')+'.'); return; }
'@
SubRx @'
p.hp=0; p.downed=true; p.downT=CFG.downTime; p.pendKiller=src; p.prep=null;
'@ @'
p.hp=0; p.downed=true; p.downT=CFG.downTime; p.pendKiller=src; p.prep=null; p.prepA=null;
'@
SubRx @'
  if(p.prep){
    var _pf=clamp(p.prep.t/p.prep.max,0,1);
    var _py=p.y-62;
    wc.fillStyle='rgba(6,9,13,.85)';
    wc.fillRect(p.x-24,_py,48,8);
    wc.strokeStyle='rgba(255,255,255,.22)'; wc.lineWidth=1;
    wc.strokeRect(p.x-23.5,_py+0.5,47,7);
    wc.fillStyle=p.prep.kind==='armor'?'#5aa9e6':'#6fe0a0';
    wc.fillRect(p.x-23,_py+1,46*_pf,6);
  }
'@ @'
  // v11.82: two timers now (prep is medical, prepA is armour); each gets its
  // own bar, the armour bar a row above when both are running.
  var _pbs=[p.prep,p.prepA], _pbi;
  for(_pbi=0;_pbi<2;_pbi++) if(_pbs[_pbi]){
    var _pb=_pbs[_pbi];
    var _pf=clamp(_pb.t/_pb.max,0,1);
    var _py=p.y-62-((_pbi&&p.prep)?10:0);
    wc.fillStyle='rgba(6,9,13,.85)';
    wc.fillRect(p.x-24,_py,48,8);
    wc.strokeStyle='rgba(255,255,255,.22)'; wc.lineWidth=1;
    wc.strokeRect(p.x-23.5,_py+0.5,47,7);
    wc.fillStyle=_pb.kind==='armor'?'#5aa9e6':'#6fe0a0';
    wc.fillRect(p.x-23,_py+1,46*_pf,6);
  }
'@
SubRx @'
               (_shp.roll>0)||(_shp.reloading>0)||(!!_shp.prep);
'@ @'
               (_shp.roll>0)||(_shp.reloading>0)||(!!_shp.prep)||(!!_shp.prepA);
'@

# STAMPS.
SubRx @'
var VER='11.81';
'@ @'
var VER='11.82';
'@
SubRx @'
var WHATSNEW_VER='11.81';
'@ @'
var WHATSNEW_VER='11.82';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'HEALING STACKS AGAIN. The next bandage goes on while the prior one is still healing, and a plate goes on while a bandage is being applied. The one-at-a-time refusal and its countdown are gone.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.81:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.81 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.81:[^']*'",{ param($m) "now:'v11.82: HIS NOTES of 2026-09-06, the countdown on still applying prior healing item was wrong and is gone with the refusal it belonged to; the next bandage goes on while the prior one heals (a second item adds its health at the faster rate and the higher ceiling), and a plate goes on while a bandage is being applied (two application timers, prep for medical and prepA for armour). Reverses his v3.34 one-heal-at-a-time rule on his own note; the healSolo dial is removed. Check 11.82 stages a hurt player with two bandages and a plate, applies one, applies the second while the first heals and the plate while the second is being applied, requires each to have started and the refusal never said, and after the timers requires the queue to have grown and the armour to be on; fails on v11.81.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
