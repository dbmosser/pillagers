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

SubRx @'
    // hits still do not; being SHOT TO THE FLOOR is not an ordinary hit.
    p.healQ=0; p.healRate=0; p.healCap=undefined;
'@ @'
    // hits still do not; being SHOT TO THE FLOOR is not an ordinary hit.
    p.healQ=0; p.healRate=0; p.healCap=undefined; p.healHi=0; p.healLo=undefined;   // v15.26: and what may pass a Bandage ceiling goes with it
'@
SubRx @'
  return (it&&typeof it.capHp==='number')?Math.min(mx,it.capHp):mx;
}
function applyHeal(key){
'@ @'
  return (it&&typeof it.capHp==='number')?Math.min(mx,it.capHp):mx;
}
// v15.26, his ruling of 2026-09-16: HOW HIGH A RUNNING HEAL WILL REALLY TAKE HIM. The drain stops at the queue ceiling
// (healCap) and, past the lowest ceiling in the queue (healLo, a Bandage 85), lets on only the health a Medkit brought
// (healHi). Every refusal that asks what is already on its way reads this, so none of them disagrees with the drain.
function healReach(p){
  var q=p.healQ||0;
  if(!(q>0)) return p.hp;
  var r=Math.min((p.healCap===undefined?p.maxhp:p.healCap),p.hp+q);
  return (p.healLo===undefined)?r:Math.min(r,Math.max(p.hp,p.healLo)+Math.min(p.healHi||0,q));
}
function applyHeal(key){
'@
SubRx @'
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
'@ @'
    // v15.26, his ruling of 2026-09-16: ONLY A MEDKIT GETS HIM BACK TO 100. "bandages should only let players heal to 85 HP --
    // only medkit gets player back to 100". The higher ceiling is shared by the whole queue, so a Bandage put on while a Medkit
    // was still running rode the Medkit up to 100: from 30, about 96, where the Medkit and then a Bandage stop near 91. Stacking
    // and the higher ceiling stay. The queue also carries the lowest ceiling in it (healLo) and how much of it may go past that
    // ceiling (healHi, the health a Medkit brought); the drain lets only healHi past healLo. With the heal ceilings dial off
    // every ceiling is full health, healLo stays unset and nothing changes.
    var _rate=amt/(hot*(CFG.healSlow===undefined?1.6:CFG.healSlow)), _cap=healCeil(it), _hi=(_cap>=p.maxhp)?amt:0;
    if((p.healQ||0)>0){
      p.healQ+=amt; p.healAmt0=p.healQ;
      p.healRate=Math.max(p.healRate||0,_rate);
      p.healCap=Math.max((p.healCap===undefined)?0:p.healCap,_cap);
      p.healHi=(p.healHi||0)+_hi;
      if(_cap<p.maxhp) p.healLo=Math.min((p.healLo===undefined)?_cap:p.healLo,_cap);
    } else {
      p.healQ=amt; p.healAmt0=amt;
      p.healRate=_rate;
      // v9.62: the ceiling travels with the heal, because the drain runs for
      // seconds afterwards and has no idea which item started it.
      p.healCap=_cap;
      p.healHi=_hi; p.healLo=(_cap<p.maxhp)?_cap:undefined;
    }
'@
SubRx @'
  // 85 is not refused as Already healing.
  var _reach=Math.min(p.hp+(p.healQ||0),(p.healCap===undefined?p.maxhp:p.healCap));
'@ @'
  // 85 is not refused as Already healing.
  // v15.26: and a Bandage over a Medkit stops at 85 plus what the Medkit had left, so the reach is the drain's own, healReach.
  var _reach=healReach(p);
'@
SubRx @'
  // out below. Left behind, a Bandage's 85 made every later test read full health as 85.
  if(room<=0){ p.healQ=0; p.healRate=0; p.healCap=undefined; return; }
  if(give>room) give=room;
  p.hp+=give; p.healQ-=give;
  if(p.healQ<=0.001){ p.healQ=0; p.healRate=0; p.healCap=undefined; }
'@ @'
  // out below. Left behind, a Bandage's 85 made every later test read full health as 85.
  if(room<=0){ p.healQ=0; p.healRate=0; p.healCap=undefined; p.healHi=0; p.healLo=undefined; return; }
  if(give>room) give=room;
  // v15.26, his ruling of 2026-09-16: ONLY A MEDKIT GETS HIM BACK TO 100. Past the lowest ceiling in the queue (a Bandage 85)
  // only the health a Medkit brought goes on. Once that is spent, what is left of the queue cannot raise him and goes. The
  // queue is only emptied when that limit cut this step to nothing, so a step with no time in it never loses a heal.
  if(p.healLo!==undefined){
    var _ov=p.hp+give-Math.max(p.hp,p.healLo), _h=p.healHi||0;
    if(_ov>_h){
      give-=_ov-_h; _ov=_h;
      if(give<=1e-6){ p.healQ=0; p.healRate=0; p.healCap=undefined; p.healHi=0; p.healLo=undefined; return; }
    }
    if(_ov>0) p.healHi=_h-_ov;
  }
  p.hp+=give; p.healQ-=give;
  if(p.healHi>p.healQ) p.healHi=p.healQ;
  if(p.healQ<=0.001){ p.healQ=0; p.healRate=0; p.healCap=undefined; p.healHi=0; p.healLo=undefined; }
'@
SubRx @'
    if(G.player&&Math.min(G.player.hp+(G.player.healQ||0),(G.player.healCap===undefined?G.player.maxhp:G.player.healCap))>=healCeil(it)) continue;   // v12.04: what is inbound counts, up to what the running heal can deliver
'@ @'
    // v15.26: the reach is the drain's own, so a Bandage over a Medkit counts as stopping at 85 plus what the Medkit had left.
    if(G.player&&healReach(G.player)>=healCeil(it)) continue;   // v12.04: what is inbound counts, up to what the running heal can deliver
'@
SubRx @'
      // Bandage's 85 does not make a Medkit on its own key Already healing.
      if(Math.min(_pp.hp+(_pp.healQ||0),(_pp.healCap===undefined?_pp.maxhp:_pp.healCap))>=_pp.maxhp){
'@ @'
      // Bandage's 85 does not make a Medkit on its own key Already healing.
      // v15.26: nor does a Bandage over a Medkit, which stops at 85 plus what the Medkit had left: the drain's own reach.
      if(healReach(_pp)>=_pp.maxhp){
'@
SubRx @'
      if(Math.min(_pp.hp+(_pp.healQ||0),(_pp.healCap===undefined?_pp.maxhp:_pp.healCap))>=healCeil(ait)){ say(ait.name+' will not take you past '+Math.round(healCeil(ait))+'.'); return; }
'@ @'
      if(healReach(_pp)>=healCeil(ait)){ say(ait.name+' will not take you past '+Math.round(healCeil(ait))+'.'); return; }
'@
SubRx @'
var VER='15.25';
'@ @'
var VER='15.26';
'@

$pat = "(?m)^  now:'v15\.25:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.26: A BANDAGE ON A RUNNING MEDKIT STOPS AT 85, HIS RULING OF 2026-09-16. A Bandage put on while a Medkit was still healing shared the Medkit ceiling of 100, so from 30 the two ended near 96 where the Medkit and then a Bandage stop near 91. Past 85 only the health a Medkit brought goes on now, and every Already healing refusal reads the same reach. Check 15.26 stacks Bandages and Medkits from 30, 50, 60 and 70 with ceilings on and off; it fails on v15.25',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
