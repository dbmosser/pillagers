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

# BREACH LABEL CLEARS THE PLAYERS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      ls=w2s(gp.x+s.nx*70,0,gp.y+s.ny*70);
'@ @'
      // v28.xx (cw-cx-breachclear): the critic found the outside label over the pillagers at the gate. Put it inside the doorway, opposite the players holding search.
      ls=w2s(gp.x-s.nx*70,0,gp.y-s.ny*70);
'@

SubRx @'
var VER='36.15';
'@ @'
var VER='36.16';
'@

$pat = "(?m)^  now:'v36\.15:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.16: the breach gate says which key to hold, clear of the players Check 36.16 fails on v36.15',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
