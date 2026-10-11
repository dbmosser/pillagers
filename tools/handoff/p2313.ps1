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

# PARTY SUMMARY WRITES MONEY AS DOLLARS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
       '<span style="width:90px;text-align:right">'+(e?(e.v.toLocaleString()+'c'):'')+'</span></div>';
'@ @'
       '<span style="width:90px;text-align:right">'+(e?('$'+e.v.toLocaleString()):'')+'</span></div>';   // v23.xx (tr9fixn): money is Credits, written $1,234 (R48)
'@

SubRx @'
var VER='23.12';
'@ @'
var VER='23.13';
'@

$pat = "(?m)^  now:'v23\.12:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.13: The party summary on the run card writes each value as dollars. Check 23.13 fails on v23.12',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
