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

# THE SIREN SAYS LOCKED ON (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  MSIREN.n=n;
'@ @'
  MSIREN.n=n;
  // lean7, HIS WORDS (2026-10-15): "there is a siren noise i hear some time but i don't know what it means". It is this one, the lock-on siren: a machine has had its
  // eyes on you for 0.6 s. It says so now, once, the moment the lock-on starts (and again when a fresh lock-on starts after the 5 s cool-off), as a terse caps alert
  // that is also a feed line. The extraction low alarm already comes with EXTRACTION CALLED.
  if(!MSIREN.said){ MSIREN.said=1; try{ say('LOCKED ON','warn',{key:'msiren',sub:'MACHINE HAS YOU IN SIGHT'}); }catch(_lo){} }
'@

SubRx @'
  if(!n){ if(MSIREN.v||MSIREN.on) machSirenOff(); return true; }
'@ @'
  if(!n){ MSIREN.said=0; if(MSIREN.v||MSIREN.on) machSirenOff(); return true; }
'@

SubRx @'
var VER='28.72';
'@ @'
var VER='28.73';
'@

$pat = "(?m)^  now:'v28\.72:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.73: The lock-on siren now flashes LOCKED ON so you know what it means. Check 28.73 fails on v28.72',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
