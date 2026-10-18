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

# CONTROLS LIST FOLDS AWAY AFTER 30 SECONDS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function elapsed(){

'@ @'
// v28.xx (cw-legend30), UI step 4, the HUD in play (style guide: the controls list is hidden except on F1 and in the first 30 seconds).
// The list opens on arrival (his v6.68 note: always open on arrival) and, once, at 30 seconds into the raid, folds to the one-line
// hint if it is still the compact list. F1 still cycles it, and a list he opens again later is left alone.
function legendAuto(sec){
  if(!G||G.legendAutoDone||sec<30) return false;
  G.legendAutoDone=true;
  if(G.legendOn===1){ G.legendOn=0; return true; }
  return false;
}
function elapsed(){

'@

SubRx @'
    if(FEEDBOX.on&&G.legendOn===1){

'@ @'
    legendAuto(elapsed());   // v28.xx (cw-legend30): the compact controls list folds away 30 seconds in
    if(FEEDBOX.on&&G.legendOn===1){

'@

SubRx @'
var VER='29.28';
'@ @'
var VER='29.29';
'@

$pat = "(?m)^  now:'v29\.28:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.29: The controls list folds to its one-line hint 30 seconds into a raid. F1 opens it again. Check 29.29 fails on v29.28',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
