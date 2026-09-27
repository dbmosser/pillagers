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

# QUIETER CLOCK ALARMS, AND INBOUND. His notes of 2026-09-27.

SubRx @'
      cwo.type='square';
      cwo.frequency.setValueAtTime(520,cwt); cwo.frequency.exponentialRampToValueAtTime(1040,cwt+.24);
'@ @'
      cwo.type='triangle';   // v16.30, his note: the clock alarms were far too loud; a softer tone at a third of the level
      cwo.frequency.setValueAtTime(520,cwt); cwo.frequency.exponentialRampToValueAtTime(1040,cwt+.24);
'@

SubRx @'
      cwg.gain.setValueAtTime(.12*vol,cwt); cwg.gain.setValueAtTime(.12*vol,cwt+.2);
'@ @'
      cwg.gain.setValueAtTime(.04*vol,cwt); cwg.gain.setValueAtTime(.04*vol,cwt+.2);
'@

SubRx @'
    ckg.gain.setValueAtTime(.09*vol,t); ckg.gain.exponentialRampToValueAtTime(.001,t+.09);
'@ @'
    ckg.gain.setValueAtTime(.03*vol,t); ckg.gain.exponentialRampToValueAtTime(.001,t+.09);   // v16.30: a third of the level
'@

SubRx @'
    ctx.fillText(holding?extractNowLine(_exL,G.shipHold):('EXTRACT '+_exL+' INCOMING  '+Math.ceil(G.beaconT)+'s'),W/2,_exBan);
'@ @'
    ctx.fillText(holding?extractNowLine(_exL,G.shipHold):('EXTRACT '+_exL+' INBOUND  '+Math.ceil(G.beaconT)+'s'),W/2,_exBan);   // v16.30, his word: inbound
'@

SubRx @'
var VER='16.29';
'@ @'
var VER='16.30';
'@

$pat = "(?m)^  now:'v16\.29:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.30: QUIETER CLOCK ALARMS, AND INBOUND. His notes. The raid clock warnings (5 minutes left and the rest) play a softer tone at a third of the old level, and the last ten seconds tick at a third too. The extraction banner says INBOUND, not INCOMING. No game number moved. Check 16.30 fails on v16.29',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
