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

# PILLAGERS KEEP COMING FOR PLAYER 2 (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function crewShout(caller,px,py){
  if(!G||!G.ents||G.over) return 0;
'@ @'
function crewShout(caller,px,py){
  // v20.37, from the whole-game bug hunt of 2026-10-08 (H10): the raid a host keeps running for his party after his own run is over
  // (netSpecStart) is live, so a pillager who spots player 2 still brings his crew. Any other raid that is over calls nobody.
  if(!G||!G.ents||(G.over&&!(typeof NET==='object'&&NET&&NET.specG===G))) return 0;
'@

SubRx @'
function tickRaiderWaves(dt){
  if(CFG.raiderWaves===0||!G||G.over||!G.roster) return;
'@ @'
function tickRaiderWaves(dt){
  if(CFG.raiderWaves===0||!G||(G.over&&!(typeof NET==='object'&&NET&&NET.specG===G))||!G.roster) return;   // v20.37 (H10): and on the raid kept for the party
'@

SubRx @'
    refreshVseg(); updateEnts(wdt); updateBullets(wdt); updateThrowables(wdt);
'@ @'
    refreshVseg(); updateEnts(wdt); updateBullets(wdt); updateThrowables(wdt);
    tickRaiderWaves(wdt);   // v20.37 (H10): new pillagers still arrive for the party; only a raid frame ran this, and that stops with the host run
'@

SubRx @'
var VER='20.36';
'@ @'
var VER='20.37';
'@

$pat = "(?m)^  now:'v20\.36:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.37: In co-op, after the host is out, pillager crews still answer a shout and new pillagers still arrive for player 2. Check 20.37 fails on v20.36',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
