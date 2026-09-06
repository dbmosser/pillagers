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
# The same block sits in openItemMenu and openGunMenu; both are patched.
function SubRx2([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 2) { throw "regex matched $c times, wanted 2: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# HIS NOTE, 2026-09-06 about 14:05: "right click menu in stash is wayyy too
# small -- you know i'm playing at 4k right??" The item menu and the gun menu
# are appended to the body, outside every element applyMenuZoom scales, so
# they drew at 1.0 under a stash drawn at 2.6. Same factor as the windows;
# the click point and the screen clamp are scaled to match.
SubRx2 @'
  document.body.appendChild(m);
  var w=m.offsetWidth,h=m.offsetHeight;
  m.style.left=Math.max(4,Math.min(x,window.innerWidth-w-8))+'px';
  m.style.top=Math.max(4,Math.min(y,window.innerHeight-h-8))+'px';
'@ @'
  document.body.appendChild(m);
  // v12.19, HIS NOTE: the menu is outside every element applyMenuZoom scales,
  // so at 4K it was a 1080p menu under a 4K stash. Same factor as the windows;
  // zoom scales the fixed offsets too, so the click point is divided by it.
  var _mz=Math.max(1,(P&&P.menuZoom)||1)*titleRes();
  var _hubEl=document.getElementById('hub');   // the stash runs at 0.92 of the window factor (v9.67); the menu matches the surface it opens over
  if(_hubEl&&_hubEl.classList.contains('on')&&parseFloat(_hubEl.style.zoom)>0) _mz=parseFloat(_hubEl.style.zoom);
  m.style.zoom=_mz; x=x/_mz; y=y/_mz;
  var w=m.offsetWidth,h=m.offsetHeight;
  m.style.left=Math.max(4,Math.min(x,window.innerWidth/_mz-w-8))+'px';
  m.style.top=Math.max(4,Math.min(y,window.innerHeight/_mz-h-8))+'px';
'@

# STAMPS.
SubRx @'
var VER='12.18';
'@ @'
var VER='12.19';
'@
SubRx @'
var WHATSNEW_VER='12.18';
'@ @'
var WHATSNEW_VER='12.19';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE RIGHT-CLICK MENU IN THE STASH IS DRAWN AT THE SIZE OF THE SCREEN IT OPENS OVER, at 4K and at every text size.',
'@
$cnt=([regex]::Matches($s,"now:'v12\.18:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.18 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.18:[^']*'",{ param($m) "now:'v12.19: HIS NOTE of 2026-09-06, the stash right-click menu was far too small at 4K: it is appended to the body, outside everything applyMenuZoom scales. The item menu and the gun menu take the same zoom as the windows now, with the click point scaled to match. Check 12.19 opens the item menu at 3840x2160 and requires the zoom of the windows and a menu on screen; fails on v12.18.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx2? @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
