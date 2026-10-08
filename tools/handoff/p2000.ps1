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

# THE PARTY FRAME STAYS CLEAR OF THE CREDITS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #partymodal::before{ inset:50% auto auto 50%; width:min(1180px,calc(100% - 28px)); height:min(760px,calc(100% - 28px)); transform:translate(-50%,-50%); }
'@ @'
  /* v20.00, seen on the 4K PARTY screenshot (2026-10-08): in a window about 830 menu pixels tall (1080p, 1440p, a 4K window) the
     frame's top line ran 33 pixels down, under the CREDITS readout in the corner. The frame now stays 75 pixels clear of the top
     and bottom, which holds the party content with room and keeps the corner readout off its line. */
  #partymodal::before{ inset:50% auto auto 50%; width:min(1180px,calc(100% - 28px)); height:min(760px,calc(100% - 150px)); transform:translate(-50%,-50%); }
'@

SubRx @'
var VER='19.99';
'@ @'
var VER='20.00';
'@

$pat = "(?m)^  now:'v19\.99:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.00: The PARTY window frame no longer runs under the credits in the corner. Check 20.00 fails on v19.99',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
