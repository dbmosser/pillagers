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

# THE CRIER LINES READ LIKE A SHOOTER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
if(!e.markSeat) say('A crier has you. Kill it or move.');
'@ @'
if(!e.markSeat) say('A CRIER IS REVEALING YOUR LOCATION');   // v21.78, his note (2026-10-09): his words, in the voice of a shooter HUD
'@

SubRx @'
say(sees?'The Crier raised the alarm. They know exactly where you are.'   // v11.94, HIS NOTE: name the Crier
                 :'The Crier raised the alarm. They are heading to where it last saw you.');
'@ @'
say(sees?'CRIER REVEALED YOUR LOCATION':'CRIER REVEALED YOUR LAST LOCATION');   // v21.78: still names the Crier (v11.94, his note)
'@

SubRx @'
if(mine) say('A crier has you. Kill it or move.');
'@ @'
if(mine) say('A CRIER IS REVEALING YOUR LOCATION');
'@

SubRx @'
say(m.sees?'The Crier raised the alarm. They know exactly where you are.':'The Crier raised the alarm. They are heading to where it last saw you.');
'@ @'
say(m.sees?'CRIER REVEALED YOUR LOCATION':'CRIER REVEALED YOUR LAST LOCATION');
'@

SubRx @'
var VER='21.77';
'@ @'
var VER='21.78';
'@

$pat = "(?m)^  now:'v21\.77:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.78: Criers now say A CRIER IS REVEALING YOUR LOCATION, then CRIER REVEALED YOUR LOCATION. Check 21.78 fails on v21.77',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
