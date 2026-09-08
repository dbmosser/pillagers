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

# THE LAST OPEN LINE OF THE 2026-09-06 IN-RAID AUDIT, and the only one on that
# list a player never sees. It is on this list because it corrupts MY numbers.
#
# The weather turn expires, the picker is asked for something different, and
# with the weather PINNED it can only ever answer with the pinned one. The guard
# loop asks it twelve times, gets the same answer twelve times, and returns
# without parking the clock. So the clock stays expired and the whole thing
# happens again on the very next frame: thirteen seeded draws every frame from
# the first expiry to the end of the raid.
#
# Nothing on screen shows it, and that is exactly the danger. Every paired
# measurement run with a pinned weather was comparing two different seeded
# streams, which is the one thing a paired measurement exists to rule out.
SubRx @'
  if(G.wxTurnsLeft<=0) return;
  G.wxAt-=dt;
  if(G.wxAt>0) return;
  var nw=pickWeather(),guard=0;
'@ @'
  if(G.wxTurnsLeft<=0) return;
  G.wxAt-=dt;
  if(G.wxAt>0) return;
  // v12.58, 2026-09-06 in-raid audit: A PINNED WEATHER HAS NO TURNS LEFT, so say
  // so once rather than asking a question that cannot have a different answer.
  // The loop below asked the picker twelve times, got the pinned weather every
  // time, and returned WITHOUT putting the clock forward, so the clock stayed
  // expired and it all happened again on the next frame: thirteen seeded draws
  // every frame for the rest of the raid. Nothing on screen shows it, and that
  // is the danger, because it means every paired measurement run with a pinned
  // weather was comparing two different seeded streams. This line draws nothing
  // itself and is the truth by definition: a weather that cannot change has no
  // turns to make.
  var _wxPin=(typeof wxPicked==='function')?wxPicked():null;
  if(_wxPin&&_wxPin!=='any'){ G.wxTurnsLeft=0; return; }
  var nw=pickWeather(),guard=0;
'@

# NEW IN.
SubRx @'
  'WALKING THROUGH ANOTHER EXTRACTION POINT NO LONGER ABANDONS YOUR OWN. The game follows one point at a time, and standing in a second open one used to move everything onto it: the banner, the prompt, the approach pings and the last-seconds warning, while the extraction you had already called left without you.',
'@ @'
  'WALKING THROUGH ANOTHER EXTRACTION POINT NO LONGER ABANDONS YOUR OWN. The game follows one point at a time, and standing in a second open one used to move everything onto it: the banner, the prompt, the approach pings and the last-seconds warning, while the extraction you had already called left without you.',
  'A WEATHER YOU PINNED IN SETTINGS STOPS ASKING TO CHANGE. It could not change, so it asked thirteen times a frame for the rest of the raid. Nothing on screen showed it, and it was quietly spoiling every measurement I took with the weather held still.',
'@

# STAMPS.
SubRx @'
var VER='12.57';
'@ @'
var VER='12.58';
'@
SubRx @'
var WHATSNEW_VER='12.57';
'@ @'
var WHATSNEW_VER='12.58';
'@
$cnt=([regex]::Matches($s,"now:'v12\.57:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.57 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.57:[^']*'",{ param($m) "now:'v12.58: the last open line of the 2026-09-06 in-raid audit, and the only one on that list a player never sees. It is on the list because it corrupts MY numbers. The weather turn expires, the picker is asked for something different, and with the weather PINNED it can only ever answer with the pinned one; the guard loop asks it twelve times, gets the same answer twelve times, and returns without putting the clock forward. So the clock stayed expired and the whole thing happened again on the very next frame: thirteen seeded draws every frame from the first expiry to the end of the raid. Nothing on screen shows it, and that is exactly the danger, because it means every paired measurement I have run with a pinned weather was comparing two different seeded streams, which is the one thing a paired measurement exists to rule out. One line, drawing nothing itself and true by definition: a weather that cannot change has no turns to make. Check 12.58 counts the calls to the picker itself over sixty frames with the weather pinned and the clock expired, requiring none at all, with a control that an unpinned weather in the same state still asks and still turns; fails on v12.57.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
