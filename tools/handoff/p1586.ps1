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
function padFocusables(root){
  var out=[],q=root.querySelectorAll('button,.cell,.vcell,.crow,.invtab,.scard,.vpill,input,select');
'@ @'
function padFocusables(root){
  // v15.86, sector audit finding: A CONTROLLER CAN CHOOSE A SECTOR. renderSector builds each sector card as a plain div with
  // the classes row and sectorpick, and this list named buttons, cells, .crow rows, tabs, cards, pills and fields but never
  // .sectorpick, so on the sector page the D-pad and the stick moved only between DAY, NIGHT, the six weather buttons, ASCEND
  // TO THIS SECTOR and CLOSE: the highlight could never land on a sector card and A could never press one. The only thing that
  // sets P.mapIx is the card's onclick, so a pad-only player always went up to whatever P.mapIx already held, COLD STORAGE on
  // a new profile, and THE COLD MILE was out of reach although both sectors are offered: the page's own question, Where are
  // you going?, could not be answered. The cards are in the list now. They are laid out, visible, never disabled and not
  // greyed out, so they pass every filter below; the .padfocus outline draws on a div; A runs the same onclick a mouse click
  // runs; and after that click rebuilds the cards the v14.22 place keeping in padMenu puts the highlight back on the same
  // card, because the cards come first in the panel and their count does not change. .sectorpick exists only inside
  // #sectorlist, so no other panel gains a control. No player text, no number and no seeded draw moved.
  var out=[],q=root.querySelectorAll('button,.cell,.vcell,.crow,.invtab,.scard,.vpill,.sectorpick,input,select');
'@
SubRx @'
var VER='15.85';
'@ @'
var VER='15.86';
'@

$pat = "(?m)^  now:'v15\.85:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.86: A CONTROLLER CAN CHOOSE A SECTOR. On the sector page the two sector cards were never in the list of controls a controller can reach, so the highlight moved only between DAY, NIGHT, the weather buttons, ASCEND TO THIS SECTOR and CLOSE, and a pad player always went up to the sector already set. The cards are in that list now: the highlight lands on either card and A picks it, exactly as a click does. Check 15.86 puts a faked controller highlight on the second card and presses A; it fails on v15.85',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
