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

SubRx @'
  var pbx=document.getElementById('pausebox');
  if(pbx&&pbx.classList.contains('on')) return pbx;
'@ @'
  var pbx=document.getElementById('pausebox');
  if(pbx&&pbx.classList.contains('on')) return pbx;
  // v15.57, first run audit finding: THE END-OF-RAID CARD CAN BE LEFT WITH A CONTROLLER. The card that comes up after an
  // extraction or a death is an .outcome, not a .modal, and this list never looked at it. So padMenu found no panel, and the
  // pad fell through to the raid branch with G.over set, where A does not fire, B does not roll and Menu does not pause:
  // nothing on a pad reached Log run and return, and a pad player's first extraction or first death left him on the card
  // until he picked up the mouse. v14.23 closed the same gap for the pause box and v14.26 for the title. The card is a panel
  // now: the focus lands on Log run and return, A presses it, and B finds it by its word return and presses it, so the run
  // is logged exactly as a click logs it. An A still held from the raid does not press it, because every raid frame stamps
  // PAD.prev and tap wants a fresh press. Checked after the windows, which still win, and after the pause box, which endRaid
  // shuts before the card goes up. No player text, no number and no seeded draw moved.
  var ocw=document.getElementById('outcome');
  if(ocw&&ocw.classList.contains('on')) return ocw;
'@
SubRx @'
var VER='15.56';
'@ @'
var VER='15.57';
'@

$pat = "(?m)^  now:'v15\.56:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.57: THE END-OF-RAID CARD CAN BE LEFT WITH A CONTROLLER. The card after an extraction or a death is not a window, so a controller found nothing to press on it, and a pad player stayed on the card after his first extraction or death until he picked up the mouse. The card now takes the controller the way the pause box does: the focus lands on Log run and return, A or B presses it, and an A still held from the raid does not. Check 15.57 leaves an extraction card with B and a death card with A on a faked controller; it fails on v15.56',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
