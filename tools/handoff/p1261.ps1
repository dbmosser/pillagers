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

# FROM THE 2026-09-08 READ-ONLY AUDIT, confirmed by a skeptic against the source.
#
# HIS ANSWER 24 IS DAY BY DEFAULT, EVERY ASCENT. The reset that keeps that
# promise lives inside the lift's E act, the one that opens the sector page, and
# nowhere else. The lift has TWO doors: E opens the page, and R is quick ascent,
# advertised on the floor's own sign.
#
# So pick night on the page, ascend, come back down, and press R. The surface
# choice is still night, because nothing on that path ever names day. The ground
# palette, the lamps, the night XP multiplier and the run record's night flag
# all follow it, and nothing on screen says a word before the raid loads.
#
# v10.05 shipped the promise and its check drives the E door only, which is why
# this has been true underneath a green check ever since.
SubRx @'
  var stations=[
'@ @'
  // v12.61, 2026-09-08 audit: DAY BY DEFAULT ON EVERY ASCENT, and this station
  // has TWO doors out of it. The reset used to live inside the E act alone, so
  // quick ascent inherited the surface he chose on the last raid, which is
  // exactly what his answer 24 forbids. One named thing, used by both, so they
  // cannot drift apart again.
  function liftResetDay(){
    if(P.cond!=='day'){ P.cond='day'; hubGround=null; saveProfile(); }
  }
  var stations=[
'@

SubRx @'
             if(P.cond!=='day'){ P.cond='day'; hubGround=null; saveProfile(); }
'@ @'
             liftResetDay();   // v12.61: the same reset the quick ascent below now makes
'@

SubRx @'
           KeyR:['quick ascent',function(){ commitKit(); ac(); startRaid(); }],
'@ @'
           KeyR:['quick ascent',function(){ liftResetDay(); commitKit(); ac(); startRaid(); }],   // v12.61: day by default here too, which is his answer 24
'@

# NEW IN.
SubRx @'
  'AN AMMO BOX FROM THE PEDDLER ACTUALLY GIVES YOU ROUNDS. It went into your backpack, where nothing in the game can use it, so you paid at the moment you were dry and got a brick. It goes into your reserve now, like every other box in the game, and the line says how many.',
'@ @'
  'AN AMMO BOX FROM THE PEDDLER ACTUALLY GIVES YOU ROUNDS. It went into your backpack, where nothing in the game can use it, so you paid at the moment you were dry and got a brick. It goes into your reserve now, like every other box in the game, and the line says how many.',
  'QUICK ASCENT STARTS AT DAY LIKE THE OTHER DOOR DOES. Pressing R at the lift used to inherit whatever surface you chose last raid, so a night you picked once followed you up every time until you opened the sector page again.',
'@

# STAMPS.
SubRx @'
var VER='12.60';
'@ @'
var VER='12.61';
'@
SubRx @'
var WHATSNEW_VER='12.60';
'@ @'
var WHATSNEW_VER='12.61';
'@
$cnt=([regex]::Matches($s,"now:'v12\.60:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.60 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.60:[^']*'",{ param($m) "now:'v12.61: from the 2026-09-08 read-only audit, confirmed by a skeptic against the source. His answer 24 is day by default on every ascent, and the reset that keeps that promise lived inside the lifts E act, the one that opens the sector page, and nowhere else. The lift has TWO doors: E opens the page, and R is quick ascent, advertised on the floors own sign. So pick night on the page, ascend, come back down and press R, and the surface choice is still night, because nothing on that path ever names day: the ground palette, the lamps, the night XP multiplier and the run records night flag all follow it, and nothing on screen says a word before the raid loads. v10.05 shipped the promise and its check drives the E door only, which is why this has been true underneath a green check ever since. One named reset now, used by both doors, so they cannot drift apart again. Check 12.61 sets the surface to night, presses the quick ascent key through the real floor update, and requires the raid to start at day; a control opens the page door and requires the same, and a third arm requires a night deliberately chosen on the page and ascended from the page to still be night, so this build does not take his choice away; fails on v12.60.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
