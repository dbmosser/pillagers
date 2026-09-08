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

# FROM THE 2026-09-07 READ-ONLY AUDIT, specced from the source.
#
# THE CANCEL FIRES THE THING IT CANCELS. Breaking the Crier's line of sight for
# three seconds is supposed to call the alarm off: the branch sets the state back
# to patrol and clears the windup. It clears it to null, and nothing stops the
# rest of the branch from running in the same frame. Four lines later the windup
# is decremented, and null minus a number is a negative number, so the very next
# test sees a windup at or below zero and fires the whole alarm: the siren, the
# ping on the mark, the marked flag, the counter, the line telling him they are
# coming to where it LAST saw him, every machine within 900 units sent to the
# mark and every Listener sent hunting.
#
# So hiding from a Crier has never once cancelled an alarm. At best it brought
# it forward by under a second.
#
# The three seconds were also cumulative rather than continuous, because the
# counter is zeroed only when the alarm starts, never when it sees him again.
SubRx @'
        if(sees){ e.markX=p.x; e.markY=p.y; }
        if(!sees){ e.lost+=dt; if(e.lost>3){ e.state='patrol'; e.cd=0; e.wind=null; } }
'@ @'
        if(sees){ e.markX=p.x; e.markY=p.y; }
        // v12.50, 2026-09-07 audit: THREE CONTINUOUS SECONDS, not three added up
        // over a whole alarm. The counter below was zeroed only when the alarm
        // began, so a man who ducked behind three different walls for a second
        // each had it cancel as though he had stayed hidden throughout.
        if(sees) e.lost=0;
        if(!sees){ e.lost+=dt; if(e.lost>3){ e.state='patrol'; e.cd=0; e.wind=null; } }
'@

SubRx @'
        e.wind-=dt;
'@ @'
        // v12.50: AND THE CANCEL ABOVE ACTUALLY CANCELS. It clears the windup to
        // null and nothing stopped the rest of this branch running in the same
        // frame: null minus dt is a negative number, so the test below saw a
        // windup at or below zero and fired the entire alarm, siren, mark, and
        // every machine within 900 units, one frame after calling it off. Both
        // lines now ask whether this is still an alarm at all.
        if(e.state==='alarm') e.wind-=dt;
'@

SubRx @'
        if(e.wind<=0){
'@ @'
        if(e.state==='alarm'&&e.wind!==null&&e.wind!==undefined&&e.wind<=0){
'@

# NEW IN.
SubRx @'
  'A HOWLER SHELL NO LONGER REACHES THROUGH A WALL. A shell bursting in the street took about twenty health off you standing well inside a building, with the hit ring pointing at something you could not see. Walls stop the blast now, exactly as they stop a frag.',
'@ @'
  'A HOWLER SHELL NO LONGER REACHES THROUGH A WALL. A shell bursting in the street took about twenty health off you standing well inside a building, with the hit ring pointing at something you could not see. Walls stop the blast now, exactly as they stop a frag.',
  'BREAKING A CRIER LINE OF SIGHT NOW ACTUALLY CANCELS ITS ALARM. The cancel cleared the windup and then fired the alarm on the very same frame, so hiding never once called one off. The three seconds have to be unbroken now, which they always claimed to be.',
'@

# STAMPS.
SubRx @'
var VER='12.49';
'@ @'
var VER='12.50';
'@
SubRx @'
var WHATSNEW_VER='12.49';
'@ @'
var WHATSNEW_VER='12.50';
'@
$cnt=([regex]::Matches($s,"now:'v12\.49:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.49 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.49:[^']*'",{ param($m) "now:'v12.50: 2026-09-07 audit. The cancel fired the thing it cancels. Breaking the Crier line of sight for three seconds is meant to call the alarm off: the branch sets the state back to patrol and clears the windup to null, and nothing stopped the rest of that branch running in the same frame. Four lines later the windup is decremented, and null minus a number is a negative number, so the very next test saw a windup at or below zero and fired the entire alarm: the siren, the ping on the mark, the marked flag, the counter, the line telling him they are coming to where it LAST saw him, every machine within 900 units sent to the mark and every Listener sent hunting. So hiding from a Crier has never once cancelled an alarm; at best it brought it forward by under a second. The three seconds were also cumulative rather than continuous, because the counter is zeroed only when the alarm starts and never when it sees him again. Two guards on the countdown and one reset. Honestly, the two halves pull opposite ways: the cancel now works, which favours him, and the three seconds must be unbroken, which does not, and unbroken is what the counterplay always claimed to be. Check 12.50 stages a Crier in alarm with the countdown still running and the player already hidden, steps the machines once, and requires the state back to patrol with no siren, no mark, no counter and no line; the control runs the same Crier with the player in plain sight and requires the alarm to fire exactly as it always has; fails on v12.49.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
