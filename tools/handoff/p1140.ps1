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

# THE PILLBOX VENT STUN DRAINED TWICE AS FAST. The general machine block
# decrements htImmune (and, while overheating, continues before reaching the
# kind branches). The Choir branch decremented htImmune AGAIN, so once the
# overheat phase ended and the general block stopped continuing, the vent
# lockout drained at double speed: a Pillbox cleared its stun in 5.5 seconds
# against the 7 the dial sets, while every other machine cleared in 7. The
# overheat line here was unreachable anyway, since the block above returns on
# overheat. Both come out; the general block already owns them.
SubRx @'
    if(e.kind==='choir'){
      if(e.htImmune>0) e.htImmune-=dt;
      if(e.overheat>0){ e.overheat-=dt; e.cd=Math.max(e.cd||0,0.35); }
      if(e.cd>0) e.cd-=dt;
'@ @'
    if(e.kind==='choir'){
      // v11.40: htImmune and overheat are decremented once for EVERY machine in
      // the block above, and that block returns while overheating before it ever
      // reaches here, so these two lines only ever double-drained the vent stun
      // (5.5s of a 7s lockout) and never ran during overheat. Removed.
      if(e.cd>0) e.cd-=dt;
'@

# STAMPS.
SubRx @'
var VER='11.39';
'@ @'
var VER='11.40';
'@
SubRx @'
var WHATSNEW_VER='11.39';
'@ @'
var WHATSNEW_VER='11.40';
'@
SubRx @'
  'THE "H CONTROLS" HINT NO LONGER SITS ON YOUR HEALTH BAR. With the controls list toggled off, the little "H controls" reminder was printed inside the vitals panel, over the STAMINA or HP readout. It sits just above the panel now.',
'@ @'
  'A VENTED PILLBOX STAYS STUNNED AS LONG AS IT SHOULD. The stun from a vent shot on a Pillbox was draining almost twice as fast as the setting says, so it came back to life early. It now holds for the full lockout, like every other machine.',
  'THE "H CONTROLS" HINT NO LONGER SITS ON YOUR HEALTH BAR. With the controls list toggled off, the little "H controls" reminder was printed inside the vitals panel, over the STAMINA or HP readout. It sits just above the panel now.',
'@
SubRx @'
  now:'v11.39: with the controls list toggled off, drawLegend drew the "H controls" hint at 14,H-14, inside HUDBOX.body, so the grey reminder printed across the STAMINA label or the HP number. The compact legend already anchors above the panel; the off hint now does too, HUDBOX.body.y minus a line, and follows the panel when it is dragged. Reproduced by tracing the fillText against the panel box. From the rendering agent.',
'@ @'
  now:'v11.40: the Pillbox vent stun drained twice as fast. The general machine update decrements htImmune once for every machine and returns while overheating before it reaches the kind branches; the Choir branch decremented htImmune a second time, so once the overheat phase ended the vent lockout drained at double speed, 5.5 seconds of a 7-second stun. Measured against a sentry, which cleared at 7. The redundant lines are removed. From the combat agent.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
