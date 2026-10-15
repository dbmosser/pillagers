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

# POWER-UPS END WHEN YOU DIE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(why!=='bench') ARCADE.deaths=(ARCADE.deaths|0)+1;   // v23.25 (arcade6): coming off the bench is not a death
'@ @'
  if(why!=='bench') ARCADE.deaths=(ARCADE.deaths|0)+1;   // v23.25 (arcade6): coming off the bench is not a death
  if(why!=='bench'&&G.pwr) G.pwr.act={};   // v28.62 (cloud-raid-pwrdeath), CLOUD HUNT 2026-10-15: a death ends the power-ups; the dying test in pwrTick never ran, the death beat skips the player tick
'@

SubRx @'
var VER='28.61';
'@ @'
var VER='28.62';
'@

$pat = "(?m)^  now:'v28\.61:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.62: In the two player DEMO a death now ends your power-ups instead of carrying them into the respawn. Check 28.62 fails on v28.61',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
