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

# THE CONTROLS LIST NAMES F9 (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  ['ALSO',[['CAPS','walk on, hands free'],['NUM + -','zoom'],['- =','HUD size'],['0','reset zoom']]]
'@ @'
  ['ALSO',[['CAPS','walk on, hands free'],['NUM + -','zoom'],['- =','HUD size'],['0','reset zoom'],['F9','record your play for the title']]]   // v21.56: the recorder (v21.18) was named only on the what is new card
'@

SubRx @'
var VER='21.55';
'@ @'
var VER='21.56';
'@

$pat = "(?m)^  now:'v21\.55:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.56: The full controls list now shows F9 to record your play for the title. Check 21.56 fails on v21.55',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
