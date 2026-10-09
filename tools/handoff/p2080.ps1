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

# MACHINES IN SIGHT ARE HEARD FIRST (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(VOICE_BUDGET<1) continue;
    VOICE_BUDGET--;
    var ear=earsOf(e.x,e.y);
    // Occlusion matters more for a voice than for a gunshot: a machine behind a
    // wall should sound like it is behind a wall, or the ear cannot place it.
    var occ=losClear(p.x,p.y,e.x,e.y,G.map.segs)?1:1.9;
    blip(V.v,ear.d*occ,ear.pan,hunting?1:0);
'@ @'
    if(VOICE_BUDGET<1) continue;
    var ear=earsOf(e.x,e.y);
    // Occlusion matters more for a voice than for a gunshot: a machine behind a
    // wall should sound like it is behind a wall, or the ear cannot place it.
    var occ=losClear(p.x,p.y,e.x,e.y,G.map.segs)?1:1.9;
    // v20.80, from the whole-game bug hunt of 2026-10-08 (H55): A VOICE NOBODY CAN HEAR SPENDS NOTHING. The voice was paid for before
    // the wall was counted, and blip plays nothing at 882 or more (its level, 1 less a nine hundredth of the distance, is under .02
    // there), so a machine behind a wall further than 464 spent a voice in silence: crawlers hunting behind walls used up the whole
    // budget and a machine in plain sight after them in the list was never heard. Only a voice that will sound is paid for now.
    if(ear.d*occ>=882) continue;
    VOICE_BUDGET--;
    blip(V.v,ear.d*occ,ear.pan,hunting?1:0);
'@

SubRx @'
var VER='20.79';
'@ @'
var VER='20.80';
'@

$pat = "(?m)^  now:'v20\.79:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.80: Machines you can hear are no longer drowned out by silent ones behind walls. Check 20.80 fails on v20.79',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
