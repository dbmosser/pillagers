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

# A LATE TEAMMATE IS TOLD ABOUT BODIES THAT CAME UP AFTER THE BUILD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  for(i=0;i<g.ents.length;i++){ g.ents[i].nid=g.nidN++; g.ents[i].nIn=1; NET.entMap[g.ents[i].nid]=g.ents[i]; }
'@ @'
  for(i=0;i<g.ents.length;i++){ g.ents[i].nid=g.nidN++; g.ents[i].nIn=1; NET.entMap[g.ents[i].nid]=g.ents[i]; }
  NET.entBuilt=g.nidN;   // v17.50: the first number a body that comes up after the build takes
'@

SubRx @'
  m.gone=gone;
  return netSend(peer,m)?'sent':'lost';
'@ @'
  m.gone=gone;
  if(!netSend(peer,m)) return 'lost';
  // v17.50: then every body that came up after the build (the boss, a late crew), which the late window never heard announced
  for(id=0;id<G.ents.length;id++) if(G.ents[id]&&G.ents[id].nid>=(NET.entBuilt||1e9)) netSend(peer,netEntNewWord(G.ents[id]));
  return 'sent';
'@

SubRx @'
var VER='17.49';
'@ @'
var VER='17.50';
'@

$pat = "(?m)^  now:'v17\.49:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.50: JOIN THE RAID IN PROGRESS: a teammate who joins late now sees THE OVERSEER and anyone who came up after the start with their names and sizes, as the host does. Check 17.50 fails on v17.49',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
