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

# LARGER RARITY PIPS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  c.fillStyle='#0b0c0d'; c.fillRect(cx-S*.4,cy+S*.39,S*.8,S*.18);
  c.fillStyle='#efe9dc';
  for(var i=0;i<n;i++) c.fillRect(cx-S*.34+i*S*.145,cy+S*.43,S*.1,S*.1);
'@ @'
  // v28.xx (cw-cx-pipreadable): the greyscale backpack critic found 5px pips too small; 52px icons now carry 9px-high rank bars.
  c.fillStyle='#0b0c0d'; c.fillRect(cx-S*.4,cy+S*.36,S*.8,S*.24);
  c.fillStyle='#efe9dc';
  for(var i=0;i<n;i++) c.fillRect(cx-S*.34+i*S*.145,cy+S*.39,S*.12,S*.18);
'@

SubRx @'
var VER='34.02';
'@ @'
var VER='34.03';
'@

$pat = "(?m)^  now:'v34\.02:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.03: Rarity pips are taller and wider: about 9px high on a backpack icon at 1080p. Check 34.03 fails on v34.02',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
