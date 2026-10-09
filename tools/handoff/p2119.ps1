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

# THE FLOOR BELT STAYS OUT OF THE WINDOWS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(CFG.hubBelt===0){ HUBBELT.cells=[]; return; }
'@ @'
  if(CFG.hubBelt===0){ HUBBELT.cells=[]; return; }
  // v21.19, from the 4K visual pass of 2026-10-08 (V-A14): THE FLOOR BELT STAYS OUT OF A STATION WINDOW. The belt is drawn on the
  // floor canvas, under every window, and showed faintly along the bottom edge below the window frame, keys and all, as the floor
  // heading did before v20.88. While a window is open over the floor it is not drawn; the window has its own belt where it needs one.
  if(hubWinOn()){ HUBBELT.cells=[]; return; }
'@

SubRx @'
var VER='21.18';
'@ @'
var VER='21.19';
'@

$pat = "(?m)^  now:'v21\.18:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.19: The Undercroft belt no longer shows through the bottom of station windows. Check 21.19 fails on v21.18',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
