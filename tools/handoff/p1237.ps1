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

# FROM THE 2026-09-07 READ-ONLY AUDIT (f-held-revive), specced from the source
# and attacked by a skeptic before a line was written.
#
# healLock is the edge latch on the one self-revive, and the whole file SETS it
# in exactly one place: inside the downed branch of updatePlayer. The two other
# lines that name it only CLEAR it. So a hand already resting on F when the hit
# landed arrived on the floor with the latch clear, and the very first downed
# frame read that held key as a fresh press and spent the one self-revive with
# no decision made. F has been the melee strike since v10.64, so holding it
# through a fight is ordinary play, and the man then paid for it on his second
# down with the v12.10 line telling him a revive he never chose was already
# gone. Latching at the instant he goes down makes the revive wait for a release
# and a real press, which is what the DOWN overlay asks for on screen.
SubRx @'
    if(p.cooking) releaseCook();
p.hp=0; p.downed=true; p.downT=CFG.downTime; p.pendKiller=src; p.prep=null; p.prepA=null;
'@ @'
    if(p.cooking) releaseCook();
    // v12.37, 2026-09-07 read-only audit (f-held-revive): A KEY ALREADY DOWN IS
    // NOT A PRESS. healLock is the edge latch for the self-revive and it is SET
    // in exactly one place, inside the downed branch of updatePlayer; the two
    // other lines that name it only CLEAR it. So a hand already resting on F
    // when the hit landed arrived on the floor with the latch clear, and the
    // first downed frame read that held key as a fresh press and spent the one
    // self-revive with no decision made. F is the melee strike since v10.64, so
    // holding it through a fight is ordinary play, and the man then paid for it
    // on his second down with the v12.10 line telling him a revive he never
    // chose was gone. Latched here, at the instant he goes down: the revive now
    // waits for a release and a real press, which is what the DOWN overlay asks
    // for, and the clear on the next frame still frees that press.
    p.healLock=!!keys['KeyF'];
p.hp=0; p.downed=true; p.downT=CFG.downTime; p.pendKiller=src; p.prep=null; p.prepA=null;
'@

# THE OTHER HALF OF THE EDGE, comment only.
SubRx @'
    if(keys['KeyF']&&!p.healLock){ p.healLock=true; selfRevive(); }
    if(!keys['KeyF']) p.healLock=false;
'@ @'
    // v12.37, audit (f-held-revive): THE OTHER HALF OF THE EDGE. The latch below
    // is set only in here, so this line used to read a key that was already down
    // before he went down as a press, and the one self-revive was spent on the
    // first downed frame. damagePlayer latches it at the moment he goes down now;
    // the clear on the line after still frees the real press that follows.
    if(keys['KeyF']&&!p.healLock){ p.healLock=true; selfRevive(); }
    if(!keys['KeyF']) p.healLock=false;
'@

# NEW IN.
SubRx @'
  'WHOEVER KILLED YOU KILLED YOU. A round landing on your body during the death fade used to throw a second DOWN over the top of it, add another down to your record, and put its own name on the KILLED IN ACTION card in place of the machine that actually did it.',
'@ @'
  'WHOEVER KILLED YOU KILLED YOU. A round landing on your body during the death fade used to throw a second DOWN over the top of it, add another down to your record, and put its own name on the KILLED IN ACTION card in place of the machine that actually did it.',
  'A KEY ALREADY DOWN IS NOT A PRESS. F is the melee strike, so a hand resting on it when the hit landed used to spend your one self-revive on the first downed frame, with no decision made. The revive now waits for a release and a real press.',
'@

# STAMPS.
SubRx @'
var VER='12.36';
'@ @'
var VER='12.37';
'@
SubRx @'
var WHATSNEW_VER='12.36';
'@ @'
var WHATSNEW_VER='12.37';
'@
$cnt=([regex]::Matches($s,"now:'v12\.36:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.36 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.36:[^']*'",{ param($m) "now:'v12.37: 2026-09-07 audit (f-held-revive). healLock is the edge latch on the one self-revive, and the whole file SETS it in exactly one place, inside the downed branch of updatePlayer; the two other lines that name it only clear it. So a hand already resting on F when the hit landed arrived on the floor with the latch clear, and the very first downed frame read that held key as a fresh press and spent the one self-revive with no decision made. F has been the melee strike since v10.64, so holding it through a fight is ordinary play, and the man then paid for it on his second down with the v12.10 line telling him a revive he never chose was already gone. One assignment at the down moment latches the flag to whatever F is doing at that instant, so the revive waits for a release and a real press, which is what the DOWN overlay asks for on screen; with F not held the latch is cleared and the first real press still revives, bit for bit as before. Nothing measurable moves: the bot auto-revives on a branch that never reads the latch. Check 12.37 puts him down with the strike key held and requires him to stay on the floor with the revive unspent, then proves in two controls that a real press still stands him up and that letting go and pressing again after a held down still revives; fails on v12.36.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
