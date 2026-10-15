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

# PLAYER 2 KILLS COUNT TOO (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  try{ contractKill(k); }catch(_ck){}
'@ @'
  try{ contractKill(k); }catch(_ck){}
  if(e){ try{ gunKillNote(e); }catch(_gkn2){} try{ trophyKill(e); }catch(_tk2){} }   // v26.xx (career10): cloud review 24: player 2 kill tally and trophies count on his own window too
'@

SubRx @'
var VER='27.33';
'@ @'
var VER='27.34';
'@

$pat = "(?m)^  now:'v27\.33:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.34: Player 2 kills now count for his gun tally and his trophies. Check 27.34 fails on v27.33',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
