$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# PAD GOALS AND STATUS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  8:'KeyI',       // View   backpack. v13.44: TAB pauses and backs out now, so View taps I
'@ @'
  8:'KeyI',       // v28.xx (cw-cx-padstatus): View tap backpack / hold status is handled separately in the raid.
'@

SubRx @'
    var n=+k,now=pressed(n);
'@ @'
    var n=+k,now=pressed(n); if(n===8) continue;   // v28.xx (cw-cx-padstatus): View waits for tap or hold.
'@

SubRx @'
  // triggers: RT fires, LT is steady aim. Both are analog, so a light pull is
'@ @'
  // v28.xx (cw-cx-padstatus): his 3.21 a: goals and raid status together. View tap keeps the bag; hold uses ALT.
  var _viewDown=pressed(8), _viewNow=netPadNow();
  if(_viewDown&&!PAD.prev[8]){ PAD.viewAt=_viewNow; PAD.viewHeld=false; }
  if(_viewDown&&PAD.viewAt!=null&&_viewNow-PAD.viewAt>=0.25) PAD.viewHeld=true;
  padHold('AltLeft',!!(_viewDown&&PAD.viewHeld&&!G.over&&!G.paused&&!G.mapOpen&&!G.bagOpen&&!G.wheel));
  if(!_viewDown&&PAD.prev[8]&&PAD.viewAt!=null&&!PAD.viewHeld){ raidKey('KeyI',false,null); keys.KeyI=false; }
  if(!_viewDown){ PAD.viewAt=null; PAD.viewHeld=false; }
  // triggers: RT fires, LT is steady aim. Both are analog, so a light pull is
'@

SubRx @'
  PAD.xWas=false; PAD.yGift=0;   // v22.19
'@ @'
  PAD.xWas=false; PAD.yGift=0; PAD.viewAt=null; PAD.viewHeld=false;   // v28.xx (cw-cx-padstatus): a panel spends the View hold; v22.19
'@

SubRx @'
ShiftLeft:'LS',ControlLeft:'B',KeyM:'D-UP',KeyI:'VIEW'};
'@ @'
ShiftLeft:'LS',ControlLeft:'B',KeyM:'D-UP',KeyI:'VIEW',AltLeft:'VIEW'};
'@

SubRx @'
KeyM:12,KeyI:8,
'@ @'
KeyM:12,KeyI:8,AltLeft:8,
'@

SubRx @'
[8,'backpack','GEAR']
'@ @'
[8,'backpack (tap), status (hold)','GEAR']
'@

SubRx @'
[n(8),'backpack']
'@ @'
[n(8)+' tap','backpack'],[n(8)+' hold','goals / raid status']
'@

SubRx @'
[b(8),'backpack']
'@ @'
[b(8)+' tap','backpack'],[b(8)+' hold','goals / status']
'@

SubRx @'
['LB / RB','tactical belt'],['VIEW','backpack']
'@ @'
['LB / RB','tactical belt'],['VIEW tap','backpack'],['VIEW hold','goals / status']
'@

SubRx @'
['D-DOWN','item wheel (hold), revive when down'],['VIEW','backpack']
'@ @'
['D-DOWN','item wheel (hold), revive when down'],['VIEW tap','backpack'],['VIEW hold','goals / raid status']
'@

SubRx @'
'focus','fire','backpack','pause'
'@ @'
'focus','fire','bag / status','pause'
'@

SubRx @'
+'HOLD '+keyName(keysOf('AltLeft'))
'@ @'
+'HOLD '+keyLabel('AltLeft',keyName(keysOf('AltLeft')))
'@

SubRx @'
var VER='32.61';
'@ @'
var VER='32.62';
'@

$pat = "(?m)^  now:'v32\.61:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.62: Tap View for the bag. Hold View for goals and raid status together. Check 32.62 fails on v32.61',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
