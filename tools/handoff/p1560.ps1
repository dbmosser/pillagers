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
  // v10.93, HIS NOTE: this was rgba(140,152,163,.75).
  ctx.font=FS(TYPE.micro); ctx.fillStyle='#aab6c2';
  ctx.textAlign='center';
'@ @'
  // v10.93, HIS NOTE: this was rgba(140,152,163,.75).
  ctx.font=FS(TYPE.micro); ctx.fillStyle='#aab6c2';
  ctx.textAlign='center';
  // v15.60, first run audit finding: ON A CONTROLLER THE UNDERCROFT BOTTOM LINE NAMES THE PAD BUTTONS. The line below is the
  // only place the floor controls are taught (v11.58), and it had no controller branch, so with a pad connected it still said
  // WASD to walk, SHIFT to jog and E to use a station, in the same frame as a station prompt that says [A] (keyLabel reads
  // PADLABEL_HUB on the floor). The pad has no E: on the floor it walks on the left stick (updateHubWorld reads PAD.mx and
  // PAD.my), jogs on the left stick click (padHold ShiftLeft on button 10) and works a station with A (padHold KeyE on button
  // 0). The raid swaps its legends for LEGEND_MINI_PAD and LEGEND_PAD; this line never had a pad version. With a pad on it now
  // draws the pad words in the raid legend's own terms, L STICK and LS, with A from the same keyLabel the prompt uses, and
  // returns. The keyboard line below is untouched word for word. No number and no seeded draw moved.
  if(padOn()){ ctx.fillText('L STICK WALK  \u00b7  LS JOG  \u00b7  '+keyLabel('KeyE','E')+' USE STATION',W/2,H-16); ctx.textAlign='left'; return; }
'@
SubRx @'
var VER='15.59';
'@ @'
var VER='15.60';
'@

$pat = "(?m)^  now:'v15\.59:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.60: ON A CONTROLLER THE UNDERCROFT BOTTOM LINE NAMES THE PAD BUTTONS. With a controller on the Undercroft floor, the line along the bottom still taught WASD to walk, SHIFT to jog and E to use a station, in the same frame as a station prompt that says A, and a controller has no E. With a controller connected the line now reads L STICK WALK, LS JOG and A USE STATION, and the keyboard line is unchanged. Check 15.60 draws the floor at the lift with a faked controller and without one; it fails on v15.59',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
