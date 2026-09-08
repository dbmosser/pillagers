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

# FROM THE 2026-09-08 READ-ONLY AUDIT OF THE FIVE REGIONS NOBODY HAD LOOKED AT,
# confirmed by a skeptic against the source. This is the worst thing on that
# list, and it is the third time this exact shape has been found.
#
# The floor freezes under a panel by asking one question, and the Undercroft
# backpack is not one of the things that question knows about. It is painted on
# the HUD canvas rather than being a window, so the floor keeps running
# underneath it: E, R, F and T still reach whatever station you are standing on,
# and WASD walks you off it while you read.
#
# Stand on the lift, press I to check your packing, press R, and a raid starts
# from behind a full-screen panel. No sector page, no day reset, no question
# about the loadout or the freebie kit, and the prompt that would have warned
# you is painted over by the panel you are looking at. The lift's own act calls
# commitKit, so your stash moves too.
#
# v11.50 fixed one act, the stash, and its own not-verified line says the other
# stations were not checked. v12.06 added the character screen to this same
# question for the same reason. This is the last surface that was missing.
SubRx @'
  var _ttl=document.getElementById('title');
  if(_ttl&&_ttl.classList.contains('on')) return true;
  return !!document.querySelector('.modal.on');
'@ @'
  var _ttl=document.getElementById('title');
  if(_ttl&&_ttl.classList.contains('on')) return true;
  // v12.59, 2026-09-08 audit: AND THE BACKPACK, which is painted on the HUD
  // canvas and is not a window at all, so nothing above could see it. The floor
  // kept running underneath it: E, R, F and T still reached whatever station he
  // was standing on and WASD walked him off it while he read. On the lift that
  // meant R started a raid from behind a full-screen panel, with no sector page,
  // no day reset and no loadout question, and with the prompt that would have
  // warned him painted over by the panel itself. v11.50 closed one act and said
  // in as many words that the others were not checked; v12.06 added the
  // character screen here for exactly this reason. This is the last surface.
  // Only the floor freeze asks this question, so nothing else changes: the key
  // that closes the backpack has its own gate and still works.
  if(typeof hubBagOpen!=='undefined'&&hubBagOpen) return true;
  return !!document.querySelector('.modal.on');
'@

# NEW IN.
SubRx @'
  'A WEATHER YOU PINNED IN SETTINGS STOPS ASKING TO CHANGE. It could not change, so it asked thirteen times a frame for the rest of the raid. Nothing on screen showed it, and it was quietly spoiling every measurement I took with the weather held still.',
'@ @'
  'A WEATHER YOU PINNED IN SETTINGS STOPS ASKING TO CHANGE. It could not change, so it asked thirteen times a frame for the rest of the raid. Nothing on screen showed it, and it was quietly spoiling every measurement I took with the weather held still.',
  'THE OPEN BACKPACK STOPS THE FLOOR. Reading it in the Undercroft used to leave every station live underneath: standing on the lift and pressing R started a raid from behind the panel, with no sector page, no day reset and no question about what you were taking up.',
'@

# STAMPS.
SubRx @'
var VER='12.58';
'@ @'
var VER='12.59';
'@
SubRx @'
var WHATSNEW_VER='12.58';
'@ @'
var WHATSNEW_VER='12.59';
'@
$cnt=([regex]::Matches($s,"now:'v12\.58:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.58 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.58:[^']*'",{ param($m) "now:'v12.59: from the 2026-09-08 read-only audit of the five regions nobody had looked at, confirmed by a skeptic against the source, and the worst thing on that list. The floor freezes under a panel by asking one question, and the Undercroft backpack is not one of the things that question knows about: it is painted on the HUD canvas rather than being a window, so the floor kept running underneath it. E, R, F and T still reached whatever station he was standing on and WASD walked him off it while he read. Stand on the lift, press I to check the packing, press R, and a raid started from behind a full-screen panel: no sector page, no day reset, no question about the loadout or the freebie kit, and the prompt that would have warned him painted over by the panel he was looking at. The lifts own act calls commitKit, so the stash moved too. v11.50 fixed one act, the stash, and its own not-verified line says the other stations were not checked; v12.06 added the character screen to this same question for the same reason; this is the last surface that was missing. Only the floor freeze asks this question, so nothing else changes and the key that closes the backpack has its own gate. Check 12.59 stands him on the lift with the backpack open, presses R through the real floor update, and requires no raid to have started and the station under him to be unarmed, with a control that the same key with the backpack shut still starts one; fails on v12.58.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
