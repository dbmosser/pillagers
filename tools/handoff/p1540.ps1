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
    return 0;
'@ @'
    if((p.healQ||0)>0){
      p.healQ+=amt;
      p.healRate=Math.max(p.healRate||0,_rate);
      p.healCap=Math.max((p.healCap===undefined)?0:p.healCap,_cap);
      p.healHi=(p.healHi||0)+_hi;
      if(_cap<p.maxhp) p.healLo=Math.min((p.healLo===undefined)?_cap:p.healLo,_cap);
    } else {
      p.healQ=amt;
      p.healRate=_rate;
      // v9.62: the ceiling travels with the heal, because the drain runs for
      // seconds afterwards and has no idea which item started it.
      p.healCap=_cap;
      p.healHi=_hi; p.healLo=(_cap<p.maxhp)?_cap:undefined;
    }
    // v15.40, hud audit finding: THE INCOMING HEAL SHOWS ONLY THE HEALTH THAT WILL ARRIVE. healAmt0 is only what the ring over
    // his head measures its fill against, and it held everything poured into the queue. A Bandage landing at 80 stored 20 while
    // the drain stops at 85 and delivers 5, so once the ring counts down to the real stop it would start three quarters full.
    // It now stores what the drain will really deliver, the reach less his health, so the ring starts empty and fills as the
    // health arrives. The queue, the rate, the ceilings and every number are untouched.
    p.healAmt0=Math.max(0,healReach(p)-p.hp);
    return 0;
'@
SubRx @'
    applyHeal(PR.key);
    say(it&&it.hot>0&&CFG.healOverTime!==0
      ?(it.name+' is healing you, '+fmtMS((p.healQ||0)/(p.healRate||10)))
'@ @'
    applyHeal(PR.key);
    // v15.40, hud audit finding: THE INCOMING HEAL SHOWS ONLY THE HEALTH THAT WILL ARRIVE. The seconds in this line were the
    // whole queue over the rate, and the queue knows nothing of the ceilings. A Bandage landing at 80 said 6 sec while the drain
    // reaches 85 in under 2 and drops the rest. The seconds are now to healReach, where the drain really stops. Same sentence.
    say(it&&it.hot>0&&CFG.healOverTime!==0
      ?(it.name+' is healing you, '+fmtMS(Math.max(0,healReach(p)-p.hp)/(p.healRate||10)))
'@
SubRx @'
      drawOp(p.x,p.y,p.face,p.roll>0?(1-p.roll/.38)*12.6:p.bob,'#242832',
        0,p.muzzle,((G.deathBeat>0||p.hp<=0)?'down':(G.punchT>0?'fist':((pmode===''&&(G.handsT>0||(p.wep&&p.wep.id==='fists')))?'none':pmode))),p.iv,
        {hero:1,own:p,moving:!!p.moving,sprint:!!G.sprinting,ads:!!p.ads,hurt:p.hitFlash,bulk:armorById(p.rig).bulk,
         healLeft:(p.healQ||0),healTot:(p.healAmt0||0),
         healSec:((p.healQ||0)>0&&(p.healRate||0)>0)?((p.healQ)/(p.healRate)):0,
'@ @'
      // v15.40, hud audit finding: THE INCOMING HEAL SHOWS ONLY THE HEALTH THAT WILL ARRIVE. The ring over his head counted
      // the whole queue, so a Bandage landing at 80 read 7s and drained a ring sized for 20 while the drain stops at 85 after
      // about a second and a half and throws the other 15 away. What is left and the seconds are now to healReach, the drain's
      // own stop, and applyHeal stores that same reach as the total, so the ring runs from empty to full over the health that
      // arrives.
      drawOp(p.x,p.y,p.face,p.roll>0?(1-p.roll/.38)*12.6:p.bob,'#242832',
        0,p.muzzle,((G.deathBeat>0||p.hp<=0)?'down':(G.punchT>0?'fist':((pmode===''&&(G.handsT>0||(p.wep&&p.wep.id==='fists')))?'none':pmode))),p.iv,
        {hero:1,own:p,moving:!!p.moving,sprint:!!G.sprinting,ads:!!p.ads,hurt:p.hitFlash,bulk:armorById(p.rig).bulk,
         healLeft:Math.max(0,healReach(p)-p.hp),healTot:(p.healAmt0||0),
         healSec:((p.healQ||0)>0&&(p.healRate||0)>0)?(Math.max(0,healReach(p)-p.hp)/(p.healRate)):0,
'@
SubRx @'
    var h0=16+HBW*clamp(p.hp/p.maxhp,0,1);
    var h1=16+HBW*clamp((p.hp+p.healQ)/p.maxhp,0,1);
'@ @'
    var h0=16+HBW*clamp(p.hp/p.maxhp,0,1);
    // v15.40, hud audit finding: THE INCOMING HEAL SHOWS ONLY THE HEALTH THAT WILL ARRIVE. The green block ran from his health
    // to his health plus everything queued, and the queue has no idea of the ceilings the drain obeys. A Bandage landing at 80
    // drew the block to 100 while tickHeal stops at 85 and throws the other 15 away, the very promise his ruling of 2026-09-16
    // (only a Medkit gets him back to 100) says the screen must not make. The same fault drew a Bandage over a nearly spent
    // Medkit past where it stops. The block now ends at healReach, the stop the drain and every refusal already read.
    var h1=16+HBW*clamp(healReach(p)/p.maxhp,0,1);
'@
SubRx @'
var VER='15.39';
'@ @'
var VER='15.40';
'@

$pat = "(?m)^  now:'v15\.39:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.40: THE INCOMING HEAL SHOWS ONLY THE HEALTH THAT WILL ARRIVE. A Bandage landing at 80 drew the green block on the health bar to 100, put 7s over his head and said 6 sec, while the heal stops at 85 in under two seconds and the rest is thrown away. The block, the ring over his head and the Bandage is healing you line now all stop where the heal really stops, and the ring fills with the health that arrives. Check 15.40 lands a Bandage at 80 and reads the drawn block, the seconds, the line and the ring, with 50 and the heal ceilings off as controls; it fails on v15.39',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
