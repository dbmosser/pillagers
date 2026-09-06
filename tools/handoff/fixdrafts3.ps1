$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# Repairs to 1182, 1187, 1188, 1189 from the 2026-09-06 read-only review.
# Blocks are built from line arrays; line breaks match \r?\n.
$enc = New-Object Text.UTF8Encoding $false
function L { param([string[]]$lines) return ($lines -join "`n") }
function RepRx([string]$file, [string]$old, [string]$new, [int]$n) {
  $path = 'C:\claudecode\dark raiders\tools\handoff\' + $file
  $s = [IO.File]::ReadAllText($path)
  if ($s.IndexOf($new) -ge 0 -and $s.IndexOf($old) -lt 0) { Write-Output ($file + ': already repaired'); return }
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($s, $pat)).Count
  if ($c -ne $n) { throw ($file + ': anchor matched ' + $c + ' times, wanted ' + $n + ': ' + $old.Substring(0, [Math]::Min(60, $old.Length))) }
  $s = [regex]::Replace($s, $pat, { param($m) $new })
  [IO.File]::WriteAllText($path, $s, $enc)
  Write-Output ($file + ': repaired')
}
$STAMPS86 = L @('# STAMPS.', "SubRx @'", "var VER='11.86';")
$STAMPS87 = L @('# STAMPS.', "SubRx @'", "var VER='11.87';")
$STAMPS88 = L @('# STAMPS.', "SubRx @'", "var VER='11.88';")

# 1182: the v3.34 heading and the raider heal comment are made history, not
# rule; the check names the true cause of the plate half on the old build.
RepRx 'p1182.ps1' (L @(
  "SubRx @'",
  'smokeR:165,fragR:190,healSolo:1',
  "'@ @'",
  'smokeR:165,fragR:190',
  "'@")) (L @(
  "SubRx @'",
  'smokeR:165,fragR:190,healSolo:1',
  "'@ @'",
  'smokeR:165,fragR:190',
  "'@",
  "# The v3.34 heading and the raider's parity comment, made history rather than rule.",
  "SubRx @'",
  '    // ONE AT A TIME, AND SLOWER, v3.34. His note: "change it so you can only use',
  "'@ @'",
  '    // ONE AT A TIME, AND SLOWER, v3.34 (the one-at-a-time half REVERSED at v11.82',
  '    // on his later note; the slower half stands). His note then: "change it so you can only use',
  "'@",
  "SubRx @'",
  '  // that heals. One at a time and over time, exactly as v3.34 made it for the',
  '  // player, so the same three seconds of vulnerability applies to him.',
  "'@ @'",
  '  // that heals. One at a time and over time, as v3.34 made it for the player',
  "  // (the player's one-at-a-time rule was reversed at v11.82; his stays, so the",
  '  // same three seconds of vulnerability still applies to him).',
  "'@")) 1
RepRx 'f1182.ps1' "       if(!p.prepA) bad.push('the plate was refused while a bandage was being applied');" (L @(
  "       if(p.prep&&p.prep.kind==='armor') bad.push('this build has one application timer, so the plate took the medical one and a bandage would have waited on it');",
  "       else if(!p.prepA) bad.push('the plate was refused while a bandage was being applied');")) 1
RepRx 'd1182.txt' (L @(
  'On the v11.81 fixture the',
  'second Bandage is refused with the countdown and the plate is refused, and',
  'the check names both.')) (L @(
  'On the v11.81 fixture the',
  'second Bandage is refused with the countdown, and the plate, having no timer',
  'of its own, takes the single one; the check names both.')) 1
RepRx 'a1182.txt' 'fails on the v11.81 fixture (second bandage refused, plate refused).' 'fails on the v11.81 fixture (second bandage refused; the plate takes the single timer).' 1

# 1187: he faces where he walks; the count reaches the run record and the
# export; the check steps through the harness wrapper so routes are granted.
RepRx 'p1187.ps1' '        if(_sz&&_szd>_sz.r*0.9){ navSeek(e,_sz.x,_sz.y,120,dt); e.moving=true; }' (L @(
  '        if(_sz&&_szd>_sz.r*0.9){',
  '          navSeek(e,_sz.x,_sz.y,120,dt); e.moving=true;',
  '          e.face+=clamp(angDiff(Math.atan2(_sz.y-e.y,_sz.x-e.x),e.face),-2.2*dt,2.2*dt);   // he faces where he walks',
  '        }')) 1
