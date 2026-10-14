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

# CROUCH STILL TO CREEP BACK HEALTH (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var _top=healCeil(ITEMS.bandage);
  if(p.downed||p.hp>=_top||p.combatT<CFG.regenDelay){ p.regenAcc=0; return; }
'@ @'
  var _top=healCeil(ITEMS.bandage);
  // v26.xx (crouchregen), HIS NOTE (2026-10-13): "crouching and sitting still should very slowly regain health". CROUCHED AND KEPT
  // STILL, he creeps back one point every 2 seconds. It wants 3 seconds of stillness (no move input and no push of more than a few
  // units), 3 seconds since the last shot fired or taken and 6 since the last hit that landed; a move, a shot, a roll, standing up
  // or a hit puts the wait back to the start. It stops at the Bandage ceiling like the creep below, so 85 and no higher and a Medkit
  // stays the only way to 100, and while it runs it takes the place of that creep (one point in 2 seconds beats one in 3, and it
  // starts at 6 quiet seconds, not 10) so the two never stack. Not downed, not dying, not the bot. The RECOVERING mark rides the
  // same regenLive stamp. The health is this window's own and rides the same broadcast a heal does. No seeded draw, no new dial.
  var _cs=!G.sim&&crouchHeld()&&!p.moving&&!p.downed&&!p.dying&&p.hp>0&&!p.specOut&&!(G.deathBeat!==undefined&&G.deathBeat!==null);
  p.crQuiet=(p.crQuiet===undefined?99:p.crQuiet)+dt;
  if(_cs&&p.crX!==undefined&&Math.abs(p.x-p.crX)+Math.abs(p.y-p.crY)<6) p.crStill=(p.crStill||0)+dt;
  else { p.crStill=0; p.crX=p.x; p.crY=p.y; }
  if(_cs&&p.crStill>=3&&p.combatT>=3&&p.crQuiet>=6&&p.hp<_top){
    p.crAcc=(p.crAcc||0)+dt; p.regenAcc=0; p.regenLive=G.t; p.crLive=G.t;
    while(p.crAcc>=2&&p.hp<_top){ p.crAcc-=2; p.hp=Math.min(_top,p.hp+1); G.tel.regen=(G.tel.regen||0)+1; }
    return;
  }
  p.crAcc=0;
  if(p.downed||p.hp>=_top||p.combatT<CFG.regenDelay){ p.regenAcc=0; return; }
'@

SubRx @'
  p.combatT=0;
  // HIS NOTE, 2026-08-26: "add screen shake any time you take damage"
'@ @'
  p.combatT=0; p.crQuiet=0;   // v26.xx (crouchregen): and the 6 quiet seconds the crouched creep wants start over
  // HIS NOTE, 2026-08-26: "add screen shake any time you take damage"
'@

SubRx @'
      if(!p.downed&&p.hp>0&&p.hp<top&&(p.combatT||0)>=CFG.regenDelay&&typeof p.regenLive==='number'&&G.t-p.regenLive<0.5){ E.on=true; if(E.vk!==top){ E.vk=top; E.v='to '+top; } }
'@ @'
      if(!p.downed&&p.hp>0&&p.hp<top&&((p.combatT||0)>=CFG.regenDelay||(typeof p.crLive==='number'&&G.t-p.crLive<0.5))&&typeof p.regenLive==='number'&&G.t-p.regenLive<0.5){ E.on=true; if(E.vk!==top){ E.vk=top; E.v='to '+top; } }
'@

SubRx @'
var VER='26.03';
'@ @'
var VER='26.04';
'@

$pat = "(?m)^  now:'v26\.03:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.04: Crouch and keep still and your health slowly creeps back, up to 85. Check 26.04 fails on v26.03',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
