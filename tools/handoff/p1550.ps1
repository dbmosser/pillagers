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
    if(pressed(2)&&!PAD.prev[2]){ raidKey('KeyE',false,null); keys['KeyE']=false; G.pedSel=0; PAD.xAfterTrade=1; }
    for(var _tb=0;_tb<bt.length;_tb++) PAD.prev[_tb]=pressed(_tb);
'@ @'
    if(pressed(2)&&!PAD.prev[2]){ raidKey('KeyE',false,null); keys['KeyE']=false; G.pedSel=0; PAD.xAfterTrade=1; }
    // v15.50, pause audit finding 10: THE CONTROLLER MENU BUTTON PAUSES AT THE PEDDLER STALL. The stall is painted on the canvas,
    // so padMenu finds no panel and hands the pad to this branch, and this branch returned before the tap loop that turns Menu
    // into P. So on a controller Menu at the open stall did nothing, while the stall is not a pause (v12.34: the raid clock, the
    // machines, the extraction clocks and the waves all run on behind it) and keyboard P at the same stall opens the pause box.
    // A pad player could not pause until he walked away with X. Menu now sends P from here on a fresh press, the way the tap
    // loop does, so the box opens over the stall and the stall is still open behind it on resume. PAD.prev is stamped below,
    // so on the next poll the box owns the pad and reads the same held Menu as already down: one press, one change. Pausing is
    // not an act behind the panel, so the v13.49 rule above still holds. No player text, no number and no seeded draw moved.
    if(pressed(9)&&!PAD.prev[9]){ raidKey('KeyP',false,null); keys['KeyP']=false; }
    for(var _tb=0;_tb<bt.length;_tb++) PAD.prev[_tb]=pressed(_tb);
'@
SubRx @'
var VER='15.49';
'@ @'
var VER='15.50';
'@

$pat = "(?m)^  now:'v15\.49:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.50: THE CONTROLLER MENU BUTTON PAUSES AT THE PEDDLER STALL. With the stall open on a controller, Menu did nothing, so the raid clock and the waves ran on with no way to pause short of walking away with X, while keyboard P at the same stall pauses. Menu at the open stall now opens the pause box over it, one change per press, and the stall is still open behind the box. Check 15.50 presses Menu on a faked controller with the stall shut and with it open, and keyboard P at the open stall; it fails on v15.49',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
