$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# COMBAT AND PLAYER STATE AUDIT OF 2026-09-14, finding 1: A GUN DROPPED AND PICKED UP AGAIN CAME
# BACK WITH HALF A MAGAZINE, AS OFTEN AS YOU LIKED. Since v12.42 a gun put in the backpack keeps
# its load (stowRounds), and equipping it from the backpack takes that load back (takeRounds).
# But dropping it leaves a crate, and picking it up from the crate goes through grantLoot, which
# auto-equips a better gun with half a magazine and never reads the stored load. Empty a Burst
# Carbine, bag it, drop it, pick it up: twelve fresh rounds, every time, with no reserve spent.
# A gun picked up from a crate you dropped now comes back with what it had.
SubRx @'
        p.sec=found; p.secAmmo=Math.ceil(found.mag/2); p.secIssued=false; p.secFromArmory=false;
'@ @'
        // v13.81, combat audit: a gun from a crate you dropped comes back with its own load (v12.42), not half a magazine.
        p.sec=found; p.secAmmo=(ct&&ct.dropped)?takeRounds(found.id,found.mag):Math.ceil(found.mag/2); p.secIssued=false; p.secFromArmory=false;
'@
SubRx @'
        p.wep=found; p.ammo=Math.ceil(p.wep.mag/2); p.wepIssued=false; p.wepFromArmory=false;
'@ @'
        p.wep=found; p.ammo=(ct&&ct.dropped)?takeRounds(found.id,found.mag):Math.ceil(p.wep.mag/2); p.wepIssued=false; p.wepFromArmory=false;   // v13.81
'@
SubRx @'
var VER='13.80';
'@ @'
var VER='13.81';
'@

$pat = "(?m)^  now:'v13\.80:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.81: A DROPPED GUN COMES BACK WITH ITS OWN ROUNDS. Combat and player state audit of 2026-09-14, finding 1: a gun put in the backpack keeps its load and takes it back when equipped from the backpack, but dropped and picked up from the crate it went through grantLoot, which auto-equips with half a magazine and never read the stored load, so empty, bag, drop and pick up gave twelve free Burst Carbine rounds every loop. A gun auto-equipped from a crate you dropped now takes its stored load. Check 13.81 empties, bags, drops and picks up a carbine and requires no rounds created, with a carbine found in an ordinary crate still arriving with half a magazine as the control; it fails on v13.80',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
