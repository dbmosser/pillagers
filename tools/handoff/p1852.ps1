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

# AN UNPLUGGED CONTROLLER PAUSES ONLY ITS OWN WINDOW (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  RUMBLE.gp=(gp&&gp.vibrationActuator&&typeof gp.vibrationActuator.playEffect==='function')?gp:null;   // v17.37: the pad this window plays, for padRumble
'@ @'
  RUMBLE.gp=(gp&&gp.vibrationActuator&&typeof gp.vibrationActuator.playEffect==='function')?gp:null;   // v17.37: the pad this window plays, for padRumble
  if(gp&&typeof gp.index==='number') PAD.ix=gp.index;   // v18.52, from the code comb (2026-10-07): the last pad this window played, own or handed over, for the unplug handler
'@

SubRx @'
  if(typeof NET==='object'&&NET&&NET.same&&typeof NET.padIx==='number'&&NET.padIx>=0&&_gi>=0&&_gi!==NET.padIx) return;
'@ @'
  if(typeof NET==='object'&&NET&&NET.same&&typeof NET.padIx==='number'&&NET.padIx>=0&&_gi>=0&&_gi!==NET.padIx) return;
  // v18.52, FROM THE CODE COMB (2026-10-07): THE PICK ALONE MISSED THE DEFAULT. With no controller picked (NET.padIx -1, the default) the
  // test above passed every unplug, so player 2 pulling their cable paused player 1 mid fight too. A window now reacts only to the pad it
  // last played (PAD.ix, kept by pollPad); in a same machine pair a window that never played a pad (the keyboard player) ignores them all.
  if(_gi>=0&&((typeof PAD.ix==='number')?(_gi!==PAD.ix):!!(typeof NET==='object'&&NET&&NET.same))) return;
'@

SubRx @'
var VER='18.51';
'@ @'
var VER='18.52';
'@

$pat = "(?m)^  now:'v18\.51:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.52: When one player pulls their controller cable, only their own window pauses. Check 18.52 fails on v18.51',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
