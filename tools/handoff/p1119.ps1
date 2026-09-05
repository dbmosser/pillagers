$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# NOTHING IN THE GAME CHANGES IN THIS BUILD. It carries the measurement the
# last seven builds each left unverified, and its version stamps.
SubRx @'
var VER='11.18';
'@ @'
var VER='11.19';
'@
SubRx @'
var WHATSNEW_VER='11.18';
'@ @'
var WHATSNEW_VER='11.19';
'@
SubRx @'
  'NO INTERIOR WALL ENDS INSIDE A DOORWAY.
'@ @'
  'NOTHING IN THE GAME CHANGED IN THIS BUILD. It measures what the last seven did: with the machines now able to get out of buildings, the test robot was run through the same sixty raids on the old rules and the new, and the difference is written in the notes rather than guessed at.',
  'NO INTERIOR WALL ENDS INSIDE A DOORWAY.
'@
SubRx @'
  now:'v11.18: no interior wall ends inside a doorway. Measured on v11.17 at seed 4242: 3 doors on COLD STORAGE and 19 on THE COLD MILE opened onto the end of a partition, and 4 of the mile\'s left under 30 units either side of it, so nothing 30 wide could use the door. Every partition reaching into a door\'s zone has that part cut away. No random number is drawn.',
'@ @'
  now:'v11.19: the measurement the last seven builds owed. Sixty seeded robot raids on COLD STORAGE, each run twice, once with every building rule since v11.12 switched off and once with them on, so the extract rate difference of machines that can get out of buildings is a number and not a direction. Nothing in the game changed.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
