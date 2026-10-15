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

# PLAYER 2 SEES THE GUN EACH PILLAGER REALLY HOLDS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  for(i=0;i<g.ents.length;i++){ g.ents[i].nid=g.nidN++; g.ents[i].nIn=1; NET.entMap[g.ents[i].nid]=g.ents[i]; }
'@ @'
  for(i=0;i<g.ents.length;i++){ g.ents[i].nid=g.nidN++; g.ents[i].nIn=1; NET.entMap[g.ents[i].nid]=g.ents[i]; }
  for(i=0;i<g.ents.length;i++) if(g.ents[i].kind==='raider'&&g.ents[i].wep) g.ents[i].nwW0=g.ents[i].nwW=g.ents[i].wep.id;  // v28.39 (cloud-coop-pillager-gun-sync), CLOUD HUNT 2026-10-15: the gun each pillager was built with, so a swap on the host is told to player 2
'@

SubRx @'
function netEntNewWord(e){
'@ @'
function netEntGunWord(e){ var m=netEntNewWord(e); delete m.idn; delete m.lx; delete m.ly; return m; }  // v28.39 (cloud-coop-pillager-gun-sync), CLOUD HUNT 2026-10-15: a known body took another gun: the new word without his name tag, so player 2 keeps his place, look and state and takes the gun
function netEntNewWord(e){
'@

SubRx @'
    seen[e.nid]=1;
'@ @'
    seen[e.nid]=1;
    if(e.kind==='raider'&&e.wep&&e.nwW!==e.wep.id){ if(e.nwW!==undefined) netBroadcast(netEntGunWord(e)); e.nwW=e.wep.id; }  // v28.39 (cloud-coop-pillager-gun-sync), CLOUD HUNT 2026-10-15: a pillager who swapped guns on the host (raiderUseKit) holds the same gun in player 2 window
'@

SubRx @'
  for(id=0;id<G.ents.length;id++) if(G.ents[id]&&G.ents[id].nid>=(NET.entBuilt||1e9)) netSend(peer,netEntNewWord(G.ents[id]));
'@ @'
  for(id=0;id<G.ents.length;id++) if(G.ents[id]&&G.ents[id].nid>=(NET.entBuilt||1e9)) netSend(peer,netEntNewWord(G.ents[id]));
  for(id=0;id<G.ents.length;id++) if(G.ents[id]&&G.ents[id].nid<(NET.entBuilt||0)&&G.ents[id].kind==='raider'&&G.ents[id].wep&&G.ents[id].nwW0!==undefined&&G.ents[id].wep.id!==G.ents[id].nwW0) netSend(peer,netEntGunWord(G.ents[id]));  // v28.39 (cloud-coop-pillager-gun-sync), CLOUD HUNT 2026-10-15: and a late player 2 hears every built pillager who swapped guns
'@

SubRx @'
var VER='28.38';
'@ @'
var VER='28.39';
'@

$pat = "(?m)^  now:'v28\.38:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.39: In co-op, player 2 now sees the gun each pillager really holds, with the right role colour, and his KILLED BY card names the right gun. Check 28.39 fails on v28.38',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
