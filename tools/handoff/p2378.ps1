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

# GUN STAT CARD MODEL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var WTIER={fists:0,tacker:1,pistol:1,sputter:2,scuttle:2,smg:2,chatter:2,magnum:3,carbine:3,shotgun:3,rifle:3,lmg:4,dmr:4,whisper:4,sniper:5,lance:5};
'@ @'
var WTIER={fists:0,tacker:1,pistol:1,sputter:2,scuttle:2,smg:2,chatter:2,magnum:3,carbine:3,shotgun:3,rifle:3,lmg:4,dmr:4,whisper:4,sniper:5,lance:5};
// v23.xx (feat2a), HIS #17 (2026-10-12): "better gun stat cards - yes", and his answer 34: the card shows on pickup and in the
// backpack. THE MODEL, pure and drawn by nobody yet (the pickup card and the backpack card are the next two builds, and the UI
// redesign can restyle both without touching this). Five numbers, all higher-is-better: DMG a pull (a pellet gun counts every
// pellet, a burst gun every round of the burst), RATE in pulls a minute, MAG, RANGE in metres (10 units a metre) and HANDLING (0 to
// 100: 60 parts tight spread, 40 parts quick reload). The verdict against the gun in your hands: a higher tier (WTIER, the rank the
// arcade routing and the raid auto-equip already use) is an UPGRADE and a lower one a DOWNGRADE; at the same tier the sustained damage
// with reloads decides (8 percent either way, else a SIDEGRADE). Against bare hands any gun is an UPGRADE. No draw on any stream.
function gunStats(w){
  w=w||WEAPONS.fists;
  var pel=w.pellets||1, bu=w.burst||1, per=(w.dmg||0)*pel*bu, rof=Math.max(1,w.rof||1), mag=w.mag||0, rl=w.reload||0, pulls=mag>0?mag/bu:0;
  var sus=mag>0?per*pulls/(pulls*rof/1000+rl/1000):per*1000/rof;
  var hand=Math.round(100*(0.6*clamp(1-(w.spread||0)/0.2,0,1)+0.4*clamp(1-(rl-1200)/3000,0,1)));
  return {id:w.id||'fists',name:w.name||'Bare Hands',tier:WTIER[w.id]||0,dmg:Math.round(per),rpm:Math.round(60000/rof),mag:mag,
          rng:Math.round((w.rng||0)/10),hand:hand,dps:Math.round(sus)};
}
var GUNSTAT_ROWS=[['dmg','DMG'],['rpm','RATE'],['mag','MAG'],['rng','RANGE'],['hand','HANDLING']];
function gunCompare(f,h){
  var F=gunStats(f), H=(h&&h.id&&h.id!=='fists'&&h.mag!==0)?gunStats(h):null, v, r, d={}, k, KS=['dmg','rpm','mag','rng','hand','dps'];
  if(!H) v='UPGRADE';
  else if(F.tier!==H.tier) v=(F.tier>H.tier)?'UPGRADE':'DOWNGRADE';
  else { r=H.dps>0?F.dps/H.dps:2; v=(r>=1.08)?'UPGRADE':((r<=0.92)?'DOWNGRADE':'SIDEGRADE'); }
  for(k=0;k<KS.length;k++) d[KS[k]]=H?(F[KS[k]]-H[KS[k]]):F[KS[k]];
  return {verdict:v,f:F,h:H,d:d};
}
'@

SubRx @'
var VER='23.77';
'@ @'
var VER='23.78';
'@

$pat = "(?m)^  now:'v23\.77:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.78: Every gun can now be compared on damage, rate, magazine, range and handling, as an upgrade, a downgrade or a sidegrade. Check 23.78 fails on v23.77',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
