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

# A FIELD WRITTEN IN FIVE PLACES AND READ IN NONE, and two builds have described what
# it does. Found while reading the freebie kit for his come-back-empty note.
#
# WHAT IT CLAIMED. P._gunSlot is cleared when the freebie kit is taken, kept aside in
# the snapshot, and put back when he switches to his own loadout. v12.82 is written up
# as restoring "the items, the tactical belt plan and the gun slot", and the comment at
# the handoff says the same. A reader would take all three to be real.
#
# WHAT IT DOES. Nothing. Grep the whole file: five writes, no reads. What a raid arms
# him with comes from P.equipped and P.equippedSec, which this never touches.
#
# SO THE INVARIANT IT PRETENDED TO PROTECT IS ALREADY TRUE FOR A DIFFERENT REASON, and
# that is the part worth keeping: taking the freebie kit does not change the gun he
# owns or the one in his hands, because the raid simply ignores them while the kit is
# on. The check added with this build asserts that directly, which is what should have
# been asserted all along instead of a field nothing reads.
#
# THE FIELD GOES, and the two claims about it go with it. A comment that describes a
# no-op is worse than no comment: it is the reason nobody looked.
SubRx @'
    // so both are the loadout and both go. The gun slot goes with them: a slot
    // pointing at a gun he is not carrying is the v5.72 fault.
    P.kit=[]; P.hotAssign={}; P._gunSlot=null;
'@ @'
    // so both are the loadout and both go. v13.06: the gun slot used to be cleared
    // here too, and it was a field nothing in the file ever read; what he goes up
    // armed with is P.equipped and P.equippedSec, which none of this touches.
    P.kit=[]; P.hotAssign={};
'@

SubRx @'
    if(!P.freeKit) P.kitSaved={kit:(P.kit||[]).slice(),hot:JSON.parse(JSON.stringify(P.hotAssign||{})),gun:P._gunSlot||null};   // kept aside for the restore, as the stash button does since v12.16
    P.hotAssign={}; P._gunSlot=null;
'@ @'
    // v13.06: the gun slot is gone from this snapshot. It was written here, cleared
    // here, kept aside and put back, and read by nothing in the file: what a raid arms
    // him with comes from P.equipped and P.equippedSec, which none of that touched.
    if(!P.freeKit) P.kitSaved={kit:(P.kit||[]).slice(),hot:JSON.parse(JSON.stringify(P.hotAssign||{}))};   // kept aside for the restore, as the stash button does since v12.16
    P.hotAssign={};
'@

SubRx @'
    P.kitSaved={kit:(P.kit||[]).slice(),hot:JSON.parse(JSON.stringify(P.hotAssign||{})),gun:P._gunSlot||null};
    P.kit=[]; P.hotAssign={}; P._gunSlot=null;
'@ @'
    P.kitSaved={kit:(P.kit||[]).slice(),hot:JSON.parse(JSON.stringify(P.hotAssign||{}))};
    P.kit=[]; P.hotAssign={};
'@

SubRx @'
  P.kit=_kit; P.hotAssign=_ks.hot||{}; P._gunSlot=_ks.gun||null;
'@ @'
  P.kit=_kit; P.hotAssign=_ks.hot||{};
'@

# NEW IN.
SubRx @'
  'THE EXPERIMENTAL WARNING IS SPELLED ONE WAY.
'@ @'
  'THE FREEBIE KIT NEVER TOUCHED THE GUN YOU OWN, AND NOW THE CODE SAYS SO. It kept a gun slot aside and handed it back, and nothing in the game ever read it: what you go up with comes from the gun you have equipped, which taking the kit does not change. The dead field is gone and there is a test on the thing that is actually true.',
  'THE EXPERIMENTAL WARNING IS SPELLED ONE WAY.
'@

# STAMPS.
SubRx @'
var VER='13.03';
'@ @'
var VER='13.06';
'@
SubRx @'
var WHATSNEW_VER='13.03';
'@ @'
var WHATSNEW_VER='13.06';
'@
$cnt=([regex]::Matches($s,"now:'v13\.03:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v13.03 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v13\.03:[^']*'",{ param($m) "now:'v13.06: a field written in five places and read in none, and two builds have described what it does. Found while reading the freebie kit for his come-back-empty note. P._gunSlot is cleared when the freebie kit is taken, kept aside in the snapshot, and put back when he switches to his own loadout; v12.82 is written up as restoring the items, the tactical belt plan and the gun slot, and the comment at the handoff says the same, so a reader would take all three to be real. It does nothing: grep the whole file and there are five writes and no reads, because what a raid arms him with comes from P.equipped and P.equippedSec, which this never touches. The invariant it pretended to protect is already true for a different reason, and that is the part worth keeping: taking the freebie kit does not change the gun he owns or the one in his hands, because the raid simply ignores them while the kit is on. The field goes and the two claims about it go with it, because a comment that describes a no-op is worse than no comment, it is the reason nobody looked. The version numbers 13.04 and 13.05 are not skipped by accident: they were spent on harness-only checks that carry no game build, the outcome card sweep and the canvas sweep for his text edits. Check 13.06 equips a gun he owns, takes the freebie kit, commits and runs a raid, and requires the gun he owns and the gun in his hands to be exactly what they were, then switches back to his own loadout and requires the same, with the control that the freebie kit really was taken so the check is not passing on a raid that never used it; fails on v13.03 only in the sense that the field it removes is still there, so the check is written against the behaviour rather than the field and passes on both, which is stated plainly rather than dressed up as a control.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
