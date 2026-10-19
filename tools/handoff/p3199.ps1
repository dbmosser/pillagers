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

# STEADY PAD TRIGGERS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var rtOn=!G.over&&!G.paused&&!G.mapOpen&&!G.bagOpen&&trig(7)>0.35;   // v16.72, his order: RT fires or uses the selected item, as a mouse click does
'@ @'
  // v28.xx (cw-cx-triggerhyst): J9: RT and LT turn on above 0.35 and off below 0.25.
  PAD.rtHeld=PAD.rtHeld?trig(7)>=0.25:trig(7)>0.35;
  PAD.ltHeld=PAD.ltHeld?trig(6)>=0.25:trig(6)>0.35;
  var rtOn=!G.over&&!G.paused&&!G.mapOpen&&!G.bagOpen&&PAD.rtHeld;
'@

SubRx @'
  PAD.adsAim=!!(trig(6)>0.35&&!G.over&&!G.paused);
'@ @'
  PAD.adsAim=!!(PAD.ltHeld&&!G.over&&!G.paused); // v28.xx (cw-cx-triggerhyst): focus uses the same hysteresis as fire.
'@

SubRx @'
function padRelease(){
'@ @'
function padRelease(){
  // v28.xx (cw-cx-triggerhyst): forget trigger travel when a menu or pad loss releases owned inputs.
  PAD.rtHeld=false; PAD.ltHeld=false;
'@

SubRx @'
var VER='31.98';
'@ @'
var VER='31.99';
'@

$pat = "(?m)^  now:'v31\.98:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.99: RT and LT press above 0.35 and release below 0.25, holding steady between those points. Check 31.99 fails on v31.98',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
