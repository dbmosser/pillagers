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

# ARCADE LOOT IS HOLD E AGAIN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(near&&(keys['KeyX']||(keys['KeyE']&&!onPad)||arcadeAutoSrch(near))){
'@ @'
  // v23.xx, HIS ORDER (2026-10-11 evening): "i dont like the autoloot, change it back to hold E to loot". The arcade searches by holding
  // E (or X, or the pad search button) like every other raid again, at the usual speed; arcadeAutoSrch stays for the tests but is not asked.
  if(near&&(keys['KeyX']||(keys['KeyE']&&!onPad))){
'@

SubRx @'
var ARCADE_SRCH=6, ARCADE_LOOT_DIV=10;
'@ @'
var ARCADE_SRCH=1, ARCADE_LOOT_DIV=10;   // v23.xx: his order, hold E to loot at the usual speed (was 6, walk-over loot)
'@

SubRx @'
    ['EXTRACT','HOLD '+kn('KeyE')+' IN A TEAL RING','HOLD '+padB('X')+' IN A TEAL RING']];
'@ @'
    ['EXTRACT','HOLD '+kn('KeyE')+' IN A TEAL RING','HOLD '+padB('X')+' IN A TEAL RING'],['LOOT','HOLD '+kn('KeyE'),'HOLD '+padB('X')]];   // v23.xx: hold E to loot, so the card says so
'@

SubRx @'
var VER='23.54';
'@ @'
var VER='23.55';
'@

$pat = "(?m)^  now:'v23\.54:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.55: Arcade looting is hold E again, like every other raid, and the controls card shows it. Check 23.55 fails on v23.54',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
