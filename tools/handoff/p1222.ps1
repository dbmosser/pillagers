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

# FROM THE 2026-09-06 FIRST-TEN-MINUTES AUDIT: the pause box's own legend says
# "P / ESC pause", and P could open the box but never close it. Since the v0.8
# baseline the box handed the keyboard to its note 40 ms after opening, and the
# key handler ignores every key whose target is a text field, so the second P
# typed a letter p into the note and the raid stayed paused; only ESC (v7.68,
# capture phase) or the Resume button got out. The box no longer takes the
# keyboard on open: the note is a click away (its placeholder invites the
# click), so P toggles as the legend promises and ESC still leaves from inside
# the note. And because keys now reach the raid with the box up, the raid
# answers none of them but P and ESC while it is paused: M, Q, C and the
# digits would otherwise act on a paused raid, and a note typed without the
# click would open the map and swap the belt. The same rule the floor has had
# since v8.16: nothing answers a key while something is open over it.
SubRx @'
  syncPause();
  if(on){ keys={}; mouse.down=false; setTimeout(function(){ document.getElementById('pausenote').focus(); },40); }
'@ @'
  syncPause();
  // v12.22: THE BOX NO LONGER TAKES THE KEYBOARD ON OPEN. It used to focus its
  // note 40 ms in, and the key handler drops every key aimed at a text field, so
  // the second P (the key the legend names) typed a p into the note and the raid
  // stayed paused. The note is a click away; ESC still leaves from inside it.
  if(on){ keys={}; mouse.down=false; }
'@
SubRx @'
function raidKey(code,repeat,ev){
  keys[code]=true;
  // The emote bar owns the number row while it is up, same rule as the stall.
'@ @'
function raidKey(code,repeat,ev){
  keys[code]=true;
  // v12.22: NOTHING IN THE RAID ANSWERS A KEY WHILE THE PAUSE BOX IS UP, except
  // the two keys its legend names. Until v12.22 the box handed the keyboard to
  // its note on open, so no key reached here; now that it does not, M, Q, C and
  // the digits would act on a paused raid, and a note typed without clicking
  // the box first would open the map and swap the belt. The floor rule (v8.16).
  if(pauseOpen&&code!=='KeyP'&&code!=='Escape'){ if(ev) ev.preventDefault(); return; }
  // The emote bar owns the number row while it is up, same rule as the stall.
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'P RESUMES A PAUSED RAID, the way the pause box says. The box used to hand the keyboard to its note the moment it opened, so a second P typed a letter into the note; click the note to write one. While the box is up, no other key touches the raid.',
'@

# STAMPS.
SubRx @'
var VER='12.21';
'@ @'
var VER='12.22';
'@
SubRx @'
var WHATSNEW_VER='12.21';
'@ @'
var WHATSNEW_VER='12.22';
'@
$cnt=([regex]::Matches($s,"now:'v12\.21:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.21 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.21:[^']*'",{ param($m) "now:'v12.22: first-ten-minutes audit: the pause box handed the keyboard to its note the moment it opened, so the second P, the key its own legend names, typed a letter into the note and the raid stayed paused; only ESC or the button got out. The box no longer takes the keyboard (the note is a click away) and while it is up no key but P and ESC reaches the raid. Check 12.22 opens the box by the key with its timers run at once, sends P to whatever holds the keyboard and requires the raid to resume, and requires M with the box up to leave the map shut; fails on v12.21.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
