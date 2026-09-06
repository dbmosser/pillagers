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

# HIS NOTE, 2026-09-06: "at bottom of screen 'EXTRACTION IN PROGRESS' -- not
# sure if this means extraction is coming or its actually available for players
# to extract". It means the second one: the extraction has LANDED and the
# boarding window is running, so it is the one moment he must be in the ring
# holding E. The words are his own from v8.68, chosen then over OPEN, and he is
# telling me now that they read as something happening elsewhere rather than an
# instruction. He already gave the right words at v11.54 for the ring badge:
# EXTRACT NOW. The banner and the off-screen ring label say that, with the
# seconds named as what is LEFT.
SubRx @'
function drawHUD(){
  var p=G.player,T=G.tel,i;
'@ @'
// v11.74, HIS NOTE: the one line that says the window is open and he must move.
// Both places that announce it read from here, so they cannot drift apart, and
// the seconds are named as what is LEFT rather than a bare number.
function extractNowLine(letter,secs){
  return 'EXTRACT NOW!  '+letter+'  '+Math.max(0,Math.ceil(secs))+'S LEFT';
}
function drawHUD(){
  var p=G.player,T=G.tel,i;
'@

# 1. THE OFF-SCREEN RING LABEL.
SubRx @'
    ctx.fillText(_rHold?
      ('EXTRACTION IN PROGRESS!  '+extLetter(RZ)+'  '+Math.max(0,Math.ceil(RZ.hold))+'s'):
      ('EXTRACT '+extLetter(RZ)+' INBOUND '+Math.ceil(RZ.beaconT)+'s'),rs.x,rs.y);
'@ @'
    ctx.fillText(_rHold?
      extractNowLine(extLetter(RZ),RZ.hold):
      ('EXTRACT '+extLetter(RZ)+' INBOUND '+Math.ceil(RZ.beaconT)+'s'),rs.x,rs.y);
'@

# 2. THE BANNER ABOVE THE BELT, which is the one he was reading, AND the comment
# above it, which still quotes the old wording. The check's control reads the
# whole function source, comments included, so a stale comment would fail it;
# and leaving it would leave the file claiming a phrase the game no longer says.
SubRx @'
    // v8.68, his wording: the boarding window is EXTRACTION IN PROGRESS, not OPEN.
    ctx.fillText(holding?('EXTRACTION IN PROGRESS!  '+_exL+'  '+Math.max(0,Math.ceil(G.shipHold))+'s'):('EXTRACT '+_exL+' INCOMING  '+Math.ceil(G.beaconT)+'s'),W/2,_exBan);
'@ @'
    // v8.68 named this window for him rather than calling it OPEN. v11.74, his
    // note: that name read as something happening elsewhere, so it tells him to
    // move instead, in the words he gave for the ring badge at v11.54.
    ctx.fillText(holding?extractNowLine(_exL,G.shipHold):('EXTRACT '+_exL+' INCOMING  '+Math.ceil(G.beaconT)+'s'),W/2,_exBan);
'@

# STAMPS.
SubRx @'
var VER='11.73';
'@ @'
var VER='11.74';
'@
SubRx @'
var WHATSNEW_VER='11.73';
'@ @'
var WHATSNEW_VER='11.74';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE BOARDING WINDOW SAYS EXTRACT NOW. It used to say EXTRACTION IN PROGRESS, which reads as something happening without you rather than the one moment you have to be in the ring holding E.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.73:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.73 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.73:[^']*'",{ param($m) "now:'v11.74: HIS NOTE of 2026-09-06, EXTRACTION IN PROGRESS at the bottom of the screen did not say whether the extraction was coming or was his to take. It marks the boarding window, the one moment he must be in the ring holding E. The wording was his own from v8.68, chosen over OPEN. Both places that announce the window now read one helper, extractNowLine, which says EXTRACT NOW with the ring letter and the seconds LEFT, the words he gave for the ring badge at v11.54. Check 11.74 reads the helper and requires his words, the letter and the seconds, and controls that both draw sites use it and that the phrase IN PROGRESS is gone from them.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
