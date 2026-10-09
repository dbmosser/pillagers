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

# THE LOADOUT COUNTS LINE UP WITH THE SLOTS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #kitcol .loslab{ padding-right:28px; }
  #kitcol .lohead{ padding-right:28px; }
'@ @'
  /* v21.31, from the whole-game bug hunt of 2026-10-08 (W-B1), seen on the 4K stash picture: THE LOADOUT COUNTS END WHERE THE SLOTS END.
     The counts on the right of LOADOUT, BACKPACK and TACTICAL BELT (0c going up, 0 PACKED, 0 ON KEYS) stood 28 px in from the edge of
     the column, while the backpack slots and the belt keys under them reach to 12 px from it, so the right side of the column did not
     line up (the names on the left already start where the slots start). The counts now end 12 px in, where the slots end. */
  #kitcol .loslab{ padding-right:12px; }
  #kitcol .lohead{ padding-right:12px; }
'@

SubRx @'
var VER='21.30';
'@ @'
var VER='21.31';
'@

$pat = "(?m)^  now:'v21\.30:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.31: On the stash screen the backpack and belt counts line up with the right edge of the slots. Check 21.31 fails on v21.30',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
