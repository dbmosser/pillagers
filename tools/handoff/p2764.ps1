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

# KEYS WINDOW CROUCH AND SPRINT ROWS CLAIM NO MODE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var KEYS_ACTS=[['KeyW','move up'],['KeyA','move left'],['KeyS','move down'],['KeyD','move right'],['Space','dodge roll'],['ShiftLeft','sprint (hold)'],
  ['ControlLeft','crouch (hold)'],['KeyC','crouch toggle'],['KeyE','search and use'],['KeyR','reload'],['KeyQ','item wheel (hold)'],['KeyV','melee (crowbar)'],['KeyF','next gun'],
'@ @'
// v27.64 (cloud-menus-keys-hold-toggle-labels), CLOUD HUNT 2026-10-15: these rows said SHIFT sprint (hold), CTRL crouch (hold) and C crouch toggle, but the CROUCH and
// SPRINT settings decide hold or toggle (by default a Ctrl tap crouches and a second tap stands), so the rows name the action and claim no mode. C is the second crouch key.
var KEYS_ACTS=[['KeyW','move up'],['KeyA','move left'],['KeyS','move down'],['KeyD','move right'],['Space','dodge roll'],['ShiftLeft','sprint'],
  ['ControlLeft','crouch'],['KeyC','crouch (second key)'],['KeyE','search and use'],['KeyR','reload'],['KeyQ','item wheel (hold)'],['KeyV','melee (crowbar)'],['KeyF','next gun'],
'@

SubRx @'
var VER='27.63';
'@ @'
var VER='27.64';
'@

$pat = "(?m)^  now:'v27\.63:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.64: The Keys window names sprint and crouch without claiming hold or toggle; the CROUCH and SPRINT settings decide that. Check 27.64 fails on v27.63',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
