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

SubRx @'
// rof is rounds per minute in WEAPONS, spread is radians, rng is world units and
'@ @'
// rof is MILLISECONDS between shots in WEAPONS (the trigger fires when now-lastShot>rof), spread is radians, rng is world units and
'@
SubRx @'
    if(W2.auto&&W2.mag) dmgTxt+='   ~'+Math.round(perShot*(W2.rof/60))+'/sec held';
'@ @'
    // v14.96, unit audit finding 1: THE RATE IS THE GAP BETWEEN SHOTS TURNED INTO SHOTS. rof was printed as if it were rounds per
    // minute, so the hover showed a faster gun as slower and the Whisper, the slowest, as the fastest: 520 rpm and 121 a second
    // held, against about 115 rpm. The rate and the damage a second now come from the gap.
    if(W2.auto&&W2.mag) dmgTxt+='   ~'+Math.round(perShot*(1000/W2.rof))+'/sec held';
'@
SubRx @'
    R.push(['RATE',Math.round(W2.rof)+' rpm'+(W2.auto?'   automatic':'   semi')]);
'@ @'
    R.push(['RATE',Math.round(60000/W2.rof)+' rpm'+(W2.auto?'   automatic':'   semi')]);
'@
SubRx @'
var VER='14.95';
'@ @'
var VER='14.96';
'@

$pat = "(?m)^  now:'v14\.95:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.96: THE GUN HOVER PRINTS ITS REAL RATE OF FIRE. The time between shots, in milliseconds, was printed as rounds per minute, so the fastest guns read slowest and the slowest read fastest, and the damage a second held was wrong by up to eight times. The rate and damage a second now come from the gap. Check 14.96 compares the hover of the fastest and slowest guns; it fails on v14.95',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
