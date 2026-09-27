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

# EVERY RUN REPORT SAYS WHICH WINDOW IT CAME FROM (telemetry for his co-op session on this PC, 2026-09-27).

SubRx @'
  L.push('Install: '+installId()+'   Origin: '+location.hostname+'   Shared: '+(shareOn()?'yes':'no'));
'@ @'
  L.push('Install: '+installId()+'   Origin: '+location.hostname+'   Shared: '+(shareOn()?'yes':'no'));
  // v16.60, his order: he plays co-op in two windows on this PC so the run reports can be read straight off it. Both windows
  // write reports, so each says which window and which party it came from.
  L.push('Window: '+(NETP2?'player 2 (the second window, its own save)':'player 1')+'   Party: '+((typeof NET==='object'&&NET&&NET.on)?((NET.same?'same machine, ':'')+(NET.role==='host'?'host':'guest')):'none'));
'@

SubRx @'
var VER='16.59';
'@ @'
var VER='16.60';
'@

$pat = "(?m)^  now:'v16\.59:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.60: EVERY RUN REPORT SAYS WHICH WINDOW IT CAME FROM. He plays co-op in two windows on this PC so the run reports can be read straight off it. Both windows write a report at the end of every raid, and the two looked alike; each now says player 1 or player 2 and its place in the party. Check 16.60 fails on v16.59',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
