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

# THE REWARDS XP COUNT CAN BE READ (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    <div id="seasonbar" style="height:16px;
'@ @'
    <!-- v19.40, seen on the 4K REWARDS screenshot (2026-10-08): the count was dark text meant for the amber fill, but with the fill near empty
         (XP out of 1,200,000) it sat on the dark track and could not be read. Light text with a dark edge reads on both; the bar is a little taller. -->
    <div id="seasonbar" style="height:20px;
'@

SubRx @'
      <div id="seasontext" style="position:absolute;inset:0;text-align:center;font-size:11px;line-height:16px;color:#120e0c;font-weight:700"></div>
'@ @'
      <div id="seasontext" style="position:absolute;inset:0;text-align:center;font-size:13px;line-height:20px;color:#f3ead8;font-weight:700;text-shadow:0 0 3px #000,0 1px 2px #000"></div>
'@

SubRx @'
var VER='19.39';
'@ @'
var VER='19.40';
'@

$pat = "(?m)^  now:'v19\.39:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.40: The XP count on the REWARDS bar is readable. Check 19.40 fails on v19.39',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
