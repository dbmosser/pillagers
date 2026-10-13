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

# DEMO EXTRACTION WAITS AS LONG AS CAREER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var ARCADE_CFG={raidSec:0,extractWait:15};
'@ @'
// v25.xx (demoextract), HIS QUESTION (2026-10-13): "demo mode -- why does the extraction prep countdown take less time? I want default
// gameplay to be exactly the same". The overlay below also set the extraction call to 15 seconds, while a CAREER raid (and a normal raid)
// waits the extractWait dial, 30 by default, so a DEMO ship arrived in half the time. His rule of 2026-10-12: gameplay is EXACTLY THE SAME
// in DEMO and CAREER. The overlay no longer touches the call: a DEMO call waits the dial, as a CAREER call does (and a dial moved in
// Settings applies to both). The raid clock dial stays as it was.
var ARCADE_CFG={raidSec:0};
'@

SubRx @'
var VER='25.81';
'@ @'
var VER='25.82';
'@

$pat = "(?m)^  now:'v25\.81:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.82: A demo extraction call now waits as long as a career one. Check 25.82 fails on v25.81',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
