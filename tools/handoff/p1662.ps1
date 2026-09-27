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

# PLAYER 2 CANNOT REVIVE A PILLAGER THE HOST RUNS (co-op review 2026-09-27).

SubRx @'
    if(DE.kind==='raider'&&DE.downed&&dist(p,DE)<64){ downRdr=DE; break; }
'@ @'
    // v16.62, stability (co-op hunt): a body on a linked window is a copy of one the host runs (net). Picking it up happened on
    // that window alone: the child was paid the gun in the man's hands (so it existed twice), his standing and revive tally
    // went up and were saved, and the next word from the host put the man back down. Copies are no longer picked up here.
    if(DE.kind==='raider'&&DE.downed&&!DE.net&&dist(p,DE)<64){ downRdr=DE; break; }
'@

SubRx @'
var VER='16.61';
'@ @'
var VER='16.62';
'@

$pat = "(?m)^  now:'v16\.61:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.62: PLAYER 2 CANNOT REVIVE A PILLAGER THE HOST RUNS. Stability pass before a co-op session. On the player 2 window a downed pillager is a copy of the one the host runs, and picking him up happened on that window alone: the child was handed the gun in the man hands (so the gun existed twice), his standing and revive count went up and were saved, and the man fell back down a moment later. The REVIVE prompt no longer shows on those copies. Check 16.62 fails on v16.61',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
