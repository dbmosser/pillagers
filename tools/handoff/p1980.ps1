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

# THE CARD CAPTIONS ARE READABLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .crlab{ font-size:10.5px; letter-spacing:.16em; color:#6a655a; margin:4px 0 7px; }
'@ @'
  .crlab{ font-size:12.5px; letter-spacing:.16em; color:#6a655a; margin:4px 0 7px; }   /* v19.80, seen on the 4K Mainframe screenshot (2026-10-08): PROGRESS, REWARDS and REQUIRED RESOURCES were 10.5px captions */
'@

SubRx @'
var VER='19.79';
'@ @'
var VER='19.80';
'@

$pat = "(?m)^  now:'v19\.79:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.80: PROGRESS, REWARDS and REQUIRED RESOURCES on the cream cards are easier to read. Check 19.80 fails on v19.79',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
