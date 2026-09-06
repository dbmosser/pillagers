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

# THE WHOLE UNDERCROFT HUD WAS PAINTED AND THEN ERASED IN THE SAME FRAME.
# Found by the 2026-09-06 read-only menu audit and confirmed by a skeptic
# against the project's own measurement, which recorded zero opaque pixels on
# the HUD canvas of the Undercroft floor and read it as a fact about the floor
# rather than as the bug it is. v8.95 added a clear BELOW the world draw, to
# wipe whatever the last raid had left on that canvas. But drawHubWorld ENDS by
# calling drawHubHUD, which paints the entire floor HUD onto the same canvas.
# So every frame the floor drew its heading, its "[E] STATION" prompt and the
# key list under it, the H controls panel, the NEW IN card and the line that
# teaches WASD and E, and then wiped all of it a few lines later, repainting
# only the belt. The floor has been running with no HUD at all, and H has been
# a dead key. Clearing FIRST keeps the v8.95 guarantee and lets the floor be
# seen.
SubRx @'
      tickBuzz(dt); updateHubWorld(dt); drawHubWorld(dt); drawBuzzFx();
      // v8.95: the HUD canvas is never drawn on the Undercroft, so it is holding
      // whatever the last raid left there. Cleared every frame, and the backpack
      // painted onto it when he asks for it.
      try{
        ctx.clearRect(0,0,W,H);
        // v9.88: the belt is on the floor now, answer 22. The opened backpack
        // draws its own copy of it as before, so exactly one is ever drawn.
        if(hubBagOpen) drawHubBag(); else drawHubBelt();
      }catch(_hbd){}
'@ @'
      // v8.95: the HUD canvas holds whatever the last raid left there, so it is
      // cleared every frame. v11.58, from the 2026-09-06 menu audit: ABOVE the
      // world draw, not below it. drawHubWorld ENDS by calling drawHubHUD,
      // which paints the whole floor HUD on this same canvas: the heading, the
      // [E] STATION prompt and its key list, the H controls panel, the NEW IN
      // card and the line that teaches WASD and E. Clearing after that erased
      // every one of them on every frame, so the floor had no HUD and H was a
      // dead key. Cleared first, the raid leftovers still go and the floor
      // survives to be seen.
      try{ ctx.clearRect(0,0,W,H); }catch(_hc0){}
      tickBuzz(dt); updateHubWorld(dt); drawHubWorld(dt); drawBuzzFx();
      try{
        // v9.88: the belt is on the floor now, answer 22. The opened backpack
        // draws its own copy of it as before, so exactly one is ever drawn.
        if(hubBagOpen) drawHubBag(); else drawHubBelt();
      }catch(_hbd){}
'@

# STAMPS.
SubRx @'
var VER='11.57';
'@ @'
var VER='11.58';
'@
SubRx @'
var WHATSNEW_VER='11.57';
'@ @'
var WHATSNEW_VER='11.58';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE UNDERCROFT HAS ITS SCREEN BACK. The floor was painting its heading, its [E] STATION prompt, the key list, the H controls panel and the line that teaches the controls, and then erasing all of it in the same frame. It has been invisible for a long time, and H did nothing. It is all there now.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.57:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.57 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.57:[^']*'",{ param($m) "now:'v11.58: the whole Undercroft HUD was painted and then erased in the same frame. From the 2026-09-06 read-only menu audit. v8.95 cleared the HUD canvas BELOW the world draw to wipe the last raid leftovers, but drawHubWorld ends by calling drawHubHUD, which paints the floor heading, the E STATION prompt and its key list, the H controls panel, the NEW IN card and the WASD teaching line onto that same canvas; the clear erased all of it every frame and repainted only the belt, so the floor had no HUD and H was a dead key. The clear moved above the world draw. Check 11.58 drives the real loop in the hub and counts opaque pixels in the top strip of the HUD canvas, with a control that the belt still draws.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
