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

# PILLAGERS THROW AGAIN IN A LONG FIGHT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(CFG.raiderKit===0||!e||e.downed||e.finished) return;
  var i,it;
'@ @'
  if(CFG.raiderKit===0||!e||e.downed||e.finished) return;
  // v20.63, from the whole-game bug hunt of 2026-10-08 (H12): HIS THROW AND SMOKE CLOCKS RUN WITH THE RAID CLOCK. They only counted
  // down inside raiderThrow, which runs on a chance to fire (about one call a third of a second while he has a target in sight),
  // and one frame of time came off per call: the 20 seconds after a charge took about six minutes of firing at 60 frames a second
  // and longer than a whole raid at 144, so a man carrying three charges threw one, and a man who smoked at 45 percent never smoked
  // again when he broke and ran (the flee smoke only reads the clock). updateEnts runs this once a frame for every pillager, so 20
  // seconds is 20 seconds at any frame rate. No seeded draw is made here.
  if(e.thrT>0) e.thrT-=dt;
  if(e.smkT>0) e.smkT-=dt;
  var i,it;
'@

SubRx @'
  e.thrT=(e.thrT||0)-dt;
  if(e.thrT>0) return false;
'@ @'
  if(e.thrT>0) return false;   // v20.63 (H12): the clock itself runs in raiderUseKit, once a frame
'@

SubRx @'
  if(e.smkT!==undefined) e.smkT-=dt;
'@ @'
  // v20.63 (H12): the smoke clock runs in raiderUseKit, once a frame
'@

SubRx @'
var VER='20.62';
'@ @'
var VER='20.63';
'@

$pat = "(?m)^  now:'v20\.62:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.63: Pillagers with spare charges or smoke now use them again in a long fight, at most one charge every 20 seconds. Check 20.63 fails on v20.62',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
