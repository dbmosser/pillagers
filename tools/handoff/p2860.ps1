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

# PLAYER 2 FIGHTS THE OVERSEER, NOT A WARDEN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  e.elite=m.el?1:0; e.hostile=!!m.ho; e.affix=(typeof m.af==='string'&&AFFIX[m.af])?m.af:null;   // v26.xx (ai25)
'@ @'
  e.elite=m.el?1:0; e.hostile=!!m.ho; e.affix=(typeof m.af==='string'&&AFFIX[m.af])?m.af:null;   // v26.xx (ai25)
  e.boss=(e.kind==='warden'&&e.name===BOSS_NAME)?1:0;   // v28.60 (cloud-raid-p2boss), CLOUD HUNT 2026-10-15: the copy of THE OVERSEER is the boss: his rounds met a plain Warden front and he never saw the laser
'@

SubRx @'
var VER='28.59';
'@ @'
var VER='28.60';
'@

$pat = "(?m)^  now:'v28\.59:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.60: Player 2 now hits the Overseer as hard as player 1 and sees its sweeping laser. Check 28.60 fails on v28.59',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
