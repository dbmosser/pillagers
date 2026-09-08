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

# FROM THE 2026-09-08 FIRST-HOUR AUDIT, confirmed by a skeptic and then by me
# reading the two sites. IT IS THE THIRD TIME THE SAME MISTAKE HAS BEEN MADE.
#
# A migration exists to repair a save written by an older build. A profile
# created by THIS build has nothing to repair, so meeting one is always wrong.
# The file already knows this: dayMigrated was put into the born profile at
# v8.44 for exactly this reason, and pname at v11.73, each with a comment saying
# so. mig739 never was.
#
# mig739 is the v7.39 fold to one map, and what it does is delete the seal record
# and the explored bitmap for sector index 1. Both sectors are offered to a brand
# new player. So: he picks THE COLD MILE, cuts at the great door, extracts, is
# told "Banked" by the run report and by the Undercroft, closes the tab or simply
# reloads the page, and on that second load the fold fires for the first and only
# time and takes all of it. The explored map goes with it, on any outcome, because
# the fog is banked at the end of every raid whether he got out or not. Then the
# stamp is set and it never happens again, which is the shape that reads as random
# loss rather than as a rule.
#
# The comment sitting directly above that block describes this exact loss and
# says it was fixed. It was, for saves already on disk. It was never fixed for
# the profiles created since.
#
# mig945, the rig buyback, is harmless on an empty stash, but it is the same
# class and is stamped here as well, so the rule is a rule and not a third
# one-off. Old saves are untouched: they still carry no stamp and are still
# folded exactly as they were.
SubRx @'
var P={credits:900,stash:[],weapons:['pistol'],equipped:'fists',runs:0,ext:0,died:0,best:0,dayMigrated:1,
'@ @'
var P={credits:900,stash:[],weapons:['pistol'],equipped:'fists',runs:0,ext:0,died:0,best:0,dayMigrated:1,
  // v12.43, 2026-09-08 first-hour audit: THE OTHER MIGRATIONS ARE BORN SET TOO,
  // for the same reason dayMigrated is above and pname is below. A migration
  // repairs a save from an older build; a profile born from THIS literal has
  // nothing to repair, so meeting one is always a mistake. mig739 is the v7.39
  // fold to one map and it DELETES the seal record and the explored bitmap for
  // sector index 1, which is a sector a new player is offered on day one. He
  // cut at the great door, was told Banked, reloaded the page, and the second
  // load took it, once, silently. mig945 is the rig buyback, harmless on an
  // empty stash, and is stamped for the same reason: the rule is the rule.
  mig739:1,mig945:1,
'@

# NEW IN.
SubRx @'
  'A GUN YOU STOW KEEPS ITS ROUNDS. Putting a gun in your backpack used to throw away the magazine in it, and taking one back out handed you half a magazine that no reserve paid for. A gun you find in the field still comes up on half a magazine.',
'@ @'
  'A GUN YOU STOW KEEPS ITS ROUNDS. Putting a gun in your backpack used to throw away the magazine in it, and taking one back out handed you half a magazine that no reserve paid for. A gun you find in the field still comes up on half a magazine.',
  'A NEW CHARACTER KEEPS WHAT THEIR FIRST SESSION EARNED. A repair meant for saves from old builds ran once on brand new ones as well, so cutting at the great door on THE COLD MILE, being told it was banked, and then reloading the page lost the cutting and the explored map. It happened once per character, which is why it read as random.',
'@

# STAMPS.
SubRx @'
var VER='12.42';
'@ @'
var VER='12.43';
'@
SubRx @'
var WHATSNEW_VER='12.42';
'@ @'
var WHATSNEW_VER='12.43';
'@
$cnt=([regex]::Matches($s,"now:'v12\.42:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.42 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.42:[^']*'",{ param($m) "now:'v12.43: from the 2026-09-08 first-hour audit, and the third time I have made the same mistake. A migration exists to repair a save written by an older build, so a profile created by THIS build has nothing to repair and meeting one is always wrong. The file already knows that: dayMigrated was put into the born profile at v8.44 for exactly this reason and pname at v11.73, each with a comment saying so. mig739 never was. mig739 is the v7.39 fold to one map, and what it does is delete the seal record and the explored bitmap for sector index 1, which is a sector a brand new player is offered on day one. So he picks THE COLD MILE, cuts at the great door, extracts, is told Banked by the run report and by the Undercroft, and then reloads the page: on that second load the fold fires for the first and only time and takes the cutting and the explored map with it. The fog goes on any outcome, because it is banked at the end of every raid whether he got out or not. Then the stamp is set and it never happens again, which is the shape that reads as random loss rather than as a rule, and it is guaranteed to happen to every single new player exactly once. The comment directly above that block describes this loss and says it was fixed; it was, for saves already on disk, and never for the profiles created since. mig945, the rig buyback, is harmless on an empty stash but is the same class and is stamped as well so the rule is a rule. Old saves are untouched: they carry no stamp and are still folded exactly as they were. Check 12.43 reads the born profile out of the running page and requires a stamp in it for EVERY one-shot migration the loader guards on, not just this one; it then drives the real loader with the save a player of this build would have written, carrying progress on the second sector, and requires the progress to survive, with a control that a save carrying no stamp is still migrated; fails on v12.42.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
