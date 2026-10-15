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

# SUPPORT MG KEEPS ACCELERATING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var LMG_SPIN_T=0.75, LMG_SPIN_DOWN=0.6, LMG_SPIN_GO=0.2, LMG_SLOW=2.2, LMGSPIN={hum:null};
'@ @'
// v27.xx (feel2d), HIS WORDS (2026-10-14): "feels good but needs to increase fire rate once fully spinning". THE SUPPORT MG KEEPS ACCELERATING. The spin-up used to close the gap between rounds
// to the gun's own 105 ms and stop there; now it keeps closing: the gap runs from LMG_SLOW (2.2 times the gun's gap) at the start of the spin to 1 / LMG_FULL (1.3 times the rate, a gap of
// 81 ms) at full spin, in a straight line over the same wind-up (the gun's own rate is passed about four fifths of the way up), and it drops back down as the barrels wind down when you
// let go. THE SOUND RISES WITH THE RATE: the report of every round is played at a pitch (SND_PITCH, read by the shot voice) from about 0.82 at the start of the spin to 1.1 at full speed,
// the controller rumble grows with it, and the quiet whirr is unchanged. A balance change (a magazine of 60 is gone in 4.9 seconds, not 6.3), allowed since 2 October. Live play only
// (G.sim never spins), and nothing here draws from the seeded stream.
var LMG_SPIN_T=0.75, LMG_SPIN_DOWN=0.6, LMG_SPIN_GO=0.2, LMG_SLOW=2.2, LMG_FULL=1.3, LMGSPIN={hum:null}, SND_PITCH=1;
function lmgPitch(p){ var m; if(!G||G.sim||!lmgUp(p)) return 1; m=spinMul(p); return clamp(1+0.35*(1/m-1),0.82,1.14); }
function lmgOver(p){ var m; if(!G||G.sim||!lmgUp(p)) return 0; m=spinMul(p); return clamp((1/m-1)/(LMG_FULL-1),0,1); }
'@

SubRx @'
  return 1+(LMG_SLOW-1)*(1-s);
'@ @'
  return LMG_SLOW+(1/LMG_FULL-LMG_SLOW)*s;   // v27.xx (feel2d): and it keeps closing past the gun's own gap, to 1.3 times the rate at full spin
'@

SubRx @'
    var J=1+(Math.random()*2-1)*0.06, J2=1+(Math.random()*2-1)*0.06;
'@ @'
    var J=(1+(Math.random()*2-1)*0.06)*(SND_PITCH||1), J2=1+(Math.random()*2-1)*0.06;   // v27.xx (feel2d): the Support MG report rises with its rate
'@

SubRx @'
  if(fromPlayer) blipMine(melee?'hit':'shot',0,undefined,wep.id);   // v20.41 (H51): and the party hears it where you stand
'@ @'
  if(fromPlayer){ SND_PITCH=(!melee&&G&&!G.sim&&gunBase(wep.id)==='lmg')?lmgPitch(G.player):1; try{ blipMine(melee?'hit':'shot',0,undefined,wep.id); } finally { SND_PITCH=1; } }   // v20.41 (H51): and the party hears it where you stand   // v27.xx (feel2d): at the pitch of the spin
'@

SubRx @'
    padRumble(0.12,35);   // v17.37: a light tick per shot
'@ @'
    padRumble(0.12+0.12*lmgOver(G.player),35);   // v17.37: a light tick per shot   // v27.xx (feel2d): and the Support MG rumbles harder as it spins up
'@

SubRx @'
var VER='27.51';
'@ @'
var VER='27.52';
'@

$pat = "(?m)^  now:'v27\.51:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.52: The Support MG fires about 1.3 times faster once fully spinning, and its report rises in pitch with the rate. Check 27.52 fails on v27.51',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
