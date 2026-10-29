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

# LANCE RELOAD TAIL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    var lp=a.createBiquadFilter(); lp.type='lowpass'; lp.frequency.value=3200;
'@ @'
    // v28.xx (cw-cx-lancetail), HIS WORDS (2026-10-28): "some sort of reverb sound that goes wayyy too long" on the Lance reload.
    // v28.xx (cw-cx-lancetail): Web Audio lowpass Q is in dB. The default +1 dB creates a peak exceeding unity in a vault feedback loop.
    // v28.xx (cw-cx-lancetail): -3.0103 dB is Butterworth, with no resonant boost, so the room decays after the charge cuts.
    var lp=a.createBiquadFilter(); lp.type='lowpass'; lp.frequency.value=3200; lp.Q.value=-3.0103;
'@

SubRx @'
return {wet:0.62,damp:1400,fb:0.86,n:'vault'};
'@ @'
return {wet:0.62,damp:1400,fb:0.80,n:'vault'}; /* v28.xx (cw-cx-lancetail): keep the enclosed wet sound; its tail now decays below .001 within 1.5 seconds. */
'@

SubRx @'
var VER='36.31';
'@ @'
var VER='36.32';
'@

$pat = "(?m)^  now:'v36\.31:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.32: the Lance no longer rings on after a reload Check 36.32 fails on v36.31',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
