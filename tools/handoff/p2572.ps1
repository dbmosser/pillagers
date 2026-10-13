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

# A SEARCH ALWAYS OPENS ON THE RUMMAGE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  SRCHFX.hit++; SRCHFX.n++;
'@ @'
  // v25.xx (searchfix): a search OPENS on the rummage itself. The counters rode over from the search before, so an opening could land on
  // a dig left due by the last search, or lose the rummage to the no-repeat rule when the last search ended on it.
  if(first){ SRCHFX.hit=0; SRCHFX.n=0; SRCHFX.last=''; }
  SRCHFX.hit++; SRCHFX.n++;
'@

SubRx @'
var VER='25.71';
'@ @'
var VER='25.72';
'@

$pat = "(?m)^  now:'v25\.71:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.72: Every box search now opens on the hands-in-the-box rummage. Check 25.72 fails on v25.71',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
