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

# CALLING EXTRACTION LEAVES THE PEDDLER BE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
        if(dist(se,z)>2200) continue;
        se.alert=Math.max(se.alert,3);
'@ @'
        if(dist(se,z)>2200) continue;
        // v22.08, from the whole-game bug hunt of 2026-10-08 (K19): THE CALL LEAVES THE PEDDLER AND THE SURVIVOR AT THEIR PITCH. Their
        // tx/ty are where they stand, not a target, so this pull set the stall down at the ring and left both alerted and looking for
        // the rest of the raid: a yellow mark, a place in the count coming for the ring and the threat sound at the stall. Every other
        // pull already skips them (the noise, the Crier alarm, a round, a blast); this one does now. The two scatter draws are still
        // taken for them, so the seeded stream does not move.
        if(se.neutral||se.kind==='peddler'||se.kind==='stray'){ if(!onYourTail(se.state)){ rnd(-40,40); rnd(-40,40); } continue; }
        se.alert=Math.max(se.alert,3);
'@

SubRx @'
      var _jx=rnd(-50,50), _jy=rnd(-50,50);
'@ @'
      var _jx=rnd(-50,50), _jy=rnd(-50,50);
      if(be.neutral||be.kind==='peddler'||be.kind==='stray') continue;   // v22.08 (K19): and the siege pull, after the same two draws; nor do they take a pull slot
'@

SubRx @'
    for(var _wi=0;_wi<G.ents.length;_wi++){ var _we=G.ents[_wi]; if(dist(_we,Z)>2200) continue;
'@ @'
    // v22.08 (K19): the party call leaves the Peddler and the Survivor at their pitch too, as the local call does (no draw here)
    for(var _wi=0;_wi<G.ents.length;_wi++){ var _we=G.ents[_wi]; if(dist(_we,Z)>2200) continue; if(_we.neutral||_we.kind==='peddler'||_we.kind==='stray') continue;
'@

SubRx @'
        jx=rnd(-50,50); jy=rnd(-50,50);
'@ @'
        jx=rnd(-50,50); jy=rnd(-50,50);
        if(be.neutral||be.kind==='peddler'||be.kind==='stray') continue;   // v22.08 (K19): as the siege pull of the host's own raid
'@

SubRx @'
var VER='22.07';
'@ @'
var VER='22.08';
'@

$pat = "(?m)^  now:'v22\.07:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.08: Calling extraction no longer moves the Peddler stall or alerts the Peddler and the Survivor. Check 22.08 fails on v22.07',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
