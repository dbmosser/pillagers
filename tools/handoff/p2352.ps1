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

# ARCADE: WAVES FOLLOW THE RAID OWNER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function arcadeWaveTick(dt){
  if(!G||!G.arcade||G.over||G.sim||!G.map||!Array.isArray(G.ents)) return 0;
  if(ARCADE.role==='p2'||netEntsPeer()) return 0;
'@ @'
// v23.52, HIS YES (2026-10-11) to the five recommendations, arcade28 (a low finding of the arcade 14-25 review): WAVES FOLLOW THE RAID
// OWNER. When the host window leaves mid-run, player 2 takes the raid over (G.netWasJoin, his 2026-10-02 ruling), but the waves
// stopped for good, because this tick returned on the p2 role. Now the run authority runs them: the host, or the player 2 that took
// the raid over (the same rule as arcadeBoardAuth). A player 2 still sharing the host world never spawns waves. Only an arcade run
// reaches any of it.
function arcadeWaveTick(dt){
  if(!G||!G.arcade||G.over||G.sim||!G.map||!Array.isArray(G.ents)) return 0;
  if((ARCADE.role==='p2'&&!G.netWasJoin)||netEntsPeer()) return 0;   // v23.52 (arcade28): a player 2 that took the raid over runs the waves
'@

SubRx @'
var VER='23.51';
'@ @'
var VER='23.52';
'@

$pat = "(?m)^  now:'v23\.51:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.52: In the arcade the enemy waves keep coming after player 2 takes over a raid the host left. Check 23.52 fails on v23.51',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
