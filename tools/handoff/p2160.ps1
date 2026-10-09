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

# THE PILLBOX IS GENTLER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var CHOIR_HP=1250, CHOIR_RNG=520;
'@ @'
// v21.60, HIS NOTE (2026-10-09): "pillbox should deal less damage and/or fire slower -- also should have less health". Health 1250 to 850,
// a shot 22 to 17, and a shot every 0.60 to 0.90 s instead of 0.42 to 0.66: about 23 damage a second where it was about 40. The
// stand-off band is unchanged (range 520), and the one cadence draw stays one draw, so the seeded stream does not move.
var CHOIR_HP=850, CHOIR_RNG=520;
'@

SubRx @'
    cd:0,alert:0,spd:0,dmg:22,rng:CHOIR_RNG,cone:6.2832,
'@ @'
    cd:0,alert:0,spd:0,dmg:17,rng:CHOIR_RNG,cone:6.2832,   // v21.60: 22 to 17, his note
'@

SubRx @'
          e.cd=rnd(0.42,0.66);
'@ @'
          e.cd=rnd(0.60,0.90);   // v21.60, his note: fires slower (was 0.42 to 0.66)
'@

SubRx @'
var VER='21.59';
'@ @'
var VER='21.60';
'@

$pat = "(?m)^  now:'v21\.59:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.60: The pillbox hits softer, fires slower and goes down faster. Check 21.60 fails on v21.59',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
