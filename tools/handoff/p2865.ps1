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

# AN AIR STRIKE KILL IS NOT COUNTED ON YOUR GUN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    e.airH=(e.hp>0)?e.hp:0; e.hitT=.2; e.pHitT=.3; e.pHitSeat=0;
'@ @'
    e.airH=(e.hp>0)?e.hp:0; e.hitT=.2; e.pHitT=.3; e.pHitSeat=0; e.blow='a'; e.blowT=G.t;   // v27.xx (cloud-robust-air-tally), CLOUD HUNT 2026-10-15: the last blow was the strike, so the kill is on no gun (gunKillNote) and is no gun style (styleKill)
'@

SubRx @'
var VER='28.64';
'@ @'
var VER='28.65';
'@

$pat = "(?m)^  now:'v28\.64:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.65: A kill made by your air strike is no longer added to the kill count of the last gun you hit that target with. Check 28.65 fails on v28.64',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
