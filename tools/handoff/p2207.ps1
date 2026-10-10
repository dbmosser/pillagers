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

# SHOOTING THE SURVIVOR COSTS PLAYER 2 TOO (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(e.kind==='raider'&&e.hostile===false&&!e.merc&&!e.friendlyPC) e.hostile=true;
'@ @'
  if(e.kind==='raider'&&e.hostile===false&&!e.merc&&!e.friendlyPC) e.hostile=true;
  if(e.kind==='stray'&&!e.hostile){ e.hostile=1; e.helped=0; e.foeSeat=s; }   // v22.07 (K18): a round from one of the party turns the Survivor, as the host own round does, and he fires back at that seat
'@

SubRx @'
if(en.kind==='stray'&&!en.hostile&&!G.sim){
                en.hostile=1; en.helped=0;
                say('The survivor returns fire.');
              }
'@ @'
              // v22.07, from the whole-game bug hunt of 2026-10-08 (K18): ON A LINKED WINDOW THE HOST TURNS HIM. Up top in co-op this
              // body is a copy of the one the host runs: turning it here was put back by the next snapshot, so the line came again on
              // every hit while the real Survivor kept walking to the ring. The round goes to the host (below), which turns him now;
              // here the line is said once. Solo and the host window are unchanged.
if(en.kind==='stray'&&!en.hostile&&!G.sim){
                if(NET.on&&netEntsPeer()){ if(!en._rfTold){ en._rfTold=1; say('THE SURVIVOR RETURNS FIRE','warn'); } }
                else { en.hostile=1; en.helped=0; en.foeSeat=0; say('THE SURVIVOR RETURNS FIRE','warn'); }
              }
'@

SubRx @'
      if(!G.sim&&e.hostile&&!e.downed){
        if(sdd<420&&losClear(e.x,e.y,p.x,p.y,G.vseg)){
          e.face=Math.atan2(p.y-e.y,p.x-e.x);
          e.cd=(e.cd||0)-dt;
          if(e.cd<=0){ e.cd=0.9; fireWeapon(e,WEAPONS.pistol,p.x,p.y,false); }
        }
'@ @'
      if(!G.sim&&e.hostile&&!e.downed){
        // v22.07, from the whole-game bug hunt of 2026-10-08 (K18): HE FIRES BACK AT THE ONE WHO TURNED HIM. Turned by a round from
        // one of the party (netShotTake sets foeSeat), he aims at that player while he can see him, not at whoever stands nearest.
        // With no seat (solo, or a host round) it is p, as before.
        var _sT=p, _sL, _sj;
        if(e.foeSeat>0&&NET.on){ _sL=netPlayersList(); for(_sj=0;_sj<_sL.length;_sj++) if(_sL[_sj]&&_sL[_sj].net&&_sL[_sj].seat===e.foeSeat&&!_sL[_sj].downed){ _sT=_sL[_sj]; break; } }
        if(dist(e,_sT)<420&&losClear(e.x,e.y,_sT.x,_sT.y,G.vseg)){
          e.face=Math.atan2(_sT.y-e.y,_sT.x-e.x);
          e.cd=(e.cd||0)-dt;
          if(e.cd<=0){ e.cd=0.9; fireWeapon(e,WEAPONS.pistol,_sT.x,_sT.y,false); }
        }
'@

SubRx @'
    sayWhenFree((e.name||'He')+' will remember that.');
  }
  return 'kill';
'@ @'
    sayWhenFree((e.name||'He')+' will remember that.');
  }
  // v22.07, from the whole-game bug hunt of 2026-10-08 (K18): A SURVIVOR OR THE PEDDLER THIS PLAYER KILLED COSTS HIM. The death
  // branch in updateEnts charges notoriety only for the host round (byPlayer), so a kill by one of the party was free. It is
  // charged here, on this window save, with the stamp and the NOTORIETY +1 label the host gets for his own (the raid text plan dropped the sentence).
  if(k==='stray'||k==='peddler'){
    P.notoriety=(P.notoriety||0)+1; saveProfile();
    T[k==='stray'?'strayKilled':'pedKilled']=1;
    if(e) label(e.x,e.y-18,'NOTORIETY +1','#ff6b5a',0,true);
    notoStamp(k==='stray'?'YOU SHOT AN UNARMED SURVIVOR':'YOU KILLED THE PEDDLER');
  }
  return 'kill';
'@

SubRx @'
var VER='22.06';
'@ @'
var VER='22.07';
'@

$pat = "(?m)^  now:'v22\.06:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.07: In co-op, the Survivor fires back at player 2 when shot, and killing him or the Peddler costs player 2 notoriety. Check 22.07 fails on v22.06',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