RepRx 'p1187.ps1' $STAMPS86 (L @(
  '# He no longer turns to face you while walking out, the count reaches the run',
  '# record, and the export prints it.',
  "SubRx @'",
  '      if(sdd<300) e.face+=clamp(angDiff(Math.atan2(p.y-e.y,p.x-e.x),e.face),-2.2*dt,2.2*dt);',
  "'@ @'",
  '      if(sdd<300&&!(e.helped&&!e.hostile)) e.face+=clamp(angDiff(Math.atan2(p.y-e.y,p.x-e.x),e.face),-2.2*dt,2.2*dt);   // v11.87: a helped man faces his road, not you',
  "'@",
  "SubRx @'",
  '    strayHelped:T.strayHelped||0,strayKilled:T.strayKilled||0,wildKilled:T.wildKilled||0,',
  "'@ @'",
  '    strayHelped:T.strayHelped||0,strayKilled:T.strayKilled||0,strayOut:T.strayOut||0,wildKilled:T.wildKilled||0,',
  "'@",
  "SubRx @'",
  "    if(r.strayHelped||r.strayKilled) line+=' strays:'+(r.strayHelped||0)+'helped/'+(r.strayKilled||0)+'killed';",
  "'@ @'",
  "    if(r.strayHelped||r.strayKilled||r.strayOut) line+=' strays:'+(r.strayHelped||0)+'helped/'+(r.strayKilled||0)+'killed/'+(r.strayOut||0)+'out';",
  "'@",
  '',
  $STAMPS86)) 1
RepRx 'f1187.ps1' "     if(typeof updateEnts!=='function'||typeof mkStray!=='function') return 'SKIP: no survivor or entity update in this build';" "     if(typeof mkStray!=='function'||!window.__ents) return 'SKIP: no survivor or entity step in this build';" 1
RepRx 'f1187.ps1' '         updateEnts(0.1); t+=0.1;' '         __ents(0.1); t+=0.1;   // the harness step: refreshVseg first, so routes are granted' 1
RepRx 'f1187.ps1' "       if(reached&&!(g.tel&&g.tel.strayOut)) bad.push('the run report does not count the survivor as out');" (L @(
  "       if(reached&&!(g.tel&&g.tel.strayOut)) bad.push('the run report does not count the survivor as out');",
  "       if(reached){ p.downed=false; __endRaid('extract'); var rec=(__P().log||[]).slice(-1)[0]; if(!rec||!rec.strayOut) bad.push('the banked run record carries no strayOut'); }")) 1

# 1188: the cache is built through setLoot so its glow knows its rarity; the
# card line names the condition.
RepRx 'p1188.ps1' $STAMPS87 (L @(
  "# Built through setLoot, so the cache's glow knows what it holds (mkContainer",
  '# stamped best from the roll it threw away).',
  "SubRx @'",
  "          ct.loot=[key]; ct.tag='FULGURITE'; ct.time=1.0; ct.cache=1;",
  "'@ @'",
  "          setLoot(ct,[key]); ct.tag='FULGURITE'; ct.time=1.0; ct.cache=1;   // v11.88: setLoot, so best is right",
  "'@",
  '',
  $STAMPS87)) 1
RepRx 'p1188.ps1' "  'A LIGHTNING STRIKE LEAVES FULGURITE, worth 2,500, and nothing else.'," "  'A LIGHTNING STRIKE THAT MISSES YOU SOMETIMES FUSES THE GROUND. What it leaves is FULGURITE, worth 2,500, and nothing else.'," 1

# 1189: the swap flips only when a gun actually came up; the belt comment.
RepRx 'p1189.ps1' '    p.swapped=!sw;   // the gun that came up keeps the numbered slot it had' "    if(p.wep&&p.wep.id!=='fists') p.swapped=!sw;   // the gun that came up keeps its numbered slot; nothing came up, nothing flips" 1
RepRx 'p1189.ps1' $STAMPS88 (L @(
  '# The header above the belt block stated the old rule.',
  "SubRx @'",
  '  // same drag the bag uses. Guns select only.',
  "'@ @'",
  '  // same drag the bag uses. Guns select only while the backpack is closed (v11.89).',
  "'@",
  '',
  $STAMPS88)) 1
