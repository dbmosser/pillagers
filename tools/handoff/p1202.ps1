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

# FROM THE 2026-09-06 READ-ONLY REVIEW OF v11.75 (the hold-to-craft build):
# deleting the button's onclick also deleted the only way a controller (the
# pad presses controls with a synthetic click) or the keyboard (Enter on the
# focused button) could craft, so with a pad crafting became impossible, not
# merely un-holdable. A mouse click carries detail 1 or more; a pad's .click()
# and a keyboard Enter carry detail 0. The click handler comes back and
# answers only the synthetic kind, so a real click still spends nothing and
# the hold is still the mouse's way. Also: the hold now dies when the trader
# window is hidden (it was only checking that the button was still in the
# page, and the window hides rather than detaches), the tooltip reads the
# hold length from the constant it claims to, and the card stops describing
# a SERVICE button the game cannot draw since wear went out at v9.43.
SubRx @'
    b.onmousedown=function(e){ if(e&&e.button!==undefined&&e.button!==0) return; craftHoldStart(b,function(){ btn.click(); }); };
    b.onmouseleave=function(){ craftHoldCancel(); };
    b.title=((kind==='repair')?'Hold to service':'Hold to craft')+' (1 second)';
'@ @'
    b.onmousedown=function(e){ if(e&&e.button!==undefined&&e.button!==0) return; craftHoldStart(b,function(){ btn.click(); }); };
    b.onmouseleave=function(){ craftHoldCancel(); };
    // v12.02: the pad presses a control with a synthetic click and the
    // keyboard with Enter, both with detail 0; a real mouse click has detail
    // 1 or more and still spends nothing, the hold is its way.
    b.onclick=function(e){ if(e&&e.detail) return; btn.click(); };
    b.title=((kind==='repair')?'Hold to service':'Hold to craft')+' ('+CRAFT_HOLD+' second'+(CRAFT_HOLD===1?'':'s')+')';
'@
SubRx @'
  if(!b||b.disabled||(b.isConnected===false)){ craftHoldCancel(); return; }
'@ @'
  // v12.02: and a button whose window has been hidden; the trader hides its
  // modal rather than detaching it, so isConnected alone let a hold outlive it.
  if(!b||b.disabled||(b.isConnected===false)||!b.offsetParent){ craftHoldCancel(); return; }
'@

# STAMPS.
SubRx @'
var VER='12.01';
'@ @'
var VER='12.02';
'@
SubRx @'
var WHATSNEW_VER='12.01';
'@ @'
var WHATSNEW_VER='12.02';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'A CONTROLLER CAN CRAFT AGAIN. The hold is the mouse way; a pad press on the button crafts at once.',
'@
$cnt=([regex]::Matches($s," The same goes for the service button, which is the same control\.")).Count
if($cnt -ne 1){ throw "service sentence matched $cnt times" }
$s=[regex]::Replace($s," The same goes for the service button, which is the same control\.","")
$n++
$cnt=([regex]::Matches($s,"now:'v12\.01:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.01 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.01:[^']*'",{ param($m) "now:'v12.02: from the read-only review of the shipped v11.75, the hold-to-craft build deleted the only way a controller (a synthetic click from the pad) could press CRAFT. A click handler that answers only synthetic clicks (detail 0) is back; a real mouse click still spends nothing. The hold also dies when the trader window is hidden, the tooltip reads CRAFT_HOLD, and the card no longer describes a SERVICE button the game cannot draw. Check 12.02 crafts through a synthetic click (the pad press), requires a detail-1 click to spend nothing, and requires a hold to die when the window is hidden; fails on v12.01.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 2
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
