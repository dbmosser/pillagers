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

# THE CORNER CREDITS STAY PUT OVER A CARD WINDOW (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  body:has(.modal.on) #topright{ top:24px; right:33px; }
'@ @'
  /* v19.89, from the code review of 2026-10-08: the centred card windows (PARTY, TERMS, the gambler, the bar, the one question card)
     have no heading row in the corner, and at 4K the move put the figures on the PARTY frame's top line. They keep the corner. */
  body:has(.modal.on:not(#partymodal):not(#termsmodal):not(#gamblemodal):not(#barmodal):not(#askmodal)) #topright{ top:24px; right:33px; }
'@

SubRx @'
var VER='19.88';
'@ @'
var VER='19.89';
'@

$pat = "(?m)^  now:'v19\.88:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.89: With the PARTY window open at 4K, the corner credits no longer sit on its frame. Check 19.89 fails on v19.88',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
