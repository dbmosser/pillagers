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

# CALMER LEFT FEED (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(sub) segs.push({t:'  \u00b7  '+sub,c:HUDC.dim});
'@ @'
  if(sub&&sub.split(/\s+/).length<=4) segs.push({t:'  \u00b7  '+sub,c:HUDC.dim});   // v28.xx (cw-feedcalm), the critic (2026-10-19): 'explaining sentences' in the left feed. A detail of five words or more (limited visibility due to fog, kill it for the hoard) stays out of the feed line; the headline is the line.
'@

SubRx @'
var FEED={show:10,keep:40,hold:6,dim:0.35,
'@ @'
var FEED={show:10,keep:40,hold:6,dim:0.6,
'@

SubRx @'
var VER='30.92';
'@ @'
var VER='30.93';
'@

$pat = "(?m)^  now:'v30\.92:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.93: Left feed lines are short names and older lines stay readable. Check 30.93 fails on v30.92',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
