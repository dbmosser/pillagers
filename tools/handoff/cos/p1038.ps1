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

# ============ HIS ANSWER 25, 2026-09-03: the CONTROLS legend is one of the
# ============ four HUD things that bother him most; answer 30: he plays at 4K.
#
# MEASURED on v10.14 with the text trace, the full list (H cycled to it):
#   1920x1080: the MOVE heading drawn at y -52, above the screen; the rule
#              cards drawn at x 1454 to 1865, y 50 to 152, inside the
#              conditions panel's box, five lines of them.
#   3840x2160: the whole list drawn at x 4797 and beyond. The screen is 3840
#              wide. On his monitor, H to the full list showed NOTHING.
# The cause is one line: the full list centres itself on W in unscaled space
# and is then drawn inside the compact panel's corner zoom, anchored at the
# left edge and the bottom target, so its centre lands at W*z/2 and its top
# at target-(target-top)*z. That zoom is right for the compact panel it was
# written for and wrong for a centred list. The full list is scaled about the
# bottom centre now, and the scale is capped so the whole list is on screen.

SubRx @'
    ctx.save();
    ctx.translate(_legDX,_legShift+_legDY);   // bottom on the target, plus his drag
    hudZoomIn('legend',0,_legTarget);    // then grow upward from there
    drawLegend();
    ctx.restore();
'@ @'
    ctx.save();
    if(G.legendOn===2){
      // v10.38, his answer 25: THE FULL LIST IS CENTRED, AND IT FITS. The corner
      // zoom below is right for the compact panel in the bottom left; the full
      // list centres itself on W, and a zoom about the left edge threw that
      // centre to W*z/2, off the right of a 4K screen, while its height ran
      // off the top. Scaled about the bottom centre instead, capped so the
      // whole list is on screen at any size.
      var _fz=hudRes()*hudUserZ('legend');
      var _fRows=0, _fLEG=(PAD&&PAD.on)?LEGEND_PAD:LEGEND;
      for(var _fi=0;_fi<_fLEG.length;_fi++) _fRows+=1+_fLEG[_fi][1].length;
      var _fBox=Math.max(_fRows*LH(12),GEARRULES.length*LH(11)+SOUNDKEY.length*LH(10)+LH(30))+LH(26);
      _fz=Math.min(_fz,Math.max(0.5,(H-LH(12))/(_fBox+LH(96))));
      ctx.translate(W/2,H); ctx.scale(_fz,_fz); ctx.translate(-W/2,-H);
    } else {
      ctx.translate(_legDX,_legShift+_legDY);   // bottom on the target, plus his drag
      hudZoomIn('legend',0,_legTarget);    // then grow upward from there
    }
    drawLegend();
    ctx.restore();
'@

SubRx @'
var VER='10.37';
'@ @'
var VER='10.38';
'@
SubRx @'
  now:'v10.37: the message line grows with the monitor. On a 4K screen it was nineteen pixels tall while every panel around it had doubled; it scales with them now.',
'@ @'
  now:'v10.38: the full controls list is on the screen. Press H twice and the whole list is centred and fits, at any monitor size; on a 4K screen it used to be drawn off the right edge entirely, and at 1080p its rule cards sat under the conditions panel.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
