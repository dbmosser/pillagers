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

# HIS NOTES, 2026-09-05 in-run at 266 s and 269 s: "activating sprint should
# automatically stop crouching" and "rolling should automatically stop
# crouching". Crouch has been a toggle since v10.07 (his answer 33) and sprint
# a held key since v10.87. The sprint line let the crouch veto the key, so
# Shift while crouched did nothing at all, and the roll never touched the
# toggle, so he came out of a roll still crouched. Sprint wins and a roll
# stands you up.

# 1. SPRINT LEAVES THE CROUCH.
SubRx @'
  var _shHeld=!!(keys['ShiftLeft']||keys['ShiftRight']);
  if(!_shHeld) p.stamRelease=0;
var sprint=_shHeld&&p.stam>2&&!p.stamLock&&!p.stamRelease&&!crouch&&mg>0;
'@ @'
  var _shHeld=!!(keys['ShiftLeft']||keys['ShiftRight']);
  if(!_shHeld) p.stamRelease=0;
  // v11.53, HIS NOTE: "activating sprint should automatically stop crouching".
  // The crouch toggle (v10.07) used to veto the sprint key on the line below,
  // so Shift while crouched did nothing. Sprint wins: the toggle clears and
  // the stance follows this same frame. Movement input is required, the same
  // rule sprint itself has, so a held Shift while standing still changes nothing.
  if(_shHeld&&mg>0&&G.crouchTog&&!p.downed){ G.crouchTog=false; crouch=false; }
var sprint=_shHeld&&p.stam>2&&!p.stamLock&&!p.stamRelease&&!crouch&&mg>0;
'@

# 2. A ROLL LEAVES THE CROUCH.
SubRx @'
  if(p.downed||p.roll>0||p.rollCd>0||p.stam<ROLLSTAM) return;
'@ @'
  if(p.downed||p.roll>0||p.rollCd>0||p.stam<ROLLSTAM) return;
  G.crouchTog=false;   // v11.53, HIS NOTE: "rolling should automatically stop crouching"
'@

# STAMPS.
SubRx @'
var VER='11.52';
'@ @'
var VER='11.53';
'@
SubRx @'
var WHATSNEW_VER='11.52';
'@ @'
var WHATSNEW_VER='11.53';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'SPRINT AND ROLL STAND YOU UP. Holding Shift while crouched used to do nothing; now it leaves the crouch and sprints. A roll leaves the crouch too.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.52:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.52 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.52:[^']*'",{ param($m) "now:'v11.53: HIS NOTES of 2026-09-05, sprint and roll leave the crouch. The crouch toggle vetoed the sprint key so Shift while crouched did nothing, and tryRoll never touched the toggle. Sprint with movement input clears the toggle in the same frame and tryRoll clears it. Check 11.53 crouches, holds Shift with W through real frames and requires the crouch gone and sprinting on; crouches and rolls and requires the crouch gone with the roll started; controls that walking without Shift keeps the crouch.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
