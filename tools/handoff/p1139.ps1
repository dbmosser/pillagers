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

# THE "H CONTROLS" HINT SAT INSIDE THE VITALS PANEL. With the legend cycled
# off, drawLegend drew "H  controls" at 14,H-14, the bottom-left corner, which
# is inside HUDBOX.body (the health/stamina/armour panel), so the grey hint
# printed across the STAMINA label or the HP number. The compact legend two
# branches down already anchors ABOVE the panel for this exact reason. The off
# hint now sits just above the panel too, and follows it when it is dragged.
SubRx @'
  if(!G.legendOn){
    ctx.font=MONO; ctx.fillStyle='rgba(140,152,163,.55)';
    ctx.fillText('H  controls',14,H-14);
    return;
  }
'@ @'
  if(!G.legendOn){
    ctx.font=MONO; ctx.fillStyle='rgba(140,152,163,.55)';
    // v11.39: above the vitals panel, not inside it. HUDBOX.body is set earlier
    // this frame and carries the panel drag, so the hint follows it.
    var _hy=(HUDBOX.body?HUDBOX.body.y-LH(6):H-14);
    ctx.fillText('H  controls',14,_hy);
    return;
  }
'@

# STAMPS.
SubRx @'
var VER='11.38';
'@ @'
var VER='11.39';
'@
SubRx @'
var WHATSNEW_VER='11.38';
'@ @'
var WHATSNEW_VER='11.39';
'@
SubRx @'
  'YOUR PUNCH NO LONGER HITS YOUR OWN MERC. A melee swing near the man you hired used to hurt him and, on the killing blow, bill you for it. Your fists pass through him now, the same as your bullets always have.',
'@ @'
  'THE "H CONTROLS" HINT NO LONGER SITS ON YOUR HEALTH BAR. With the controls list toggled off, the little "H controls" reminder was printed inside the vitals panel, over the STAMINA or HP readout. It sits just above the panel now.',
  'YOUR PUNCH NO LONGER HITS YOUR OWN MERC. A melee swing near the man you hired used to hurt him and, on the killing blow, bill you for it. Your fists pass through him now, the same as your bullets always have.',
'@
SubRx @'
  now:'v11.38: the melee swing hit your own merc. The fists sweep excluded downed and finished entities but not the man you hired, while the bullet path has passed through him since v6.72; so a punch near your merc hurt him and a killing blow billed you. One line, the same merc exclusion the round uses. Reproduced: a swing next to a merc dropped his health. From the combat agent.',
'@ @'
  now:'v11.39: with the controls list toggled off, drawLegend drew the "H controls" hint at 14,H-14, inside HUDBOX.body, so the grey reminder printed across the STAMINA label or the HP number. The compact legend already anchors above the panel; the off hint now does too, HUDBOX.body.y minus a line, and follows the panel when it is dragged. Reproduced by tracing the fillText against the panel box. From the rendering agent.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
