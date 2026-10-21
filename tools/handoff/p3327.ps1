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

# power-up pickups half size (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var PWRI={R:34,hover:44,bob:5,beam:340,
'@ @'
// v33.25 (cw-pwrhalf), HIS WORDS (2026-10-20): "powerups need to be like 50^ smaller". PWRK is the one size knob: the medallion, its glyph and rim, the glow round it, the ground glow, the spawn flash, the hover height, the bob and the beam width all take it. The reach ring (PWR.pick) and the beam height stay.
var PWRK=0.5;var PWRI={R:34*PWRK,hover:44*PWRK,bob:5*PWRK,beam:340,
'@

SubRx @'
s.x,s.y,PWR.pick*q*1.7); gr.addColorStop
'@ @'
s.x,s.y,PWR.pick*q*1.7*PWRK); gr.addColorStop
'@

SubRx @'
c.arc(s.x,s.y,PWR.pick*q*1.7,0,6.2832)
'@ @'
c.arc(s.x,s.y,PWR.pick*q*1.7*PWRK,0,6.2832)
'@

SubRx @'
PWR.pick*q*(0.4+2.2*u)
'@ @'
PWR.pick*q*PWRK*(0.4+2.2*u)
'@

SubRx @'
c.moveTo(s.x-14*q,s.y); c.lineTo(s.x-5*q,s.y-bl); c.lineTo(s.x+5*q,s.y-bl); c.lineTo(s.x+14*q,s.y);
'@ @'
c.moveTo(s.x-14*q*PWRK,s.y); c.lineTo(s.x-5*q*PWRK,s.y-bl); c.lineTo(s.x+5*q*PWRK,s.y-bl); c.lineTo(s.x+14*q*PWRK,s.y);
'@

SubRx @'
c.fillRect(s.x-1.6*q,s.y-bl*0.8,3.2*q,bl*0.8);
'@ @'
c.fillRect(s.x-1.6*q*PWRK,s.y-bl*0.8,3.2*q*PWRK,bl*0.8);
'@

SubRx @'
(9+7*u)*q;
'@ @'
(9+7*u)*q*PWRK;
'@

SubRx @'
var VER='33.26';
'@ @'
var VER='33.27';
'@

$pat = "(?m)^  now:'v33\.26:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.27: Power-up pickups are half the size. Picking them up works the same. Check 33.27 fails on v33.26',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
