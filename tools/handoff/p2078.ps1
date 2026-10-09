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

# A HIT BUZZ PLAYS ITS FULL LENGTH (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(now-RUMBLE.at<50&&s<=RUMBLE.s) return 'soon';
  RUMBLE.at=now; RUMBLE.s=s;
'@ @'
  if(now-RUMBLE.at<50&&s<=RUMBLE.s) return 'soon';
  // v20.78, from the whole-game bug hunt of 2026-10-08 (H48): A WEAKER BUZZ NEVER CUTS A STRONGER ONE SHORT. Only the first 50 ms of
  // a buzz were kept, so the light tick of the next round (0.12 for 35 ms) replaced a 230 ms hit buzz after 100 ms, and every hit in
  // a firefight felt like the same blip; the blast thump and the teammate-down buzz were cut the same way. A weaker request is now
  // dropped until the stronger buzz has played out; an equal or stronger one still takes over at once.
  if(now<(RUMBLE.until||0)&&s<RUMBLE.s) return 'soon';
  RUMBLE.at=now; RUMBLE.s=s; RUMBLE.until=now+Math.min(1000,ms);
'@

SubRx @'
var VER='20.77';
'@ @'
var VER='20.78';
'@

$pat = "(?m)^  now:'v20\.77:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.78: On a controller a hit, a blast or a teammate going down buzzes its full length even while you fire. Check 20.78 fails on v20.77',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
