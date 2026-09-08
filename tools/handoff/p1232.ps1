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

# HIS NOTE (2026-09-07 morning): "crafting progress bar is not working
# correctly, can't craft items at all". Investigated on the dry fixture and by
# reading at v12.31. The machinery is sound: a real mousedown starts the hold,
# the frame loop fills it, and a full second crafts, spends and awards
# correctly; the fill is visible while the pointer is on the button, because
# the hover rule turns the button background down to 8 percent amber and the
# fill is painted at 55. What is NOT sound is that the button never tells him
# any of it. It reads CRAFT, so it reads like a button you click. His own
# v11.75 order is that a mouse click spends nothing and the hold is the way,
# and v12.17 made that exact, so a click on it does nothing AND says nothing.
# Letting go early cancels in silence too. Every natural reaction to a button
# that looks unresponsive gets silence back, which is "cannot craft at all".
# Three edits: the button says what to do, a click says why nothing happened,
# and letting go early says so.
SubRx @'
  b.textContent=(kind==='repair')?'SERVICE':'CRAFT';
'@ @'
  // v12.32, HIS NOTE: it read CRAFT, which reads like a button you click, and a
  // click spends nothing by his v11.75 order. The label is the instruction now.
  b.textContent=(kind==='repair')?'HOLD TO SERVICE':'HOLD TO CRAFT';
'@
SubRx @'
    b.onclick=function(e){ if(e&&e.detail) return; btn.click(); };
'@ @'
    // v12.32, HIS NOTE: a real mouse click still spends nothing, his v11.75
    // rule, but it used to return in silence, so the bench looked broken.
    b.onclick=function(e){ if(e&&e.detail){ try{ say2('Hold it down for a second. A click on its own spends nothing.'); }catch(_cs){} return; } btn.click(); };
'@
SubRx @'
try{ window.addEventListener('mouseup',function(){ craftHoldCancel(); }); }catch(_chm){}
'@ @'
try{ window.addEventListener('mouseup',function(){
  // v12.32, HIS NOTE: letting go before the second is up cancelled in silence,
  // which is the same dead press from his side. It says so, once, and only for
  // a press that had really started; a completed hold has cleared itself above.
  if(craftHold&&craftHold.t>0.12&&craftHold.t<CRAFT_HOLD){ try{ say2('Let go too soon. Hold it for a full second.'); }catch(_cu){} }
  craftHoldCancel();
}); }catch(_chm){}
'@

# NEW IN.
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE BENCH SAYS HOLD TO CRAFT ON THE BUTTON, because holding it is what crafts. A click on its own still spends nothing, as you asked, but it now says so instead of doing nothing, and so does letting go too soon.',
'@

# STAMPS.
SubRx @'
var VER='12.31';
'@ @'
var VER='12.32';
'@
SubRx @'
var WHATSNEW_VER='12.31';
'@ @'
var WHATSNEW_VER='12.32';
'@
$cnt=([regex]::Matches($s,"now:'v12\.31:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.31 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.31:[^']*'",{ param($m) "now:'v12.32: his note of 2026-09-07 (the crafting bar does not work and nothing can be crafted): the machinery is sound and a full second of holding does craft, spend and award, and the fill does show while the pointer is on the button, because the hover rule drops the button to 8 percent amber under a fill painted at 55. What was wrong is that the bench never said any of it: the button read CRAFT, a real mouse click spends nothing by his v11.75 order and returned in silence, and letting go early cancelled in silence. The button now reads HOLD TO CRAFT, a click says to hold it, and an early release says it was let go too soon. Check 12.32 stages the Component Kit parts, requires the label to say HOLD, sends a real click and requires a spoken line with nothing crafted, releases early and requires a spoken line, and requires a synthetic click and a full hold still to craft; fails on v12.31.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
