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

# SCORE PLATE AT THE TOP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  ctx.font=fs; ctx.fillStyle=UIC.tx_2; hudText(solo?'SCORE':'TEAM SCORE',cx,Math.round(yL-h*0.80));   // v23.54 (arcade30): SCORE in the 1 player arcade; v28.xx (cw-scoretop): the label is quiet grey (amber is for a warning), the number is the hero
'@ @'
  // v28.xx (cw-scoreplate), the critic (2026-10-19): "the score cluster has no plate". One plate (the HUD plate, 78 percent) hangs from the top edge behind the label, the number and the clock, so the numbers read on any floor; it is as wide as the number plus the streak and the teammate score beside it.
  var _sx0=arcadeStreakLive(), _cl0=raidClockOn(), _fin0=(_cl0&&Math.ceil(Math.max(0,+G.timeLeft||0))<=CLOCK_RED), _pw0, _ph0;
  ctx.font=fb; _pw0=Math.max(Math.round(80*z),Math.round(ctx.measureText(nm).width/2+22*z+(solo?0:100*z)+(_sx0>1?40*z:0))); _ph0=Math.round(y+h*(_cl0?(_fin0?1.42:1.22):0.35));
  hudPlate(cx-_pw0,-Math.round(8*z),_pw0*2,_ph0+Math.round(8*z),null,HUDC.plate);
  ctx.font=fs; ctx.fillStyle=UIC.tx_2; hudText(solo?'SCORE':'TEAM SCORE',cx,Math.round(yL-h*0.80));   // v23.54 (arcade30): SCORE in the 1 player arcade; v28.xx (cw-scoretop): the label is quiet grey (amber is for a warning), the number is the hero
'@

SubRx @'
var VER='30.95';
'@ @'
var VER='30.96';
'@

$pat = "(?m)^  now:'v30\.95:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.96: The score, label and clock sit on one plate hung from the top edge. Check 30.96 fails on v30.95',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
