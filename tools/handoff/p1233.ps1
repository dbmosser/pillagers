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

# FROM THE 2026-09-07 READ-ONLY AUDIT (P2, trade-freeze), specced and then
# attacked by a skeptic before it was written. The trade window returns out of
# updatePlayer, and the only real call to tryExtractTick lives below that
# return, so every extraction clock stops dead for as long as the stall is
# open: the inbound countdown, the thirty second boarding window, the siege the
# call bought, the two second re-ping, the mirrors the HUD reads, the closing
# of a point whose time has come, and the raider waves. Nothing else stops.
# The frame loop gates on none of it and keeps adding to the raid time, taking
# dt off the raid clock and running the machines, the bullets and the
# throwables on the next three lines of the same frame. So the label over the
# ring held EXTRACT A INBOUND at whatever second the panel opened while the
# raid ran on around him, and a landed extraction waited for as long as he
# shopped.
#
# THE SHAPE OF THE FIX IS ALREADY IN THIS FUNCTION, TWICE. The downed branch
# and the roll branch both carry this same call past their own early return,
# and the downed one says why in as many words. This one takes the roll's form,
# with no wantCall: while the panel is up, E belongs to the panel, so the
# clocks run and no pull of his own does.
#
# SAID PLAINLY: this has an in-raid effect and it is not nil. Today the stall
# is a free pause on extraction pressure. After this it is not. No dial, no
# default, no table and no number moves; one function that is meant to run
# every frame of a raid now runs in the one state that was skipping it.
SubRx @'
  if(G.trade){ tickRegen(dt); return; }
'@ @'
  if(G.trade){
    tickRegen(dt);
    // v12.33, 2026-09-07 audit (trade-freeze): THE STALL IS NOT A PAUSE. This
    // return skips the tail of updatePlayer, and the only real call to
    // tryExtractTick is down there, so every extraction clock stopped while the
    // trade window was open: the inbound countdown, the boarding window, the
    // siege arrivals, the re-ping, the mirrors the HUD reads, the closing of a
    // point whose time has come, and the raider waves. Nothing else stopped;
    // loop() gates on none of it and kept the raid clock and the machines
    // running in the same frames. Same fault and same fix as the two branches
    // above. No wantCall, as in the roll: E belongs to the panel while it is
    // open, so the clocks run and no pull of his own does.
    tryExtractTick(dt);
    return;
  }
'@

# NEW IN.
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE PEDDLER STALL IS NOT A PAUSE. Shopping used to stop every extraction clock while the raid clock and the machines ran on, so an extraction you had called sat at the same number until you closed the panel. It counts down while you trade now.',
'@

# STAMPS.
SubRx @'
var VER='12.32';
'@ @'
var VER='12.33';
'@
SubRx @'
var WHATSNEW_VER='12.32';
'@ @'
var WHATSNEW_VER='12.33';
'@
$cnt=([regex]::Matches($s,"now:'v12\.32:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.32 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.32:[^']*'",{ param($m) "now:'v12.33: 2026-09-07 audit (trade-freeze). The trade window returns out of updatePlayer above the only real call to tryExtractTick, so opening the Peddler stopped every extraction clock: the inbound countdown, the thirty second boarding window, the siege the call bought, the two second re-ping, the mirrors the HUD reads, the closing of a point whose time has come, and the raider waves. Nothing else stopped, because the frame loop gates on none of it and kept the raid clock, the machines, the bullets and the throwables running in the same frames. The downed branch and the roll branch already carry this call past their own early return; the stall takes the roll form, with no wantCall, so the clocks run while E belongs to the panel. This has a real in-raid effect and it is named rather than hidden: the stall was a free pause on extraction pressure and is not one any more. No dial moves. Check 12.33 opens the stall through the real loop with a real E, then drives sixty frames three times: the inbound countdown must fall with the raid clock, a landed boarding window must spend, and a point whose closing time passes while he shops must shut; two controls require the raid clock to have run at all and the same clocks to move once the stall is shut. Fails on v12.32.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
