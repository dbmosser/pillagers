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

# THE KEY LINE STAYS OUT OF A WINDOW (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  // v10.93, HIS NOTE: this was rgba(140,152,163,.75).
'@ @'
  // v21.30, from the whole-game bug hunt of 2026-10-08 (W-A3): THE KEY LINE STAYS OUT OF A STATION WINDOW. Since the floor belt stopped
  // drawing under a window (v21.19) this line has no belt to sit above and drops to the bottom edge of the screen, so on the 4K
  // pictures of the shop and FASHION the words WASD WALK, SHIFT JOG, E USE STATION showed in the dark strip under the window, cut
  // through by its frame line. It is not drawn while a window is open, as the floor heading is not (v20.88), and is back the frame
  // the window closes. It is the last thing the floor HUD draws, so nothing after it is skipped.
  if(hubWinOn()){ ctx.textAlign='left'; return; }
  // v10.93, HIS NOTE: this was rgba(140,152,163,.75).
'@

SubRx @'
var VER='21.29';
'@ @'
var VER='21.30';
'@

$pat = "(?m)^  now:'v21\.29:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.30: The Undercroft key line no longer shows under the bottom edge of a station window. Check 21.30 fails on v21.29',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
