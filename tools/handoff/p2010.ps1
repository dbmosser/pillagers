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

# THE GUN ARM FOLLOWS THE BUILD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  wc.fillStyle=coat; wc.fillRect(1+ext,-2.4,6,4.8);
'@ @'
  wc.fillStyle=coat; if(_BLD==='broad') wc.fillRect(1+ext,-2.9,6,5.8); else if(_BLD==='curved') wc.fillRect(1+ext,-2.0,6,4.0); else wc.fillRect(1+ext,-2.4,6,4.8);   // v20.10: a thicker arm on Broad, a slimmer one on Curved
'@

SubRx @'
var VER='20.09';
'@ @'
var VER='20.10';
'@

$pat = "(?m)^  now:'v20\.09:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.10: Broad has a thicker gun arm and Curved a slimmer one. Check 20.10 fails on v20.09',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
