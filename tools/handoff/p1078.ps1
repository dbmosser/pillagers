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

# ============ TWO WINDOWS CUT THEIR OWN CONTENTS OFF AND NOTHING COULD SCROLL
# ============ TO IT.
# ============
# ============ Found by sweeping every one of the nineteen windows for the fault
# ============ v10.74 found on the run report. Two of them push content past
# ============ their own box while the box is overflow:hidden, so what is past it
# ============ is not below a fold, it is GONE.
# ============
# ============ MEASURED at 1920x1080, in css pixels:
# ============   the Discount Fashion Depot   521 past its box
# ============   the ascent check             401 past its box
# ============
# ============ In the Depot that is SURPRISE ME, sitting 412 device pixels below
# ============ the window, and all three LOOKS slots with their SAVE buttons at
# ============ 499, 571 and 643. A whole feature nobody can use. On the ascent
# ============ check it is sixteen rows including BEARD, EYES, FACE, BOOTS,
# ============ GLOVES and BACKPACK, so half the operator cannot be dressed there.
# ============ A fresh character measures exactly the same, so this is not about
# ============ how much he has unlocked.
# ============
# ============ There is no scrollbar and the wheel cannot help: the wheel handler
# ============ deliberately only scrolls a box whose overflow is auto or scroll,
# ============ and this one is hidden, so the wheel zooms the menus instead.
# ============
# ============ THE FIX IS THE HOUSE RULE, not a new idea. v5.31: a modal must
# ============ never push its own footer off the screen, so the modal stays
# ============ hidden and the LIST scrolls inside itself. v8.76 did exactly this
# ============ for the map picker. Both of these panels are built round the same
# ============ two column grid, and it is the grid that overflows.
# ============
# ============ AFTER, measured: the Depot pushes 0 past its box, the grid carries
# ============ an 11 pixel bar, SURPRISE ME is reachable, and CLOSE stays where
# ============ it was. The ascent check the same, with ASCEND still in place.
SubRx @'
  #sectormodal #sectorlist{ flex:1 1 auto; min-height:0; overflow-y:auto; }
  #sectormodal #sectorkit{ flex:0 0 auto; }
'@ @'
  #sectormodal #sectorlist{ flex:1 1 auto; min-height:0; overflow-y:auto; }
  #sectormodal #sectorkit{ flex:0 0 auto; }
  /* v10.78: AND THE LAST TWO PANELS THAT STILL BROKE THE v5.31 RULE. Swept all
     nineteen windows: the Depot pushed 521 css pixels past its own box and the
     ascent check 401, both overflow:hidden with nothing to scroll them, so
     SURPRISE ME, all three LOOKS slots and half the operator's appearance rows
     were not below a fold, they were gone. The wheel cannot rescue them either:
     it only scrolls a box whose overflow is auto or scroll. Both are built round
     the same two column grid, so the grid scrolls inside itself and the footer
     stays where v5.31 says it must. */
  #appearmodal .hubgrid, #stagemodal .hubgrid{ min-height:0; overflow-y:auto; }
'@

SubRx @'
var VER='10.77';
'@ @'
var VER='10.78';
'@
SubRx @'
  now:'v10.77: the title screen fills a 4K monitor too. v10.73 fixed 1080p and left 4K painting 45 percent of the screen, because the css cap cannot know the zoom that multiplies it. It is worked out from that zoom now: 80 percent at 1080p, 1440p and 4K alike.',
'@ @'
  now:'v10.78: the Discount Fashion Depot and the ascent check stop cutting their own contents off. SURPRISE ME, all three LOOKS slots and half the appearance rows sat past the bottom of a window that could not be scrolled, so nobody could reach them at all.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
