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

# the two player respawn count says ascending in n, not dropping in (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  n=Math.max(1,Math.ceil(t)); s='DROPPING IN '+n;
'@ @'
  // v31.20 (cw-ascendin), HIS LORE (memory pillagers-lore-ascend.md): "YOU DO NOT DROP. YOU ASCEND." The count said DROPPING IN n; it says ascending in n now.
  n=Math.max(1,Math.ceil(t)); s='ascending in '+n;
'@

SubRx @'
var VER='31.19';
'@ @'
var VER='31.20';
'@

$pat = "(?m)^  now:'v31\.19:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.20: The respawn count on the demo HUD reads ascending in 3, 2, 1 (it said dropping in). Check 31.20 fails on v31.19',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
