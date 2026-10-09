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

# FAR SOUNDS ARE HEARD WHERE THEIR RINGS ARE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var vol=d===undefined?1:Math.max(0,1-d/900); if(vol<=.02) return;
'@ @'
  // v20.81, from the whole-game bug hunt of 2026-10-08 (H56): A SOUND THAT LEAVES A RING CAN BE HEARD WHERE ITS RING IS. Every sound
  // faded to nothing at 882, but a gunshot, an explosion, an alarm and the three extraction sounds draw their ring out to 1150 to
  // 1500 (NOISEMARK), so a ship pinging or touching down 1000 away showed its ring in silence. Those six now keep the level they
  // always had out to 450, then fade in a straight line to nothing a little past the reach of their ring (hear times 1.05, so the
  // edge of the ring is faint but heard). Every other sound, and everything within 450, plays exactly as before.
  var _hr=(NOISEMARK[type]&&NOISEMARK[type].hear>900)?NOISEMARK[type].hear*1.05:900;
  var vol=d===undefined?1:(d<=450?1-d/900:Math.max(0,0.5*(_hr-d)/(_hr-450))); if(vol<=.02) return;
'@

SubRx @'
var VER='20.80';
'@ @'
var VER='20.81';
'@

$pat = "(?m)^  now:'v20\.80:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.81: Far gunfire, explosions and the ship coming in can be heard as far as their rings show. Check 20.81 fails on v20.80',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
