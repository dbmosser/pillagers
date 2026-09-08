$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# FROM THE 2026-09-07 READ-ONLY AUDIT (P3), specced from the source. SAME FAULT
# AND SAME FIX AS v12.34, one door along.
#
# Cutting the seal returns out of updatePlayer on every frame of the hold, and
# two things live below that return: the only recovery tick on the standing
# path, and the only real call to the extraction clocks. So for the forty to a
# hundred and fifteen seconds of a cut, the health bar is flat and the recovery
# clock does not even advance, and every extraction clock is frozen with it: a
# ship already called stops inbound, the boarding window stops running, and no
# pillager wave can arrive while he makes the loudest noise in the game.
#
# The roll branch and the trade window both carry these calls past their own
# returns for exactly this reason. The seal was the last one that did not.
SubRx @'
      return;                       // cutting owns the key and your attention
'@ @'
      // v12.45, 2026-09-07 audit: CUTTING OWNS THE KEY, NOT THE CLOCKS. This
      // return skips the tail of updatePlayer, where the only recovery tick on
      // the standing path lives and where the only real call to the extraction
      // clocks lives. So the whole forty to a hundred and fifteen seconds of a
      // cut ran with the health bar flat and the recovery clock not even
      // advancing, and with every extraction clock stopped: a ship already
      // called went no further, the boarding window did not run, and no wave
      // could arrive while he made the loudest noise in the game. The roll and
      // the trade window carry both calls past their own returns for exactly
      // this reason; this was the last early return that did not. No wantCall,
      // as in those two: E belongs to the seal while he is cutting, so the
      // clocks run and no pull of his own does.
      tickRegen(dt);
      tryExtractTick(dt);
      return;                       // cutting owns the key and your attention
'@

# NEW IN.
SubRx @'
  'THE BOARDING WINDOW NEVER OUTLIVES THE CLOCK. A ship landing in the last seconds of a raid used to announce three seconds on every readout and then let the timer kill you with a second still showing. It now says what the raid actually has left.',
'@ @'
  'THE BOARDING WINDOW NEVER OUTLIVES THE CLOCK. A ship landing in the last seconds of a raid used to announce three seconds on every readout and then let the timer kill you with a second still showing. It now says what the raid actually has left.',
  'CUTTING THE SEAL NO LONGER STOPS THE WORLD. For the whole length of a cut your health did not recover, a ship you had already called stopped coming, the boarding window stopped running, and no pillager wave could arrive while you made the loudest noise in the game.',
'@

# STAMPS.
SubRx @'
var VER='12.44';
'@ @'
var VER='12.45';
'@
SubRx @'
var WHATSNEW_VER='12.44';
'@ @'
var WHATSNEW_VER='12.45';
'@
$cnt=([regex]::Matches($s,"now:'v12\.44:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.44 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.44:[^']*'",{ param($m) "now:'v12.45: 2026-09-07 audit (P3), the same fault and the same fix as v12.34 one door along. Cutting the seal returns out of updatePlayer on every frame of the hold, and two things live below that return: the only recovery tick on the standing path, and the only real call to the extraction clocks. So for the forty to a hundred and fifteen seconds of a cut the health bar was flat and the recovery clock did not even advance, which costs thirteen points on a tier zero cut and thirty eight at tier three, and every extraction clock was frozen with it: a ship already called stopped inbound, the boarding window stopped running, the re-ping stopped, and no pillager wave could arrive while he made the loudest noise in the game. The roll branch and the trade window both carry these calls past their own returns for exactly this reason and this was the last early return that did not. No wantCall, as in those two: E belongs to the seal while he is cutting, so the clocks run and no pull of his own does. Honestly: the wave half makes cutting riskier than it has been, because a wave that could never arrive now can. Check 12.45 holds E at a real seal through the real frame loop and requires the cut to advance, the recovery clock to advance with it, health to come back, and a beacon already inbound to keep counting down, with a control that a man standing beside the seal and not cutting recovers exactly as before; fails on v12.44.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
