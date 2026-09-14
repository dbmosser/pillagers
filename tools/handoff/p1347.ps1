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

# THE CONTROLLER ON THE UNDERCROFT FLOOR. Found by the key remap review of 2026-09-13:
# the floor branch of pollPad binds only A, X, Y, RB and the left stick, so View and Menu
# did nothing down there. A pad could not open or close the floor backpack or raise and
# close the pause box, while both buttons do exactly that upstairs. Called directly, not
# as synthetic key events, because a synthetic key on window reaches the capture closer
# as well and toggles the pause box twice.
SubRx @'
function raidKey(code,repeat,ev){
'@ @'
// v13.47: THE PAD ON THE FLOOR. View is the backpack and Menu is pause, the same rules
// the keyboard I and P follow down here: nothing answers under a title, a window or a
// right-click menu, and under the pause box only Menu does.
function floorPadTap(code){
  if(state!=='hub') return;
  var _t=document.getElementById('title');
  if((_t&&_t.classList.contains('on'))||document.querySelector('.modal.on')||document.querySelector('.imenu')) return;
  if(code==='KeyP'){ togglePauseBox(!document.getElementById('pausebox').classList.contains('on')); return; }
  if(pauseOpen) return;
  if(code==='KeyI'){
    var _hb=document.getElementById('hub');
    if(_hb&&_hb.classList.contains('on')) _hb.classList.remove('on');
    hubBagOpenSet(!hubBagOpen);
  }
}
function raidKey(code,repeat,ev){
'@
SubRx @'
    padHold('KeyT',pressed(5));
    for(var b0=0;b0<bt.length;b0++) PAD.prev[b0]=pressed(b0);
'@ @'
    padHold('KeyT',pressed(5));
    // v13.47: View opens and closes the backpack, Menu pauses, one change per press.
    if(pressed(8)&&!PAD.prev[8]) floorPadTap('KeyI');
    if(pressed(9)&&!PAD.prev[9]) floorPadTap('KeyP');
    for(var b0=0;b0<bt.length;b0++) PAD.prev[b0]=pressed(b0);
'@
SubRx @'
var VER='13.46';
'@ @'
var VER='13.47';
'@

$pat = "(?m)^  now:'v13\.46:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.47: THE CONTROLLER WORKS ON THE UNDERCROFT FLOOR. Found by the key remap review of 2026-09-13: the floor branch of pollPad bound only A, X, Y, RB and the left stick, so View and Menu did nothing down there, and a pad could not open or close the floor backpack or raise and close the pause box. floorPadTap now gives View the backpack and Menu the pause box under the same rules the keyboard I and P follow on the floor, one change per press, called directly rather than as synthetic keys. Check 13.47 fakes a pad on the floor and requires View to open and close the backpack, Menu to raise and close the box, View to do nothing under the box, and a held View to open once; it fails on v13.46',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
