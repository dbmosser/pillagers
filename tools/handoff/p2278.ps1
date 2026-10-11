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

# HOLDING A KEY NEVER REPEATS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(z&&wantCall&&!z.open){
    G.extSay=(G.extSay||0)-dt;
    if(G.extSay<=0){
      G.extSay=2.5;
'@ @'
  // v22.78, the raid text rewrite (R33): HOLDING A KEY NEVER REPEATS A LINE. E held in a closed ring said the closed line and
  // played its clank again every 2.5 s, three lines and three clanks in six seconds for one fact the ring badge already shows.
  // It is said once per visit now: G.closedSaid remembers the ring until he stands outside it (z is the ring he stands in).
  if(G.closedSaid&&G.closedSaid!==z) G.closedSaid=null;
  if(z&&wantCall&&!z.open){
    if(G.closedSaid!==z){
      G.closedSaid=z;
'@

SubRx @'
var VER='22.77';
'@ @'
var VER='22.78';
'@

$pat = "(?m)^  now:'v22\.77:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.78: Holding E in a closed extraction ring says it is closed once per visit instead of every few seconds. Check 22.78 fails on v22.77',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
