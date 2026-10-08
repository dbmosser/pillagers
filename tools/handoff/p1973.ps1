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

# THE CORNER CREDITS LINE UP WITH THE WINDOW HEADING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #topright{ text-shadow:0 0 3px rgba(4,6,9,.95),0 0 8px rgba(4,6,9,.8); }   /* v18.62: the corner readout reads over a light wall (CREDITS vanished on the Undercroft side wall) */
'@ @'
  #topright{ text-shadow:0 0 3px rgba(4,6,9,.95),0 0 8px rgba(4,6,9,.8); }   /* v18.62: the corner readout reads over a light wall (CREDITS vanished on the Undercroft side wall) */
  /* v19.73, seen on the 4K shop and settings screenshots (2026-10-08): with a window open the corner readout sits in its heading row
     (v11.52, v12.19), but 18 pixels above the heading, so at every size its figures sat on the window's frame. While a window is
     up it drops to the heading's line. */
  body:has(.modal.on) #topright{ top:24px; }
'@

SubRx @'
var VER='19.72';
'@ @'
var VER='19.73';
'@

$pat = "(?m)^  now:'v19\.72:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.73: The credits in the corner sit level with the window title instead of on its frame. Check 19.73 fails on v19.72',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
