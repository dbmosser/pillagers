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

# ABANDON QUESTION HIDES THE PAGE TOAST (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #root .ocloss ~ .octiles{ margin:-16px 0 32px; }
'@ @'
  #root .ocloss ~ .octiles{ margin:-8px 0 32px; }
  /* v34.xx (cw-endcards3), the critic on 59 (3 of 5, P1, twice): "the running slowly toast stays bright over the 80 percent scrim, the brightest thing on screen after the card". The page toast (#hubtoast, not the canvas feed) waits while the abandon question is up. Tiles 24px under the hero label (was 16). */
  body:has(#pausebox.asking) #hubtoast{ visibility:hidden; }
'@

SubRx @'
var VER='34.32';
'@ @'
var VER='34.33';
'@

$pat = "(?m)^  now:'v34\.32:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.33: The abandon question no longer has a toast shining over it. Check 34.33 fails on v34.32',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
