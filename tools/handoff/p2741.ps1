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

# THE OVERSEER CALLS A LIMITED NUMBER OF CRAWLERS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var OV_P2=0.66, OV_P3=0.33, OV_SUMMON=20, OV_SWEEPCD=10, OV_CHARGE=1.0, OV_SWEEP=2.6, OV_RATE=0.6, OV_HALF=18, OV_TICK=0.1, OV_DMG=8, OV_MAXC=6;

'@ @'
var OV_P2=0.66, OV_P3=0.33, OV_SUMMON=20, OV_SWEEPCD=10, OV_CHARGE=1.0, OV_SWEEP=2.6, OV_RATE=0.6, OV_HALF=18, OV_TICK=0.1, OV_DMG=8, OV_MAXC=6;
// v26.xx (aip7), the cloud review of 2026-10-15 (finding 22): "the Overseer is an endless crawler farm in DEMO". It called three crawlers every twenty seconds for as long
// as it had seen you (never more than six alive), and each one scores, rolls its drops and feeds the streak like any other kill, so a player who stood by a phase 2
// Overseer could harvest them for the whole run. It calls at most OV_SUMTOT crawlers in all now (four calls of three); after that it fights with its cannon and its laser.
var OV_SUMTOT=12;

'@

SubRx @'
  var n=0, made=0, i, c, a, x, y, pl=G.player;
  for(i=0;i<G.ents.length;i++){ c=G.ents[i]; if(c.summoned&&c.hp>0&&!c.downed) n++; }

'@ @'
  var n=0, made=0, i, c, a, x, y, pl=G.player;
  if((e.sumN|0)>=OV_SUMTOT) return 0;   // v26.xx (aip7): it has called all it may
  for(i=0;i<G.ents.length;i++){ c=G.ents[i]; if(c.summoned&&c.hp>0&&!c.downed) n++; }

'@

SubRx @'
    G.ents.push(c); made++;
    i+=3;
  }
  return made;

'@ @'
    G.ents.push(c); made++;
    i+=3;
  }
  e.sumN=(e.sumN|0)+made;   // v26.xx (aip7): the running total of its calls
  return made;

'@

SubRx @'
var VER='27.40';
'@ @'
var VER='27.41';
'@

$pat = "(?m)^  now:'v27\.40:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.41: The Overseer now calls at most twelve crawlers in all. Check 27.41 fails on v27.40',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
