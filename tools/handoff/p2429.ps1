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

# DARKER, MOODIER NIGHTS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var DAY_SHEET=0.13, NIGHT_SHEET=0.30;

'@ @'
// v23.xx, HIS ANSWERS (2026-10-12), answer 39: "darker moodier nights". He asks for it now, after the earlier notes (v4.35, v5.54)
// that night was too dark to play: so the dark goes where he is not looking and the light stays where he is. The night sheet goes
// from 0.30 to 0.55 (the brightness dial divides it, and at its 1.7 default the sheet goes from .18 to .32), so the frame falls about
// 11% darker and the streets away from him and the lamps more; the lamps cut through the dark harder at night (0.95 of their
// strength, was 0.85), so they read as pools of light in a darker city; and his own lamp is a little stronger at night (0.62, was 0.5), so
// the ground at his feet stays readable. NIGHT_MOOD 0 is the old night. The brightness dial still lifts it for anyone who wants it lighter. Day is untouched.
var DAY_SHEET=0.13, NIGHT_SHEET=0.55, NIGHT_MOOD=1;

'@

SubRx @'
    gr.addColorStop(0,'rgba(0,0,0,'+(.85*L.i)+')');

'@ @'
    gr.addColorStop(0,'rgba(0,0,0,'+((NIGHT_MOOD&&!isDay())?Math.min(1,.95*L.i):(.85*L.i))+')');   // v23.xx (his answer 39): lamps cut harder at night

'@

SubRx @'
  pgr.addColorStop(0,'rgba(0,0,0,'+clamp(.5*BR,.3,.9)+')'); pgr.addColorStop(1,'rgba(0,0,0,0)');

'@ @'
  pgr.addColorStop(0,'rgba(0,0,0,'+clamp(((NIGHT_MOOD&&!isDay())?.62:.5)*BR,.3,.9)+')'); pgr.addColorStop(1,'rgba(0,0,0,0)');   // v23.xx (his answer 39): his own lamp keeps his feet readable

'@

SubRx @'
var VER='24.28';
'@ @'
var VER='24.29';
'@

$pat = "(?m)^  now:'v24\.28:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.29: Nights are darker away from you and the lamps, with brighter pools of lamplight; your own light is unchanged. Check 24.29 fails on v24.28',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
