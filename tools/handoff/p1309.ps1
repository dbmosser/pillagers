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

# HIS NOTE, 2026-09-12: "is there a way to make it so hitting esc in the game won't
# break fullscreen?"
#
# THE HONEST ANSWER IS THAT A PAGE CANNOT CANCEL IT. Escape leaving fullscreen is a
# guarantee the browser makes to the person using it, not an event the page is allowed
# to swallow, and no amount of preventDefault touches it. That is deliberate and it is
# not going to change.
#
# THERE IS EXACTLY ONE SUPPORTED MECHANISM AND IT WAS BUILT FOR THIS. Keyboard Lock
# hands Escape to the page while it is fullscreen, and it exists because fullscreen
# games kept asking for precisely this. It is requested on entering fullscreen and
# released on leaving.
#
# WHAT IT DOES NOT DO, and he should hear it from me rather than find out:
#   - Chrome, Edge and Opera have it. FIREFOX AND SAFARI DO NOT, and in those Escape
#     will still drop out of fullscreen. P pauses in every browser, which is why the
#     pause box names both keys.
#   - It needs a secure page. Itch is https, so that is satisfied; a file:// copy is
#     not, and will behave like Firefox.
#   - HOLDING Escape for about two seconds still leaves fullscreen, in every browser
#     that implements the lock. That is the browser's own escape hatch and it cannot
#     be removed. It is also the right behaviour: nobody is ever trapped in a game.
#
# WIRED INTO THE EVENT RATHER THAN THE BUTTON, because every way in and out reports
# through fullscreenchange and only some of them go through the button. That is the
# same reason the label is set there and not on click.
SubRx @'
function fsCan(){
'@ @'
// v13.09, HIS NOTE: "hitting esc in the game won't break fullscreen". A page cannot
// cancel Escape leaving fullscreen; that is a promise the browser makes to the person
// using it. Keyboard Lock is the one supported mechanism, built for fullscreen games,
// and it hands Escape to the page instead. Chromium only, secure pages only, and
// holding Escape still leaves, which is the browser's escape hatch and is right.
// Every failure here is silent on purpose: a browser without it must play exactly as
// it played before.
function fsKeyLock(){
  try{
    var k=navigator.keyboard;
    if(!k||!k.lock||!k.unlock) return false;
    if(fsOn()){ var pr=k.lock(['Escape']); if(pr&&pr.catch) pr.catch(function(){}); return true; }
    k.unlock();
    return true;
  }catch(_kl){ return false; }
}
function fsCan(){
'@

SubRx @'
        .forEach(function(evn){ document.addEventListener(evn,function(){ fsSync(); }); });
'@ @'
        // v13.09: and the Escape lock with it. Both belong on the event rather than
        // the button, because leaving fullscreen with Escape or the browser chrome
        // never goes through the button.
        .forEach(function(evn){ document.addEventListener(evn,function(){ fsSync(); fsKeyLock(); }); });
'@

# NEW IN.
SubRx @'
  'YOU ARE NOT CARRYING A GUN AROUND THE UNDERCROFT.
'@ @'
  'ESC NO LONGER DROPS YOU OUT OF FULLSCREEN, IN CHROME AND EDGE. A page is not allowed to cancel that key, so the game now asks the browser to hand Escape over while you are fullscreen, which is what the browser built for games like this. Firefox and Safari do not offer it and will still drop out; P pauses in every browser. Holding Escape always leaves fullscreen, so you can never be stuck.',
  'YOU ARE NOT CARRYING A GUN AROUND THE UNDERCROFT.
'@

# STAMPS.
SubRx @'
var VER='13.08';
'@ @'
var VER='13.09';
'@
SubRx @'
var WHATSNEW_VER='13.08';
'@ @'
var WHATSNEW_VER='13.09';
'@
$cnt=([regex]::Matches($s,"now:'v13\.08:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v13.08 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v13\.08:[^']*'",{ param($m) "now:'v13.09: his note of 2026-09-12, is there a way to make it so hitting esc in the game will not break fullscreen. The honest answer is that a page cannot cancel it: Escape leaving fullscreen is a guarantee the browser makes to the person using it, not an event the page may swallow, and no amount of preventDefault touches it. There is exactly one supported mechanism and it was built for this, Keyboard Lock, which hands Escape to the page while it is fullscreen because fullscreen games kept asking for precisely this; it is requested on entering fullscreen and released on leaving. What it does not do, and he should hear it from me rather than find out: Chrome, Edge and Opera have it and FIREFOX AND SAFARI DO NOT, so in those Escape still drops out of fullscreen and P pauses in every browser, which is why the pause box names both keys; it needs a secure page, so itch is fine and a file copy is not; and HOLDING Escape for about two seconds still leaves fullscreen in every browser that implements the lock, which is the browser own escape hatch, cannot be removed, and is the right behaviour because nobody should ever be trapped in a game. It is wired into the fullscreenchange event rather than the button, because every way in and out reports through that event and only some of them go through the button, which is the same reason the label is set there. Every failure is silent on purpose, so a browser without the lock plays exactly as it played before. Check 13.09 stubs the keyboard interface and requires Escape to be locked when fullscreen is entered and released when it is left, requires nothing to throw when the interface is absent, and requires the lock call to name Escape and not the whole keyboard; fails on v13.08 where the function does not exist.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
