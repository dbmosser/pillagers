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

# BULWARK WRECK MATCHES THE BIG BODY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawWreckBulwark(ct){
  var P=MBPAL, fl=grit(ct.x,ct.y)>.5?1:-1, o=!!ct.opened, i;
  wc.save(); wc.translate(ct.x,ct.y-1); wc.scale(fl,1);
'@ @'
// v28.xx (cw-bulwarkwreck), HIS NOTES (2026-10-25): "Player too big vs the bulwark which is too small". The live bulwark is drawn FIG_MACH*BULWARK_BIG times bigger; its wreck is drawn the same, so the corpse is as big as the machine was.
function wreckBulwarkK(){ return FIG_MACH*BULWARK_BIG; }
function drawWreckBulwark(ct){
  var P=MBPAL, fl=grit(ct.x,ct.y)>.5?1:-1, o=!!ct.opened, i, wk=wreckBulwarkK();
  wc.save(); wc.translate(ct.x,ct.y-1); wc.scale(fl*wk,wk);
'@

SubRx @'
var VER='34.98';
'@ @'
var VER='34.99';
'@

$pat = "(?m)^  now:'v34\.98:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.99: A dead bulwark leaves a wreck as big as the machine was. Check 34.99 fails on v34.98',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
