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

# THE FORGE: CRYO ROUNDS SLOW AND FREEZE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(ELEM_MACH[e.kind]&&!e.boss&&!(e.stunImm>0)){ e.stunT=(e.kind==='warden'||e.kind==='choir')?0.25:0.5; e.stunImm=e.stunT+2.5; }
  }
  return true;
}
'@ @'
    if(ELEM_MACH[e.kind]&&!e.boss&&!(e.stunImm>0)){ e.stunT=(e.kind==='warden'||e.kind==='choir')?0.25:0.5; e.stunImm=e.stunT+2.5; }
  } else if(el==='cryo'){
    // v23.xx, THE FORGE (2026-10-12), forge5: CRYO. Every hit chills the body for 2.5 s (it moves at 60 percent, in moveToward) and
    // adds cold by the size of the hit (d/25, between 0.35 and 3). At 6 cold the body freezes: 1.4 s rooted, silent and unable to fire
    // (a Warden or a Choir 0.7 s, the Overseer 0.6 s), then 4 s in which it cannot freeze again. Pillagers freeze too. The cold runs
    // off once the chill ends. Host or solo only; no draw on any stream.
    e.chill=(e.chill||0)+clamp(d/25,0.35,3); e.chillT=2.5;
    if(e.chill>=6-1e-6&&!(e.freezeImm>0)){
      e.frozenT=e.boss?0.6:((e.kind==='warden'||e.kind==='choir')?0.7:1.4);
      e.chill=0; e.freezeImm=e.frozenT+4; e.roll=0;
    }
  }
  return true;
}
'@

SubRx @'
    if(e.stunImm>0){ e.stunImm-=dt; if(e.stunImm<0) e.stunImm=0; }
'@ @'
    if(e.stunImm>0){ e.stunImm-=dt; if(e.stunImm<0) e.stunImm=0; }
    if(e.chillT>0){ e.chillT-=dt; if(e.chillT<=0){ e.chillT=0; e.chill=0; } }   // v23.xx (forge5): the cold runs off with the chill
    if(e.frozenT>0){ e.frozenT-=dt; if(e.frozenT<0) e.frozenT=0; }
    if(e.freezeImm>0){ e.freezeImm-=dt; if(e.freezeImm<0) e.freezeImm=0; }
'@

SubRx @'
  if(e.stunT>0){ e.moving=false; e.cd=Math.max(e.cd||0,0.35); return true; }
'@ @'
  if(e.stunT>0||e.frozenT>0){ e.moving=false; e.cd=Math.max(e.cd||0,0.35); return true; }   // v23.xx (forge4, forge5): stunned by shock or frozen by cryo: no sight, no move, no shot, as the overheat
'@

SubRx @'
  if(e!==G.player&&inWater(e.x,e.y)) spd*=.55;
'@ @'
  if(e!==G.player&&inWater(e.x,e.y)) spd*=.55;
  if(e!==G.player&&e.chillT>0) spd*=0.6;   // v23.xx (forge5): THE FORGE, a body chilled by cryo moves at 60 percent (every walker reaches here)
'@

SubRx @'
var VER='25.23';
'@ @'
var VER='25.24';
'@

$pat = "(?m)^  now:'v25\.23:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.24: Cryo rounds from a MK III gun slow enemies and freeze them after a few hits. Check 25.24 fails on v25.23',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
