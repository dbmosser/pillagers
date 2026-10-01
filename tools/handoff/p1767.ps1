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

# SITTING A RAID OUT LASTS FOR THAT RAID ONLY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  NET.upWord=m;   // v17.46: his pick 3, kept for a teammate who joins late
'@ @'
  NET.upWord=m;   // v17.46: his pick 3, kept for a teammate who joins late
  NET.lateOut={};   // v17.67: a new raid, nobody sits it out yet
'@

SubRx @'
  if(typeof m.seed==='number') NET.hostSeed=m.seed>>>0;   // v17.46: his pick 3, the host is up on this seed
'@ @'
  if(typeof m.seed==='number') NET.hostSeed=m.seed>>>0;   // v17.46: his pick 3, the host is up on this seed
  if(!m.late) NET.lateBan=0;   // v17.67: a new raid from the host; a death in the last one does not keep him out of this one
'@

SubRx @'
var VER='17.66';
'@ @'
var VER='17.67';
'@

$pat = "(?m)^  now:'v17\.66:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.67: A teammate who sat a raid out after dying or extracting can always go up with the party on the next raid. Check 17.67 fails on v17.66',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
