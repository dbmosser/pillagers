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

# F11 FULLSCREENS THE PLAYER 2 WINDOW (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var tn=(ev.target&&ev.target.tagName)||'', up=(ev.type==='keyup'), cd=String(ev.code||'');
'@ @'
  var tn=(ev.target&&ev.target.tagName)||'', up=(ev.type==='keyup'), cd=String(ev.code||'');
  // v22.06, from the whole-game bug hunt of 2026-10-08 (K17): F11 BELONGS TO THIS WINDOW. Every key pressed here was handed to the
  // player 1 window and stopped, F11 too, so the v17.92 toggle never ran in the player 2 window: F11 there never fullscreened it,
  // and in the player 1 window it ran the toggle, which took a fullscreen player 1 out of fullscreen. F11, down and up, now stays
  // here and fullscreens this window. Every other key still goes to player 1.
  if(cd==='F11') return;
'@

SubRx @'
var VER='22.05';
'@ @'
var VER='22.06';
'@

$pat = "(?m)^  now:'v22\.05:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.06: F11 in the player 2 window now fullscreens that window and leaves the player 1 window alone. Check 22.06 fails on v22.05',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
