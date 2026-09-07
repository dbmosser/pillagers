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

# HIS NOTE (2026-09-07 morning): "when you gave my loadout back i am not sure i
# got the whole thing back including everything in my backpack". Traced by the
# 2026-09-07 read-only notes investigation and verified by reading at v12.25:
# the stash screen's TAKE THE FREEBIE KIT button (v12.16) empties P.kit into
# P.kitSaved and sets P.freeKit; the lift question (askKit) still offers
# FREEBIE KIT as an answer whether or not the kit is already taken, and its
# ASKALT re-snapshotted P.kitSaved from the now-empty P.kit with no guard. So a
# player who took the kit at the stash and confirmed it again at the lift went
# up with {kit:[]} kept aside: commitKit took the empty list as kitBeforeFree,
# the death restore in endRaid (v6.88) had nothing to give back and said
# nothing, and P.kitSaved was already nulled. His items were still in the
# stash; the packing and the belt plan were gone. The stash button has the
# guard (if(P.freeKit){...return;}); the lift answer now has the same rule.
SubRx @'
    P.kitSaved={kit:(P.kit||[]).slice(),hot:JSON.parse(JSON.stringify(P.hotAssign||{})),gun:P._gunSlot||null};   // kept aside for the restore, as the stash button will at v12.16 (nothing reads it before then)
    P.hotAssign={}; P._gunSlot=null;
    P.freeKit=1; P.kitBeforeFree=null; saveProfile();
'@ @'
    // v12.26, HIS NOTE: "when you gave my loadout back i am not sure i got the
    // whole thing back including everything in my backpack". The stash button
    // (v12.16) empties P.kit into P.kitSaved when the kit is taken there, and this
    // answer, still offered at the lift, re-snapshotted the emptied kit over it, so
    // commitKit kept an empty list and the death restore gave nothing back. Kept
    // aside only when the kit is not already taken: the stash button's own rule.
    if(!P.freeKit) P.kitSaved={kit:(P.kit||[]).slice(),hot:JSON.parse(JSON.stringify(P.hotAssign||{})),gun:P._gunSlot||null};   // kept aside for the restore, as the stash button does since v12.16
    P.hotAssign={}; P._gunSlot=null;
    P.freeKit=1; P.kitBeforeFree=null; saveProfile();
'@

# NEW IN.
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'TAKING THE FREEBIE KIT AT THE STASH AND THEN CONFIRMING IT AGAIN AT THE LIFT NO LONGER THROWS AWAY THE PACKING KEPT ASIDE FOR YOU. A run that ends badly gives that packing back, as it was meant to.',
'@

# STAMPS.
SubRx @'
var VER='12.25';
'@ @'
var VER='12.26';
'@
SubRx @'
var WHATSNEW_VER='12.25';
'@ @'
var WHATSNEW_VER='12.26';
'@
$cnt=([regex]::Matches($s,"now:'v12\.25:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.25 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.25:[^']*'",{ param($m) "now:'v12.26: his note of 2026-09-07 (the loadout did not all come back): the stash button (v12.16) empties the packing into P.kitSaved when the freebie kit is taken there, and the lift question, which still offers FREEBIE KIT, re-snapshotted the emptied kit over it, so commitKit kept an empty list and the death restore gave nothing back and said nothing. The lift answer keeps the packing aside only when the kit is not already taken, the stash button rule. Check 12.26 takes the kit at the stash for real, answers FREEBIE KIT at the lift, requires the three packed items to be the list kept for the restore, then starts the raid, ends it dead, and requires the backpack to hold them again with the card saying so; fails on v12.25. The belt half of his note (keys unbound after the restore) is the parked build 1227.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
