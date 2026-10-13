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

# THE KIA CARD DOES NOT NAG (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    // v13.15, from his telemetry: three runs, two knock-downs each, medical
    // carried every time and applied zero times. The belt cell for it is built
    // automatically and the freebie kit issues two Bandages, so nothing was
    // stopping him; nothing had ever said so either. Only when it is true.
    if(T.diedWithMed)
      s.textContent+='   \u00b7   YOU DIED CARRYING MEDICAL YOU NEVER USED';
'@ @'
    // nomednag, HIS NOTE (2026-10-12) on the KIA card: "soooo random, why is that where it is". The v13.15 unused medical hint
    // that was bolted onto the end of this line is gone: a death card states what killed you and does not nag. The flag
    // (G.tel.diedWithMed) is still recorded at death for the run report and the telemetry export line (unusedMed:1).
'@

SubRx @'
var VER='24.91';
'@ @'
var VER='24.92';
'@

$pat = "(?m)^  now:'v24\.91:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.92: The KIA card no longer tells you that you died carrying medical you never used. Check 24.92 fails on v24.91',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
