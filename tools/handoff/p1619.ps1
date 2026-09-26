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

# HIS WORDS: EXTRACTION PROGRESS BAR RESET (2026-09-26), replacing v16.18. Text only.

SubRx @'
      say('Knocked down. Extraction attempt reset. Hold E to try again.');   // v16.17, his note: extraction hold meant nothing to him; v16.18: his words, Extraction attempt reset
'@ @'
      say('Knocked down. Extraction progress bar reset. Hold E to try again.');   // v16.17, his note: extraction hold meant nothing to him; v16.19: his words, Extraction progress bar reset
'@

SubRx @'
var VER='16.18';
'@ @'
var VER='16.19';
'@

$pat = "(?m)^  now:'v16\.18:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.19: HIS WORDS: EXTRACTION PROGRESS BAR RESET. Knocked down while holding E to extract now says Knocked down. Extraction progress bar reset. Hold E to try again. Text only. Check 16.19 fails on v16.18',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
