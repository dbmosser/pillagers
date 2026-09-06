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

# HIS NOTES, 2026-09-06: "credits and xp in the corner in the undercroft are so
# small that they are useless" and then "credits and xp in corner during raid
# still wayyyyyy too tiny". v11.52 sized the readout to fit the 30-unit band
# above the raid's CONDITIONS box: 15px figures, 9.5px labels, 24px tall. It is
# one size everywhere now, twice that, and the CONDITIONS box starts below the
# readout's real bottom instead of the readout being squeezed above the box.
SubRx @'
  /* v11.52, HIS NOTE: credits and XP in the upper right, at all times. z 9000 puts
     it above every screen (10), pause box (35), card (40) and window (60), and
     below the item menu (12000) and the drag ghost (9999). 24px tall at top 4px,
     inside the band above the raid's CONDITIONS box, which starts at LH(30). */
  #topright{ position:fixed; top:4px; right:16px; height:24px; line-height:24px; z-index:9000; pointer-events:none;
    font-family:'Rubik',system-ui,sans-serif; font-weight:800; font-size:15px; color:var(--amber); white-space:nowrap; text-align:right; }
  #topright small{ font-size:9.5px; color:var(--ash); letter-spacing:.24em; font-weight:400; margin-left:5px; margin-right:14px; }
  #topright small:last-child{ margin-right:0; }
  .toprow{ padding-right:270px; }   /* v11.52: the stash screen's top row keeps clear of the corner readout, so CLOSE stays reachable */
'@ @'
  /* v11.52, HIS NOTE: credits and XP in the upper right, at all times. z 9000 puts
     it above every screen (10), pause box (35), card (40) and window (60), and
     below the item menu (12000) and the drag ghost (9999).
     v11.78, HIS NOTES: too small to be useful on the floor, and still far too
     small in a raid. One size everywhere, twice what it was: 32px figures, 14px
     labels, 44px tall at top 6px. The raid's CONDITIONS box now starts below
     the readout's real bottom (drawHUD reads it) rather than the readout
     fitting the band above the box. */
  #topright{ position:fixed; top:6px; right:20px; height:44px; line-height:44px; z-index:9000; pointer-events:none;
    font-family:'Rubik',system-ui,sans-serif; font-weight:800; font-size:32px; color:var(--amber); white-space:nowrap; text-align:right; }
  #topright small{ font-size:14px; color:var(--ash); letter-spacing:.24em; font-weight:400; margin-left:7px; margin-right:20px; }
  #topright small:last-child{ margin-right:0; }
  .toprow{ padding-right:480px; }   /* v11.52: the stash screen's top row keeps clear of the corner readout, so CLOSE stays reachable; v11.78: the readout is twice as wide */
'@
SubRx @'
function syncTopRight(){
  var el=document.getElementById('topright'); if(!el) return;
'@ @'
// v11.78: where the corner readout ends, in CSS pixels, so the raid HUD can
// start its CONDITIONS box below it. The HUD canvas is W CSS pixels wide (the
// device ratio is applied to the backing store, not to W), so no conversion.
function topRightBottom(){
  var el=document.getElementById('topright'); if(!el) return 0;
  try{ return el.getBoundingClientRect().bottom||0; }catch(_e){ return 0; }
}
function syncTopRight(){
  var el=document.getElementById('topright'); if(!el) return;
'@
SubRx @'
    var _cz=(HUDZ.cond||1)*hudRes()*hudUserZ('cond');
    bx=clamp(bx+HOc.dx/_cz,Math.min(W-16-bw,W-(W-4)/_cz),Math.max(W-(W-4)/_cz,W-bw-4/_cz));
'@ @'
    var _cz=(HUDZ.cond||1)*hudRes()*hudUserZ('cond');
    // v11.78, HIS NOTES: the corner readout is 44px tall now and this box sat
    // at LH(30), under it. It starts below the readout's real bottom, read from
    // the page in CSS pixels and put into this scaled space; LH(30) still holds
    // if the readout is ever shorter than that.
    by=Math.max(by,Math.ceil((topRightBottom()+8)/_cz));
    bx=clamp(bx+HOc.dx/_cz,Math.min(W-16-bw,W-(W-4)/_cz),Math.max(W-(W-4)/_cz,W-bw-4/_cz));
'@

# STAMPS.
SubRx @'
var VER='11.77';
'@ @'
var VER='11.78';
'@
SubRx @'
var WHATSNEW_VER='11.77';
'@ @'
var WHATSNEW_VER='11.78';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE CREDITS AND XP READOUT IN THE CORNER IS TWICE THE SIZE, on the floor and in a raid. The CONDITIONS box starts below it.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.77:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.77 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.77:[^']*'",{ param($m) "now:'v11.78: HIS NOTES of 2026-09-06, the credits and XP readout in the corner was useless on the Undercroft floor and still far too tiny in a raid. One size everywhere, twice what it was: 32px figures, 14px labels, 44px tall. The raid CONDITIONS box now starts below the readout, read from the page in CSS pixels (topRightBottom) and put into the box scaled space, instead of the readout being squeezed into the band above the box. Check 11.78 requires the readout at 28px or more and 40px or more tall on the floor and in a raid, and in a raid requires the CONDITIONS box top at or below the readout bottom; fails on v11.77.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
