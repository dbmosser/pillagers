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

# FINDING 7 OF THE 2026-09-11 AUDIT. The two lines the game speaks at its most
# time-critical moments were blind to the extraction it had already called.
#
# WHAT HAPPENS. He calls extraction A with 60 seconds on the clock. It lands at 35
# and the window runs to 5. At exactly thirty seconds the raid clock speaks, and
# what it says is "THIRTY SECONDS. You are standing in the way out. Hold E to call
# it." He is standing in ring A, the banner directly above him reads EXTRACT NOW,
# and the ship he paid for is already on the ground. Holding E there does not call
# anything: it extracts him. The line names a different action than the one that
# happens, at the exact moment he has no time to work out which.
#
# THE OTHER HALF IS WORSE, because it sends him the wrong way. With ring A called
# and ring C nearer, the same warning names C and tells him to stand in it and hold
# E, which is a full inbound wait he cannot finish, while the HUD arrow beside it
# points the other way at the ship he already has.
#
# WHY. nearestOut reads only whether a ring is open and how far it is, and outHint
# reads only nearestOut. Neither looks at the beacon or the hold, so neither knows
# an extraction exists. A called ring is deliberately KEPT open, which is what puts
# it in the running to be beaten by a nearer one.
#
# THE FIX IS THAT A LIVE BEACON OWNS THE SENTENCE. When one is burning, the line
# names that ring and nothing else, in the words the rest of the game already uses:
# extract when the ship is down, wait when it is inbound. Where nothing is called,
# the old two lines stand exactly as they were.
SubRx @'
function outHint(urgent){
  var no=nearestOut();
  // v9.39: nearestOut returns nothing when every ring is shut, which is a real
  // sentence rather than a missing one.
  if(!no) return 'Every extraction point is closed.';
  var far=metres(no.d);
  var dir=compass8(no.z.x-G.player.x,no.z.y-G.player.y);
  // Standing in it already is a different instruction from walking to it.
  if(no.d<no.z.r) return 'You are standing in the way out. Hold E to call it.';
  return 'Nearest way out '+far+'m '+dir+'. Stand in it and hold E.';
}
'@ @'
function outHint(urgent){
  // v12.93, audit finding 7: A LIVE BEACON OWNS THIS SENTENCE. Everything below
  // used to read distance and nothing else, so at thirty seconds the game told a
  // man standing on a landed ship to hold E to CALL one, which is not the action
  // that happens when he does, and told a man with a ship inbound to walk to a
  // different ring and start a second wait he could never finish. A called ring is
  // deliberately kept open, which is exactly what let a nearer one beat it.
  //
  // beaconT is the inbound clock and is not cleared when the ship lands; hold is
  // the boarding window and only exists once it is down. That is the whole state
  // machine this line was missing.
  var ac=G&&G.active;
  if(ac&&ac.beaconT!==null&&ac.beaconT!==undefined){
    var landed=(typeof ac.hold==='number'&&ac.hold>0);
    var din=dist(G.player,ac);
    if(din<ac.r)
      return landed?('Your way out is down. Hold E to extract, '+Math.ceil(ac.hold)+'s left.')
                   :('Your way out is '+Math.ceil(ac.beaconT)+'s away. Stay in the ring.');
    return 'Your extraction is '+metres(din)+'m '+compass8(ac.x-G.player.x,ac.y-G.player.y)+'. '+
           (landed?('It leaves in '+Math.ceil(ac.hold)+'s.'):('It lands in '+Math.ceil(ac.beaconT)+'s.'));
  }
  var no=nearestOut();
  // v9.39: nearestOut returns nothing when every ring is shut, which is a real
  // sentence rather than a missing one.
  if(!no) return 'Every extraction point is closed.';
  var far=metres(no.d);
  var dir=compass8(no.z.x-G.player.x,no.z.y-G.player.y);
  // Standing in it already is a different instruction from walking to it.
  if(no.d<no.z.r) return 'You are standing in the way out. Hold E to call it.';
  return 'Nearest way out '+far+'m '+dir+'. Stand in it and hold E.';
}
'@

# NEW IN.
SubRx @'
  'ON A CONTROLLER THE STATIONS NAME THE BUTTON THEY ACTUALLY USE.
'@ @'
  'THE LAST-MINUTE WARNINGS KNOW YOU ALREADY CALLED A RIDE. At thirty seconds they told you to hold E to CALL an extraction you were standing on top of, which is not what holding E there does, or sent you to a different ring to start a wait you could never finish while the arrow beside them pointed at the extraction you already had. They name your ride now, and whether it is down or still coming.',
  'ON A CONTROLLER THE STATIONS NAME THE BUTTON THEY ACTUALLY USE.
'@

# STAMPS.
SubRx @'
var VER='12.92';
'@ @'
var VER='12.93';
'@
SubRx @'
var WHATSNEW_VER='12.92';
'@ @'
var WHATSNEW_VER='12.93';
'@
$cnt=([regex]::Matches($s,"now:'v12\.92:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.92 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.92:[^']*'",{ param($m) "now:'v12.93: finding 7 of the 2026-09-11 audit. The two lines the game speaks at its most time-critical moments were blind to the extraction it had already called. He calls extraction A with 60 seconds on the clock; it lands at 35 and the window runs to 5, and at exactly thirty seconds the raid clock speaks and says THIRTY SECONDS, you are standing in the way out, hold E to call it. He is standing in ring A, the banner directly above him reads EXTRACT NOW, and the ship he paid for is already on the ground; holding E there does not call anything, it extracts him, so the line names a different action than the one that happens at the exact moment he has no time to work out which. The other half is worse because it sends him the wrong way: with ring A called and ring C nearer, the same warning names C and tells him to stand in it and hold E, which is a full inbound wait he cannot finish, while the HUD arrow beside it points the other way at the ship he already has. nearestOut reads only whether a ring is open and how far it is, and outHint reads only nearestOut, so neither knows an extraction exists, and a called ring is deliberately KEPT open, which is what puts it in the running to be beaten by a nearer one. The fix is that a live beacon owns the sentence: when one is burning the line names that ring and nothing else, in the words the rest of the game already uses, extract when the ship is down and wait when it is inbound, and where nothing is called the old two lines stand exactly as they were. beaconT is the inbound clock and is not cleared when the ship lands, and hold is the boarding window that only exists once it is down; that is the whole state machine the line was missing. Check 12.93 stages a called ring with a second ring nearer and requires the warning to name the called one and never to tell him to call what he is standing on, requires the inbound and landed wordings to differ and to carry the right seconds, and controls that with nothing called both original sentences are word for word what they were; fails on v12.92.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
