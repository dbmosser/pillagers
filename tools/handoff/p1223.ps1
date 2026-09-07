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

# FROM THE 2026-09-06 READ-ONLY IN-RAID AUDIT (P2 WRONG STATE, verified by
# reading at v12.19): damagePlayer's down branch clears p.prep and p.prepA
# and leaves p.cooking, p.cookT and p.cookKind alone. The cook clock and the
# release both sit past the downed return in updatePlayer, so a grenade that
# was cooking at the moment of the hit froze with its COOKING clock painted
# over the man on the floor for the whole bleed-out, and the self-revive
# stood him up still holding it, fuse half burned, with the clock running
# again. killPlayer already drops a cook on a death; the down did not. A man
# going down lets go of what is in his hand: the pin is out, so it goes the
# way a release sends it (the same verb as letting go of the button), with
# the time it has cooked. Smoke and decoy have no fuse and simply leave the
# hand the same way.
SubRx @'
  if(p.hp<=0){
p.hp=0; p.downed=true; p.downT=CFG.downTime; p.pendKiller=src; p.prep=null; p.prepA=null;
'@ @'
  if(p.hp<=0){
    // v12.23: A MAN GOING DOWN LETS GO OF WHAT IS IN HIS HAND. The cook clock and
    // the release both live past the downed return in updatePlayer, so a grenade
    // cooking at the moment of the hit froze with its fuse on screen for the whole
    // bleed-out and came back live, fuse half burned, on the self-revive. The pin
    // is out, so it goes the way a release sends it, with the time it has cooked
    // (2026-09-06 in-raid audit). killPlayer has dropped a cook on a death all along.
    if(p.cooking) releaseCook();
p.hp=0; p.downed=true; p.downT=CFG.downTime; p.pendKiller=src; p.prep=null; p.prepA=null;
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'GOING DOWN LETS GO OF THE GRENADE YOU WERE COOKING. It flies where you were aiming with the fuse it has burned; the clock no longer freezes over you, and you do not get up holding a live one.',
'@

# STAMPS.
SubRx @'
var VER='12.22';
'@ @'
var VER='12.23';
'@
SubRx @'
var WHATSNEW_VER='12.22';
'@ @'
var WHATSNEW_VER='12.23';
'@
$cnt=([regex]::Matches($s,"now:'v12\.22:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.22 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.22:[^']*'",{ param($m) "now:'v12.23: in-raid audit: a grenade cooking at the moment you went down froze with its clock on screen for the whole bleed-out and came back live on the self-revive, because the down branch cleared the heal in progress and not the cook. Going down lets go of it: the throw leaves the hand with the fuse it has burned, the same as releasing the button. Check 12.23 cooks a frag for half a second, puts him down, and requires one throw carrying that half second, no cook left in hand, no COOKING clock painted, and a self-revive that stands him up empty-handed; fails on v12.22.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
