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

# HIS NOTE, 2026-09-06: "credits and xp in the corner in the undercroft are so
# small that they are useless". The v11.52 readout is 15px in a 24px band
# because in a RAID it has to sit above the CONDITIONS box, which starts at
# LH(30). The Undercroft has no such box. So the readout is twice the size on
# the floor and unchanged in a raid; the same element, one class toggled by the
# writer that already runs every frame.

# 1. STYLE: the floor size, and the stash screen's top row keeps clear of it.
SubRx @'
  #topright small:last-child{ margin-right:0; }
'@ @'
  #topright small:last-child{ margin-right:0; }
  /* v11.78, HIS NOTE: on the floor it was too small to be worth having. There is
     no CONDITIONS box to keep above in the Undercroft, so it is twice the size
     there; the raid keeps the compact size, which is what fits the band. */
  #topright.hub{ font-size:30px; height:46px; line-height:46px; top:8px; right:22px; }
  #topright.hub small{ font-size:14px; letter-spacing:.2em; margin-left:7px; margin-right:20px; }
  #topright.hub small:last-child{ margin-right:0; }
'@
SubRx @'
  .toprow{ padding-right:270px; }   /* v11.52: the stash screen's top row keeps clear of the corner readout, so CLOSE stays reachable */
'@ @'
  .toprow{ padding-right:440px; }   /* v11.52: the stash screen's top row keeps clear of the corner readout, so CLOSE stays reachable; v11.78: wider, the readout is bigger on the floor */
'@

# 2. THE WRITER: one class, flipped only when the answer changes.
SubRx @'
function syncTopRight(){
  var el=document.getElementById('topright'); if(!el) return;
'@ @'
function syncTopRight(){
  var el=document.getElementById('topright'); if(!el) return;
  // v11.78, HIS NOTE: big on the floor, compact in a raid. Toggled here because
  // this already runs every frame and on every save, and only written when the
  // answer changes so it costs nothing.
  var _onFloor=(typeof state!=='undefined'&&state==='hub'&&!G);
  if(el.__floor!==_onFloor){ el.__floor=_onFloor; try{ el.classList.toggle('hub',_onFloor); }catch(_tc){} }
'@

# STAMPS.
SubRx @'
var VER='11.77';
'@ @'
var VER='11.78';
'@
SubRx @'
var WHATSNEW_VER='11.77';
'@ @'
var WHATSNEW_VER='11.78';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'CREDITS AND XP ARE TWICE THE SIZE IN THE UNDERCROFT. In a raid they stay small, because they have to sit above the conditions panel.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.77:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.77 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.77:[^']*'",{ param($m) "now:'v11.78: HIS NOTE of 2026-09-06, the credits and XP readout in the corner is too small in the Undercroft to be useful. It is 15px in a 24px band because in a raid it must sit above the CONDITIONS box at LH(30); the floor has no such box. syncTopRight, which already runs every frame and on every save, toggles a hub class when state is hub and no raid is running, and that class doubles the size; the raid keeps the compact size and the stash top row keeps clear of the bigger readout. Check 11.78 requires the class and at least 26px of type and 40px of height on the floor, and in a raid the compact 24px height and clearance from the CONDITIONS box.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
