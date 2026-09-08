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

# FROM THE 2026-09-08 FIRST-HOUR AUDIT, two findings that are one line of text,
# confirmed by a skeptic and then by me reading the panel and the deploy.
#
# The last thing he reads before the lift is one box that says what he is taking
# up. Its comment says "what he is actually taking up there, stated at the last
# moment he can change it". Both halves of that sentence are wrong, on every
# ascent, and one of them contradicts the line printed directly beneath it.
#
# THE GUN HALF. With nothing equipped, which is exactly what a brand new
# character has, it says "an issued sidearm". The deploy does not issue a
# sidearm. It rolls a PRIMARY out of the starter list into gun one, and gun two
# is left deliberately empty. So the one line telling a first-time player what he
# will be holding names the wrong slot and promises a second gun that is not
# coming.
#
# THE ARMOUR HALF. It prints the name of his rig, which has been a constant since
# v5.77: the function returns the same standard rig for everybody, forever, and
# the name it carries is the bare word Armour, left over from when rigs could be
# chosen. So the box reads "Going up with: ... Armour" and then, in amber,
# directly underneath, "You ascend with no armour on." Two halves of one box,
# stating opposite things, every single time.
#
# The armour half is deleted rather than corrected, because the amber line under
# it is already the true and useful version of that fact.
SubRx @'
  var rig=null;
  try{ rig=myRig(); }catch(_gr){ rig=null; }
  var line='<b>Going up with:</b> '+(w?escHtml(w.name):'an issued sidearm')+
           ' &middot; '+escHtml((rig&&rig.name)||'Armour');
'@ @'
  // v12.75, 2026-09-08 first-hour audit: THIS BOX NOW SAYS WHAT ACTUALLY
  // HAPPENS. It used to say "an issued sidearm" when nothing is equipped, which
  // is what a brand new character has, and the deploy does not issue a sidearm:
  // it rolls a PRIMARY out of the starter list into gun one and leaves gun two
  // deliberately empty, so the line named the wrong slot and promised a second
  // gun that was not coming. And it printed the name of his rig, which has been
  // the same constant for everybody since v5.77 and whose name is the bare word
  // Armour, directly above an amber line saying he ascends with no armour on.
  // That half is gone rather than reworded: the amber line under this one is
  // already the true and useful version of it.
  var line='<b>Going up with:</b> '+(w?escHtml(w.name):'a gun issued at the lift');
'@

# NEW IN.
SubRx @'
  'THE PEDDLER STALL KNOWS WHAT IT JUST PAID YOU. Selling at the stall pays into money that rides with you until you extract, but the panel read your banked Credits, so it said you hold nothing one line under the message telling you it had paid you thousands, and greyed its own stock. It now names both, and says which one it cannot spend.',
'@ @'
  'THE PEDDLER STALL KNOWS WHAT IT JUST PAID YOU. Selling at the stall pays into money that rides with you until you extract, but the panel read your banked Credits, so it said you hold nothing one line under the message telling you it had paid you thousands, and greyed its own stock. It now names both, and says which one it cannot spend.',
  'THE LAST BOX BEFORE THE LIFT TELLS THE TRUTH. It said you were going up with an issued sidearm, when nothing equipped means a primary is issued and the second slot is left empty on purpose, and it listed Armour on the same line as the warning that you ascend with no armour on.',
'@

# STAMPS.
SubRx @'
var VER='12.74';
'@ @'
var VER='12.75';
'@
SubRx @'
var WHATSNEW_VER='12.74';
'@ @'
var WHATSNEW_VER='12.75';
'@
$cnt=([regex]::Matches($s,"now:'v12\.74:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.74 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.74:[^']*'",{ param($m) "now:'v12.75: from the 2026-09-08 first-hour audit, two findings that turn out to be one line of text, confirmed by a skeptic and then by me reading the panel and the deploy. The last thing he reads before the lift is one box saying what he is taking up, and its own comment says it states what he is actually taking up at the last moment he can change it. Both halves of that sentence were wrong on every ascent, and one of them contradicted the line printed directly beneath it. THE GUN HALF: with nothing equipped, which is exactly what a brand new character has, it said an issued sidearm. The deploy does not issue a sidearm. It rolls a PRIMARY out of the starter list into gun one and leaves gun two deliberately empty, by a decision from v5.37 with a comment saying no free pistol and that an empty second slot is a real choice. So the one line telling a first-time player what he will be holding named the wrong slot and promised a second gun that was never coming. THE ARMOUR HALF: it printed the name of his rig, and the rig function has returned the same constant for everybody since v5.77, with the bare word Armour as its name, left over from when rigs could be chosen. So the box read Going up with, something, Armour, and then in amber directly underneath, you ascend with no armour on. Two halves of one box stating opposite things, every single time. The armour half is deleted rather than reworded, because the amber line under it is already the true and useful version of that fact. Check 12.75 renders the box on a character with nothing equipped and requires it not to promise a sidearm and not to list armour against the warning under it, with a control that a character who HAS a gun equipped still sees that gun named; fails on v12.74.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
