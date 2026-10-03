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

# THE SECTOR ROWS HOLD THEIR MAPS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
h+='<div class="row sectorpick" data-map="'+i+'" style="display:block;cursor:pointer;'+
'@ @'
h+='<div class="row sectorpick" data-map="'+i+'" style="display:block;overflow:hidden;cursor:pointer;'+
'@

SubRx @'
c.font='bold 9px Rubik, system-ui, sans-serif';
'@ @'
c.font='bold 11px Rubik, system-ui, sans-serif';
'@

SubRx @'
var VER='17.81';
'@ @'
var VER='17.82';
'@

$pat = "(?m)^  now:'v17\.81:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.82: The sector page rows now hold their maps properly, with clearer zone names. Check 17.82 fails on v17.81',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
