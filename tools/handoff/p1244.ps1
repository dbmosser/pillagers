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

# FROM THE 2026-09-07 READ-ONLY AUDIT (P3), specced from the source.
#
# The comment two lines above the hold says it "can never promise more than the
# raid clock has left, since saying thirty and then killing him on the timer at
# twelve is a lie". There is a floor of three seconds under it that breaks that
# promise at the very end of a raid. Call the extraction with 27 seconds left,
# which draws no warning because the warning only fires under 25, and the
# extraction arrives with 2 seconds on the clock. The floor sets the window to 3.
# banner says EXTRACT NOW, 3S LEFT. The ring badge says 3S UNTIL EXTRACTION
# ENDS. The prompt on the pad says 3s. The voice line says three seconds. Two
# seconds later the raid ends as a death by the timer with a second still
# showing on every one of them.
#
# The clock-OFF half of this expression was closed at v12.24. This is the
# live-clock sibling: one clamp, so no countdown outlives the timer.
SubRx @'
z.hold=(CFG.raidSec>0)?Math.min(30,Math.max(3,G.timeLeft-1)):30; z.holdMax=z.hold;   // v12.24: with the clock OFF (v9.35) there is nothing to run out; timeLeft sits at 0 and used to read as one second left, so extraction left after three
'@ @'
z.hold=(CFG.raidSec>0)?Math.min(30,Math.max(3,G.timeLeft-1)):30;   // v12.24: with the clock OFF (v9.35) there is nothing to run out; timeLeft sits at 0 and used to read as one second left, so extraction left after three
    // v12.44, 2026-09-07 audit: AND THE FLOOR OBEYS THE CLOCK. The comment above
    // promises that the hold can never say more than the raid has left, and the
    // three second floor broke that promise at the end of a raid: call with 27
    // seconds left, which draws no warning because the warning only fires under
    // 25, arrive with 2 on the clock, and all four readouts announced 3 while the
    // timer ended the raid as a death two seconds later with a second still
    // showing. Half a second is kept underneath so the window is never a zero
    // that reads as no window at all; if that is all the raid has left then that
    // is the truth, and an unwinnable second is better than a promised three.
    if(CFG.raidSec>0&&z.hold>G.timeLeft) z.hold=Math.max(0.5,G.timeLeft);
    z.holdMax=z.hold;
'@

# NEW IN.
SubRx @'
  'AIMING AND WADING NO LONGER LEAVE A SPRINT TRAIL. Shift held while you aimed, or while you waded, laid scent behind a man who was not sprinting, and everything on patrol within 170 units follows that scent. You were being hunted along a trail you never made.',
'@ @'
  'AIMING AND WADING NO LONGER LEAVE A SPRINT TRAIL. Shift held while you aimed, or while you waded, laid scent behind a man who was not sprinting, and everything on patrol within 170 units follows that scent. You were being hunted along a trail you never made.',
  'THE EXTRACTION WINDOW NEVER OUTLIVES THE CLOCK. An extraction arriving in the last seconds of a raid used to announce three seconds on every readout and then let the timer kill you with a second still showing. It now says what the raid actually has left.',
'@

# STAMPS.
SubRx @'
var VER='12.43';
'@ @'
var VER='12.44';
'@
SubRx @'
var WHATSNEW_VER='12.43';
'@ @'
var WHATSNEW_VER='12.44';
'@
$cnt=([regex]::Matches($s,"now:'v12\.43:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.43 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.43:[^']*'",{ param($m) "now:'v12.44: 2026-09-07 audit (P3). The comment two lines above the extraction window says the hold can never promise more than the raid clock has left, because saying thirty and then killing him on the timer at twelve is a lie. A three second floor under it broke that promise at the very end of a raid. Call the extraction with 27 seconds left, which draws no warning at all because the warning only fires under 25, and the extraction arrives with 2 seconds on the clock: the floor sets the window to 3, the banner says EXTRACT NOW 3S LEFT, the ring badge says 3S UNTIL EXTRACTION ENDS, the prompt on the pad says 3s and the voice line says three seconds. Two seconds later the raid ends as a death by the timer with a second still showing on every one of them. The clock-OFF half of the same expression was closed at v12.24; this is the live-clock sibling. One clamp, with half a second kept underneath so the window is never a zero that reads as no window at all: if that is all the raid has left then that is the truth, and an unwinnable second is better than a promised three. Check 12.44 brings an extraction in on a live clock with two seconds left and requires the hold and every readout that prints it to agree with the clock, with a control at full clock requiring the ordinary thirty second window to be untouched; fails on v12.43.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
