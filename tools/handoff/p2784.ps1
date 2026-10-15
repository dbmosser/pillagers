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

# HIT STOP CANNOT STUN LOCK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var HITSTOP_DMG=40, HITSTOP_T=0.06, LANCE_KICK_V=190, LANCE_KICK_T=0.12;
'@ @'
// v27.xx (feel2h), a cloud review finding (2026-10-15, #16): HIT-STOP CAN NO LONGER STUN-LOCK A BODY. hitStopOn reads the round's FINAL damage, after DOUBLE DAMAGE, the active reload bonus
// and the rest, so with DOUBLE DAMAGE an Auto Rifle round (23) is 46 and stops the body for HITSTOP_T, and with RAPID FIRE too (66 ms between rounds) the body was held about nine
// frames in ten: any body that was not a boss, the golden enemy and wardens included, froze in place. A body that has just been stopped is now immune to the next stop for HITSTOP_IMM
// seconds (the same shape as the shock stun immunity, stunImm), so the most a stream of rounds can hold it is HITSTOP_T of every HITSTOP_IMM, a fifth of the time. One heavy round is still
// stopped for the same beat. Live play only, no seeded draw.
var HITSTOP_DMG=40, HITSTOP_T=0.06, HITSTOP_IMM=0.30, LANCE_KICK_V=190, LANCE_KICK_T=0.12;
'@

SubRx @'
  e.stopT=HITSTOP_T; G.elemAny=1;
'@ @'
  if(e.stopImm>0) return false;   // v27.xx (feel2h): just stopped: not again for HITSTOP_IMM
  e.stopT=HITSTOP_T; e.stopImm=HITSTOP_IMM; G.elemAny=1;
'@

SubRx @'
    if(e.stopT>0){ e.stopT-=dt; if(e.stopT<0) e.stopT=0; }   // v26.xx (feel10): the hit-stop clock
'@ @'
    if(e.stopT>0){ e.stopT-=dt; if(e.stopT<0) e.stopT=0; }   // v26.xx (feel10): the hit-stop clock
    if(e.stopImm>0){ e.stopImm-=dt; if(e.stopImm<0) e.stopImm=0; }   // v27.xx (feel2h): and its immunity
'@

SubRx @'
var VER='27.83';
'@ @'
var VER='27.84';
'@

$pat = "(?m)^  now:'v27\.83:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.84: A stream of heavy rounds can hold a body frozen for at most a fifth of the time, and one heavy round still stops it for a beat. Check 27.84 fails on v27.83',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
