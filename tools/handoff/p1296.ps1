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

# FINDING 12 OF THE 2026-09-11 AUDIT. A card that contradicts itself in two lines.
#
# WHAT HE SEES. He plays a few clean raids, never goes down once, but presses E over
# three downed pillagers to take their guns, which is his own answer 37 and is
# prompted on screen. He opens the stats panel and the card reads "Went down 0", with
# "3 times you got back up" printed directly underneath it.
#
# WHY. The counter behind that subtitle is incremented in three places and only two
# of them are him standing up: the self-revive, and a merc pulling him up. The third
# is him reviving a downed PILLAGER, which is a different act entirely, and the game
# knows it: the self-revive is one a raid, reviving others is unlimited, and it
# already files those pickups separately as well.
#
# THE SAME NUMBER GOES INTO THE REPORT HE IS SENT, as "rev:" beside "downs:", where
# it conflates the same two acts.
#
# COMPUTED, NOT MIGRATED. Every run already in his log stores the pickups separately,
# so subtracting them repairs his whole history in one rule, with nothing rewritten
# and no one-shot stamp to get wrong. The recording is left exactly as it is, so a
# run exported before today still reads the same way.
SubRx @'
    o.downs+=(r.downs||0); o.revives+=(r.revives||0);
'@ @'
    o.downs+=(r.downs||0); o.revives+=standUps(r);
'@

SubRx @'
      ' kills:'+kills+(r.eliteKills?' elites:'+r.eliteKills:'')+' heals:'+r.heals+' downs:'+(r.downs||0)+' rev:'+(r.revives||0)+
'@ @'
      ' kills:'+kills+(r.eliteKills?' elites:'+r.eliteKills:'')+' heals:'+r.heals+' downs:'+(r.downs||0)+' rev:'+standUps(r)+
'@

SubRx @'
function statSummary(
'@ @'
// v12.96, audit finding 12: THE TIMES HE GOT BACK UP, which is not what the revives
// counter holds. It is incremented in three places and only two of them are him
// standing up, the self-revive and a merc pulling him up; the third is him pressing E
// over a downed pillager, which is a different act and unlimited where the self-revive
// is one a raid. A clean run with three pickups printed "Went down 0" over "3 times
// you got back up", two lines of one card contradicting each other.
//
// Computed rather than migrated: every run already in his log files the pickups
// separately, so subtracting them repairs the whole history in one rule with nothing
// rewritten and no one-shot stamp to get wrong.
function standUps(r){ return Math.max(0,((r&&r.revives)||0)-((r&&r.raiderRevives)||0)); }
function statSummary(
'@

# NEW IN.
SubRx @'
  'THE PAUSE BOX IN THE UNDERCROFT OWNS THE KEYBOARD NOW.
'@ @'
  'THE CAREER CARD STOPS COUNTING PILLAGERS YOU PICKED UP AS TIMES YOU GOT BACK UP. A clean run where you revived three of them read Went down 0 with 3 times you got back up underneath it. The same number went into the report you send. Runs already in your log read right too, without anything stored being changed.',
  'THE PAUSE BOX IN THE UNDERCROFT OWNS THE KEYBOARD NOW.
'@

# STAMPS.
SubRx @'
var VER='12.95';
'@ @'
var VER='12.96';
'@
SubRx @'
var WHATSNEW_VER='12.95';
'@ @'
var WHATSNEW_VER='12.96';
'@
$cnt=([regex]::Matches($s,"now:'v12\.95:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.95 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.95:[^']*'",{ param($m) "now:'v12.96: finding 12 of the 2026-09-11 audit, a card that contradicts itself in two lines. He plays a few clean raids, never goes down once, but presses E over three downed pillagers to take their guns, which is his own answer 37 and is prompted on screen; he opens the stats panel and the card reads Went down 0, with 3 times you got back up printed directly underneath it. The counter behind that subtitle is incremented in three places and only two of them are him standing up, the self-revive and a merc pulling him up, and the third is him reviving a downed PILLAGER, which is a different act entirely that the game already knows about: the self-revive is one a raid, reviving others is unlimited, and those pickups are already filed separately as raiderRevives. The same number goes into the report he is sent, as rev beside downs, where it conflates the same two acts. Computed rather than migrated: every run already in his log stores the pickups separately, so subtracting them repairs his whole history in one rule with nothing rewritten and no one-shot stamp to get wrong, which is its own defect class, and the recording is left exactly as it is so a run exported before today still reads the same way. Check 12.96 plants a run with three pickups and no downs and requires the card to say he got back up no times, plants a run with a self-revive and no pickups and requires it to say once, plants one with both and requires only the stand-up to be counted, and controls that the run report line carries the same number as the card; fails on v12.95. NOT BUILT AND FLAGGED TO HIM: the pillagers he picked up are a real number and now have no card of their own, which is a new row on his stats panel and his call rather than mine.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
