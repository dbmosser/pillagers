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

# NO GUN MEANS A SCAV PISTOL, NEVER A LOANER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var wep=WEAPONS[P.equipped],wepIssued=false;
'@ @'
  var wep=WEAPONS[P.equipped],wepIssued=false,wepSpawn=false,wepDrew=false;   // v26.17 (noloaner): wepSpawn, the Scav Pistol that replaces the loaner; wepDrew, whether the starter draw was made (what wepIssued meant)
'@

SubRx @'
    else wep=WEAPONS[pick(STARTERS)];
    wepIssued=true;
'@ @'
    else wep=WEAPONS[pick(STARTERS)];
    // v26.17 (noloaner), HIS ORDER (2026-10-14, playing CAREER): "i chose top gear and it gave me a loaner gun -- if i don't have a gun it
    // should just give me a scav pistol". Gun 1 empty or not his (after a death, TOP GEAR or RANDOM FROM STASH with nothing in the armoury
    // to equip, MY LOADOUT on bare hands, the quick ascent) issued one of four loaner starters, flagged issued, so an extraction banked
    // nothing. It now takes the Scav Pistol in hand exactly as the freebie kit does: not issued, not from the armoury, so an
    // extraction banks it, a death loses it, and the death card never bills it as a gun he owned. The starter draw above is still made
    // and thrown away, so the seeded stream, the seed 4242 raid and the party's loaner word (issDraw) are what they were. The bot sim
    // keeps its starter. DEMO never comes here (its sandbox owns the gun it deals).
    wepDrew=true;
    if(!sim&&WEAPONS[FREEKIT_GUN]){ wep=WEAPONS[FREEKIT_GUN]; wepSpawn=true; } else wepIssued=true;
'@

SubRx @'
    if(!wepIssued&&wep&&wep.id&&P.forged[wep.id]) wep=forgeApply(wep,P.forged[wep.id].fk,P.forged[wep.id].el);
'@ @'
    if(!wepIssued&&!wepSpawn&&wep&&wep.id&&P.forged[wep.id]) wep=forgeApply(wep,P.forged[wep.id].fk,P.forged[wep.id].el);   // v26.17 (noloaner): not the spawn pistol
'@

SubRx @'
spawnDbg:_spDbg,issDraw:wepIssued,
'@ @'
spawnDbg:_spDbg,issDraw:wepDrew,spawnGun:wepSpawn,
'@

SubRx @'
wepIssued:wepIssued,secIssued:secIss,wepFromArmory:!wepIssued,secFromArmory:!secIss,
'@ @'
wepIssued:wepIssued,secIssued:secIss,wepFromArmory:!wepIssued&&!wepSpawn,secFromArmory:!secIss,
'@

SubRx @'
        g.player.wepIssued=false; g.player.wepFromArmory=false;
'@ @'
        g.player.wepIssued=false; g.player.wepFromArmory=false;
        g.spawnGun=false;   // v26.17 (noloaner): on the freebie kit the freebie rules are the only ones in play
'@

SubRx @'
    if(!G.sim&&G.player&&G.player.wepIssued&&(P.stash||[]).some(
'@ @'
    if(!G.sim&&G.player&&G.spawnGun&&(P.stash||[]).some(
'@

SubRx @'
      var _loanLn='LOANER GUN';
'@ @'
      var _loanLn='SCAV PISTOL';   // v26.17 (noloaner): the gun he holds, and the detail still tells him his own gun waits
'@

SubRx @'
          if(_d3h[0]||(G.freeKit&&_d3g===FREEKIT_GUN&&!_d3h[1])) continue;
'@ @'
          if(_d3h[0]||((G.freeKit||G.spawnGun)&&_d3g===FREEKIT_GUN&&!_d3h[1])) continue;   // v26.17 (noloaner): the spawn pistol is the kit pistol here
'@

SubRx @'
        if(G.freeKit&&_d3w<0&&_d3g===FREEKIT_GUN) continue;
'@ @'
        if((G.freeKit||G.spawnGun)&&_d3w<0&&_d3g===FREEKIT_GUN) continue;
'@

SubRx @'
      else if(!_ks[i][2]&&ITEMS['gun_'+_kw.id]) P.stash.push('gun_'+_kw.id);
'@ @'
      // v26.17 (noloaner): the spawn pistol is never a second Scav Pistol in the stash (spawn-only, his order of 2026-10-12): it is banked
      // when the armoury has none and otherwise it is simply gone, as the pistol he started the raid with.
      else if(!_ks[i][2]&&ITEMS['gun_'+_kw.id]&&!(G.spawnGun&&_kw.id===FREEKIT_GUN)) P.stash.push('gun_'+_kw.id);
'@

SubRx @'
    var _keq=kept.filter(function(w){ return !(G.freeKit&&w.id===FREEKIT_GUN&&
'@ @'
    var _keq=kept.filter(function(w){ return !((G.freeKit||G.spawnGun)&&w.id===FREEKIT_GUN&&
'@

SubRx @'
      var _egFree=!!(G.freeKit&&!_egArm&&gone[j].id===FREEKIT_GUN);
'@ @'
      var _egFree=!!((G.freeKit||G.spawnGun)&&!_egArm&&gone[j].id===FREEKIT_GUN);   // v26.17 (noloaner): the spawn pistol is not a gun he owned either
'@

SubRx @'
(w?escHtml(w.name):'a gun issued at the lift')
'@ @'
(w?escHtml(w.name):'a Scav Pistol')
'@

SubRx @'
no gun of your own, a loaner
'@ @'
no gun of your own, a Scav Pistol
'@

SubRx @'
var VER='26.16';
'@ @'
var VER='26.17';
'@

$pat = "(?m)^  now:'v26\.16:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.17: A kit never issues a loaner: with no gun of your own you go up with the Scav Pistol in hand, kept on an extraction, and with a gun of your own only that gun goes up. Check 26.17 fails on v26.16',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
