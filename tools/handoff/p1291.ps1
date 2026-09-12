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

# FINDING 11 OF THE 2026-09-11 AUDIT. The downed screen asks him to do one thing,
# and on a controller that one thing is the only thing he cannot do.
#
# WHAT HAPPENS. He is on the pad, and the game itself told him the left stick
# moves. He is shot to the floor 200 units short of the ring. The downed overlay
# says CRAWL TO THE RING, says "Crawl to an open extraction point if possible",
# and tells him how far the nearest one is. He pushes the stick and does not move a
# single unit for the whole bleed-out, then dies where he fell.
#
# WHY. The downed branch builds its movement vector from keyboard codes alone and
# then moves the body. The stick lives in PAD.mx and PAD.my, which pollPad
# refreshes every frame and which every OTHER movement site reads: the standing
# branch, the roll direction and the Undercroft walk. This branch is the one place
# it was never added, and nothing anywhere synthesises a movement key from the pad.
#
# IT IS NOT THAT THE PAD IS DEAD WHILE DOWNED, which makes it worse rather than
# better. D-DOWN still self-revives and X still extracts, because both of those go
# through keys the pad does write. And the left stick still swings the aim cursor,
# so he turns on the spot while going nowhere. Movement alone was missing.
#
# THE FIX IS THE SAME THREE LINES THE OTHER SITES USE, placed before the magnitude
# so the flat 30-units-a-second crawl normalisation is untouched. No speed moves.
SubRx @'
    if(keys['KeyD']||keys['ArrowRight'])mx0+=1;
    var mg0=Math.sqrt(mx0*mx0+my0*my0);
'@ @'
    if(keys['KeyD']||keys['ArrowRight'])mx0+=1;
    // v12.91, audit finding 11: THE STICK CRAWLS TOO. This branch read the
    // keyboard only, so the one action the downed overlay asks for was the one
    // action a controller could not perform, while the same stick worked standing,
    // rolling and on the Undercroft floor. Before the magnitude, so the flat
    // 30-units-a-second crawl below is unchanged: this adds an input, not a speed.
    if(PAD.on&&(PAD.mx||PAD.my)){ mx0=PAD.mx; my0=PAD.my; }
    var mg0=Math.sqrt(mx0*mx0+my0*my0);
'@

# NEW IN.
SubRx @'
  'THE FEELING TAG FOR THE TACTICAL BELT CALLS IT THE TACTICAL BELT.
'@ @'
  'THE LEFT STICK CRAWLS WHEN YOU ARE DOWN. On a controller the one thing the downed screen asks you to do was the one thing you could not do: the crawl read the keyboard only, so you turned on the spot and bled out where you fell. Self-revive and extracting always worked; it was moving that did not.',
  'THE FEELING TAG FOR THE TACTICAL BELT CALLS IT THE TACTICAL BELT.
'@

# STAMPS.
SubRx @'
var VER='12.90';
'@ @'
var VER='12.91';
'@
SubRx @'
var WHATSNEW_VER='12.90';
'@ @'
var WHATSNEW_VER='12.91';
'@
$cnt=([regex]::Matches($s,"now:'v12\.90:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.90 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.90:[^']*'",{ param($m) "now:'v12.91: finding 11 of the 2026-09-11 audit. The downed screen asks him to do one thing and on a controller that one thing is the only thing he cannot do. He is on the pad, and the game itself told him the left stick moves; he is shot to the floor 200 units short of the ring, and the downed overlay says CRAWL TO THE RING, says crawl to an open extraction point if possible, and tells him how far the nearest one is. He pushes the stick and does not move a single unit for the whole bleed-out, then dies where he fell. The downed branch builds its movement vector from keyboard codes alone and then moves the body; the stick lives in PAD.mx and PAD.my, which pollPad refreshes every frame and which every other movement site reads, the standing branch, the roll direction and the Undercroft walk, and this branch is the one place it was never added, with nothing anywhere synthesising a movement key from the pad. It is not that the pad is dead while downed, which makes it worse rather than better: D-DOWN still self-revives and X still extracts, because both go through keys the pad does write, and the left stick still swings the aim cursor, so he turns on the spot while going nowhere. Movement alone was missing. The fix is the same three lines the other sites use, placed before the magnitude so the flat thirty-units-a-second crawl normalisation is untouched: this adds an input, not a speed. Check 12.91 downs the player, pushes the stick with nothing on the keyboard and requires the body to have moved in the direction pushed, requires the keyboard crawl to still work with the pad off, and requires the two speeds to match so the stick is not a faster crawl; fails on v12.90 where the body does not move at all.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
