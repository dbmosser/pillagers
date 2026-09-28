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

# KID MODE AT 1/20 NOW REALLY GIVES PLAYER 2 A TWENTIETH OF EVERY HIT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function kidMulOwn(){ var v=(typeof P!=='undefined'&&P)?+P.kidDmg:1; return (isFinite(v)&&v>=0.1&&v<=1)?v:1; }
function netKidMul(){ var h=(typeof NET.kidHost==='number'&&NET.kidHost>=0.1&&NET.kidHost<=1)?NET.kidHost:1; return Math.min(kidMulOwn(),h); }
'@ @'
var KID_MIN=KID_OPTS[KID_OPTS.length-1][0];   // v17.02, co-op hunt 2026-09-28: the floor is the smallest level in the row; a 0.1 floor read a saved or sent 1/20 as OFF
function kidMulOwn(){ var v=(typeof P!=='undefined'&&P)?+P.kidDmg:1; return (isFinite(v)&&v>=KID_MIN&&v<=1)?v:1; }
function netKidMul(){ var h=(typeof NET.kidHost==='number'&&NET.kidHost>=KID_MIN&&NET.kidHost<=1)?NET.kidHost:1; return Math.min(kidMulOwn(),h); }
'@

SubRx @'
  if(typeof m.kd==='number'&&isFinite(m.kd)) NET.kidHost=clamp(m.kd,0.1,1);   // v16.44: kid mode as the host has it
'@ @'
  if(typeof m.kd==='number'&&isFinite(m.kd)) NET.kidHost=clamp(m.kd,KID_MIN,1);   // v16.44: kid mode as the host has it; v17.02, co-op hunt 2026-09-28: down to 1/20, not 1/10
'@

SubRx @'
var VER='17.01';
'@ @'
var VER='17.02';
'@

$pat = "(?m)^  now:'v17\.01:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.02: Kid mode at 1/20 now works. The level added in v16.73 was saved as 0.05, but kidMulOwn, netKidMul and netWorldTake only took values from 0.1 to 1, so a saved or sent 1/20 read as OFF: the Settings row printed OFF, the next press went to 1/2, the host sent OFF to the party and player 2 took every hit at full strength. The floor is now the smallest level in KID_OPTS (KID_MIN), used in all three places, so 1/20 shows on the row, cycles on to OFF, is carried by the host word and takes a twentieth of each hit. Check 17.02 fails on v17.01',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
