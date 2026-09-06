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

# FIRST TEN MINUTES AUDIT, 2026-09-06 (two readers, independently): the NEW
# IN card on the Undercroft floor is shown to a brand-new player the comment
# above it says it must never be shown to, and with the list past a hundred
# and thirty entries it is near five screens tall at 1080p, so its heading
# and its only dismiss line are both off the canvas: a black slab over the
# whole floor with a middle slice of patch notes in it. Two lines: the gate
# the comment promised, and a cut to what fits.
SubRx @'
  if(!WNSEEN){
    // v8.79, HIS NOTE: "the NEW IN vXXX text is too small". Two sizes up on the
'@ @'
  // v11.92: THE GATE THAT COMMENT PROMISES, written at last. No line ever read
  // the run count; the per-load latch was the only gate, so a friend arriving
  // cold walked into a list of changes to controls he had never used. A profile
  // with no runs stamps itself current here and the card is never drawn.
  if(!WNSEEN&&!(((P&&P.runs)||0)>0)) WNSEEN=1;
  if(!WNSEEN){
    // v8.79, HIS NOTE: "the NEW IN vXXX text is too small". Two sizes up on the
'@
SubRx @'
      if(wnH<=H-LH(60)) break;
    }
    var wnX=W/2-wnW/2, wnY=H/2-wnH/2-LH(10);
'@ @'
      if(wnH<=H-LH(60)) break;
    }
    // v11.92: WHAT DOES NOT FIT IS CUT. The list is past a hundred and thirty
    // entries and grows every build; the size fallback above then drew all of
    // it anyway, a card near five screens tall at 1080p with the heading and
    // the only dismiss line both off the canvas, and a black slab over the
    // whole floor. The list is newest first, so the cut takes the oldest, and
    // it falls between entries, never inside one.
    if(wnH>H-LH(60)){
      var _wnFit=H-LH(60), _wnAcc=LH(90), _wnKeep=0, _wk;
      for(_wk=0;_wk<wnRows.length;_wk++){
        var _wnAdd=wnLH+(wnRows[_wk].gap?LH(7):0);
        if(_wnAcc+_wnAdd>_wnFit) break;
        _wnAcc+=_wnAdd; _wnKeep++;
      }
      while(_wnKeep>1&&_wnKeep<wnRows.length&&!wnRows[_wnKeep].gap) _wnKeep--;
      wnRows.length=Math.max(1,_wnKeep); wnGaps=0;
      for(_wk=0;_wk<wnRows.length;_wk++) if(wnRows[_wk].gap) wnGaps++;
      wnH=LH(90)+wnRows.length*wnLH+wnGaps*LH(7);
    }
    var wnX=W/2-wnW/2, wnY=H/2-wnH/2-LH(10);
'@

# STAMPS.
SubRx @'
var VER='11.91';
'@ @'
var VER='11.92';
'@
SubRx @'
var WHATSNEW_VER='11.91';
'@ @'
var WHATSNEW_VER='11.92';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THIS CARD FITS THE SCREEN NOW, newest first, and a first launch never sees it at all.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.91:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.91 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.91:[^']*'",{ param($m) "now:'v11.92: from the 2026-09-06 first-ten-minutes audit, the NEW IN card had no gate for a fresh profile (the comment above it promised one since v2.79) and drew every one of its entries, past a hundred and forty, a card near five screens tall with its heading and its dismiss line off the canvas. A profile with no runs stamps itself current and never sees it; what does not fit is cut, newest first, between entries. Check 11.92 draws the floor HUD with runs at 0 and requires no card, then with runs and requires the heading and the dismiss line inside the canvas; fails on v11.91.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
