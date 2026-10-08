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

# THE LOADOUT QUESTION FITS ITS BUTTONS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #askmodal .askrow{ display:flex; gap:10px; align-items:stretch; }
'@ @'
  #askmodal .askrow{ display:flex; gap:10px; align-items:stretch; }
  /* v20.24, seen on the 4K ascent screenshot (2026-10-08): the WHAT ARE YOU TAKING UP card held five choices in 560 pixels, so
     RANDOM FROM STASH broke over three lines and MY LOADOUT over two. The card grows to fit its buttons on one line (up to 1000),
     never narrower than before, and its words stay 560 wide so they do not run into long lines. A yes or no looks as it did. */
  #askmodal .askcard{ width:fit-content; min-width:min(560px,90vw); max-width:min(1000px,94vw); }
  #askmodal .askcard .msub{ max-width:560px; }
  #askmodal .askrow button{ white-space:nowrap; }
'@

SubRx @'
var VER='20.23';
'@ @'
var VER='20.24';
'@

$pat = "(?m)^  now:'v20\.23:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.24: Every choice on the WHAT ARE YOU TAKING UP card sits on one line. Check 20.24 fails on v20.23',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
