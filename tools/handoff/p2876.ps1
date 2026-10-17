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

# CRAWLERS BITE FOR LESS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
cd:0,alert:0,spd:120,dmg:13,rng:26,cone:1.5,hitT:0,legs:rnd(0,6.28)});
'@ @'
cd:0,alert:0,spd:120,dmg:9,rng:26,cone:1.5,hitT:0,legs:rnd(0,6.28)});   // v28.xx (crawldmg), HIS NOTE (2026-10-16): "crawlers deal too much damage per hit". 13 to 9 a bite (about 30 percent less), balancing
'@

SubRx @'
var VER='28.75';
'@ @'
var VER='28.76';
'@

$pat = "(?m)^  now:'v28\.75:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.76: A crawler bite does 9 damage instead of 13. Check 28.76 fails on v28.75',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
