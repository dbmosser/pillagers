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

# PRE-RAID MAP: ZONE NAMES 20 PX, EXIT AND KEYED ROOM NAMES 18 PX (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
fs=18, cx=ox+(z.x+z.w/2)*sc
'@ @'
fs=20, cx=ox+(z.x+z.w/2)*sc
'@

SubRx @'
while(fs>12&&c.measureText(nm).width>zw)
'@ @'
while(fs>14&&c.measureText(nm).width>zw)
'@

SubRx @'
c.font='600 16px '+FF; c.textAlign='center'; c.fillStyle='#47d8c6';
'@ @'
c.font='600 18px '+FF; c.textAlign='center'; c.fillStyle='#47d8c6';
'@

SubRx @'
c.font='600 16px '+FF; c.textAlign='right'; c.fillStyle='#dcc3f4';
'@ @'
c.font='600 18px '+FF; c.textAlign='right'; c.fillStyle='#dcc3f4';
'@

SubRx @'
var VER='32.52';
'@ @'
var VER='32.53';
'@

$pat = "(?m)^  now:'v32\.52:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.53: The map names on the pre-raid page are bigger and easier to read. Check 32.53 fails on v32.52',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
