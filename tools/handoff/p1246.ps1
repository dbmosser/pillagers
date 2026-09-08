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
# Auto-jog is cleared in exactly one place, by a movement key, and that line
# sits below the early return that runs while you are on the floor. So nothing
# clears it while you are down. The down branch clears the prep, the heal, the
# pull and the cook, and has never touched this flag; neither revive path
# touches it either. So the first standing frame after a revive, with no key
# held, walks the man off toward the cursor at 40 health with no input at all.
# That is his v7.94 note about the character randomly walking off, in the one
# state nobody looked at, and it is worse with a hired merc: he presses nothing
# whatever, the merc pulls him up, and he wanders away on his own.
SubRx @'
p.hp=0; p.downed=true; p.downT=CFG.downTime; p.pendKiller=src; p.prep=null; p.prepA=null;
'@ @'
p.hp=0; p.downed=true; p.downT=CFG.downTime; p.pendKiller=src; p.prep=null; p.prepA=null;
    // v12.46, 2026-09-07 audit: AND THE AUTO-JOG STOPS WHEN HE DOES. It is
    // cleared in exactly one place, by a movement key, and that line sits below
    // the early return that runs while he is on the floor, so nothing could
    // clear it while he was down. This branch already clears the prep, the heal,
    // the pull and the cook; the flag belonged with them. Without it the first
    // standing frame after a revive walked him off toward the cursor at 40
    // health with no key held, which is his v7.94 note in the one state nobody
    // looked at, and worse with a hired merc: he presses nothing at all, the
    // merc pulls him up, and he wanders away by himself.
    if(p.autoJog){ p.autoJog=false; if(!G.sim) say('Auto-jog off.'); }
'@

# NEW IN.
SubRx @'
  'CUTTING THE SEAL NO LONGER STOPS THE WORLD. For the whole length of a cut your health did not recover, a ship you had already called stopped coming, the boarding window stopped running, and no pillager wave could arrive while you made the loudest noise in the game.',
'@ @'
  'CUTTING THE SEAL NO LONGER STOPS THE WORLD. For the whole length of a cut your health did not recover, a ship you had already called stopped coming, the boarding window stopped running, and no pillager wave could arrive while you made the loudest noise in the game.',
  'AUTO-JOG STOPS WHEN YOU GO DOWN. It used to survive the whole time you were on the floor, so the moment you got up again you walked off toward the cursor at 40 health with no key held, which was the character walking off by himself.',
'@

# STAMPS.
SubRx @'
var VER='12.45';
'@ @'
var VER='12.46';
'@
SubRx @'
var WHATSNEW_VER='12.45';
'@ @'
var WHATSNEW_VER='12.46';
'@
$cnt=([regex]::Matches($s,"now:'v12\.45:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.45 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.45:[^']*'",{ param($m) "now:'v12.46: 2026-09-07 audit (P3). Auto-jog is cleared in exactly one place in the whole file, by a movement key, and that line sits below the early return that runs while he is on the floor, so nothing could clear it while he was down. The down branch clears the prep, the heal, the pull and the cook and has never touched this flag, and neither revive path touches it either. So the very first standing frame after a revive, with no key held at all, walked the man off toward the cursor at 40 health: his v7.94 note about the character randomly walking off, in the one state nobody looked at. It is worse with a hired merc, where he presses nothing whatever, the merc pulls him up, and he wanders away by himself. One line in the down branch, beside the four clears that were already there. Check 12.46 arms the auto-jog from a standstill, puts him down with a real hit, stands him back up and runs ten frames with no key touched, requiring him not to have moved, with two controls: an armed auto-jog with no down still walks him, so the check can see the walk at all, and a man with no auto-jog armed still stands still; fails on v12.45.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
