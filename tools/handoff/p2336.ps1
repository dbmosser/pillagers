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

# ARCADE: OVERSEER SCORES 2,000 FOR PLAYER 2 (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(G.arcade) arcadeKill(k,!!(m.el||(e&&e.elite)),!!(e&&e.boss));   // v23.29 (arcade8): the arcade score of player 2
'@ @'
  // v23.36 (arcmidfixa), review of arcade builds 7 to 13: AN OVERSEER KILL BY PLAYER 2 SCORED 400, NOT 2,000. The body here is a mirror
  // made by netEntMake/netEntFill, which never set boss, so player 2 scored the Overseer as a plain warden. A mirror is known as the
  // boss by its name, as every other mirror site does (name===BOSS_NAME). The kill word itself is unchanged.
  if(G.arcade) arcadeKill(k,!!(m.el||(e&&e.elite)),!!(e&&(e.boss||e.name===BOSS_NAME)));   // v23.29 (arcade8): the arcade score of player 2
'@

SubRx @'
var VER='23.35';
'@ @'
var VER='23.36';
'@

$pat = "(?m)^  now:'v23\.35:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.36: In the arcade the Overseer scores 2,000 for player 2 as it does for the host. Check 23.36 fails on v23.35',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
